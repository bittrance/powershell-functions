using namespace System.Net

Import-Module NtpTime

function Respond {
    param(
        [Parameter(Mandatory = $true)]
        [HttpStatusCode] $StatusCode,
        [Parameter(Mandatory = $true)]
        $Message
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
