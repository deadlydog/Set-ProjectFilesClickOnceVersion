# Description
This PowerShell script can be used to update a project file's (.csproj or .vbproj file) ClickOnce version, and to set the Minimum Required Version to the lastest version.

This script is useful when publishing your ClickOnce application as part of your build and release system, since normally Visual Studio would automatically handle updating the ClickOnce version for you.

Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user. If you are simply looking to have the Minimum Required Version update automatically, but still publish your ClickOnce application from Visual Studio, try using the [AutoUpdateProjectsMinimumRequiredClickOnceVersion NuGet Package][AutoUpdateProjectsMinimumRequiredClickOnceVersionNugetPackageWebpage].


# Script Parameters
* **ProjectFilePath** (required) - Path of the .csproj and .vbproj file to process.

* **Version** - The Version to update the ClickOnce version number to. This version must be of the format Major.Minor.Build or Major.Minor.Build.Revision. The Build and Revision parts will be overridden by the BuildSystemsBuildId parameter, if it is provided. The Revision parts will be overriden by the IncrementProjectFilesRevision parameter, if it is provided.

* **BuildSystemsBuildId** - The build system's unique and auto-incrementing Build ID. This will be used to generate the Build and Revision parts of the new Version number. This will override the Build and Revision specified in the Version parameter, if it was provided. This parameter cannot be used with the IncrementProjectFilesRevision parameter.

* **IncrementProjectFilesRevision** - If this switch is provided, the Revision from the project file will be incremented and used in the new ClickOnce Version. This will override the Revision specified in the Version parameter, if it was provided. This parameter cannot be used with the BuildSystemsBuildId parameter.

* **UpdateMinimumRequiredVersionToCurrentVersion** - If this switch is provided, the ClickOnce MinimumRequiredVersion will be updated to match the new Version. Setting the MinimumRequiredVersion property forces the ClickOnce application to update automatically without prompting the user.

* **PublishUrl** - If this switch is provided, the ClickOnce PublishUrl will be updated. The publish url format is \\fileshare\foldername

* **InstallUrl** - If this switch is provided, the ClickOnce InstallUrl will be updated. The install url format is http://fileshare/foldername

# Examples
Update a project file's ClickOnce version to the specified version.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version '1.2.3.4'
```

---

Update the Build and Revision parts of a project file's ClickOnce version, based on a unique, auto-incrementing integer, such as a build system's Build ID.
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

---

Update a project file's ClickOnce version and its install and publish url values.
```
& .\Set-ProjectFilesClickOnceVersion.ps1 -ProjectFilePath "C:\SomeProject.csproj" -Version 1.0.1.9 -PublishUrl "\\fileshare\foldername" -InstallUrl "http://fileshare/foldername"
```

[AutoUpdateProjectsMinimumRequiredClickOnceVersionNugetPackageWebpage]: https://www.nuget.org/packages/AutoUpdateProjectsMinimumRequiredClickOnceVersion
