# Check if PnP PowerShell module is installed
$moduleName = "PnP.PowerShell"
$moduleInstalled = Get-Module -Name $moduleName -ListAvailable

# Install the module if not already installed
if (-not $moduleInstalled) {
    Write-Host "Installing $moduleName module..."
    Install-Module -Name $moduleName -Force -AllowClobber -Scope CurrentUser
}

# Import the PnP PowerShell module
Import-Module -Name $moduleName

# Get parameters
$siteUrl = Read-Host "Enter the SharePoint site URL"
$username = Read-Host "Enter the username"
$password = Read-Host -AsSecureString "Enter the password"
$listName = Read-Host "Enter the SharePoint list name"
$folderPath = Read-Host "Enter the library folder path"

# Convert secure string to plain text password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Connect to the SharePoint site
Connect-PnPOnline -Url $siteUrl -Credentials $credentials

# Query to filter list items
$query = "<View><Query><Where><Eq><FieldRef Name='YourFieldInternalName'/><Value Type='Text'>YourFilterValue</Value></Eq></Where></Query></View>"
$query = $query.Replace("YourFieldInternalName", $fieldInternalName).Replace("YourFilterValue", $fieldValue)

# Get list items based on the query
$listItems = Get-PnPListItem -List $listName -Query $query

# Export list items to CSV
$csvFilePath = "C:\Path\to\your\file.csv"
$listItems | Select-Object * | Export-Csv -Path $csvFilePath -NoTypeInformation

# Upload the CSV file to SharePoint library
Add-PnPFile -Path $csvFilePath -Folder $folderPath

# Disconnect from the SharePoint site
Disconnect-PnPOnline
