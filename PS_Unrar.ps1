
<#
    .SYNOPSIS
    Script to unrar multiple archives from all subdirectorys in a specified path
    .DESCRIPTION
    Script to unrar/unpack multiple folders contaiong .rar archives.
    This script works recurive on subfolders and has the ability woth a filter to limit what that folders recursed are unpacked.
    .EXAMPLE
    .\PS_Unrar.ps1 -SourcePath X:\Film\HD\GreatMovie -DestinationPath C:\Unrar
    Unrar contents of X:\Film\HD\GreatMovie to C:\Unrar
    .EXAMPLE
    .\PS_Unrar.ps1 -SourcePath X:\Film\HD\ -DestinationPath C:\Unrar -Filter *S
    Unrar contents of X:\Film\HD\ to C:\Unrar, but only folders that start with the letter "S"
    .PARAMETER SourcePath
    The path to where the rar files to be unrared ar located
    .PARAMETER DestinationPath
    The path where you want the files you unrar to end up
    .PARAMETER Filter
    This gives you the opportunity to filter out folders that start with for example a certian letter in a path that contains multiple folders
    .PARAMETER UnrarEXEPath
    This parameter is used if you need to override the default path to the UnRAR.exe included in the WinRAR installation
    .NOTES
    Author     : SpaceFarmer
    Version    : 1.0
    .Link
    https://github.com/SpaceFarmer/PS_Unrar
#>

Param (
    [Parameter(Mandatory=$True,Position=1)]
    [string]$SourcePath,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$DestinationPath,
    [Parameter(Mandatory=$False)]
    [string]$Filter="false",
    [Parameter(Mandatory=$False)]
    [string]$UnrarEXEPath="C:\Program Files\WinRAR\UnRAR.exe"
)

$RarFiles = @()
$Folders = @()
$Subfolders = @()
$FolderFiles = @()
$SubFolderFiles = @()
$ContainsSubFolders = $true

# Check unrar.exe default path
if ((Test-Path -Path $UnrarEXEPath) -ne $true){
    Write-Warning 'Unrar.exe not present in default unrar folder, C:\Program Files\WinRAR\UnRAR.exe'
    break
}

# Test to see if Unpackdir is present
if ((Test-Path -Path $DestinationPath) -ne $true){
    # If not present, create Unpackdir
    Write-Warning "The provided destination path did not exist, creating folder: $DestinationPath"
    mkdir $DestinationPath
}

# If a filter is used we need to adjust the scope of what folders to include
If ($Filter -ne "false") {
	$Folders = Get-ChildItem $SourcePath\$Filter -Directory | Select-Object FullName
    $SubFolders = Get-ChildItem $SourcePath\$Filter -Directory -Recurse | Select-Object FullName
}
ElseIf ((Get-ChildItem -Directory -Path $SourcePath ).count -eq "0") {
	$Folder = $SourcePath
	$ContainsSubFolders = $false
}
Else {
    $Folders = Get-ChildItem $SourcePath -Directory | Select-Object FullName
    $SubFolders = Get-ChildItem $SourcePath\* -Directory -Recurse | Select-Object FullName
}

If ($ContainsSubFolders -eq $true) {
	# Get .rar files from top level folders
	foreach ($Folder in $Folders) {
		$File = New-Object PSObject
		$Folder = $Folder.FullName
		$File = (Get-ChildItem -File -Path $Folder\* -Include *.rar -Depth 0 | Select-Object -First 1)
		$FolderFiles = $FolderFiles + $File
	}

	# Get .rar files from all subfolders
	foreach ($SubFolder in $SubFolders) {
		$File = New-Object PSObject
		$SubFolder = $SubFolder.FullName
		$File = (Get-ChildItem -Path $SubFolder\* -Include *.rar -Recurse | Select-Object -First 1)
		$SubFolderFiles = $SubFolderFiles + $File
	}
} Else {
	$FolderFiles = (Get-ChildItem -File -Path $Folder\* -Include *.rar -Depth 0)
}

$RarFiles = $FolderFiles.FullName + $SubFolderFiles.FullName

Write-Host "----" -ForegroundColor Red
Write-Host "TopFolderFiles:"
$FolderFiles.FullName
Write-Host "----" -ForegroundColor Red
Write-Host "SubFolderFiles:"
$SubFolderFiles.FullName
Write-Host "----" -ForegroundColor Red
Write-Host "AllFolderFiles:"
$RarFiles

foreach ($RarFile in $RarFiles) {
    # UnRAR the files. -y responds Yes to any queries UnRAR may have
    & "$UnrarEXEPath" x -y $RarFile $DestinationPath
}