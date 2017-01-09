# Turn on Strict Mode to help catch syntax-related errors.
# 	This must come after a script's/function's param section.
# 	Forces a function to be the first non-comment code to appear in a PowerShell Module.
Set-StrictMode -Version Latest

# Clear the screen before running our tests.
cls

# Get the directory that this script is in.
$THIS_SCRIPTS_DIRECTORY = Split-Path $script:MyInvocation.MyCommand.Path

# Get the path of the script to test.
$scriptDirectoryPath = Split-Path -Path $THIS_SCRIPTS_DIRECTORY -Parent
$scriptPath = Join-Path -Path $scriptDirectoryPath -ChildPath 'Set-ProjectFilesClickOnceVersion.ps1'

# Get the path to the project file to use in our tests.
$projectFilePath = Join-Path -Path (Join-Path -Path $THIS_SCRIPTS_DIRECTORY -ChildPath 'TestFiles') -ChildPath 'TestProject.csproj'

$runScriptExpression = "& $scriptPath -ProjectFilePath $projectFilePath "

function RunScriptWithParameters($parameters)
{
	$output = Invoke-Expression "$runScriptExpression $parameters"
	
}

$testNumber = 0

Write-Host ("{0}. Explicitly set version number..." -f ++$testNumber)
if ((RunScriptWithParameters "-Version 1.2.3.4 -IncrementProjectFilesRevision").EndsWith("'1.2.3.4'.")) { Write-Host "Passed" } else { throw "Test $testNumber failed." }

