# CityGeo Mulesoft Flexgateway

## Components

* Flex-Gateway - Application designed by Mulesoft
* Nginx Health Check - Conveys output of `flexctl probe --check=liveness`

## Design Choices

### Server Infrastructure

#### Kubernetes vs. Docker

Although Flex-Gateway can be run as a Kubernetes cluster, due to the simplicity of the app we decided to run it in Docker containers to save money on EKS control plane.

Flex-Gateway is stateless, supports clustering and HA, and boots quickly. There are very few benefits gained from using EKS since a mature infrastructure as code system can already automate application and OS updates.

#### Server provisioning

Upon launching an EC2 from the autoscaling group (or directly from the launch template), a short userdata script runs which downloads this Git repository and then executes the [servers/build.sh](server/build.sh) script.

The [servers/build.sh](servers/build.sh) script is a bit longer, it takes about 3 minutes to run and mostly just involves installing the required tools (mainly Docker), then parameterizes the docker configuration with values from the AWS infrastructure, then starts the docker-compose stack.

#### Health check

Mulesoft Flex-Gateway doesn't have a "normal" healthcheck like `/ready` or `/healthy`, so instead we set up a "fake" nginx web server and minutely run the command `docker exec flex-gateway flexctl probe --check=liveness`, outputting to a file that the nginx web server can read. This nginx server is accessible to the load balancer, which uses a target group to determine health.

### AWS Infrastructure

AWS infrastructure is deployed with Terraform.

#### Architecture Diagram

![architecture diagram](docs/arch_diagram.svg)

### Terraform infrastructure

There are three environments of Flex-Gateway (prod, dev, test), each highly similar besides a couple parameters. There is a primary module in [terraform/modules/flex_gateway](terraform/modules/flex_gateway) which essentially includes the entire core infrastructure. The environments in the [terraform/env](terraform/env) folder each use this module with variables relevant to that environment. There is also an inline project in [terraform/common](terraform/common) which creates the common KMS. Any parameters that may be needed by the server (such as secrets, redis url) are also deployed as SSM (systems manager) parameters.

### CI/CD infrastructure

Use of the CI/CD enables automatic deployment and testing of the Flex-Gateway infrastructure.

#### CI - All branches and pull requests

* tflint - Checks invalid values, prohibits poor coding practices
* terraform fmt - Ensures consistent formatting
* terraform plan - Investigate what Terraform will do perform merging to main
* dclint - Lints [docker-compose.yaml](server/docker/docker-compose.yaml)
* shellcheck - Lints [build.sh](server/build.sh)

#### CD - Main branch only

* terraform apply - Deploys Terraform infrastructure
* [indirect] On launch, a server downloads the code from the main branch

## Development

When developing new features, it is best to test the full functionality before merging to `main`. This is because the CI integration, while thorough for verifying the syntax, readability, and validity of the code itself, does not verify that the code will actually work as intended.

It is recommended to test all development locally with the test environment, and only allowing the prod environment to be deployed or modified through the CI/CD process, though manually running `terraform apply` on the prod environment may be needed for emergencies.

### Getting credentials locally

Check out the credentials that are pulled from Keeper in the [.github/workflows](.github/workflows) files. Set those up locally.

### Developing AWS / Terraform code

Just use `terraform apply` locally from your development machine. Please use the `test` environment and reserve applying the prod environment for Github actions.

### Developing server configuration

To test server configuration (the server/ folder), push your code to a non-main branch and update the `build_branch` parameter in terraform (in terraform/env/ folder) to that branch name. Then, use Terraform apply to update the launch template to pull from that new build branch. Finally, launch new servers by increasing the desired capacity of the AWS autoscaling group (do this manually in the AWS web console).
