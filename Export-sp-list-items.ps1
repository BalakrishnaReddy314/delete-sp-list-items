param (
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$Username,
    
    [Parameter(Mandatory = $true)]
    [string]$Password,
    
    [Parameter(Mandatory = $true)]
    [string]$ListName,

    [Parameter(Mandatory = $true)]
    [string]$FieldInternalName,

    [Parameter(Mandatory = $true)]
    [string]$FieldValue,
    
    [Parameter(Mandatory = $true)]
    [string]$FolderPath
)

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

# Convert secure string to plain text password
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

# Connect to the SharePoint site
Connect-PnPOnline -Url $SiteUrl -Credentials $credentials

# Query to filter list items
$query = "<View><Query><Where><Eq><FieldRef Name='YourFieldInternalName'/><Value Type='Text'>YourFilterValue</Value></Eq></Where></Query></View>"
$query = $query.Replace("YourFieldInternalName", $FieldInternalName).Replace("YourFilterValue", $FieldValue)

# Get list items based on the query
$listItems = Get-PnPListItem -List $ListName -Query $query

$fileName = "list-items_$(Get-Date -f "dd_MM_yyyy_hh_mm").csv"

# Export list items to CSV
$csvFilePath = "C:\$fileName"
$listItems | Select-Object * | Export-Csv -Path $csvFilePath -NoTypeInformation

# Upload the CSV file to SharePoint library
Add-PnPFile -Path $csvFilePath -Folder $FolderPath

# Disconnect from the SharePoint site
Disconnect-PnPOnline
