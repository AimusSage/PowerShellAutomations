<# 
.SYNOPSIS
    A script to override the wallpaper set by policy
#>

[CmdletBinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory=$True)]
    [string]$ImageFolderPath 
)
try {
    $dir = get-item "$ImageFolderPath"
    $supportedFileTypes = @(".jpg",".jpeg",".png",".tiff",".tif")    
    $PictureSet = Get-ChildItem -Path $dir | Where-Object {$_.Extension -in $supportedFileTypes}

    $imageFullPath = $pictureSet[(Get-Random -maximum $PictureSet.Length)].FullName
    Write-Output "the selected image is: $imageFullPath"
    Copy-Item "$imageFullPath" -destination "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -Force -errorAction Stop
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
}
catch {
    Throw $_.Exception.Message 
}
