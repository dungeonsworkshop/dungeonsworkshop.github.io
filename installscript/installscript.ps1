$id
clear
"Checking Developer Mode & Elevating as needed"

if ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
{
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    pause
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
        pause
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
"Determining the system architecture for UWPDumper..."
if ([Environment]::Is64BitOperatingSystem) {
    Invoke-WebRequest -Uri "https://cdn.discordapp.com/attachments/697445257524019313/725117586718720030/UWPDumper_x64.zip" -OutFile C:\mcdtemp\uwp64.zip
} else {
    Invoke-WebRequest -Uri "https://cdn.discordapp.com/attachments/697445257524019313/725117598697783326/UWPDumper_x86.zip" -OutFile C:\mcdtemp\uwp32.zip
}
Expand-Archive -Path C:\mcdtemp\uwp*.zip -DestinationPath C:\mcdtemp\uwp -Force
clear

if($args[0] -eq "forcesavetransfer") {
    if(Test-Path "$env:localappdata\Packages\Microsoft.Lovika_8wekyb3d8bbwe\LocalCache\Local\DungeonsBackup\" -ErrorAction SilentlyContinue) {
    } else {
    if(Test-Path "$env:localappdata\Packages\Microsoft.Lovika_8wekyb3d8bbwe\LocalCache\Local\Dungeons\" -ErrorAction SilentlyContinue) {

        if(Test-Path "$env:localappdata\Dungeons\" -ErrorAction SilentlyContinue) {

            mv "$env:localappdata\Dungeons" "$env:localappdata\DungeonsBackup"
            mkdir "$env:localappdata\Dungeons"

            } else {
                mkdir "$env:localappdata\Dungeons" 
            }
            "Making Savegame persistent..."
            $path2 = "$env:localappdata\Dungeons"
            cd "$env:localappdata\Packages\Microsoft.Lovika_8wekyb3d8bbwe\LocalCache\Local\Dungeons"
            xcopy /S /I /E /g . "$env:localappdata\Dungeons"
            cd ..
            Start-Sleep -s 1
            mv "$env:localappdata\Packages\Microsoft.Lovika_8wekyb3d8bbwe\LocalCache\Local\Dungeons" "$env:localappdata\Packages\Microsoft.Lovika_8wekyb3d8bbwe\LocalCache\Local\DungeonsBackup"
        }
    }
}

clear

if($args[0] -eq "update") {
    "Preparing to update!"
    $install = Get-AppxPackage -Name "Microsoft.Lovika.mod" | select -ExpandProperty InstallLocation
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
pause
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
    Rename-Item -Path "$install\Dungeons\Binaries\Win64\Dungeons.exe" -NewName "Dungeons-Win64-Shipping.exe"

    } else {

$application = New-Object -ComObject Shell.Application
$install = ($application.BrowseForFolder(0, 'Select a Folder where the game should be stored! (Do not select the root of a drive)', 0)).Self.Path
cd "$env:localappdata/Packages/Microsoft.Lovika_8wekyb3d8bbwe/TempState/DUMP"
xcopy /T /E /g . $install
xcopy /E /g . $install
Rename-Item -Path "$install\Dungeons\Binaries\Win64\Dungeons.exe" -NewName "Dungeons-Win64-Shipping.exe"
}

"Patching AppxManifest..."
$filecontent = Get-Content -Path $install/appxmanifest.xml
$filecontent[2] = $filecontent[2] -replace "Microsoft.Lovika","Microsoft.Lovika.mod"
$filecontent[31] = $filecontent[31] -replace "Dungeons.exe","Dungeons-Win64-Shipping.exe"
$filecontent[32] = $filecontent[32] -replace "Minecraft Dungeons","Minecraft Dungeons [Modding]"
Set-Content -Path $install/appxmanifest.xml -Value $filecontent

"Patching Intro Videos..."
mkdir "$install\Dungeons\Content\Movies\backup"
Get-ChildItem -Path "$install\Dungeons\Content\Movies\*" -File -Exclude "loader_splash1080.mp4","dungeons_intro_1080_loop.mp4","blank_splash720.mp4" | Move-Item -Destination "$install\Dungeons\Content\Movies\backup\"


"Installing modifiable version.."
Stop-Process -Id $id -Force
Add-AppxPackage -path $install/appxmanifest.xml -register
if($args[0] -eq "update") 
    {

    } else {
     New-item -Path $install/Dungeons/Content/Paks/ -Name "~mods" -ItemType "directory"
    }

ii $install/Dungeons/Content/Paks/~mods

if($args[0] -eq "update") {
    "Finishing updating process..."
    mv C:\mcdtemp\UpdateTemp\Paks\ "$install\Dungeons\Content\"
}

if(Test-Path -Path "$env:appdata\Vortex\plugins") 
{
    "Vortex Mod Manager detected, installing plugin..."
    Invoke-WebRequest -Uri "https://docs.dungeonsworkshop.net/extension/extension.zip" -OutFile "C:\mcdtemp\extension.zip"
    mkdir "$env:appdata\Vortex\plugins\game-minecraftdungeons"
    Expand-Archive -Path "C:\mcdtemp\extension.zip" -DestinationPath "$env:appdata\Vortex\plugins\game-minecraftdungeons"
} else {
    "Vortex Mod Manager not detected, skipping plugin installation!"
}

"Finished! Cleaning up..."
Remove-Item C:\mcdtemp -Force  -Recurse -ErrorAction SilentlyContinue

"To exit,press enter."
pause
exit
