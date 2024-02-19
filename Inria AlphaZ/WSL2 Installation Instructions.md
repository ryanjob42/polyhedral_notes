# WSL2 Installation Instructions
These instructions are how to install AlphaZ on Windows
using the Windows Subsystem for Linux v2 (WSL2).
The installation instructions are largely the same once your Linux distribution is set up,
with the possible exception of how you get the Eclipse tarball into your Linux file system.

* [Preparation](#preparation)
    * [Install a Distribution](#install-a-distribution)
    * [Verifying WSL2 Versions](#verifying-wsl2-versions)
* [Linux Setup](#linux-setup)
* [Getting the Eclipse Tarball into WSL2](#getting-the-eclipse-tarball-into-wsl2)
* [Creating a Shortcut on Windows](#creating-a-shortcut-on-windows)
* [Build and Install the Alpha-Language Package](#build-and-install-the-alpha-language-package)
* [Compiling GeCoS ISL](#compiling-gecos-isl)
* [Help for Graphics Issues](#help-for-graphics-issues)


## Preparation
First, you will need WSL2 and a distribution of Linux installed.
If you have one already, skip to the [Verifying WSL2 Versions](#verifying-wsl2-versions) section to make sure it is compatible.
Otherwise, proceed with the [Install a Distribution](#install-a-distribution) section.


### Install a Distribution
Everything here was tested with WSL2.
The official instructions can be found at the link below,
but will be summarized here for convenience.
Refer to the Microsoft link if you encounter any issues.

https://learn.microsoft.com/en-us/windows/wsl/install

As a prerequisite, you will need to be running either a sufficiently recent version of Windows 10
or any version of Windows 11 (the latest Windows version at the time of writing, newer versions will likely still be compatible).
A sufficiently new CPU is needed with sufficiently new graphics drivers.
At the time of writing, an 8th generation Intel CPU with integrated graphics is new enough.
Your CPU will need a virtualization technology (called "VT-x" for Intel CPUs) to run well,
although it's unclear whether this is a strict requirement.
A quick way to check this is to open the Task Manager, then under the "Performance > CPU" page,
check whether it says "Virtualization: Enabled".
Note: if your CPU is supposed to support virtualization but this says it's disabled,
you may need to enable it in your BIOS/UEFI settings.

The simplest way to install is through the Microsoft store.
You can simply search for "Windows Subsystem for Linux" and install that.
Then, you'll need to install an actual Linux distribution.
Ubuntu has been successfully tested, so we recommend that.
To create your Ubuntu instance, you may need to open the Ubuntu app.

To install from the command line instead, you should be able to run the following command.
This is supposed to install both WSL and a default distribution of Ubuntu, but has not been tested.

```bash
wsl --install
```

If you used the Microsoft store to install Ubuntu, you have two ways to open a terminal:
either launch the Ubuntu app from the start menu (to open a standalone terminal window)
or run `ubuntu` from the command line (to use your current terminal instance).

VS Code also has a convenient WSL extension,
which allows you to use the remote explorer to open inside the WSL2 instance.


### Verifying WSL2 Versions
In Windows, run the following command to check the version of WSL.
Make sure it's version 2.
These instructions most likely will not work on version 1.

```bash
wsl -v
```

If it's only version 1, you can update it using the command below.
If this fails, add the `--web-download` option.
Note: you may need to launch your terminal (PowerShell or cmd) as an admin.

```bash
wsl --update
```

Next, you need to ensure that your installed distribution is also using WSL2.
Do so with the command below, which prints a table.
Check that the "Version" is listed as 2.

```bash
wsl -l -v
```

If your distribution is version 1, you should be able to update it with the command below,
replacing `<distro>` with the name of the distribution to update (per the output of the previous command).
Note: this has not been tested to ensure it works as expected.
If it fails, you may need to install a fresh distribution.

```bash
wsl --set-version <distro> 2
```

Finally, in your Linux terminal, make sure the `/mnt/wslg` directory exists.
You can do this by running the command below and verifying that it's present.
If it's not, you may need to update your graphics drivers.

```bash
ls /mnt
```


## Linux Setup
Next, you need to install some packages in Linux to get everything working.
Run the commands below (in Linux) to do so.
Enter the root password and accept the installs as needed.
Note: if you're not using a Ubuntu distribution, you may need to use a different package manager,
which may have different names for these packages.

```bash
sudo apt update
sudo apt upgrade
sudo apt install openjdk-11-jre libwebkit2gtk-4.0-37 adwaita-icon-theme-full
```

Note: if you're working with the CSU AlphaZ version, you will also need to install `openjdk-8-jre`.

Note 2: the last package, `adwaita-icon-theme-full`, is just to install cursors.
It is not strictly necessary.

Sidebar: while using AlphaZ this way, an error was reported by Eclipse
stating that it didn't have access to `/dev/dr/renderD128`.
No negative effects were found due to this, but the following command fixes it:

```bash
sudo usermod -a -G render $USER
```

To make sure everything is installed and configured correctly,
restart the Linux system.
Simply exit the Linux terminal, then in Windows, run the command below to shut down Linux.
Then, you can launch Linux again.

```bash
wsl --shutdown
```

If you want to have minimize and maximize buttons, you'll also need to set a configuration.
Just run the command below to do so.
Note: move the colon to the end if you want the buttons on the left,
and you can reorder the buttons as well.

```bash
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
```


## Getting the Eclipse Tarball into WSL2
If you don't want to try using `wget` to download the Eclipse tarball,
you can download it into Windows first.
Then, from Ubuntu, you can copy the file.
Your Windows drives are mounted in the `/mnt` folder.
Either way, make sure you get the Linux version.

Note: some sources indicate that moving files into WSL from Windows is not recommended,
and can cause issues with the virtual machines,
so it's highly recommended you copy it from WSL this way.

For example, let's say I downloaded the file on Windows as `C:\Users\username\Downloads\eclipse.tar.gz`.
From WSL, I'd run `cp /mnt/c/Users/username/Downloads/eclipse.tar.gz .` to copy it to the current directory.


## Creating a Shortcut on Windows
If you want, you can create a shortcut so you can just launch Eclipse without needing a terminal.
Just right-click somewhere in Windows and select "New > Shortcut".
For the command to run, put in the following (fixing the path to Eclipse).

```
"C:\Program Files\WSL\wslg.exe" /home/username/eclipse/eclipse
```


## Build and Install the Alpha-Language Package
These instructions are only necessary if Eclipse reports that it can't find the "alpha-language" plugin
when following the main installation instructions.
Make sure you've tried that first before following these instructions.
Also note that you may need to periodically build the Maven package and update it.

You will need to install Maven inside your Linux distribution.
This may be available via the package manager, so you can simply run the command below.
If it's not available that way, follow the official install instructions: https://maven.apache.org/install.html

```bash
sudo apt install maven
```

Next, navigate into the alpha-language repo and run the command below.
This will build the plugin, which takes a few minutes.

```bash
mvn package
```

In Eclipse, go to "Help > Install New Software".
Click "Manage", then "Add", then "Local".
Navigate to the alpha-language repo, then to `releng\alpha.language.update\target\repository\`.
Click "Select Folder".
Set the name to "Local Alpha Plugin", click "Add", then "Apply and Close".

In the "Work with" drop-down menu, select what you just added ("Local Alpha Plugin" if you used the name above).
Select the "Alpha > Alpha Language" software, then click "Next".
Once it loads, click the new "Next" button, accept the license agreement, and click "Finish".

Wait for the "Trust" window to appear, then hit "Select All" and "Trust Selected".
Wait for the software to install, then when the window appears, let Eclipse restart now.


## Compiling GeCoS ISL
When trying to build the GeCoS-Tools-ISL repo on WSL2, a few extra packages needed to be installed.
You can install them with the following command:

```bash
sudo apt install make gcc m4 autoconf libtool openjdk-11-jdk patchelf
```

Optionally: if you want to avoid updating the makefiles to fix the Java home path,
you can run the following command to make a soft link from where the makefile expects it
to your actual install location.
The command below worked at the time of writing,
where the first path (with the "amd64") is the actual install location,
and the second path is the one that the makefiles expect.

```bash
sudo ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-11-openjdk
```

Side note: on Ubuntu, you may also want to install `sudo apt install build-essential`,
which has some additional compilation tools.
They were not necessary at the time of writing, though.


## Known Issues
As of 19-Feb-2024, menus can go off the screen (especially the right-click menu).
If you really want it working correctly, then add `export GDK_BACKEND=x11` to your .bashrc and .profile files.
(the first is needed if you launch Eclipse from a terminal, the other is needed if you're not).
The window doesn't look as nice, and has issues when dragging & dropping tabs around, so use at your own discresion.
For future reference, here's a link to a GitHub issue on this.
If you're reading this please check the link and see if the issue has been fixed.
If fixed, please update these instructions (or contact someone who can).

https://github.com/microsoft/wslg/issues/584


## Help for Graphics Issues
At the time of writing, the Eclipse instance was running without graphical issues.
If you have issues, the first step is to try restarting the Linux distribution.
Simply exit any programs/terminals, run the following command in Windows, then try launching Eclipse again:

```bash
wsl --shutdown
```

If that doesn't work, try the following:

* Restart your Windows machine.
    * Note: make sure you do a "Restart" and not a "Shut down", as a standard shut down may save much of the system state to disk, then reload it on startup (which is especially common on laptops).
* Make sure the Windows OS is up to date.
* Make sure your graphics drivers are up to date.

If you're still experiencing graphics issues after the above suggestions,
there are some Linux packages you might try installing.
They weren't necessary at the time of writing, but while determining how to install everything correctly,
they were found as suggestions on various forums.
It is recommended you install them one at a time, restarting the Linux instance and testing Eclipse between each.

```bash
sudo apt install libswt-gtk-4-jni
```
