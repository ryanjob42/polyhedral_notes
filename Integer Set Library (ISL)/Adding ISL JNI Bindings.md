# Adding ISL JNI Bindings
This document describes how to add bindings for ISL functions to the JNI bindings.

* [Preparation](#preparation)
* [Install PatchELF](#install-patchelf)
* [Clone the GeCoS ISL Tools Repository](#clone-the-gecos-isl-tools-repository)
* [Preserve the Existing Bindings](#preserve-the-existing-bindings)
* [Update the JNI Map File](#update-the-jni-map-file)
* [Generate the New JNI Mapping](#generate-the-new-jni-mapping)
* [Clean Up After Eclipse](#clean-up-after-eclipse)
* [Fix the `src-gen` Folder](#fix-the-src-gen-folder)
* [Fix the `native` Folder](#fix-the-native-folder)
* [Fix the GeCoS ISL Tools Java Home Path](#fix-the-gecos-isl-tools-java-home-path)
* [Export the ISL Function If Necessary](#export-the-isl-function-if-necessary)
* [Double Check Changed Files](#double-check-changed-files)
* [Compile the GeCoS ISL Tools](#compile-the-gecos-isl-tools)
* [Load the New Bindings](#load-the-new-bindings)
* [Test the New Bindings](#test-the-new-bindings)

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
cd "$HOME/projects/patchelf"
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
2. Ignore all errors in the code for now.
3. In the Project Explorer, find the JNI map file.
   1. `fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`
4. Right-click the file and select "Generate JNI Mapping".
5. Wait for a window to appear that says the "JNIMapping have been successfully generated."
6. Allow Eclipse to finish building the code before continuing.
   1. You should see the progress in the bottom-right corner of the screen.
   2. Double-clicking the indicator will show a screen with more details.
7. Ignore the compilation errors for now.
8. Close Eclipse.

## Clean Up After Eclipse
Eclipse has created some folders which cause a variety of issues.
They all need to be deleted to avoid these issues from coming up in the future.

The first one to delete is a `bin` folder in the GeCoS ISL Tools repo.
Use the command below to delete it.

```bash
rm -rf "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/bin/
```

The remaining folders are all caches of a shared object library for the ISL Java bindings.
These may become out of date after updating the bindings, so need to be deleted.
Otherwise, Eclipse will continue to load the old bindings.
In the terminal, navigate to the "alpha-language" repo
and run the following command.
Then, for each folder that it indicates, delete it using `rm -rf` (or whatever you prefer).

```bash
find . -type d -name .jnimap.temp.linux_64
```

## Fix the `src-gen` Folder
Now that the methods for the new Java bindings have been created,
they can be copied from the new `src-gen` folder into the original one.
This is easier than trying to fix all the errors in the new one.
For all modifications made here, do not use (or even open) Eclipse.
Use another editor, such as VS Code.

The first file we want to get changes from is `ISLNative.java`.
Many lines will likely be chagned here, but we only want to keep the new lines
for the added ISL functions we want to use.
You can use the commands below to view all the changes to the file.
Copy these lines to the original version of the file that's outside the repository.
There should be a single line added per ISL function you added.

```bash
cd "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/"
git diff ISLNative.java
```

After that, you will want to do the same to the Java classes
which contain the new binding functions.
For example, I was adding the `isl_mat_concat` function (which concatenates two matrices).
Since I put this function in the `ISLMatrix` group, the method was added to `ISLMatrix.java`.
You can use `git diff` again to find the changes to the files you wanted updated,
then copy those changes to the copied version of that file that's outside the repository.

Finally, the two `src-gen` folders need to be swapped.
The commands below will move the newly-generated `src-gen` directory to outside the repo,
then copy the original `src-gen` directory (with the edits) back into the repo.
I chose to move and copy these folders in this way so they can be preserved
in case something goes wrong, or in case a changed file was missed.
After all the testing is complete, you may delete thes folders.

```bash
mv "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/src-gen/" "$HOME/projects/GeCoS/Tools/src-gen-newer/"
cp -r "$HOME/projects/GeCoS/Tools/src-gen/" "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/src-gen"
```

## Fix the `native` Folder
Similar to the `src-gen` folder, there is some code in the newly generated bindings
that we need to copy to the original versions, then we swap the folders around.
The only ones we need to compare are the C files associated with the updated Java classes.
Similar to before, use `git diff` on the files in the newly generated `native` folder
and copy the changes to the original version of the folder that's outside the repo.

Continuing the example from before, when I added the `isl_mat_concat` function,
the file `ISL_ISLMatrix_native.c` was updated to include a version of the function.

After making all the changes, the two `native` folders need to be swapped.
The commands below will do this in the same manner as the `src-gen` folders.

```bash
mv "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/" "$HOME/projects/GeCoS/Tools/native-newer/"
cp -r "$HOME/projects/GeCoS/Tools/native/" "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native"
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
- `bundles/fr.irisa.cairn.jnimap.isl/native/*.c`
  - The only changed files here should be the C files associated with the Java classes you added bindings to.
- `bundles/fr.irisa.cairn.jnimap.isl/native/build/Linux_64/user.mk`
  - Only if you needed to change it to fix the Java Home path.
- `bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/Makefile`
  - Only if you needed to change it to export functions which weren't part of ISL's API.
- `bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/*.java`
  - One of the files should be `ISLNative.java`.
  - The only other changed files should be the Java files you added bindings to,
- `bundles/fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`

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
cd "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/gmp/"
make
cd "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/"
make
cd "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/"
make
rm -rf "$HOME/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/isl/"
```

If you need the Barvinok or Polylib bindings,
I recommend looking at the `compile_native_bindngs.sh` script to figure out how to do this.
You may need to debug the build process in this case.

## Load the New Bindings
Finally, we need to fix Eclipse, because it likely has partly broken,
then test out the new bindings.

1. Open up Eclipse again.
2. If a build starts up automatically, wait for it to finish.
3. There will be many compile errors, ignore them for now. The followin steps fix them.
4. In the Project Explorer window, find the `fr.irisa.cair.jnimap.isl/src-gen` folder.
5. Right-click the folder and select "Refresh".
6. Right-click each package in the `src-gen` folder and select "Refresh".
   1. As of 10-Aug-2023, there should be two packages here.
7. From the menu bar, select "Project > Clean".
8. In the "Clean" window, select "Clean all projects".
9. If there is an option to build all projects after cleaning, select that.
10. Click the "Clean" button.
11. A build should start automatically. If not, manually start one.
12. Wait for the build to finish.
    1. You can see the progress in the bottom-right corner of the window.
    2. Double-clicking displays a "Progress" window with more infomation.
13. Check that there are errors in the compilation.

If there are compile errors, there are a few potential reasons.

1. You may have forgotten to copy some of the code from the newly generated `src-gen` or `native` folder to the original one. Double check these folders.
2. If it appears that files are missing from Eclipse, but they're present in the file system, you may need to right-click and "Refresh" more packages.
3. If there are errors about incorrect or undefined method signatures, but they look correct to you:
   1. Make a small change to the file (e.g., add a space somewhere).
   2. Save the file.
   3. Undo the change you made.
   4. Save the file again.
   5. This seems to force Eclipse to re-analyze the file, hopefully "fixing" the issue.

## Test the New Bindings
Finally, try using all of the new bindings.
I recommend using the test file from before, if you didn't delete it.
Simply make a call to the newly added bindings
and print something to the console to check if it's working correctly or not.

If you are getting an `UnsatisfiedLinkError` exception,
you may not have cleared out the cached versions of the bindings.
See the last steps from the section
[Export the ISL Function if Necessary](#export-the-isl-function-if-necessary).
If following these steps did not fix the issue,
you may need to add (or fix) changes to the Makefile to export the functions.

I did not run into any other kinds of errors while writing this document.
If you run into something that's not here and figure out how to fix it,
please add it to the appropriate section of this document.
