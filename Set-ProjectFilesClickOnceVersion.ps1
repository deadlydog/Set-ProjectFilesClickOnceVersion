#Requires -Version 2.0
<#
.SYNOPSIS
   This script updates the ClickOnce version in a project file (.csproj or .vbproj), and may update the MinimumRequiredVersion to be this same version.
   
.DESCRIPTION
   This script updates the current ClickOnce version in a project file (.csproj or .vbproj), and may update the MinimumRequiredVersion to be this same version.
   Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.
   
.PARAMETER ProjectFilePath
	Path of the .csproj and .vbproj file to process.
	
.PARAMETER Version
	The Version to update the ClickOnce version number to. This version must be of the format Major.Minor.Build or Major.Minor.Build.Revision.
	If provided, the Revision provided will be overridden by the Revision or IncrementProjectFilesRevision parameter if provided.

.PARAMETER Revision
	The Revision to use in the new Version number. This will override the Revision specified in the Version parameter if provided.
	This parameter cannot be used with the IncrementProjectFilesRevision parameter.
	
.PARAMETER IncrementProjectFilesRevision
	If this switch is provided, the Revision from the project file will be incremented and used in the new ClickOnce Version.
	This will override the Revision specified in the Version parameter if provided.
	
.PARAMETER UpdateMinimumRequiredVersionToCurrentVersion
	If this switch is provided, the ClickOnce MinimumRequiredVersion will be updated to match the new Version.
	Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.

.EXAMPLE
	Update a project file's ClickOnce version.
	
	& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3.4'

.EXAMPLE
	Update just the Revision part of a project file's ClickOnce version.
	
	& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Revision 12345

.EXAMPLE
	Increment the Revision of a project file's ClickOnce version.
	
	& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -IncrementProjectFilesRevision

.EXAMPLE
	Update a project file's ClickOnce Minimum Required Version to match its current version.
	
	& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -UpdateMinimumRequiredVersionToCurrentVersion
	
.EXAMPLE
	Update a project file's ClickOnce version, ignoring the Revision part and incrementing the Revision stored in the file, and update the Minimum Required Version to be this new version.
	
	& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3' -IncrementProjectFilesRevision -UpdateMinimumRequiredVersionToCurrentVersion
	
.LINK
	Project Home: https://github.com/deadlydog/Set-ProjectFilesClickOnceVersion
	
.NOTES
	Author: Daniel Schroeder
	Version: 1.0.0
#>

Param
(
	[Parameter(Mandatory=$true,HelpMessage="The project file to update the ClickOnce Version in.")]
	[string]$ProjectFilePath = '',

	[Parameter(Mandatory=$false,HelpMessage="The new version number to use for the ClickOnce application.")]
	[ValidatePattern('(?i)(^(\d+(\.\d+){2,3})$)')]
	[string]$Version = [string]::Empty,

	[Parameter(Mandatory=$false,HelpMessage="The Revision part of the version number. This will override the Revision specified in the Version parameter if provided.",ParameterSetName="UseExplicitRevision")]
	[int]$Revision = -1,

	[Parameter(Mandatory=$false,HelpMessage="Use and increment the Revision part of the version number stored in the project file.",ParameterSetName="UseFilesRevision")]
	[switch]$IncrementProjectFilesRevision = $false,

	[Parameter(Mandatory=$false,HelpMessage="When the switch is provided, the ClickOnce Minimum Required Version will be updated to this new version.")]
	[switch]$UpdateMinimumRequiredVersionToCurrentVersion = $false
)

# If we can't find the project file path to update, exit with an error.
$ProjectFilePath = Resolve-Path -Path $ProjectFilePath
if (!(Test-Path $ProjectFilePath -PathType Leaf))
{
	throw "Could not locate the project file to update at the path '$ProjectFilePath'."
}

# If there are no changes to make, just exit.
if ([string]::IsNullOrEmpty($Version) -and $Revision -lt 0 -and !$IncrementProjectFilesRevision -and !$UpdateMinimumRequiredVersionToCurrentVersion)
{
	Write-Warning "None of the following parameters were provided, so nothing will be changed: Version, Revision, IncrementProjectFilesRevision, UpdateMinimumRequiredVersionToCurrentVersion"
	return
}

