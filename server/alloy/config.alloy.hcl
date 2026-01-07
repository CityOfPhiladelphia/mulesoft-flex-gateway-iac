// This file is a combination of https://github.com/grafana/alloy-scenarios/tree/main/linux and https://github.com/grafana/alloy-scenarios/tree/main/docker-monitoring

import.git "linux_shared_modules" {
  // renovate: datasource=github-releases
  repository = "https://github.com/CityOfPhiladelphia/grafana-alloy-modules.git"
  revision = "v0.0.13"
  // Only pull once, on startup
  pull_frequency = "0s"
  path = "linux"
}

// ###############################
// #### Metrics Configuration ####
// ###############################
//
linux_shared_modules.node_exporter "main" {
  destinations = [prometheus.remote_write.prod.receiver]
  scrape_interval = "30s"
}

prometheus.remote_write "prod" {
  endpoint {
    url = "https://citygeo-grafana.phila.gov:9090/api/v1/push"

    headers = {
      "X-Scope-OrgID" = "citygeo"
    }

    basic_auth {
      username = sys.env("PROMETHEUS_USER")
      password = sys.env("PROMETHEUS_PASSWORD")
    }

    write_relabel_config {
      replacement = sys.env("APP_NAME")
      target_label = "app_name"
    }
    write_relabel_config {
      replacement = sys.env("ENV_NAME")
      target_label = "env_name"
    }
    write_relabel_config {
      replacement = constants.hostname
      target_label = "instance"
    }
    write_relabel_config {
      replacement = "3"
      target_label = "alloy_cfg_v"
    }
  }
}

// ###############################
// #### Logging Configuration ####
// ###############################

linux_shared_modules.linux_syslog "main" {
  destinations = [loki.write.prod.receiver]
}

linux_shared_modules.docker_logs "main" {
  destinations = [loki.process.fluentbit.receiver]
}

loki.process "fluentbit" {
  stage.regex {
    expression = "^\\[(?P<log_type>[^\\]]+)\\] (?P<json>{.*})"
  }

  stage.labels {
    values = {
      log_type = "",
    }
  }

  stage.match {
    selector = "{log_type=\"flex-gateway-fluent\"}"

    stage.json {
      source = "json"

      expressions = {
        request_id = "",
        logger = "",
        kind = "",
        message = "",
      }
    }

    stage.labels {
      values = {
        logger = "",
        kind = "",
      }
    }

    stage.match {
      selector = "{kind=\"accessLog\"}"

      stage.logfmt {
        source = "message"

        mapping = {
          apiName = "",
          statuscode = "statusCode",
          envId = "",
          orgId = "",
          method = "",
          timing = "",
        }
      }

      stage.labels {
        values = {
          apiName = "",
          envId = "",
          orgId = "",
          method = "",
          statuscode = "",
          timing = "",
        }
      }

      stage.output {
        source = "message"
      }
    }
  }

  forward_to = [loki.write.prod.receiver]
}

loki.write "prod" {
  endpoint {
    url = "https://citygeo-grafana.phila.gov:3100/loki/api/v1/push"
    tenant_id = "citygeo"
    basic_auth {
      username = sys.env("LOKI_USER")
      password = sys.env("LOKI_PASSWORD")
    }
    min_backoff_period = "500ms"
    max_backoff_period = "5m"
    max_backoff_retries = "10"
  }
  external_labels = {
    "app_name" = sys.env("APP_NAME"),
    "env_name" = sys.env("ENV_NAME"),
    "instance" = constants.hostname,
    "node" = constants.hostname,
    "alloy_cfg_v" = "2",
  }
}

