using namespace System.Net

param($Request)

Import-Module NtpTime

function Respond {
    param(
        [Parameter(Mandatory = $true)]
        [HttpStatusCode] $StatusCode,
        [Parameter(Mandatory = $true)]
        [string] $Message
    )
    $Body = @{
        "Success"   = $StatusCode -lt [HttpStatusCode]::BadRequest
        "Timestamp" = (Get-NtpTime -NoDns).NtpTime
        "Message"   = $Message
    }
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $StatusCode
            Body       = ConvertTo-Json $Body
        })
}

$Name = $Request.Query['name']
if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = "World"
}
elseif ($Name.Contains(" ")) {
    return Respond -StatusCode BadRequest -Message "Name cannot contain spaces."
}

Respond -StatusCode OK -Message "Hello $Name!"
