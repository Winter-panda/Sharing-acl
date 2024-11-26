# Sharing-acl
Auditing sharing acl's
# Orphaned SIDs Audit Script

This PowerShell script scans file share permissions to detect orphaned Security Identifiers (SIDs). Orphaned SIDs typically indicate groups or users that no longer exist in the domain.

## Requirements

- Windows PowerShell
- Sufficient permissions to read file share permissions

## Installation

1. Download the script file and save it to your desired location.
2. Open Windows PowerShell with administrative privileges.

## Usage

1. Modify the `$sharePath` variable in the script to point to the file share you want to audit.
2. Run the script in PowerShell:
   ```powershell
   .\OrphanedSIDsAudit.ps1
