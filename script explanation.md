
```
# Technical Explanation of the Script

## Introduction
This PowerShell script aims to scan the permissions of a file share to detect orphaned Security Identifiers (SIDs). Orphaned SIDs are security identifiers that cannot be resolved to valid user or group names, typically indicating that the corresponding users or groups no longer exist in the domain.

## Script Steps

### 1. Define the Path of the File Share and Log File
The script begins by defining the path of the file share to audit and the path of the log file where messages will be recorded.

```powershell
$sharePath = "\\path\to\your\share"
$logPath = "C:\path\to\your\logfile.log"

```

### 2. Function to Write Logs

A `Write-Log` function is defined to write log messages to the specified file with a timestamp.

powershell

```
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logPath -Value $logMessage
}

```

### 3. Start the Log

The script begins the audit by writing a message to the log file.

powershell

```
Write-Log "Audit started for path: $sharePath"

```

### 4. Retrieve NTFS Permissions

The script uses `Get-ChildItem` to retrieve all files and folders under the specified path and `Get-Acl` to obtain the NTFS permissions for each item.

powershell

```
$aclList = Get-ChildItem -Path $sharePath -Recurse | Select-Object FullName, @{Name="Acl";Expression={Get-Acl $_.FullName}}

```

### 5. Initialize the Array for Orphaned SIDs

An empty array `$orphanedSids` is initialized to store the detected orphaned SIDs and their respective paths.

powershell

```
$orphanedSids = @()

```

### 6. Iterate Through the Permissions

The script iterates through each item in `$aclList` and each access entry in `Access`. For each entry, it retrieves the SID value.

powershell

```
foreach ($item in $aclList) {
    foreach ($access in $item.Acl.Access) {
        $sid = $access.IdentityReference.Value

```

### 7. Check and Resolve SIDs

The script checks if the SID starts with "S-1-5-", which is typically the format for SIDs. If so, it attempts to resolve the SID to a user or group name using `System.Security.Principal.SecurityIdentifier`. If an exception is raised, the orphaned SID and its path are added to the array and a message is written to the log file.

powershell

```
if ($sid -like 'S-1-5-*') {
    try {
        $resolvedName = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount])
    } catch {
        $orphanedSids += [PSCustomObject]@{ Path = $item.FullName; SID = $sid }
        Write-Log "Orphaned SID found: $sid at path: $($item.FullName)"
    }
}

```

### 8. Display the Results

The script checks if any orphaned SIDs were found. If so, it displays them along with their respective paths and writes the information to the log file. Otherwise, it indicates that no orphaned SIDs were found and writes a corresponding message to the log file.

powershell

```
if ($orphanedSids.Count -eq 0) {
    Write-Output "No orphaned SIDs found."
    Write-Log "No orphaned SIDs found."
} else {
    Write-Output "Orphaned SIDs found:"
    $orphanedSids | ForEach-Object { 
        Write-Output "Path: $($_.Path), SID: $($_.SID)" 
        Write-Log "Path: $($_.Path), SID: $($_.SID)"
    }
}

```

### 9. End the Log

At the end of the script, a message indicating the end of the audit is written to the log file.

    Write-Log  "Audit completed."
