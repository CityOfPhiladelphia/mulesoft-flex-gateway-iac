resource "aws_wafv2_web_acl" "main" {
  name        = "${var.app_name}-${var.env_name}-flex-waf"
  description = "Flex gateway WAF for rate limiting, bot control, and anonymous IP CAPTCHA"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "flex_waf"
    sampled_requests_enabled   = true
  }

  ##########################
  # 0. Atlas Carto bypass
  rule {
    name     = "Atlas-carto-rate-limit"
    priority = 4

    action {
      block {
        # Return 429 (Too Many Requests) with the custom JSON
        custom_response {
          response_code            = 429
          custom_response_body_key = "CartoRateLimitError"
        }
      }
    }
    statement {
      rate_based_statement {
        limit              = 200 # per 5 minutes
        aggregate_key_type = "IP"
        scope_down_statement {
          and_statement {

            # Condition 1: Header Match


            statement {
              byte_match_statement {
                search_string = "atlas.phila.gov"
                field_to_match {
                  single_header {
                    name = "referer"
                  }
                }
                positional_constraint = "EXACTLY"
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }

            # Condition 2: URI Path Match
            statement {
              byte_match_statement {
                search_string = "/carto-legacy/"
                field_to_match {
                  uri_path {}
                }
                positional_constraint = "STARTS_WITH"
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }

          } # End of and_statement
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CartoAtlasRateLimit"
      sampled_requests_enabled   = true
    }
  }

  ##########################
  # 1. DDoS Protection (Rate-Based)
  rule {
    name     = "RateLimit-DDoS"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 5000 # per 5 minutes
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "FlexRateLimit"
      sampled_requests_enabled   = true
    }
  }

  ##########################
  # 2. Anonymous IP List (VPNs, Proxies, Tor) -> CAPTCHA
  rule {
    name     = "AWS-AnonymousIP"
    priority = 20

    override_action {
      none {} # Required when using rule_action_overrides
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        # Force CAPTCHA on the specific rule inside the group
        rule_action_override {
          name = "AnonymousIPList"
          action_to_use {
            captcha {}
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "FlexAnonymousIP"
      sampled_requests_enabled   = true
    }
  }

  ##########################
  # 3. Bot Control -> CAPTCHA
  rule {
    name     = "AWS-BotControl"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"

        # Apply CAPTCHA to specific bot categories (Example: CategoryBot)
        rule_action_override {
          name = "CategoryBot"
          action_to_use {
            captcha {}
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "FlexBotControl"
      sampled_requests_enabled   = true
    }
  }


  ##########################
  # 4. Carto rate-limit
  rule {
    name     = "RateLimit-Carto-Aggressive"
    priority = 5

    action {
      block {
        # Return 429 (Too Many Requests) with the custom JSON
        custom_response {
          response_code            = 429
          custom_response_body_key = "CartoRateLimitError"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 10 # per 5 minutes
        aggregate_key_type = "IP"

        scope_down_statement {
          byte_match_statement {
            search_string         = "/carto-legacy/"
            positional_constraint = "STARTS_WITH"
            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "FlexCartoBotControl"
      sampled_requests_enabled   = true
    }
  }
}