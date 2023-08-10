# Adding ISL JNI Bindings
This document describes how to add bindings for ISL functions to the JNI bindings.

* [Preparation](#preparation)
* [Install PatchELF](#install-patchelf)
* [Clone the GeCoS ISL Tools Repository](#clone-the-gecos-isl-tools-repository)
* [Fix the GeCoS ISL Tools Java Home Path](#fix-the-gecos-isl-tools-java-home-path)
* [Compile the GeCoS ISL Tools](#compile-the-gecos-isl-tools)
* [Test That Everything Works So Far](#test-that-everything-works-so-far)
* [Export the ISL Function If Necessary](#export-the-isl-function-if-necessary)
* [Preserve the Existing Bindings](#preserve-the-existing-bindings)
* [Update the JNI Map File](#update-the-jni-map-file)
* [Generate the New JNI Mapping](#generate-the-new-jni-mapping)
* [Fix the `src-gen` Directory](#fix-the-src-gen-directory)
* [Fix the C Files and Makefiles](#fix-the-c-files-and-makefiles)
* [Double Check Changed Files](#double-check-changed-files)
* [Recompile the GeCoS ISL Tools](#recompile-the-gecos-isl-tools)
* [Load the New Bindings](#load-the-new-bindings)
* [Test the New Bindings](#test-the-new-bindings)
* [How to Fix `UnsatisfiedLinkError`](#how-to-fix-unsatisfiedlinkerror)

## Preparation
Before doing any of this, you should have a working version of Eclipse already set up.
I'm using the version of Eclipse for the Inria AlphaZ compiler.

If you've done these steps before, I recommend removing the
GeCoS ISL Tools projects from Eclipse.
It may not be necessary, but it was giving me some issues at the time of writing (11-Jul-2023).
To do this, right-click the project, select "Delete",
check the box to delete the nested projects (if applicable),
make sure the box for deleting the contents on disk is NOT selected, then click OK.
If there's a warning saying that resources aren't in sync, you can press "Continue".

You may also want to move the repository somewhere else and start these steps from scratch.
Reusing a repository was also giving me some issues at the time of writing (11-Jul-2023).
I don't recommend deleting it right away though,
just in case you have some other bindings you've added previously and still need.
This way, you can easily copy them back in.

## Install PatchELF
As of 11-Jul-2023, several of the Makefiles in this repository run the `patchelf` command,
which is not installed on the CSU machines by default.
If you're following these instructions at a significantly later date,
you should check whether this is still the case.
To do so, I'd recommend searching the entire directory for "patchelf".
If you don't find it, you can skip this step.
Otherwise, follow this step to get a copy of it.

At the time of writing, the main branch did not compile correctly on the CSU Linux machines.
After playing around with different releases, I found that version 0.17.2 worked properly.
This version is hard-coded into the script below.
The best way to see if it is working is to look at the output from the `make check`
and see whether there are any failures or not.
The "set-rpath" command looks like the only one we use, so make sure that works.
If the test fails for you, try a different release.
All the releases can be found at this page:
https://github.com/NixOS/patchelf/releases.

You will also need to make the PatchELF executable visible from
your `PATH` environment variable.
By default, the CSU linux machines have the directory `~/bin/` in the path,
so this is where I chose to put the executable.

The script below will clone the PatchELF repository to `~/projects/patchelf/`,
compile everything, and copy the executable to your `~/bin/` folder.

```bash
git clone -b 0.17.2 git@github.com:NixOS/patchelf.git "$HOME/projects/patchelf/"
cd "$HOME/patchelf"
./bootstrap.sh
./configure
make
make check
cp "$HOME/projects/patchelf/src/patchelf" "$HOME/bin/patchelf"
```

To test that this worked, run the commands below.
It should print the version number from the Git command you used.
The script above installs version 0.17.2.
Note: the `cd` command here is to make sure you're not still in the directory
where the PatchELF executable is found.

```bash
cd; patchelf --version
```

If this didn't work, it is likely because the `~/bin/` folder is not registered
as part of your `PATH` environment variable.
To check this, run `printenv PATH` and look for that folder.
If it's not there, you can use the script below to update your ".bashrc" file
to add it to your PATH.
After doing this, 

```bash
echo 'export PATH="${HOME}/bin:${PATH}"' >> $HOME/.bashrc
source $HOME/.bashrc
```

## Clone the GeCoS ISL Tools Repository
The GeCoS ISL Tools repository contains the Java bindings for ISL functions.
Currently, this is controlled by Inria.
The repository can be found on GitLab at:
https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-isl/

As of 11-Jul-2023, the master branch is not the one we want to use.
Instead, we want the `isl-binding-updates` branch.
You can use the command below to clone the correct branch
(without needing to manually check it out after cloning).
Additionally, some of the makefiles have hard-coded paths
(relative to your home directory), so it needs to be cloned
into the `$HOME/projects/GeCoS/Tools/` directory.
The command below also includes this.

```bash
git clone -b isl-binding-updates https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-isl.git "$HOME/projects/GeCoS/Tools/gecos-tools-isl/"
```

## Fix the GeCoS ISL Tools Java Home Path
The compilation requires Java 11.
If you don't have it, please install it.

The GeCoS ISL Tools makefiles have a hardcoded Java Home path.
In the various `native/build/` folders, there is a folder for the various supported
operating systems you can build for.
Inside each of these folders is a `user.mk` file, which is where the Java Home is set.
Check the appropriate file for your system and see if the specified Java Home directory exists.
If it does, you may skip the rest of this step.

If the path doesn't exist, find an appropriate version of Java 11.
It will likely be in nearly the same folder.
You will want to update all the appropriate `user.mk` files to point to this directory.

As of 11-Jul-2023, the OpenJDK Java 11 path you should use is `/usr/lib/jvm/java-11-openjdk/`.
The command below will automatically update the `user.mk` file for ISL with this path.

```bash
sed -i "s;JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/;JAVA_HOME=/usr/lib/jvm/java-11-openjdk/;" "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/Linux_64/user.mk"
```

## Compile the GeCoS ISL Tools
Compiling the GeCoS ISL Tools was an error-prone process
when initially writing these instructions (11-Jul-2023).
Therefore, it's recommended to compile and test this before making any changes.
There is a convenient script in the repository (`scripts/compile_native_bindings.sh`)
which compiles everything, including the ISL, Barvinok, and Polylib bindings.
However, at the time of writing, this failed at the Barvinok bindings,
causing issues with the entire process.
I did not need the Barvinok or Polylib bindings, so I did not attempt to fix them.
Instead, I manually compiled the ISL portion and stopped there.

The commands below will compile all of the ISL bindings.
The final call to `make` may return some warnings, but this is OK.
I recommend you check the output to make sure there were no errors, though.
The `rm` command at the end deletes the copy of the ISL repository which was cloned,
as it is no longer needed.
I recommend you do not skip this, as it can cause issues depending on the steps
you need to follow for updating the Java bindings.

```bash
cd "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/gmp"
make
cd ../isl
make
cd ..
make
rm -rf "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/isl/"
```

If you need the Barvinok or Polylib bindings,
I recommend looking at the `compile_native_bindngs.sh` script to figure out how to do this.
You may need to debug the build process in this case.

## Test That Everything Works So Far
Before we start modifying the bindings, let's test that everything is working.

The first step is to import the ISL Java bindings project into Eclipse.

1. Open Eclipse.
2. Select "File > Import".
3. In the Import Wizard, select "General > Projects from Folder or Archive" and click "Next".
4. To the right of the "Import source" textbox, click the "Directory" button.
5. In the file picker window, navigate to the repository and click "Open".
   1. The repository should be at `~/projects/GeCoS/Tools/gecos-tools-isl/` if you've been following along.
6. Click the "Deselect All" button on the right.
7. Select only the `gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl` project.
   1. Note: if you are modifying the Barvinok or PolyLib bindings, you'll want to import those projects instead.
8. Click "Finish" to complete the import.
9. Wait for the project to finish building.
   1.  In my version of Eclipse, the progress indicator is on the bottom-right corner of the screen. Double-clicking this brings up a window with more details.
10. Make sure there are no compilation errors.

Once this is done, you'll want to test that everything is working.
You can do this however you want, but the steps below are how I did it.

1. In Eclipse's Project Explorer, find any of the "alpha-language" packages.
   1. I chose `alpha-language/bundles/alpha.model/src/alpha.model`.
2. Right-click the package and select "New > Xtend Class".
3. Name the file anything you want (I chose "TestFile").
4. Select the option to create the `main` method.
5. Click "Finish".
6. Write some code to call into ISL in any way you want.
   1. The code below is what I used.
7. In the Project Explorer window, find the file you created.
8. Right-click the file and select "Run As > Java Application".
9. Check to see that the console output is what you expect.
10. If the test succeeds, feel free to delete this test file.
    1.  You may want to keep it for more testing after modifying the bindings.

```Xtend
package alpha.model

import fr.irisa.cairn.jnimap.isl.ISLBasicSet
import fr.irisa.cairn.jnimap.isl.ISLContext

class TestFile {
	def static void main(String[] args) {
		val mySet = ISLBasicSet.buildFromString(ISLContext.instance, "{ [i]: 0 <= i <= 5 }")
		println(mySet.toString())
		// Should output "{ [i] : 0 <= i <= 5 }" to the console.
	}
}
```

When initially writing this document, I was getting errors saying:
"ELF load command address/offset not properly aligned".
This ended up being due to the version of PatchELF I was using.
If you get this issue, go back to the [Installing PatchElf](#installing-patchelf) section
and try different releases until this works.

## Export the ISL Function If Necessary
You'll first want to identify what methods you want added.
To do this, you'll want to look at the ISL source code that the bindings are based off of.
The repository and version being checked out by the build script are specified in the file
`bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/versions.mk`.
To look through the code, you can either clone the repo yourself and checkout that commit/tag,
or go to the online version of the Git repo (https://repo.or.cz/isl.git)
and search for the commit/tag being checked out.

After determining which functions you want to add to the bindings,
find their signatures in the header files (under the `include/isl` folder).
You may notice that may notice that many function signatures in these files
have a line above them which says `__isl_export`.
This line indicates that the function should be exported by the object files for use.
If all the functions you want to use have this line, you can skip to the next step.

Note: some files, like `mat.h`, don't use `__isl_export` at all,
yet they still seem to work correctly.
I'm not sure how this happens, so if none of the functions in the file have this,
but there are Java bindings for these functions, you can probably skip this step.

If any function you want to use does not have an `__isl_export` line above it,
you will need to make changes to the GeCoS ISL Tools makefile.
You should not attempt to modify ISL directly, as this would only work for you,
and not for others who are attempting to use your code.
Instead, make changes to `bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/Makefile`.
Find the line of code which runs `git submodule init` (line 23 at the time of writing).
Prior to this line, add a command like the one below to modify the appropriate
header file and add the `__isl_export` before it.
The line of code below is an example I used for updating the `set.h` file
to export the function `isl_basic_set_is_bounded`.

```bash
sed -i '/isl_basic_set_is_bounded/i __isl_export' isl/include/isl/set.h
```

If you made any changes here, you will need to recompile the GeCoS ISL Tools.
The process is the same as before, but you can skip the build of GMP if you want.
See: [Compile the GeCoS ISL Tools](#compile-the-gecos-isl-tools).
Look carefully for compile errors being thrown during these steps.

## Preserve the Existing Bindings
The tool that generates the Java bindings for ISL does not work correctly.
Instead of trying to fix all the issues with the generated code (or the tool itself),
it's easier to preserve the original bindings, generate new ones,
update the original ones, then swap the files around.

First, close Eclipse if it's still open.
Do not re-open Eclipse until instructed to do so.
Then, run the commands below to preserve the existing bindings.

```bash
mv "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/src-gen/" "$HOME/projects/GeCoS/Tools/"

cp -r "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/" "$HOME/projects/GeCoS/Tools/"
```

The `src-gen` folder contains all the Java code that gets called to invoke the bindings.
If the current contents of the folder are present, they cause issues, so it is best
to move everything out and let Eclipse recreate it.

The `native` folder contains many C files that are necessary for the JNI bindings to work.
The `build` subfolder is required for everything to work,
and having the C files present doesn't cause issues,
so this folder can just be copied.

## Update the JNI Map File
The JNI Map file specifies which functions are to be added to the Java bindings
and how they should be written.
The map file is `bundles/fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`.
Open this file in an editor that isn't Eclipse (e.g., VS Code).

Partway through the file, you will see a variety of "groups".
Each group represents a Java class (and is named the same as the Java class).
Find the appropriate groups you want to add the bindings to.

Each binding is specified in two parts.
The first is a set of attributes that specify how the Java method is to be written.
The second is the signature of the method being bound to.
In general, you should be able to follow the format of similar bindings
to create your new bindings.

The table below lists a handful of commonly used attributes.
It appears that there is a strict ordering (although I'm not 100% sure),
so I recommend following the ordering laid out by other bindings.
To get more information about the binding attributes,
go to the following link and search for "Method :" (with a space).

https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-jnimapper/-/blob/master/bundles/fr.irisa.cairn.jnimap/src/fr/irisa/cairn/JniMap.xtext

| JNI Map Attribute | Description                                                                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| static            | Generates a `static` method. By default, all generated methods are instance methods.                                                  |
| private           | Generates a `private` method. By default, all generated methods are public.                                                           |
| protected         | Generates a `protected` method. By default, all generated methods are public.                                                         |
| rename=newName    | The generated method will have whatever name you specify on the right-hand side of the equals ("newName" in the example on the left). |

Copy the method signature from the appropriate ISL header file.
Then, go through the following list of changes and make all the changes that apply.
The list might not be comprehensive, so look at similar bindings for guidance.

1. Remove any newlines so the signature is all on one line.
2. In the function's return type:
   1. Remove the `__isl_give` annotation.
   2. Replace `isl_bool` with `boolean`.
3. In the function's arguments:
   1. Replace `__isl_give` with `give`
   2. Replace `__isl_take` with `take`
   3. Replace `__isl_keep` with `keep`

## Generate the New JNI Mapping
We are now ready to have Eclipse generate the new ISL Java bindings.

1. Open Eclipse again.
2. In the Project Explorer, find the JNI map file.
   1. `fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`
3. Right-click the file and select "Generate JNI Mapping".
4. Allow Eclipse to finish building the code before continuing.
   1. You should see the progress in the bottom-right corner of the screen.
   2. Double-clicking the indicator will show a screen with more details.
5. Ignore the compilation errors for now.
6. Close Eclipse.

## Fix the `src-gen` Directory
Now that the methods for the new Java bindings have been created,
they can be copied from the new `src-gen` folder into the original one.
This is easier than trying to fix all the errors in the new one.
For all modifications made here, do not use (or even open) Eclipse.
Use another editor, such as VS Code.

The first file we want to get changes from is `ISLNative.java`.
Many lines will likely be chagned here, but we only want to keep the new lines
for the added ISL functions we want to use.
You can use the command below to view all the changes to the file.
Copy these lines to the original version of the file that's outside the repository.
There should be a single line added per ISL function you added.

```bash
git diff bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/ISLNative.java
```

After that, you will want to do the same to the Java classes
which are supposed to contain these functions.
For example, I was adding the `isl_mat_concat` function (which concatenates two matrices).
Since I put this function in the `ISLMatrix` group,
the method was added to the `ISLMatrix.java` file.
You can use `git diff` again to find the changes to the files you wanted updated,
then copy those changes to the copied version of that file that's outside the repository.

Finally, the two `src-gen` directories need to be swapped.
The commands below will move the newly-generated `src-gen` directory to outside the repo,
then copy the original `src-gen` directory (with the edits) back into the repo.
Note: I chose to copy the directory instead of moving it
in case something goes wrong and we need to revert to that version again.
We won't delete the newly-generated one until after the new bindings have been tested.
These commands assume that your terminal are in the root of the repo
and that you made the initial copy of the `src-gen` folder in the same spot as I did.

```bash
mv bundles/fr.irisa.cairn.jnimap.isl/src-gen/ ../src-gen-newer
cp -r ../src-gen bundles/fr.irisa.cairn.jnimap.isl/
```

## Fix the C Files and Makefiles
Now that the `src-gen` directory should be correct, there are a few other files to fix.
Navigate to the `bundles/fr.irisa.cairn.jnimap.isl/native` directory,
then use the `git status` command.
Look for any C files in this directory.
Any Java classes you've added methods to should have a similarly-named C file
which has been modified to include the functions you added to the JNI map.
Make sure that other parts of such files are not modified negatively.
If there are other files which were modified but shouldn't have been,
use `git restore` to reset the file to what it was before.

In the `native` folder, some of the makefiles may also have been changed.
Use `git status` and `git diff` again to look at the changes.
If there are any changes to the files, aside from fixing the `JAVA_HOME` path,
either use `git restore` or manually edit the files to put them back how they were.

## Double Check Changed Files
Before continuing to the next step, I recommend navigating to the root of the repo
and running the `git status` command one last time.
The list below indicates all of the files which are expected to be changed.
If there are other files that have been changed,
or if a file that was supposed to change hasn't been changed,
you will want to investigate this so you don't encounter errors later on.

- `bundles/fr.irisa.cairn.jnimap.isl/lib/ISL_linux_64/libgmp.so.10`
- `bundles/fr.irisa.cairn.jnimap.isl/lib/ISL_linux_64/libisl.so.22`
- `bundles/fr.irisa.cairn.jnimap.isl/lib/linux_64_libjniisl.so`
- `bundles/fr.irisa.cairn.jnimap.isl/native/build/Linux_64/user.mk` (if you needed to change it)
- `bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/ISLNative.java`
- `bundles/fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`
- The C files in the below directory that is associated with the Java classes you've added bindings to.
  - `bundles/fr.irisa.cairn.jnimap.isl/native/`
- The Java files in the below directory that you've added bindings to.
  - `bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/`

## Recompile the GeCoS ISL Tools
Recompile the GeCoS ISL Tools repository using the same steps as before.
See: [Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools).
Look carefully for compile errors being thrown during these steps.

After recompiling, you may want to triple-check `git status` one last time
for any files which have changed that shouldn't have been.
It's easier to catch and fix these issues now before opening up Eclipse again,
as Eclipse may try to automatically change some files again.

## Load the New Bindings
Finally, we need to test the newly added bindings.
Open up Eclipse again.
A build may start up automatically.
If so, wait for it to finish.

Some of the Java files may be missing in the Project Explorer window.
To force Eclipse to find these files, find the `fr.irisa.cair.jnimap.isl/src-gen` folder,
right-click it, and select "Refresh".
Then, do the same to all packages within the `src-gen` folder.
At the time of writing (11-Jul-2023), there should be two:
`fr.irisa.cairn.jnimap.isl` and `fr.irisa.cairn.jnimap.isl.platform`.

Now that all the files are present, go to the menu bar and select "Project > Clean".
Select the option to clean all projects.
If applicable, also select the option to build all projects after cleaning.
A build should then start (manually start one if it does not).
Wait for this to finish.

Check to see if there were any errors in the compilation.
If there are, make sure that everything was copied over correctly and that no files are missing.
If files appear to be missing from Eclipse, but they're actually present in the file system,
you may need to refresh other folders or packages.

If there are errors indicating that methods are being called with the wrong signature
or that the method is undefined, check whether the method is actually present or not.
If it's not actually present, you may have forgotten to copy something over.
Go back to the copy of the newly-generated `src-gen` directory
(see [Fix the JNI Mapping](#fix-the-jni-mapping)) and try to retrieve the signatures.
If you've made changes to the bindings before and followed the suggestion
in the [Preparation](#preparation) section to move the repo and start over,
you may need to pull changes from there.

If there are still errors about incorrect or undefined method signatures,
for each file with errors, make a small change to the file (e.g., add a space somewhere),
save the file, undo your change, and save the file again.
This seems to force Eclipse to re-analyze the file,
and should hopefully fix the issue.

## Test the New Bindings
Finally, try using all of the new bindings.
I recommend using the test file from the 
[Test That Everything Works So Far](#test-that-everything-works-so-far) section.
Simply make a call to the newly added bindings (one at a time)
and print something to the console to check if it's working correctly or not.

If you get an exception message saying that the reference was not satisfied,
there are a few things you can try.
First, close Eclipse.
For each of the three directories indicated by the
[Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools) section,
go there and run `make clean`.
Then, re-compile all of those.
Finally, open Eclipse again, clean all projects, then rebuild them all.

## How to Fix `UnsatisfiedLinkError`
When you test the binding, you may get an unsatisfied link error.
This will happen if the binding you are using is not actually part of ISL's public API.
For example, I ran into this with the `isl_basic_set_is_bounded` function.

__WARNING:__ These instructions detail the process of having a function be exported by ISL.
If a function is not exported by ISL, there may be a reason for it, so this is not recommended.
Additionally, it doesn't seem like an easy thing to push back to the git repository.
Only follow these instructions if you are confident in what you're doing.

First, you'll need to download the ISL repository in the correct location.
The easiest way to do this is to build ISL the way you normally would for
adding functions to the JNI bindings.
Follow the first half of the instructions from the section
[Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools),
stopping after the second `make` command.

From now on, any time you run the steps in the section
[Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools),
do not run the last command (the `rm` one), as it will delete the ISL repository
and mess up your work.

Now, you'll need to find the copy of the ISL repository that was cloned.
From the root of the `gecos-tools-isl` repository,
you can find the ISL repository at `bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/isl`.

Inside the ISL repository is an `include/isl` folder containing many header (`.h`) files.
In these files, find the function you want to use.
If it is not there, you might need to add it, but I didn't test this, so your mileage may vary.
Since you got the `UnsatisfiedLinkError` message,
you should notice that the function does not have `__isl_export` before it
(usually on the previous line, all by itself).
You will need to add that.

Next, you'll need to re-build ISL and the ISL JNI bindings.
Repeat all but the last step (the `rm` command) from the section
[Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools).
Remember: when running this in the future, do not run that `rm` command ever again!
Otherwise, the next time you add a new ISL binding,
you'll probably need to re-export the function you're currently trying to export.

The last step is to delete any caches of the shared libraries from the `alpha-language` repo.
These are not normally in Git, so it's safe to delete them.
The problem is that they cached the old version of the libraries,
meaning they don't have the function you're trying to export,
so you'll just get the same (or a similar) `UnsatisfiedLinkError` exception.
You will need to delete all of the folders named `.jnimap.temp.linux_64`
(they're hidden folders, hence the starting `.` character).
One way to find them all is to run the below command from the terminal
while at the root of the `alpha-language` repository.
This will tell you where they are, then you can delete them with `rm`.

```bash
find . -type d -name .jnimap.temp.linux_64
```

When you try to run your code in Eclipse,
you may need to clean and re-build everything before it all starts working.
*