function Get-XmlNamespaceManager([xml]$XmlDocument, [string]$NamespaceURI = "")
{
    # If a Namespace URI was not given, use the Xml document's default namespace.
	if ([string]::IsNullOrEmpty($NamespaceURI)) { $NamespaceURI = $XmlDocument.DocumentElement.NamespaceURI }	
	
	# In order for SelectSingleNode() to actually work, we need to use the fully qualified node path along with an Xml Namespace Manager, so set them up.
	[System.Xml.XmlNamespaceManager]$xmlNsManager = New-Object System.Xml.XmlNamespaceManager($XmlDocument.NameTable)
	$xmlNsManager.AddNamespace("ns", $NamespaceURI)
    return ,$xmlNsManager		# Need to put the comma before the variable name so that PowerShell doesn't convert it into an Object[].
}

function Get-FullyQualifiedXmlNodePath([string]$NodePath, [string]$NodeSeparatorCharacter = '.')
{
    return "/ns:$($NodePath.Replace($($NodeSeparatorCharacter), '/ns:'))"
}

function Get-XmlNode([xml]$XmlDocument, [string]$NodePath, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
	$xmlNsManager = Get-XmlNamespaceManager -XmlDocument $XmlDocument -NamespaceURI $NamespaceURI
	[string]$fullyQualifiedNodePath = Get-FullyQualifiedXmlNodePath -NodePath $NodePath -NodeSeparatorCharacter $NodeSeparatorCharacter
	
	# Try and get the node, then return it. Returns $null if the node was not found.
	$node = $XmlDocument.SelectSingleNode($fullyQualifiedNodePath, $xmlNsManager)
	return $node
}

function Get-XmlNodes([xml]$XmlDocument, [string]$NodePath, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
	$xmlNsManager = Get-XmlNamespaceManager -XmlDocument $XmlDocument -NamespaceURI $NamespaceURI
	[string]$fullyQualifiedNodePath = Get-FullyQualifiedXmlNodePath -NodePath $NodePath -NodeSeparatorCharacter $NodeSeparatorCharacter

	# Try and get the nodes, then return them. Returns $null if no nodes were found.
	$nodes = $XmlDocument.SelectNodes($fullyQualifiedNodePath, $xmlNsManager)
	return $nodes
}

function Get-XmlElementsTextValue([xml]$XmlDocument, [string]$ElementPath, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
	# Try and get the node.	
	$node = Get-XmlNode -XmlDocument $XmlDocument -NodePath $ElementPath -NamespaceURI $NamespaceURI -NodeSeparatorCharacter $NodeSeparatorCharacter
	
	# If the node already exists, return its value, otherwise return null.
	if ($node) { return $node.InnerText } else { return $null }
}

function Set-XmlElementsTextValue([xml]$XmlDocument, [string]$ElementPath, [string]$TextValue, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
	# Try and get the node.	
	$node = Get-XmlNode -XmlDocument $XmlDocument -NodePath $ElementPath -NamespaceURI $NamespaceURI -NodeSeparatorCharacter $NodeSeparatorCharacter
	
	# If the node already exists, update its value.
	if ($node)
	{ 
		$node.InnerText = $TextValue
	}
	# Else the node doesn't exist yet, so create it with the given value.
	else
	{
		# Create the new element with the given value.
		$elementName = $ElementPath.Substring($ElementPath.LastIndexOf($NodeSeparatorCharacter) + 1)
 		$element = $XmlDocument.CreateElement($elementName, $XmlDocument.DocumentElement.NamespaceURI)		
		$textNode = $XmlDocument.CreateTextNode($TextValue)
		$element.AppendChild($textNode) > $null
		
		# Try and get the parent node.
		$parentNodePath = $ElementPath.Substring(0, $ElementPath.LastIndexOf($NodeSeparatorCharacter))
		$parentNode = Get-XmlNode -XmlDocument $XmlDocument -NodePath $parentNodePath -NamespaceURI $NamespaceURI -NodeSeparatorCharacter $NodeSeparatorCharacter
		
		if ($parentNode)
		{
			$parentNode.AppendChild($element) > $null
		}
		else
		{
			throw "$parentNodePath does not exist in the xml."
		}
	}
}

