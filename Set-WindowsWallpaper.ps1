<# 
.SYNOPSIS
    A script to override the wallpaper set by policy
#>

[CmdletBinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory=$True)]
    [string]$imageFullPath 
)
try {
    
    Copy-Item "$imageFullPath" -destination "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -Force -errorAction Stop
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
}
catch {
    Throw $_.Exception.Message 
}
