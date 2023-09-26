using namespace System.Net

param($Request)

Import-Module ./Modules/Responder.psm1

$v = (1..50) | ForEach-Object { 
    Start-ThreadJob -ThrottleLimit 25 -ArgumentList $_ -ScriptBlock { 
        $s = Get-Date
        Start-Sleep -Seconds 5
        $s
    }
}
$t = Receive-Job -Job $v -Wait

Respond -StatusCode OK -Message $t
