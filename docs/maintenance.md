# Maintenance

## OS Updates

Downtime: OS updates can be performed with no downtime

1. Update AMI in launch template
    1. Renovate will create a pull request titled \[env] Update dependency ec2_ami_id to ...
    1. Check pull request, especially the Terraform plan, for validity
    1. Merge the pull request, then wait for the Terraform apply job to run
    1. *Note* This will not actually update or replace any servers, it just means that the next server launched will have the newer AMI.
1. Wait for CI/CD pipelines to finish
1. Launch one new server
    1. Navigate to AWS web console -> EC2 -> Autoscaling
    1. Set the desired, minimum, and maximum capacity to one higher
1. Check that the new server is healthy
    1. SSH onto the new server and make sure things looks good
        1. Check `docker ps`
    1. Check in the AWS target group that the new server is healthy
        1. Navigate to AWS web console -> EC2 -> Target groups
        1. The new server will typically not be healthy until 3-4 minutes. Give it time.
    1. Check Anypoint Platform
        1. Use the root organization and select the proper environment (dev, test, prod)
        1. Navigate to Runtime Manager -> Flex Gateways -> Self-Managed Flex Gateways
1. Launch more servers until you have double the usual amount.
1. Terminate the old servers
    1. Navigate to AWS web console -> EC2 -> Autoscaling
    1. Set the desired, minimum, and maximum capacity back to the original amount

## Application Updates

Downtime: Application updates likely require no downtime

There is nowhere in the Mulesoft documentation that it mentions you can't temporarily run multiple versions of Flex Gateway in parallel. This leads me to believe that for any upgrade, you can have a mixed state.

1. Update `flex_gateway_tag` in Terraform
    1. Renovate will create a pull request titled \[env] Update mulesoft/flex-gateway Docker tag to ...
    1. There will likely be two per environment - One for a patch update and one for a minor update. Be diligent as towards which one you choose
    1. Check pull request, especially the Terraform plan, for validity
    1. Merge the pull request, then wait for the Terraform apply job to run
    1. *Note* This will not actually update or replace any servers, it just means that the next server launched will have the newer AMI.
1. Wait for CI/CD pipelines to finish
1. Launch one new server
    1. Navigate to AWS web console -> EC2 -> Autoscaling
    1. Set the desired, minimum, and maximum capacity to one higher
1. Check that the new server is healthy
    1. SSH onto the new server and make sure things looks good
        1. Check `docker ps`
    1. Check in the AWS target group that the new server is healthy
        1. Navigate to AWS web console -> EC2 -> Target groups
        1. The new server will typically not be healthy until 3-4 minutes. Give it time.
    1. Check Anypoint Platform
        1. Use the root organization and select the proper environment (dev, test, prod)
        1. Navigate to Runtime Manager -> Flex Gateways -> Self-Managed Flex Gateways
1. Launch more servers until you have double the usual amount.
1. Terminate the old servers
    1. Navigate to AWS web console -> EC2 -> Autoscaling
    1. Set the desired, minimum, and maximum capacity back to the original amount

## Valkey Maintenance

### OS Upgrades

Are handled automatically by AWS Elasticache

### Valkey Upgrades

Valkey upgrades are not handled by Terraform. This is because upgrading a Valkey instance doesn't cause any data loss, it just means the cache gets cleared. Although there is a `redis_engine_version` parameter, it is ignored by Terraform except for initial creation.

Minor upgrades happen automatically.

Major upgrades happen manually, follow AWS documentation.
