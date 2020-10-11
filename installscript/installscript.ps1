#
# Minecraft Dungeons Mod Installer/Loader (DMI)
# made by LukeFZ#4035
# with help from the Dungeoneer's Hideout server (discord.gg/Y3xZmdR)
#
# Version 2.0

# Needed for developer mode activation, as well as folder permissions
#Requires -RunAsAdministrator

# Preparing Variables
$Package = Get-AppxPackage Microsoft.Lovika                                                                     # Game package details
$PackageFamilyName = $Package.PackageFamilyName                                                                 # Game package family name
$Version = $Package.version                                                                                     # Installed game version
$Location = $Package.InstallLocation                                                                            # Game install location
$InstalledDriveLetter = (Get-Item -Path (Get-Item -Path $Location).Target).PSDrive.Name                         # Drive letter of the drive the game is installed on
$FreeSpace = (Get-WmiObject -Class Win32_logicaldisk -Filter "DeviceID = '${InstalledDriveLetter}:'").FreeSpace # Free space of the drive
$SystemArchitecture = [Environment]::Is64BitOperatingSystem                                                     # Variable for checking system architecture
$UWPDumper64 = "https://cdn.discordapp.com/attachments/697445257524019313/725117586718720030/UWPDumper_x64.zip" # Download URL for UWPDumper (x64)
$UWPDumper86 = "https://cdn.discordapp.com/attachments/697445257524019313/725117598697783326/UWPDumper_x86.zip" # Download URL for UWPDumper (x86)
$AppxManifest = "https://docs.dungeonsworkshop.net/installscript/appxmanifest.xml"                              # Download URL for patched AppxManifest.xml
$Extension = "https://docs.dungeonsworkshop.net/extension/extension.zip"                                        # Download URL for Vortex Extension
$DumpLocation = "$env:localappdata\Packages\$PackageFamilyName\TempState\DUMP"                                  # Location of dumped game
$TempPath = "C:\mcdtemp"                                                                                        # Temporary folder for all downloading
$Progress = 0                                                                                                   # Variable used for install folder checking
$Install                                                                                                        # User-chosen install folder
$Id                                                                                                             # Dungeons Process ID, used in dumping

clear 

"
+---------------------+
|Dungeons Modding Tool|
|     Version 2.0     |
| made by LukeFZ#4035 |
+---------------------+
" 
""

"Checking requirements..."

if($Package -eq $null) {
    "You do not have the Windows Store version of Minecraft: Dungeons installed."
    "Please install it from the Store or the Xbox app, then run the script again."
    exit
}

if (!($FreeSpace -gt 10000000000)) {
    "Error: You do not have enough free space left on ${InstalledDriveLetter}:\ to continue the patching."     # Dumping + Installation on the same drive uses almost 10GB, so adding this check
    "Please free up at least 10GB of space to ensure proper installation."
    exit
}

if($Package.IsDevelopmentMode) {                                                                               # IsDevelopmentMode is true for packages installed by this script,
    "Error: You already have a moddable installation of the game installed."                                   # so we can use that to check if the script is necessary.
    "If you want to rerun this script, please reinstall Minecraft: Dungeons from the Windows Store."
    exit
}

# mkdir $TempPath -Force                                                                                         # Creating the temp. folder for all downloads

"Enabling Developer Mode..."                                                                                   # Needed for reinstalling the package after dumping
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

"Downloading UWPDumper..."
if ($SystemArchitecture) {                                                                                     # Detect system architecture (64 or 32) to download the right UWPDumper
    Invoke-WebRequest -Uri $UWPDumper64 -OutFile C:\mcdtemp\uwp.zip
} else {
    Invoke-WebRequest -Uri $UWPDumper86 -OutFile C:\mcdtemp\uwp.zip
}

"Unpacking UWPDumper..."
Expand-Archive -Path $TempPath\uwp.zip -DestinationPath $TempPath\uwp -Force

"Unpacking finished. Now trying to dump the game. Do not panic if it looks stuck!"
explorer.exe shell:AppsFolder\${PackageFamilyName}!Game                                                        # Can't start the game normally, so using a workaround for UWP apps
Start-Sleep -s 10

while($Id -eq $null) {
    $Id = (Get-Process Dungeons).Id
}

C:\mcdtemp\uwp\UWPInjector.exe -p $Id                                                                          # Dumping the decrypted game files
if (!(Test-Path -Path $DumpLocation)) {
    "Something went wrong while trying to dump the game."
    "If this error persists, report this in the Discord channel."
    exit
} else {
    "Dumping finished successfully!"
    Stop-Process -Id $Id -Force
}
clear

"
+---------------------+
|Dungeons Modding Tool|
|     Version 2.0     |
| made by LukeFZ#4035 |
+---------------------+
" 

