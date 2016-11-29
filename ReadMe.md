# Description
This PowerShell script can be used to update a project file's (.csproj or .vbproj file) ClickOnce version, and to set the Minimum Required Version to the lastest version.

Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.


# Script Parameters
* **ProjectFilePath** (required) - Path of the .csproj and .vbproj file to process.
	
* **Version** - The Version to update the ClickOnce version number to. This version must be of the format Major.Minor.Build or Major.Minor.Build.Revision. If provided, the Revision provided will be overridden by the Revision or IncrementProjectFilesRevision parameter if provided.

* **Revision** - The Revision to use in the new Version number. This will override the Revision specified in the Version parameter if provided. This parameter cannot be used with the IncrementProjectFilesRevision parameter.
	
* **IncrementProjectFilesRevision** - If this switch is provided, the Revision from the project file will be incremented and used in the new ClickOnce Version. This will override the Revision specified in the Version parameter if provided.
	
* **UpdateMinimumRequiredVersionToCurrentVersion** - If this switch is provided, the ClickOnce MinimumRequiredVersion will be updated to match the new Version. Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.

# Examples

1. Update a project file's ClickOnce version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3.4'
```

2. Update just the Revision part of a project file's ClickOnce version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Revision 12345
```

3. Increment the Revision of a project file's ClickOnce version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -IncrementProjectFilesRevision
```

4. Update a project file's ClickOnce Minimum Required Version to match its current version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -UpdateMinimumRequiredVersionToCurrentVersion
```

5. Update a project file's ClickOnce version, ignoring the Revision part and incrementing the Revision stored in the file, and update the Minimum Required Version to be this new version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3' -IncrementProjectFilesRevision -UpdateMinimumRequiredVersionToCurrentVersion
```