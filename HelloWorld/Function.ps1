using namespace System.Net

param($Request)

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
        Body       = ($Return | ConvertTo-Json)
    })
