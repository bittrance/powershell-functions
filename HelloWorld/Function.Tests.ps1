using namespace System.Net

Import-Module -Name ./HelloWorld/Function.psm1 

function Global:Push-OutputBinding {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [object] $Value
    )
    $global:Response = $Value
}

Describe "Invoke" {
    BeforeAll {
        $Request = @{ Query = @{ "name" = "Test" } }
        Invoke -Request $Request
    }

    It "Returns a 200 response" {
        $global:Response.StatusCode | Should -Be ([HttpStatusCode]::OK)
    }

    It "Returns a message" {
        $global:Response.Body | Should -Match "Hello Test!"
    }

    Context "When no name is provided" {
        BeforeAll {
            $Request = @{ Query = @{} }
            Invoke -Request $Request
        }

        It "Returns a 200 response" {
            $global:Response.StatusCode | Should -Be ([HttpStatusCode]::OK)
        }

        It "Returns a message" {
            $global:Response.Body | Should -Match "Hello World!"
        }
    }
}