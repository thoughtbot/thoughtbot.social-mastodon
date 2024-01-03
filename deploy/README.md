This repository contains [Helm] value files used to generate the [Kubernetes manifests] for the thoughtbot.social rails application.

The manifests decide how the application containers will be deployed and configured. You can perform many common configuration tasks by modifying the manifests in this repository.

## Helm Chart

The Helm repository used to deploy the application is [`thoughtbot-charts/helm-rails`].

Common configuration between all releases can be found in the `values.yaml` file in this directory.

## Releases

Configuration common to a particular release can be found in subdirectories.

- [Staging](./staging/)

## Modifying Environment Variables

Environment variables are contained in the `values.yaml` files under `config.env.data`.

**Note: Do not store secrets in these files, as they will be permanently committed in the Git history.**

Add an environment variable to the appropriate `values.yaml` file and push to a release branch to update environment variables.

### Application Secrets

Secrets are managed by [AWS Secrets Manager]. Secrets are defined in the application's [Terraform configuration].

To update a user-managed secret, you will need to log into the AWS Console using a permission set with secrets access, find the secret in Secrets Manager, and use the console to update the value. Secrets will be automatically reloaded once updated.

To add a new secret, add a definition in the Terraform configuration to create an empty secret and then populate it using the procedure described above. Afterwards, update the `values.yaml` file to map the secret value to an environment variable or file.

See [Managing Secrets] for more information.

[`thoughtbot-charts/helm-rails`]: https://github.com/thoughtbot/helm-charts/tree/main/charts/helm-rails
[managing secrets]: https://thoughtbot.atlassian.net/wiki/spaces/APG/pages/15040625/Managing+Secrets
[helm]: https://helm.sh/docs/intro/install/
[kubernetes manifests]: https://thoughtbot.atlassian.net/wiki/spaces/APG/pages/15106113/Deploying+to+Kubernetes
[aws secrets manager]: https://aws.amazon.com/secrets-manager/
