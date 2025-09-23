When developing new features, it is best to test the full functionality before merging to `main`. This is because the CI integration, while thorough for verifying the syntax, readability, and validity of the code itself, does not verify that the code will actually work as intended.

It is recommended to test all development locally with the test environment, and only allowing the prod environment to be deployed or modified through the CI/CD process, though manually running `terraform apply` on the prod environment may be needed for emergencies.

### Getting credentials locally

Check out the credentials that are pulled from Keeper in the [.github/workflows](.github/workflows) files. Set those up locally.

### Developing AWS / Terraform code

Just use `terraform apply` locally from your development machine. Please use the `test` environment and reserve applying the prod environment for Github actions.

### Developing server configuration

To test server configuration (the server/ folder), push your code to a non-main branch and update the `build_branch` parameter in terraform (in terraform/env/ folder) to that branch name. Then, use Terraform apply to update the launch template to pull from that new build branch. Finally, launch new servers by increasing the desired capacity of the AWS autoscaling group (do this manually in the AWS web console).
