# Example Azure Function in Powershell

This repository contains a simple demonstration Azure Function App written in Powershell, with tests.

In order to work with this Function App, you need [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).

To run the Function App locally, you can start it like so:

```shell
func host start
```

In order to run the tests, you need to [install Pester](https://pester.dev/docs/introduction/installation). In order to run the tests:

```shell
pwsh -Command 'Invoke-Pester -Output Detailed'
```

If you want to set up the function in your Azure subscription, you first need to [install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

```shell
terraform init
terraform apply
func azure functionapp publish powershell-example
```