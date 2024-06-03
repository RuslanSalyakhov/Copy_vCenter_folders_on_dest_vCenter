$vcenter_server = "vCenter url" # For example vcenter.lab.com
$vcenter_user_name = "vCenter user name"
$vcenter_user_pass = "vCenter user password"

$logfile = "C:\logs\new_folders.log"

# Step 1: Connect to the vCenter server
Connect-VIServer -Server $vcenter_server -User $vcenter_user_name -Password $vcenter_user_pass -SaveCredentials

# Step 2: Create an array of unique folder names required
$folders = @('folder_1','folder_2','folder_3')
$folders = $folders | select -Unique

# Step 3: Define the name for parent folder for new folders which are going to be created. 
$parentFolder = Get-Folder -Name "RB_MIQ"

# Step 4: Before create new folders confirm the list of created folders. After confirmation use folder names in $folders variable to create new folders inside parentFolder on vCenter.
if ($folders.Count -gt 0) {
    Write-Host "The following new folders will be created on the vCenter:"
    Write-Host $folders
    $confirm = Read-Host "Do you want to proceed? (Y/N)"
    if ($confirm -eq "Y") {
        foreach ($newFolder in $folders) {
            New-Folder -Name $newFolder -Location $parentFolder
        }
    }
}

# Step 5: Print the list of folders from $folders variable to the screen and save the log output to the file
Write-Host "The following new folders were created on the vCenter:"
Write-Host $folders
$log = "New folders created on $(Get-Date):`n$folders"
# $log = "New folders created on $(Get-Date):`n$($folders -join ', ')"   - For comma separated values in the log output
$log | Out-File -FilePath $logfile -Append
