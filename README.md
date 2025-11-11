# etqw-mod-template
A default template for creating a new mod for ETQW.

## Setup
Here's how to setup your workspace for building an ETQW mod:

1. Create a new repository using this template.
    - This repository is a template repository.
    - In GitHub, click to "Use this template" and select "Create a new repository".
    - Give the repository a new name based on the name of your mod.
    - Set who should have access.

1. Install Visual Studio 2005 Express Edition ISO. (Disk space required 470 MB)
    - Mount the ISO.
    - Run setup.exe.
    - For installation options:
        - Enable "Graphical IDE".
        - Disable "Microsoft MSDN 2005 Express Edition" and "Microsoft SQL Server 2005 Express Edition x64".

1. Open Visual Studio 2005 Express Edition.
    - Default install location is: C:\Program Files (x86)\Microsoft Visual Studio 8\Common7\IDE\VCExpress.exe
    - File > Open > Project/Solution.
    - Browse to and open the etqw_sdk.sln.

1. Install the Windows SDK (formerly known as the Platform SDK)
When I try building the solution, I get error related to missing windows.h file.
Visual Studio 2005 Express is compatible with the Windows Server 2003 R2 Platform SDK
    - Disk space required 952 MB
    - Close Visual Studio 2005 Express if it's open.
    - Mount the ISO.
    - Run Setup.exe.
    - Agree to the license.
    - The etqw_sdk.sln file expects the PlatformSDK to be installed to the same place as $(VCInstallDir).  You don't have to do this but you may need to do an extra step below after installation.
    - Remove name and organization fields.
    - Choose Custom installation.
    - Use default options and finish installation.

1. Open Visual Studio 2005 Express Edition.
    - If you get the error - "The proper type library could not be found in the system registry.  An attempt..."  Just close the program and try running the program once as an Administrator.

1. Only do this if you did not install the Platform SDK to $(VCInstallDir).
    - In Visual Studio 2005 navigate to Tools > Options...
    - Expand Projects and Solutions and select "VC++ Directories".
    - Make sure to set the dropdown "Show directories for:" to "Include files".
    - Click New Line button to add another directory to the listing.
    - Navigate to where you installed the Platform SDK (default is C:\Program Files\Microsoft Platform SDK\Include). Click "Open".
    - Click "OK".
    - You may need to restart Visual Studio 2005.

1. Install ETQW game + SDK.
    - If installing ETQW game using ETQW CM you will also need to install Microsoft Visual C++ Redistributables in order for the ETQW SDK to work.
    - Through windows add 2 environment variables:
        - Add "ETQW_RETAIL_DIR" that points to where your retail game is installed.  This folder should contain etqw.exe.
            
            Note: This is used to set the Working Directory in Visual Studio for running a configuration for the "game" project.  Without a working directory set, there will be an fs.chk error preventing etqw.exe of the SDK from launching.
        - Add "ETQW_SDK_DIR" that points to where your "SDK 1.5" folder is located.

            Note: This is important later during a Post Build Event.  
        
        - Make sure to restart Visual Studio if you had it open, otherwise the newly added environmental variables can't be seen.

## Building/Configurations

### Building on Windows:
There are several building configurations already setup in Visual Studio that you can use for the "game" project.

#### Debug with edit and continue
Disables all optimizations and enables Edit and Continue so that code can be modified and the changes applied without restarting the game. Some operations like compiling scripts will take noticeably longer in this mode.

Since ETQW is a closed-source game, you don’t have access to the source code for etqw.exe, which means you must build your mod’s gamex86.dll with debug symbols (.pdb) in order to:
- Step through your own mod code,
- Set breakpoints that work,
- Inspect variables and call stacks in Visual Studio.

What is happening:
- etqw.exe loads your gamex86.dll at runtime using dynamic linking.
- As long as your DLL has been built in Debug mode (with .pdb), and you:
    - Place the DLL in the correct mod folder,
    - Launch the game with +set fs_game yourmodname,
    - Attach Visual Studio to the running etqw.exe process,
- Visual Studio can hook into your mod code, even though the EXE is a black box.


Run the "Debug with edit and continue" configuration in Visual Studio. A popup appears saying:

    Please specify the name of the executable file to be used for the debug session.

Set "Executable file name" by clicking "Browse..." and selecting etqw.exe inside the SDK 1.5 folder.

Another popup will appear saying:

    Debugging information for 'etqw.exe' cannot be found or does not match.  No symbols loaded.

    Do you want to continue debugging?

Click "YES" because we will still have debugging info for the gamex86.dll.

A popup will occur saying "Couldn't load fs.chk.".

To fix this you need to right-click on your game project in the Solution Explorer, choose Properties, then Debugging, and set the Working Directory for all configurations to point to the game’s folder.

Also set Configuration Properties > Debugging> Command Arguments for all Configurations to: `+set r_fullscreen 0` this way when debugging and it stops at a breakpoint it isn't fullscreen preventing you from interacting with you Desktop.


Need to test this but I think you can debug your mod in game with breakpoints.  You will likely have to attach a process (etqw.exe) in Visual Studio and set a command line arg (developer 1).

When building the mod a gamex86.dll and a gamex86.pdb is created.  The .pdb file is a Symbols file used for storing debugging information.  You may need to tell Visual Studio where this file is since the gamex86.dll will likely be moved into the mod folder where the game can see it.

