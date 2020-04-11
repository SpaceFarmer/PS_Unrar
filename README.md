# PS_Unrar
PowerShell script to unrar multiple archives recursively from all subdirectorys in a specified path.

### Pre-Req's:
WinRar needs to be installed on your system

### Examples

Unrar contents of X:\Film\HD\GreatMovie to C:\Unrar:

`.\PS_Unrar.ps1 -SourcePath "X:\Film\HD\GreatMovie" -DestinationPath "C:\Unrar"`

Unrar contents of X:\Film\HD to C:\Unrar, but only the folders that starts with the letter "S":

`.\PS_Unrar.ps1 -SourcePath "X:\Film\HD" -DestinationPath "C:\Unrar" -Filter "S*"`