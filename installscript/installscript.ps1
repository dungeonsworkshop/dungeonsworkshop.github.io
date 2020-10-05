#   Install script for the WinStore version of Minecraft: Dungeons.
#   Script made by LukeFZ#4035
#   Version last updated 05/10/2020
#


$id
$version = Get-AppxPackage -Name "Microsoft.Lovika" | select -ExpandProperty Version
$versionorig = "1.1.2.1"
$freespace = Get-WmiObject -Class Win32_logicaldisk -Filter "DeviceID = 'C:'" | select -ExpandProperty FreeSpace
clear

"Checking Developer Mode & Elevating as needed"

if ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
{
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (! (Test-Path -Path $RegistryKeyPath -ErrorAction SilentlyContinue)) 
    {
        New-Item -Path $RegistryKeyPath -ItemType Directory -Force -ErrorAction Continue
        "1"
    }

    if (! (Get-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue))
    {
        # Add registry value to enable Developer Mode
        New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
        "2"
    }
    $feature = Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online 
    if ($feature -and ($feature.State -eq "Disabled"))
    {
        Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -All -LimitAccess -NoRestart
        "3"
    }

    if ($WaitForKey)
    {
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
else
{
   # We are not running "as Administrator" - so relaunch as administrator
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = "-NoProfile",$myInvocation.MyCommand.Definition,"-WaitForKey -ExecutionPolicy Bypass";

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
}
clear
"Checking prerequisites & Downloading UWPDumper"
if ($freespace -gt 10000000000) {
    if ([Environment]::Is64BitOperatingSystem) {
        Invoke-WebRequest -Uri "https://cdn.discordapp.com/attachments/697445257524019313/725117586718720030/UWPDumper_x64.zip" -OutFile C:\mcdtemp\uwp64.zip
    } else {
        Invoke-WebRequest -Uri "https://cdn.discordapp.com/attachments/697445257524019313/725117598697783326/UWPDumper_x86.zip" -OutFile C:\mcdtemp\uwp32.zip
    }
    Expand-Archive -Path C:\mcdtemp\uwp*.zip -DestinationPath C:\mcdtemp\uwp -Force
    clear
} else {
    "You do not have enough free space on your C: drive to complete the installation. Please free up at least 10GB of space on the drive and then restart this process again."
    exit
}

if($args[0] -eq "update") {
    "Preparing to update!"
    if ([version]$version -gt [version]$versionorig) {

        "Minecraft Dungeons version after 1.3.2.0, update functionality not supported. Please backup your mods, reinstall the original version of the game and run the script normally again."
        exit

        } else {

        if($install -eq $null) {
        "Error: Modded Installation not found! Are you sure you have it installed?"
        exit
        } else {
        Remove-Item -Path "$install\Dungeons\Content\Paks\*" -include pakchunk*.pak
        mv "$install\Dungeons\Content\Paks\" C:\mcdtemp\UpdateTemp\Paks 
        Get-AppxPackage -Name "Microsoft.Lovika.mod" | Remove-AppxPackage
        rm "$install\*" -Recurse
        
        }
    }
}
clear
"Dumping... This can take a while!"
explorer.exe shell:AppsFolder\$(get-appxpackage -name Microsoft.Lovika | select -expandproperty PackageFamilyName)!Game
while($id -eq $null) {
Start-Sleep -s 10
$id = Get-process Dungeons | Select-Object -ExpandProperty Id
}
C:\mcdtemp\uwp\UWPInjector.exe -p $id
if(Test-Path "$env:localappdata/Packages/Microsoft.Lovika_8wekyb3d8bbwe/TempState/DUMP") {
    "Dump complete!"
}
else {
    "Dump failed, try running the script again. If it still fails, report this in #modding-discussion on the discord."
    exit
}

if($args[0] -eq "update") {

    "Copying updated files..."
    cd "$env:localappdata/Packages/Microsoft.Lovika_8wekyb3d8bbwe/TempState/DUMP"
    xcopy /T /E /g . $install
    xcopy /E /g . $install

    } else {

$application = New-Object -ComObject Shell.Application
$install = ($application.BrowseForFolder(0, 'Select a Folder where the game should be stored! (Do not select the root of a drive)', 0)).Self.Path
cd "$env:localappdata/Packages/Microsoft.Lovika_8wekyb3d8bbwe/TempState/DUMP"
xcopy /T /E /g . $install
xcopy /E /g . $install

}

"Decrypting copied files... this can take a while!"
cd $install
cipher /d /S:/

 "Patching AppxManifest..."
# $filecontent = Get-Content -Path $install/appxmanifest.xml
# $filecontent[2] = $filecontent[2] -replace "Microsoft.Lovika","Microsoft.Lovika.mod"
# $filecontent[31] = $filecontent[31] -replace "Dungeons.exe","Dungeons-Win64-Shipping.exe"
# $filecontent[32] = $filecontent[32] -replace "Minecraft Dungeons","Minecraft Dungeons [Modding]"
# Set-Content -Path $install/appxmanifest.xml -Value $filecontent
Remove-Item -Path $install/appxmanifest.xml -Force
Invoke-WebRequest -Uri "https://docs.dungeonsworkshop.net/installscript/appxmanifest.xml" -OutFile $install/appxmanifest.xml
$filecontent = Get-Content -Path $install/appxmanifest.xml
if ($filecontent[2] -contains $version) {}
else {$filecontent[2] -replace "1.4.6.0",$version}

"Patching Intro Videos..."
mkdir "$install\Dungeons\Content\Movies\backup"
Get-ChildItem -Path "$install\Dungeons\Content\Movies\*" -File -Exclude "loader_splash1080.mp4","dungeons_intro_1080_loop.mp4","blank_splash720.mp4" | Move-Item -Destination "$install\Dungeons\Content\Movies\backup\"



"Installing modifiable version & Uninstalling original version..."
Stop-Process -Id $id -Force
Start-Sleep -s 1
Get-AppxPackage Microsoft.Lovika | Remove-AppxPackage -AllUsers
Add-AppxPackage -path $install/appxmanifest.xml -register
if($args[0] -eq "update") 
    {} else {
     New-item -Path $install/Dungeons/Content/Paks/ -Name "~mods" -ItemType "directory"
    }

ii $install/Dungeons/Content/Paks/~mods

if($args[0] -eq "update") {
    "Finishing updating process..."
    mv C:\mcdtemp\UpdateTemp\Paks\ "$install\Dungeons\Content\"
}

if(Test-Path -Path "$env:appdata\Vortex\plugins") 
{
    "Vortex Mod Manager detected, checking if plugin is already installed..."
    if(Test-Path -Path "$env:appdata\Vortex\plugins\game-minecraftdungeons") {

        "Plguin already installed, skipping..."

    } else {

    Invoke-WebRequest -Uri "https://docs.dungeonsworkshop.net/extension/extension.zip" -OutFile "C:\mcdtemp\extension.zip"
    mkdir "$env:appdata\Vortex\plugins\game-minecraftdungeons"
    Expand-Archive -Path "C:\mcdtemp\extension.zip" -DestinationPath "$env:appdata\Vortex\plugins\game-minecraftdungeons"

    }
} else {
    "Vortex Mod Manager not detected, skipping plugin installation!"
}

"Finished! Cleaning up..."
Remove-Item C:\mcdtemp -Force  -Recurse -ErrorAction SilentlyContinue


# Shortcut Time
$TargetFile = "shell:AppsFolder\Microsoft.Lovika_8wekyb3d8bbwe!Game"
$Shortcut ="$env:USERPROFILE\Desktop\Minecraft Dungeons [Modding].lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$ShortcutCommand = $WScriptShell.CreateShortcut($Shortcut)
$ShortcutCommand.TargetPath = $TargetFile
$ShortcutCommand.Save()


"The script has created a shortcut on your desktop, which you can use to launch the game."
"To exit,press enter."
pause
exit
