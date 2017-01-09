# Description
This PowerShell script can be used to update a project file's (.csproj or .vbproj file) ClickOnce version, and to set the Minimum Required Version to the lastest version.

Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.


# Script Parameters
* **ProjectFilePath** (required) - Path of the .csproj and .vbproj file to process.
	
* **Version** - The Version to update the ClickOnce version number to. This version must be of the format Major.Minor.Build or Major.Minor.Build.Revision. The Build and Revision parts will be overridden by the BuildSystemsBuildId and IncrementProjectFilesRevision parameters, if they are provided.

* **BuildSystemsBuildId** - The build system's unique and auto-incrementing Build ID. This will be used to generate the Build and Revision parts of the new Version number. This will override the Build and Revision specified in the Version parameter, if it was provided. This parameter cannot be used with the IncrementProjectFilesRevision parameter.
	
* **IncrementProjectFilesRevision** - If this switch is provided, the Revision from the project file will be incremented and used in the new ClickOnce Version. This will override the Revision specified in the Version parameter, if it was provided.
	
* **UpdateMinimumRequiredVersionToCurrentVersion** - If this switch is provided, the ClickOnce MinimumRequiredVersion will be updated to match the new Version. Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.


# Examples
Update a project file's ClickOnce version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3.4'
```

---

Update just the Build and Revision parts of a project file's ClickOnce version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -BuildSystemsBuildId 123456
```

---

Increment the Revision of a project file's ClickOnce version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -IncrementProjectFilesRevision
```

---

Update a project file's ClickOnce Minimum Required Version to match its current version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -UpdateMinimumRequiredVersionToCurrentVersion
```

---

Update a project file's ClickOnce version, ignoring the Revision part and incrementing the Revision stored in the file, and update the Minimum Required Version to be this new version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3' -IncrementProjectFilesRevision -UpdateMinimumRequiredVersionToCurrentVersion
```