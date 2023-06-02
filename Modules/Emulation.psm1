$script:PowerShellWorkerPath = "/usr/lib/azure-functions-core-tools-4/workers/powershell/7.2/"

$global:AzFuncWorkerEmulation = $false

function Start-EmulateAzFuncWorker {
    param(
        [string] $PowerShellWorkerPath = $null
    )
    if ($global:AzFuncWorkerEmulation) {
        return
    }
    $global:AzFuncWorkerEmulation = $true
    Add-Type -Path "$script:PowerShellWorkerPath/Microsoft.Azure.Functions.PowerShellWorker.dll"
    $accelerators = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
    $accelerators::Add("HttpResponseContext", [Microsoft.Azure.Functions.PowerShellWorker.HttpResponseContext])
    $accelerators::Add("HttpRequestContext", [Microsoft.Azure.Functions.PowerShellWorker.HttpRequestContext])
}

function Stop-EmulateAzFuncWorker {
    throw "Unloading types is not possible in DotNet Core."
    $accelerators = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
    $accelerators::Remove("HttpResponseContext")
    $accelerators::Remove("HttpRequestContext")
}