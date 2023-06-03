using namespace System.Net

param($Request)

Import-Module powershell-yaml

$Name = $Request.Query['name']
if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = "World"
}

$Return = @{
    "Success" = $true
    "Message" = "Hello $Name!"
}

Push-OutputBinding -Name Response -Value (@{
        StatusCode = [HttpStatusCode]::OK
        Body       = ConvertTo-Yaml $Return
    })
