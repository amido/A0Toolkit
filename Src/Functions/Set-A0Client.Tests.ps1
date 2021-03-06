﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"


# // START test setup //

$malformedURL = "http:/url.com"
$formedURL = "http://url.com"

$testExceptionMessage = "test exception"

$testClientId = "testClientId"

$testPayload = New-Object -TypeName PSCustomObject

. "$here\Private\New-ExceptionDetail.ps1"

# // END test setup //



Describe "Set-A0Client" {

    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {@{}}

    Mock -CommandName New-ExceptionDetail
    
    Context "Parameter validation fails" {        

        It "should validate malformed URL and throw" {

            {Set-A0Client -baseURL $malformedURL -clientId $testclientId -payload $testPayload } | Should Throw

            Assert-MockCalled -CommandName Invoke-WebRequest -Exactly -Times 0
            Assert-MockCalled -CommandName New-ExceptionDetail -Exactly -Times 0
        }

        It "should validate clientId missing and throw" {

            {Set-A0Client -baseURL $formedURL -clientId -payload $testPayload } | Should Throw

            Assert-MockCalled -CommandName Invoke-WebRequest -Exactly -Times 0
            Assert-MockCalled -CommandName New-ExceptionDetail -Exactly -Times 0
        }

        It "should validate payload missing and throw" {

            {Set-A0Client -baseURL $formedURL -clientId $testclientId -payload } | Should Throw

            Assert-MockCalled -CommandName Invoke-WebRequest -Exactly -Times 0
            Assert-MockCalled -CommandName New-ExceptionDetail -Exactly -Times 0
        }


    }

    Context "Call Auth0" {

        It "should Invoke-WebRequest and return response" {

            Set-A0Client -baseURL $formedURL -clientId $testclientId -payload $testPayload | Should not be $null

            Assert-VerifiableMocks
        }

    }

    Context "Call Auth0 and fail" {

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
        
            Throw
        }

        It "should throw exception" {

            {Set-A0Client -baseURL $formedURL -clientId $testclientId -payload $testPayload} | Should Throw

        }

        Assert-VerifiableMocks
        Assert-MockCalled -CommandName New-ExceptionDetail -Exactly -Times 1


    }
}
