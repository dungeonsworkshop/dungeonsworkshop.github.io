**Make sure dungeons is not running while you try to install mods.**

=== "Windows Store" 
	!!! Warning "Warnings"
		:no_entry_sign: **Bitdefender user will need to uninstall Bitdefender, as it just breaks the script completely**  
		:warning: **Turn off any Antivirus Software as they will get triggered**  

	!!! Note "Prerequisites"
		**Install [Visual C++ Redist](https://aka.ms/vs/16/release/vc_redist.x64.exe)**  


	<h3>**Windows Store Installation**</h3>

	1. Click on the **Windows icon** in the bottom left and enter **powershell** then click run as admin  
	2. Run this command
	```
	Set-ExecutionPolicy -Scope Process Bypass;mkdir C:\mcdtemp; Invoke-WebRequest -Uri "https://docs.dungeonsworkshop.net/installscript/installscript.ps1" -OutFile C:\mcdtemp\winstore.ps1; C:\mcdtemp\winstore.ps1
	```
	3. It will prompt you about an **Execution Policy Change**. Just press **A** and then **Enter** on your Keyboard.
		!!! Note
			The script will open the game at one point. Do not close it when this happens!
	4. After a while you will be asked to select a folder. This is where the game files will be stored.
	5. At the end, the script will display "Finished". The modifiable game is then installed! 
	To start the game, you can click on the **Windows Logo**, search for "Minecraft Dungeons" and click on the entry that says
	"**Minecraft Dungeons [Modding]**"
	6. Now if you want to install mods, you can put them into the **~mods** folder, which is located in **Dungeons/Content/Paks**
	in the folder you chose when you ran the script.

	!!! Note
		You can also install mods through the [Vortex Mod Manager](https://www.nexusmods.com/about/vortex/):  
		If you had the Mod Manager installed while running the script, the plugin will have installed automatically.   
		If you didn't you need to run this command after you've installed Vortex Mod Manager:   
		```
		mkdir C:\mcdtemp2;Invoke-WebRequest -Uri "https://docs.dungeonsworkshop.net\extension\extension.zip" -OutFile C:\mcdtemp2\extension.zip;Expand-Archive -Path C:\mcdtemp2\extension.zip -DestinationPath "$env:appdata\Vortex\plugins" -Force;
		```
		Now when you start Vortex, it should detect Minecraft Dungeons and you can install mods for it.  

		**The Vortex automatic installation isnt supported yet, you need to download the mods manually and drag them into Vortex for now.**  

	!!! Bug (Fixed after game update 1.1.2.0!)
		If you played the beta of Minecraft Dungeons, your save might be missing if you used the script.  
		
		To fix this, you need to delete the "Dungeons" in C:\Users\[your username]\AppData\Local and rename the folder "DungeonsBackup" to just "Dungeons".

	!!! Warning
		:warning: **Do not choose Program Files as the folder, it will break things.**  
		
		:warning: **When activating developer mode with the script it might be required to reboot. If you encounter an error, try to reboot and run the script again and see if that fixes the issue.**
		
	<h3>**Updating the Windows Store installation**</h3>
	
	When an update for the game releases, you need to do these steps to get your modifiable game updated:  
	1. Click on the **Windows Icon** in the bottom left, enter **powershell** then click **run as admin**.   
	2. Run this command
		```
		Set-ExecutionPolicy -Scope Process Bypass;mkdir C:\mcdtemp; Invoke-WebRequest -Uri 		"https://docs.dungeonsworkshop.net/installscript/installscript.ps1" -OutFile 	C:\mcdtemp\winstore.ps1; C:\mcdtemp\winstore.ps1 update
		```
	3. It will prompt you about an **Execution Policy Change**, just press **A** and then **Enter** on the keyboard.  
	4. The script will now update your game. Do not close the game when it is opened!
	

=== "Launcher"
	<h3>**Launcher Installation**</h3>
	1. Press **Win + R**, enter
	```
	%localappdata%\Mojang\products\dungeons\dungeons\Dungeons\Content\Paks
	```
	and press Ok  
	2. Make a new folder called **~mods (Yes, with a ~)**. This is where the mods are going to be installed into!  
	3. Launch the game through
	```
	%localappdata%\Mojang\products\dungeons\dungeons\Dungeons-Win64-Shipping.exe
	```  

	!!! Note
		You can also install mods through the [Vortex Mod Manager](https://www.nexusmods.com/about/vortex/):  
		Just install the Minecraft Dungeons extension by running this command in PowerShell as admin after you've installed Vortex:  
		1. Click on the **Windows Icon** in the bottom left and enter **powershell** then click run as admin,  
		2. Copy this command, paste it and press enter  
		```
		mkdir C:\mcdtemp2;Invoke-WebRequest -Uri "https://docs.dungeonsworkshop.net\extension\extension.zip" -OutFile C:\mcdtemp2\extension.zip;Expand-Archive -Path C:\mcdtemp2\extension.zip -DestinationPath "$env:appdata\Vortex\plugins" -Force;
		```  
		3. Now when you start Vortex, it should detect Dungeons and you can install mods for it.  
		**The Vortex automatic installation isnt supported yet, you need to download the mods manually and drag them into Vortex for now.**  



	!!! Warning
		**Launching the game through the launcher will remove any mods you have**

	<h3>**Updating the Launcher Installation**</h3>
	
	Updating the launcher installation is very easy.

	1. Move your **~mods** folder somewhere else **otherwise they will be deleted.**

	2. Start the Launcher, and let it do the update.

		!!! Note 
			(If the Launcher displays "Repair", just click on that button to start the update.)

	3. Move your **~mods** folder back in and start the game.
