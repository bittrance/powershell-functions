using namespace System.Net

param($Request)

Import-Module ./Modules/Responder.psm1

$Name = $Request.Query['name']
if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = "World"
}
elseif ($Name.Contains(" ")) {
    return Respond -StatusCode BadRequest -Message "Name cannot contain spaces."
}

Respond -StatusCode OK -Message "Hello $Name!"
