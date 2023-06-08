using namespace System.Net

param($Request)

Import-Module NtpTime

$Name = $Request.Query['name']
if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = "World"
}

$Return = @{
    "Success" = $true
    "Timestamp" = (Get-NtpTime -NoDns).NtpTime
    "Message" = "Hello $Name!"
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = ($Return | ConvertTo-Json)
    })
