# Turn on Strict Mode to help catch syntax-related errors.
# 	This must come after a script's/function's param section.
# 	Forces a function to be the first non-comment code to appear in a PowerShell Module.
Set-StrictMode -Version Latest

# Clear the screen before running our tests.
Clear-Host

# Get the directory that this script is in.
$THIS_SCRIPTS_DIRECTORY = Split-Path $script:MyInvocation.MyCommand.Path

# Get the path of the script to test.
$scriptDirectoryPath = Split-Path -Path $THIS_SCRIPTS_DIRECTORY -Parent
$scriptPath = Join-Path -Path $scriptDirectoryPath -ChildPath 'Set-ProjectFilesClickOnceVersion.ps1'

# Get the path to the project file to use in our tests.
$projectFilePath = Join-Path -Path (Join-Path -Path $THIS_SCRIPTS_DIRECTORY -ChildPath 'TestFiles') -ChildPath 'TestProject.csproj'
$projectFilePathCopy = $projectFilePath + '_UsedByTests_.csproj'

# Make a backup of the project file for the tests to run against.
Copy-Item -Path $projectFilePath -Destination $projectFilePathCopy -Force

$global:runScriptExpression = "& $scriptPath -ProjectFilePath $projectFilePathCopy "
$global:versionNumberAtEndOfOutputRegex = New-Object System.Text.RegularExpressions.Regex "'(?<Version>\d+\.\d+\.\d+\.\d+)'.$", SingleLine

function RunScriptWithParameters($parameters)
{
	$output = Invoke-Expression -Command "$($global:runScriptExpression) $parameters"
	if ($output -imatch $global:versionNumberAtEndOfOutputRegex)
	{
		try
		{
			return $matches["Version"]
		}
		# If $output contains multiple lines, it will be treated as a collection instead of a string and $matches will not be defined, so catch that case.
		catch { return $output }		
	}
	return $output
}
	
$testNumber = 0
# Some tests are dependent on the order in which they are ran, which isn't ideal, but good enough for now.

Write-Host ("{0}. Use version number parameter..." -f ++$testNumber)
$output = RunScriptWithParameters "-Version '1.2.3.4'"
if ($output -eq '1.2.3.4') { Write-Host "Passed" } else { throw "Test $testNumber failed. Output was '$output'." }

Write-Host ("{0}. Use Build Id parameter..." -f ++$testNumber)
$output = RunScriptWithParameters "-BuildSystemsBuildId 1234"
if ($output -eq '1.2.0.1234') { Write-Host "Passed" } else { throw "Test $testNumber failed. Output was '$output'." }

Write-Host ("{0}. Use Build Id parameter greater than the max value to make sure build is set properly..." -f ++$testNumber)
$output = RunScriptWithParameters "-BuildSystemsBuildId 123456"
if ($output -eq '1.2.1.57921') { Write-Host "Passed" } else { throw "Test $testNumber failed. Output was '$output'." }

Write-Host ("{0}. Use IncrementProjectFilesRevision parameter..." -f ++$testNumber)
$output = RunScriptWithParameters "-IncrementProjectFilesRevision"
if ($output -eq '1.2.1.57922') { Write-Host "Passed" } else { throw "Test $testNumber failed. Output was '$output'." }

Write-Host ("{0}. Use version number parameter and update minimum required version..." -f ++$testNumber)
$output = RunScriptWithParameters "-Version '5.6.7.8' -UpdateMinimumRequiredVersionToCurrentVersion"
if ($output.Contains("Updating minimum required version to be '5.6.7.8'.")) { Write-Host "Passed" } else { throw "Test $testNumber failed. Output was '$output'." }
