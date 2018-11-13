<# 
.SYNOPSIS
    A script to override the wallpaper set by policy
.DESCRIPTION
    The script will search a folder for all images and select a new one that is different from the previously set wallpaper. 
    It does this by comparing filesizes. Be careful, this script uses recursion and requires there to be at least two different images in the folder.
#>

[CmdletBinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory=$True)]
    [string]$ImageFolderPath,
    [Parameter(Mandatory=$False)]
    [switch]$EnableLogging
)

# Global path of wallpaper, this should never change.
$global:currentWallpaperLocation ="$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"

# set up some logging
if($EnableLogging) {
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
    $timestamp = $(get-date -format yyyy-MM-dd-HH-mm);
    $global:fileName = "$($MyInvocation.MyCommand | Select-Object -ExpandProperty Name)".Replace(".ps1", "")
    $logFile = "$global:scriptPath\Logs\$($timestamp)_$($fileName).log"
    start-transcript -path $logFile
}

function Select-Wallpaper {
    # will select a new wallpaper that is different from the current one
    param (
        $PictureSet,
        $CurrentWallpaperSize
    )

    $imageFullPath = $pictureSet[(Get-Random -maximum $PictureSet.Length)].FullName
    Write-host "the selected image is: $imageFullPath"
    $newWallpaper = get-item $imageFullPath
        
    #check if the newly selected wallpaper is not the same as the current one
    if ($newWallpaper.Length -eq $CurrentWallpaperSize) {
        Write-host "the new wallpaper appears to be the same as the current one, trying again..."
        $currentStack = Get-PSCallStack
        if ($currentStack.length -gt 10) { #limit tries to max 10.
            Throw "unable to find a different image in time"
        }
        Select-Wallpaper -pictureSet $pictureSet -CurrentWallpaperSize $CurrentWallpaperSize
    } else {
        return $imageFullPath
    }
}

function update-CurrentWallpaper {
    param (
        $NewImageFullPath,
        $CurrentWallpaperSize
    )
    
    Copy-Item "$imageFullPath" -destination "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -Force -errorAction Stop
    
    # three times seems to increase likelyhood of adoption.
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 

    $newWallpaper = get-item $global:currentWallpaperLocation #retreive new wallpaper info for comparison
    
    #check if update was succesful, if not, try again
    if ($newWallpaper.Length -eq $CurrentWallpaperSize) {
        $currentStack = Get-PSCallStack
        if ($currentStack.length -gt 10) {
            Throw "I was unable to update the wallpaper this time"
        }
        Write-host "Oops, Updating didn't work quite right, let's try again..."
        Update-CurrentWallpaper -pictureSet $pictureSet -CurrentWallpaperSize $CurrentWallpaperSize
    }
}

# script execution
try {
    if($EnableLogging) {
        $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
        $timestamp = $(get-date -format yyyy-MM-dd-HH-mm);
        $global:fileName = "$($MyInvocation.MyCommand | Select-Object -ExpandProperty Name)".Replace(".ps1", "")
        $logFile = "$global:scriptPath\Logs\$($timestamp)_$($fileName).log"
        start-transcript -path $logFile
    }

    $dir = get-item "$ImageFolderPath"
    $supportedFileTypes = @(".jpg",".jpeg",".png",".tiff",".tif")    
    $PictureSet = Get-ChildItem -Path $dir | Where-Object {$_.Extension -in $supportedFileTypes}
    
    $currentWallpaper = get-item $global:currentWallpaperLocation
    $currentWallpaperSize = $currentWallpaper.Length

    $imageFullPath = select-wallpaper -PictureSet $PictureSet -CurrentWallpaperSize $currentWallpaperSize         
    
    update-CurrentWallpaper -NewImageFullPath $imageFullPath -CurrentWallpaperSize $currentWallpaperSize

    Write-Output "It looks like you got a shiny new wallpaper"
}
catch {
    Throw $_.Exception.Message 
} finally {
    if($EnableLogging) {
        stop-transcript
    }
}