- Build the mod.
- Copy the gamex86.dll file to the ETQW/mod_name folder where mod_name is your mod's name.
- Launch etqw.exe.
- Attach Visual Studio to etqw.exe by going to Debug > Attach to Process and selecting etqw.exe from the list.
- Set breakpoints in your code.

If Visual Studio can't find the .pdb file you may need to configure the symbol file path. In Visual Studio go to Tools > Options > Debugging > Symbols and at the path.

#### Debug with inlines
TODO

#### Release
This is used to create a release of your mod that others can use.
(I'm not sure if this is 100% true but in order to allow someone else to run your mod, you must build it with this configuration otherwise they may get an error "Couldn't load game dynamic library".)

### Building on Mac:
Need a mac that supports 32-bit.
Need to use XCode and launch the project.

### Building on Linux:
Have to use SConstruct file somehow to create a build.

## Running
Choose a configuration and run it.
You may need to update "game" project properties. Go to Configuration Properties > Debugging > Working Directory.  Set it to: $(ETQW_RETAIL_DIR) 

## Packaging
Typically you will build the mod dynamic library for Windows, MacOS, AND Linux first.  Game clients download only the os-specific game00#.pk4 that they need for the compiled mod.  Other pk4s that the client needs which contain assets and other things will be downloaded as well.

### Manual Packaging
1. Create OS-specific pk4s.
    1. Create an empty folder called game###.  Where ### is either 000 (for Windows), 001 (for Mac OS), or 002 (for Linux).
    1. Create a binary.conf file.
        - Create a text file named binary.conf in game###.
        - In a text editor, type a number based on which OS this pk4 is being build for:
            - Windows: 0
            - Mac: 1
            - Linux: 2
        - Save the file.
    1. Add the compiled libary to game###
        - Windows: gamex86.dll
        - Mac: gamex86.dylib
        - Linux: gamex86.so
    1. Create the pk4 by zipping up all contents of game### and naming the file game###.pk4.
        - The following names are recommended: game000.pk4 (Windows), game001.pk4 (Mac), game002.pk4 (Linux)
1. Zip all other mod assets, textures, models, etc that are not os-specific into separate pk4 files.  These pk4 files are typically named something like mod_name000.pk4, mod_name001.pk4.

## Installation
In order to be able to use a mod, the following files must be present in mod_name folder in fs_savepath:
- Os-specific gamex86 library file packaged into a pk4.
    If you don't have this packaged into a pk4, the mod won't appear in the mod list.
- Other mod-specific pk4 files
- description.txt (Optional, but recommended for a pretty name)

### Manual installation
- Create a new folder on the client in fs_savepath.
- Download the pk4 files (os-specific mod files + mod assets) to the new mod_name folder on the client.
- At some point the os-specific mod (dynamically loadable library) is extracted out of game###.pk4 and placed directly into the mod_name folder.  This is what's actually needed to run the mod.

#### SDK notes
If you are trying to test your mod in the ETQW SDK, there are several files missing in the SDK (that are present in the released game) that will prevent the mod from loading.  For convenience these files are included in the def and models folders.  I think you can just copy the contents of these folder into the respective folders of the SDK.

The ETQW executable (opened using F2 from editWorld) that the ETQW SDK provides can be used to load your mod (with a bit of work).  The ETQW executable of the SDK always loads gamex86.dll from the same location where etqw.exe is located. Trying to set fs_game will not work!  A post-build script was setup to automatically copy the compiled mod to this file.  The original gamex86.dll is renamed and appended with the text .orig.  This way the developer can always switch it back if they'd like.  If working on multiple mods, it's necessary to install multiple versions of the SDK in different locations.  If working on custom maps (that work across all mods) a single SDK is needed and should be using the provided unmodified gamex86.dll.

When using etqw.exe of the SDK, and creating a build using the debug configuration you will receive an error about using the wrong API version.  This error is not present when using the retail game etqw.exe.  I believe this is because the retail etqw only ever talks to the public API.  Whereas the SDK's etqw.exe was built by Splash Damage from their internal tree, so its default is to expect internal build numbers.  BackSnip3 posted on the Splash Damage the fix for this, which is to define SD_PUBLIC_BUILD and also SD_PUBLIC_TOOLS in 'source/framework/BuildDefines.inc'.  This has already been done in this template, but was worth noting.

### Automatic installation
If the mod is hosted on a server, the client just needs to connect to the server and accept downloading mod content.  This will perform the manual installation steps.

## Next Steps
1. Update the description.txt file. This file is used to
    - Display a mod in the ETQW SDK Launcher dropdown.  It sets part of the text that's shown in the dropdown

    - Set a pretty name for the in-game mod list.  

        This file must be directly in the mod_name folder on the ETQW client.  It can not be inside of any pk4s.  Also if you don't specify a pretty name, the name of the mod folder is used instead.  One downside to how things were implemented is that when a client connects to a server, they only download pk4s so the pretty name will only show if the user manually creates this file themselves.
        
        Note: Using etqw.org and the ETQW CM, it's possible to deploy this file to ETQW clients since downloads happen outside of the game.

1. It is suggested that you set GAME_VERSION to the name of your mod.
    - Open the solution in Visual Studio 2005.
    - Expand project 'game' and navigate to Game > Header Files > Game_local.h.  This file is located at /game/Game_local.h.
    - Edit the value for line '#define GAME_VERSION' to use the name of your mod.

1. If you are going to be storing large binary files such as 3d models, animations, sounds, etc... into your repository, you should consider tracking these files differently by using git large-file-system (git lfs).
