# Script to unrar multiple archives from all subdirectorys in a specified path.

$source_path = Read-Host 'Enter source path'
$dest_path = Read-Host 'Enter destination path'
$unrarpath = 'C:\Program Files\WinRAR\UnRAR.exe'
$files = @()

# Check unrar.exe default path
if ((Test-Path -Path $unrarpath) -ne $true){
    write-host 'Unrar.exe not present in default unrar folder, C:\Program Files\WinRAR\UnRAR.exe'
    break
}
 
# Test to see if Unpackdir is present
if ((Test-Path -Path $dest_path) -ne $true){
    # If not present, create Unpackdir
    {md $dest_path}
}

# Recurse through all subfolders looking for .rar files
Get-ChildItem $source_path -Recurse -Filter "*.rar" | % {
    $files = $files + $_.FullName
}
 
foreach ($file in $files) {
    # UnRAR the files. -y responds Yes to any queries UnRAR may have
    & "$unrarpath" x -y $file $dest_path
}