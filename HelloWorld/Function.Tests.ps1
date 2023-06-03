using namespace System.Net

Describe "Invoke" {
    BeforeAll {
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

    It "Returns a message" {
        $R.Response.Body | Should -Match "Message: Hello Test!"
    }

    Context "When no name is provided" {
        BeforeAll {
            $R.Response = $null
            $Request = @{ Query = @{} }
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