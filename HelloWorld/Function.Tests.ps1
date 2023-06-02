using namespace System.Net

Import-Module ./Modules/Emulation.psm1

$script:PowerShellWorkerPath = "/usr/lib/azure-functions-core-tools-4/workers/powershell/7.2/"

Describe "Invoke" {
    BeforeAll {
        Start-EmulateAzFuncWorker
        $R = @{ Response = $null }
        function Push-OutputBinding {
            param(
                [Parameter(Mandatory = $true)]
                [string] $Name,
                [Parameter(Mandatory = $true)]
                [object] $Value
            )
            Write-Host $Response
            $R.Response = $Value
        }
        $Request = @{ Query = @{ "name" = "Test" } }
        . ./HelloWorld/Function.ps1 -Request $Request
    }

    It "Returns a 200 response" {
        $R.Response.StatusCode | Should -Be ([HttpStatusCode]::OK)
    }

    It "Includes NTP timestamp" {
        $time = ($R.Response.Body | ConvertFrom-Json).Timestamp
        ((Get-Date) - $time).TotalSeconds | Should -BeLessThan 1
    }

    It "Returns a message" {
        $R.Response.Body | Should -Match "Hello Test!"
    }

    Context "When no name is provided" {
        BeforeAll {
            $R.Response = $null
            $Request = New-MockObject -Type HttpRequestContext -Properties @{ Query = @{} }
            . ./HelloWorld/Function.ps1 -Request $Request
        }

        It "Returns a 200 response" {
            $R.Response.StatusCode | Should -Be ([HttpStatusCode]::OK)
        }

        It "Returns a message" {
            $R.Response.Body | Should -Match "Hello World!"
        }
    }
}