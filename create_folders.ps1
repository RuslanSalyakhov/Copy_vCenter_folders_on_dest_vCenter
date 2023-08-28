$source_cluster = "Source cluster name"
$source_vcenter_server = "Source vCenter url" # For example vcenter.lab.com
$dest_vcenter_server = "Destination vCenter url"


$vcenter_user_name = "vCenter user name"
$vcenter_user_pass = "vCenter user password"

$logfile = "C:\logs\new_folders.log"

# Step 1: Connect to the source vCenter server
Connect-VIServer -Server $source_vcenter_server -User $vcenter_user_name -Password $vcenter_user_pass -SaveCredentials

# Step 2: Get folder names with prefix 'rsb_CI' for VMs in the specified cluster
$folders = Get-Cluster -Name $source_cluster | Get-VM | Where-Object {$_.Folder.Name -like "rsb_CI*"} | Select-Object -ExpandProperty Folder | Select-Object -Unique

# Step 3: Disconnect from the source vCenter
Disconnect-VIServer -Server $source_vcenter_server -Confirm:$false

# Step 4: Connect to the destination vCenter Server
Connect-VIServer -Server $dest_vcenter_server  -User $vcenter_user_name -Password $vcenter_user_pass -SaveCredentials

# Step 5: Get folders names nested into the parent folder with a name "RB_MIQ"
$parentFolder = Get-Folder -Name "RB_MIQ"
$targetFolders = $parentFolder | Get-Folder

# Step 6: Compare the source and target vCenters folder names and if source folder name were not found in the target folders list create a variable $newFolders to keep track of new folders names we are going to create on the target vCenter
$newFolders = @()
foreach ($folder in $folders) {
    if ($targetFolders.Name -notcontains $folder.Name) {
        $newFolders += $folder.Name
    }
}

# Step 7: Before create new folders confirm the list of created folders. After confirmation use folder names in $newFolders variable to create new folders inside "mig_folder" on destination vCenter.
if ($newFolders.Count -gt 0) {
    Write-Host "The following new folders will be created on the destination vCenter:"
    Write-Host $newFolders
    $confirm = Read-Host "Do you want to proceed? (Y/N)"
    if ($confirm -eq "Y") {
        foreach ($newFolder in $newFolders) {
            New-Folder -Name $newFolder -Location $parentFolder
        }
    }
}

# Step 8: Print the list of folders from $newFolders variable to the screen and save the log output to the file
Write-Host "The following new folders were created on the destination vCenter:"
Write-Host $newFolders
$log = "New folders created on $(Get-Date):`n$newFolders"
# $log = "New folders created on $(Get-Date):`n$($newFolders -join ', ')"   - For comma separated values in the log output
$log | Out-File -FilePath $logfile -Append

# Disconnect from the destination vCenter
Disconnect-VIServer -Server <destination_vcenter_server> -Confirm:$false
