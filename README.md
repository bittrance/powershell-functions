# Example Azure Function in Powershell

This repository contains a simple demonstration Azure Function App written in Powershell, with tests. You can use it as a template to make your own Powershell Function Apps.

In order to work with this Function App, you need [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).

The app includes the following example functions:

- HelloWorld: A simple function that returns a greeting and the current time.
- ParallelHelloWorld: A function that illustrates thread-based parallel execution in a function app.

## Developing an Azure Function

First, you will need the dependencies installed locally:

```powershell
Install-Module -Name Pester
Install-Module -Name NtpTime
```

This example comes with unit tests, written with [Pester](https://pester.dev/). In order to run the tests:

```powershell
Invoke-Pester -Output Detailed
```

## Running the Function App locally

To run the Function App locally, you can start it like so. The Function App worker will install your dependencies inside the worker, so this takes up to 30 seconds when dependencies change.

```shell
func host start
```

When the worker is ready, it will list detected functions:

```text
Functions:

        HelloWorld: [GET] http://localhost:7071/HelloWorld
```

The example function can be triggered by HTTP, so you can test it:

```powershell
Invoke-RestMethod -Uri http://localhost:7071/HelloWorld?name=Test
```

This should print something like this:

```text
Timestamp            Success Message
---------            ------- -------
6/5/2023 11:15:17 AM    True Hello Test!
```

## Publish an Azure Function App

If you want to set up the function in your Azure subscription, you first need to [install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

This example contains a Terraform configuration for a simple Azure Function App. You ask Terraform to create or update the Function App like so:

```shell
terraform init
terraform apply
```

Once the Function App has been created, you can publish your source code:

```shell
func azure functionapp publish powershell-example
```

This will output a message similar to the one printed by `func host start` and you can use `Invoke-RestMethod` to test it.

## Invoking the published Function App

Once the Function App has been published, you can invoke it like so:

```shell
CLIENT_ID=$(az webapp auth show --resource-group powershell-example --name powershell-example --query clientId --output tsv)
az rest --url https://powershell-example.azurewebsites.net/HelloWorld --resource $CLIENT_ID --verbose
```

