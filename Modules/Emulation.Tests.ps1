Import-Module ./Modules/Emulation.psm1

Describe "EmulateAzFuncWorker" {
    It "Throws" {
        { New-MockObject -Type HttpRequestContext } | Should -Throw
    }

    Context "When emulation is turned on" {
        BeforeAll {
            Start-EmulateAzFuncWorker
        }

        It "does not throw" {
            { New-MockObject -Type HttpRequestContext } | Should -Not -Throw
        }

        Context "When emulation is turned back off" -Skip {
            # Unloading types are not possible in DotNet Core.
            It "Throws again" {
                { New-MockObject -Type HttpRequestContext } | Should -Throw
            }        
        }
    }
}