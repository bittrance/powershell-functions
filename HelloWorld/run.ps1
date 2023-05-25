using namespace System.Net

param($Request)

$Name = $Request.Query['name']
if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = "World"
}

$Return = New-Object PSObject –Property @{
    "Success" = $true
    "Message" = "Hello $Name!"
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = ($Return | ConvertTo-Json)
    })