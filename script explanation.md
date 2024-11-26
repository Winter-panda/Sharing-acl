
# Technical Explanation of the Script

## Introduction
This PowerShell script aims to scan the permissions of a file share to detect orphaned Security Identifiers (SIDs). Orphaned SIDs are security identifiers that cannot be resolved to valid user or group names, typically indicating that the corresponding users or groups no longer exist in the domain.

## Script Steps

### 1. Define the Path of the File Share
The script begins by defining the path of the file share to audit. This path is stored in the `$sharePath` variable.

```powershell
$sharePath = "\\path\to\your\share"

```

### 2. Retrieve NTFS Permissions

The script uses `Get-ChildItem` to retrieve all files and folders under the specified path and `Get-Acl` to obtain the NTFS permissions for each item. The retrieved information is stored in `$aclList` with the full path of each file or folder.

powershell

```
$aclList = Get-ChildItem -Path $sharePath -Recurse | Select-Object FullName, @{Name="Acl";Expression={Get-Acl $_.FullName}}

```

### 3. Initialize the Array for Orphaned SIDs

An empty array `$orphanedSids` is initialized to store the detected orphaned SIDs and their respective paths.

powershell

```
$orphanedSids = @()

```

### 4. Iterate Through the Permissions

The script iterates through each item in `$aclList` and each access entry in `Access`. For each entry, it retrieves the SID value.

powershell

```
foreach ($item in $aclList) {
    foreach ($access in $item.Acl.Access) {
        $sid = $access.IdentityReference.Value

```

### 5. Check and Resolve SIDs

The script checks if the SID starts with "S-1-5-", which is typically the format for SIDs. If so, it attempts to resolve the SID to a user or group name using `System.Security.Principal.SecurityIdentifier`.

powershell

```
if ($sid -like 'S-1-5-*') {
    try {
        $resolvedName = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount])
    } catch {
        $orphanedSids += [PSCustomObject]@{ Path = $item.FullName; SID = $sid }
    }
}

```

### 6. Handle Exceptions

If an exception is raised while attempting to resolve the SID, it indicates that the SID is orphaned. The script then adds the SID and the item's path to the `$orphanedSids` array.

powershell

```
} catch {
    $orphanedSids += [PSCustomObject]@{ Path = $item.FullName; SID = $sid }
}

```

### 7. Display the Results

Finally, the script checks if any orphaned SIDs were found. If so, it displays them along with their respective paths. Otherwise, it indicates that no orphaned SIDs were found.

powershell

```
if ($orphanedSids.Count -eq 0) {
    Write-Output "No orphaned SIDs found."
} else {
    Write-Output "Orphaned SIDs found:"
    $orphanedSids | ForEach-Object { Write-Output "Path: $($_.Path), SID: $($_.SID)" 
```