while($Progress -eq "0") {

    $Application = New-Object -ComObject Shell.Application
    $Install = ($Application.BrowseForFolder(0, 'Select a Folder where the game should be stored! (Do not select the root of a drive)', 0)).Self.Path # Choose a folder dialog
    if ($Install -contains "OneDrive") {                                                                       # Problematic Folder names get filtered out here
        "You have selected a folder which is stored on your OneDrive cloud."
        "You probably don't want this, so please select a different folder."
    } elseif ($Install -contains "Program Files") {
        "Your selection can cause permission problems, please select a different one."
    } else {
        $Progress = "1"
    }
    $InstalledDriveLetter = (Get-Item -Path (Get-Item -Path $Install).Target).PSDrive.Name                          # Free space check for install drive
    $FreeSpace = (Get-WmiObject -Class Win32_logicaldisk -Filter "DeviceID = '${InstalledDriveLetter}:'").FreeSpace
    if (!($FreeSpace -gt 5000000000)) {
        "The drive you selected your folder on doesn't have enough free space available."
        "Please choose another folder on a different drive."
        $Progress = "0" 
    }
}


"Copying game files..."
cd $DumpLocation                                                                                               # Enter dump folder
xcopy /T /E /g . "$Install"                                                                                    # First copy only the directory structure, prevents errors 
xcopy /E /g . "$Install"                                                                                       # Now copy all the files, 'hopefully' prevent reencryption

"Decrypting copied game files, this can take a while!"
cd $Install
cipher /d                                                                                                      # Normally, UWP games are EFS encrypted. This + the dumping
cipher /d /S:"$Install/Dungeons"                                                                               # decrypts that

"Downloading patched AppxManifest.xml..."
Remove-Item -Path "$Install/appxmanifest.xml" -Force
Invoke-WebRequest -Uri $AppxManifest -OutFile "$Install/AppxManifest.xml"                                      # https://github.com/dungeonsworkshop/dungeonsworkshop.github.io
cipher /d "$Install/AppxManifest.xml"
$Filecontent = Get-Content -Path "$Install/appxmanifest.xml"
if ($Filecontent[2] -contains $Version) {}                                                                     # Future-proofing the AppxManifest.xml, should the game update
else {
    $Filecontent[2] -replace "1.4.6.0",$Version
    Set-Content -Path "$Install/appxmanifest.xml" -Value $Filecontent
}

"Removing intro videos..."                                                                                     # Nobody likes the videos, so we just "remove" them
mkdir "$install\Dungeons\Content\Movies\backup"
Get-ChildItem -Path "$install\Dungeons\Content\Movies\*" -File -Exclude "loader_splash1080.mp4","dungeons_intro_1080_loop.mp4","blank_splash720.mp4" | Move-Item -Destination "$install\Dungeons\Content\Movies\backup\"

"Uninstalling original version..."
Remove-AppxPackage $Package -AllUsers                                                                          # Need to first remove the original Package to install the new one

"Original version uninstalled, now installing modifiable version..."
Add-Appxpackage -Path "$install/AppxManifest.xml" -register                                                    # Installing the modifiable package with the patched AppxManifest.xml
mkdir "$install\Dungeons\Content\Paks\~mods" -Force

"Main process finished! Now checking if Vortex is installed..."                                                # Trying to install the Vortex Mod Manager plugin
if(Test-Path -Path "$env:appdata\Vortex\plugins")                                                              # Useful for installing NexusMods mods
{

    "Vortex detected, installing plugin..."
    Invoke-WebRequest -Uri $Extension -OutFile "C:\mcdtemp\extension.zip"
    mkdir "$env:appdata\Vortex\plugins\game-minecraftdungeons" -Force 
    Expand-Archive -Path "C:\mcdtemp\extension.zip" -DestinationPath "$env:appdata\Vortex\plugins\game-minecraftdungeons" -Force

} else {
    "Vortex not detected, skipping plugin installation!"
}

"Creating shortcut on the desktop..."
$TargetFile = "shell:AppsFolder\Microsoft.Lovika_8wekyb3d8bbwe!Game"                                           # PowerShell has no command for creating a shortcut,
$Shortcut ="$env:USERPROFILE\Desktop\Minecraft Dungeons [Modding].lnk"                                         # so we need to cheat a bit
$WScriptShell = New-Object -ComObject WScript.Shell
$ShortcutCommand = $WScriptShell.CreateShortcut($Shortcut)
$ShortcutCommand.TargetPath = $TargetFile
$ShortcutCommand.Save()

"Finished! Deleting temp. folder..."
Remove-Item $TempPath -Force -Recurse                                                                          # Cleaning up the downloads folder
clear
"
+---------------------------------------------+
|The script has finished!                     |
|You can start the game through the start menu|
|or by using the shortcut on your desktop.    |
|It has also opened the mods folder for you if|
|you want to install mods right now.          |
+---------------------------------------------+
"
Invoke-Item -Path "$install/Dungeons/Content/Paks/~mods"                                                       # Opening the ~mods folder

"To exit,press enter."
pause
exit