function Set-XmlNodesElementTextValue([xml]$xml, $node, $elementName, $textValue)
{
	if ($node.($elementName) -eq $null)
	{
		$element = $xml.CreateElement($elementName, $xml.DocumentElement.NamespaceURI)		
		$textNode = $xml.CreateTextNode($textValue)
		$element.AppendChild($textNode) > $null
		$node.AppendChild($element) > $null
	}
	else
	{
		$node.($elementName) = $textValue
	}
}

# The regex used to obtain the Major.Minor.Build parts from a version number.
$majorMinorBuildRegex = New-Object System.Text.RegularExpressions.Regex "^\d+\.\d+\.\d+", SingleLine

# Open the Xml file and get the <PropertyGroup> elements with the ClickOnce properties in it.
[xml]$xml = Get-Content -Path $ProjectFilePath
$clickOncePropertyGroups = Get-XmlNodes -XmlDocument $xml -NodePath 'Project.PropertyGroup' | Where-Object { $_.ApplicationVersion -ne $null }

# If no ClickOnce deployment settings were found throw an error.
if ($clickOncePropertyGroups -eq $null -or $clickOncePropertyGroups.Count -eq 0)
{
	throw "'$ProjectFilePath' does not appear to have any ClickOnce deployment settings in it. You must publish the project at least once to create the ClickOnce deployment settings."
}

# Iterate over each <PropertyGroup> that has ClickOnce deployment settings and update them.
foreach ($propertyGroup in $clickOncePropertyGroups)
{
	# If the Version to use was not provided, get it from the project file.
	$appVersion = $Version
	if ([string]::IsNullOrEmpty($appVersion))
	{
		$appVersion = $propertyGroup.ApplicationVersion
	}
	
	# Get the Major, Minor, and Build parts of the version number.
	$majorMinorBuildMatch = $majorMinorBuildRegex.Match($appVersion)
	if (!$majorMinorBuildMatch.Success)
	{
		throw "The version number '$appVersion' does not seem to have valid Major.Minor.Build version parts."
	}
	$majorMinorBuild = $majorMinorBuildMatch.Value

	# If the Revision to use was not provided, or we should be incrementing the file's revision, get it from the project file.
	if ($Revision -lt 0 -or $IncrementProjectFilesRevision)
	{
		# If the Revision is misisng from the file, or not in a valid format, throw an error.
		if ($propertyGroup.ApplicationRevision -eq $null)
		{
			throw "Could not find the <ApplicationRevision> element in the project file '$ProjectFilePath'."
		}
		$applicationRevisionString = $propertyGroup.ApplicationRevision
		if (!($applicationRevisionString -imatch '^\d+$').Success)
		{
			throw "The <ApplicationRevision> elements value '$applicationRevisionString' in the file '$ProjectFilePath' does not appear to be a valid integer."
		}
		
		$Revision = [int]::Parse($applicationRevisionString)
		
		# If the Revision should be incremented, do it.
		if ($IncrementProjectFilesRevision)
		{
			$Revision = $Revision + 1
		}
	}
	
	$Revision %= 65535 # Make sure the revision version part is not greater than the allowed value (16-bit int).
	$newVersionNumber = "$majorMinorBuild.$Revision"
	Write-Output "Updating version number to be '$newVersionNumber'."
	
	# Write the new values to the file.
	Set-XmlNodesElementTextValue -xml $xml -node $propertyGroup -elementName 'ApplicationVersion' -textValue "$majorMinorBuild.%2a"
	Set-XmlNodesElementTextValue -xml $xml -node $propertyGroup -elementName 'ApplicationRevision' -textValue $Revision.ToString()
	if ($UpdateMinimumRequiredVersionToCurrentVersion)
	{
		Set-XmlNodesElementTextValue -xml $xml -node $propertyGroup -elementName 'MinimumRequiredVersion' -textValue "$newVersionNumber"
		Set-XmlNodesElementTextValue -xml $xml -node $propertyGroup -elementName 'UpdateRequired' -textValue 'true'
		Set-XmlNodesElementTextValue -xml $xml -node $propertyGroup -elementName 'UpdateEnabled' -textValue 'true'
	}
}

# Save the changes before commiting them back into source control.
$xml.Save($ProjectFilePath)