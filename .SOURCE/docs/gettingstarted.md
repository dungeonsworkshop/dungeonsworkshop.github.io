**Make sure dungeons is not running while you try to install mods.**

=== "Windows Store" 
	<span style="color:gray">*Tutorial By LukeFZ*</span>  

	!!! Warning "Warnings"
		:no_entry_sign: **Bitdefender user will need to uninstall Bitdefender**  
		:warning: **Turn off any Antivirus Software as they will get triggered**  

		:warning: **Install this, it is required for the Script to work** 
		```
		https://aka.ms/vs/16/release/vc_redist.x64.exe
		```

	<h3>**Windows Store Installation**</h3>
	1. Click on the **Windows icon** in the bottom left and enter **powershell** then click run as admin  
	2. Run this command
	```
	Set-ExecutionPolicy -Scope Process Bypass;mkdir C:\mcdtemp; Invoke-WebRequest -Uri "https://cdn.discordapp.com/attachments/698979190942466148/719295049074081862/mcdungeon_winstore_install_v7_2.ps1" -OutFile C:\mcdtemp\winstore.ps1; C:\mcdtemp\winstore.ps1
	```
	3. It will ask you about **Execution Policy Change** just push **A** on the keyboard then Enter then Enter again  
	4. At a point you will be asked to select a folder. This is where the game files will be stored  
	5. A **~mods** folder will appear in the new installation directory under `dungeons/dungeons/Dungeons/Content/paks/~mods` this is where you place your mods  
	6. Click on the **Windows icon** in the bottom left and launch the **Minecraft dungeons [Modded]**

	!!! Note
		:warning: **Do not choose Program Files as the folder, it will break things.**  
		
		:warning: **When activating developer mode with the script it might be required to reboot. If you encounter an error, try to reboot and run the script again and see if that fixes the issue.**  
	

=== "Launcher"
	<span style="color:gray">*Tutorial From [Dokucraft](https://discord.gg/2MB8bRQ)*</span>  

	<h3>**Launcher Installation**</h3>
	1. Press **Win + R**, enter
	```
	%localappdata%\Mojang\products\dungeons\dungeons\Dungeons\Content\Paks
	```
	and press Ok  
	2. Make a new folder called **~mods** and put your mods in this folder **(Yes, with a ~)**  
	3. Launch the game through
	```
	%localappdata%\Mojang\products\dungeons\dungeons\Dungeons.exe
	``` 

	!!! Warning "Disclaimer"
		**Launching the game through the launcher will remove any mods you have**