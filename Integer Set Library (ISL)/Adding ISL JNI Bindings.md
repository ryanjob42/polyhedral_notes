# Adding ISL JNI Bindings
This document describes how to add bindings for ISL functions to the JNI bindings.

- [Preparation](#preparation)
- [Clone the GeCoS ISL Tools Repository](#clone-the-gecos-isl-tools-repository)
- [Installing PatchELF](#installing-patchelf)
- [Fixing the GeCoS ISL Tools Java Home Path](#fixing-the-gecos-isl-tools-java-home-path)
- [Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools)
- [Test That Everything Works So Far](#test-that-everything-works-so-far)
- [Modifying the ISL Bindings](#modifying-the-isl-bindings)
- [Generate the New JNI Mapping](#generate-the-new-jni-mapping)
- [Fix the JNI Mapping](#fix-the-jni-mapping)
- [Recompile the GeCoS ISL Tools](#recompile-the-gecos-isl-tools)
- [Load the New Bindings](#load-the-new-bindings)
- [Test the New Bindings](#test-the-new-bindings)

## Preparation
Before doing any of this, you should have a working version of Eclipse already set up.
I'm using the version of Eclipse for the Inria AlphaZ compiler.

If you've done these steps before, I recommend removing the
GeCoS ISL Tools projects from Eclipse.
It may not be necessary, but it was giving me some issues at the time of writing (11-Jul-2023).
To do this, right-click the project, select "Delete",
check the box to delete the nested projects, then click OK.

You may also want to move the repository somewhere else and start these steps from scratch.
Reusing a repository was also giving me some issues at the time of writing (11-Jul-2023).
I don't recommend deleting it right away though,
just in case you have some other bindings you've added previously and still need.
This way, you can easily copy them back in.

## Clone the GeCoS ISL Tools Repository
The GeCoS ISL Tools repository contains the Java bindings for ISL functions.
Currently, this is controlled by Inria.
The repository can be found on GitLab at:
https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-isl/

As of 11-Jul-2023, the master branch is not the one we want to use.
Instead, we want the `isl-binding-updates` branch.
You can use the command below to clone the correct branch
(without needing to manually check it out after cloning).
Additionally, some of the makefiles have hard-coded paths (relative to your home directory),
so it should be cloned into the `~/projects/GeCoS/Tools/` directory.
The commands below also include this.

```bash
mkdir -p $HOME/projects/GeCoS/Tools
cd $HOME/projects/GeCoS/Tools/
git clone -b isl-binding-updates https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-isl.git
```

## Installing PatchELF
As of 11-Jul-2023, several of the Makefiles in this repository run the `patchelf` command,
which is not installed on the CSU machines by default.
If you're following these instructions, you should check whether this is still the case.
To do so, I'd recommend searching the entire directory for "patchelf".
If you don't find it, you can skip this step.
Otherwise, follow this step to get a copy of it.

The PatchELF application is used for modifying
[ELF (executable and linkable format) files](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format).
Luckily, it has a publicly available GitHub repository: https://github.com/NixOS/patchelf.
First, you will need clone the repository.
At the time of writing, the main branch did not work correctly,
so the command checks out a specific release that worked properly.
After cloning, you just run the commands indicated in the README.
The commands below perform all of these steps.
Note: the `make check` command should not report any failures.
If it does, try using a different release by replacing the version number in the command.
The following page lists all the releases of PatchElf:
https://github.com/NixOS/patchelf/releases.

```bash
git clone -b 0.17.2 git@github.com:NixOS/patchelf.git
cd patchelf
./bootstrap.sh
./configure
make
make check
```

Now that you've done this, you need to make the executable visible in your environment path.
If you have root access, you can simply run `make install` here to install the application.
However, anyone reading this is likely working on a CSU machine and does not have root access.
It doesn't really matter how you make the application visible in your environment path,
but I'll describe how I did this.

The default `.bashrc` file (again, as of 11-Jul-2023) already adds `${HOME}/bin` to your path.
To check if that's the case for you, either check your `.bashrc` file and look for the above,
or run the command `printenv PATH` and look for the full path for the above.
If it's not present, run the commands below.
Note: the single and double quotes here are important to get right,
so I'd recommend you copy-paste it into your terminal.
These will add a line to your `.bashrc` file to add `~/bin` to your path,
then reload your `.bashrc` file.

```bash
echo 'export PATH="${HOME}/bin:${PATH}"' >> $HOME/.bashrc
source $HOME/.bashrc
```

Now, we need to copy the PatchELF executable to that newly created `bin` folder.
Assuming you created the same `bin` folder as above
and your terminal is still in the root of the repository,
you can run the below command to copy the executable to the `bin` folder.

```bash
cp ./src/patchelf $HOME/bin/patchelf
```

Finally, to double check that everything was done correctly,
you can run the below command to check the version of PatchELF.
If everything is done right, you should get the version number.
If Bash tells you that the command wasn't found, you may have done something wrong.

```bash
patchelf --version
```

If this works, feel free to delete the PatchELF repository, as we don't need it anymore.

## Fixing the GeCoS ISL Tools Java Home Path
As of 11-Jul-2023, the path to the Java Home directory used in the GeCoS ISL Tools makefiles
is incorrect for the CSU machines.
The path it tries to use is `/usr/lib/jvm/java-11-openjdk-amd64/`.
However, we want to instead use the path `/usr/lib/jvm/java-11-openjdk/` (remove `-amd64`).
You can either find-and-replace these paths (e.g., using VS Code)
or manually modify the files listed below.
Note: if you're only compiling ISL (which is the only one that curently works),
you only need to modify the one in the ISL bundle.

* `bundles/fr.irisa.cairn.jnimap.barvinok/native/build/Linux_64/user.mk`
* `bundles/fr.irisa.cairn.jnimap.isl/native/build/Linux_64/user.mk`
* `bundles/fr.irisa.cairn.jnimap.polylib/native/build/Linux_64/user.mk`

## Compiling the GeCoS ISL Tools
After cloning the repository, installing PatchELF (if necessary),
and fixing the `JAVA_HOME` paths, you can finally try building the code.
Since this may be error-prone, it's important to try building the code
prior to trying to modify the JNI bindings.
The easiest way to do this, assuming everything works correctly,
is simply to run the script `scripts/compile_native_bindings.sh`.
However, this is very automatic and will make it difficult to see if something failed.
Therefore, I'd recommend manually using `cd` to go to the directories
indicated in the script (see the `pushd` commands) and running `make`.
This will let you see which steps complete successfully and which fail.
You can stop after the first failure.

Currently, I get a failure when I try to compile the NTL library.
The repo's README file says that if you only need ISL,
you only need to compile the GMP library, ISL library, and then the ISL bindings.
Thus, the NTL libraries not working isn't a big deal, so I won't try fixing it.
Hopefully you don't need it either!
Sorry if you do.

TODO: I should figure out how to get the entire thing to compile,
and probably see if Louis can push fixes for all of the above into the repo.

Below is a minimal script you can copy/paste commands from
to only compile the ISL bindings (and its dependencies).
This assumes your terminal is already at the root of the repository.
The second to last command will then put you back to the  root of the repository
(or wherever you ran the `pushd` command if you modified that path).
The last command simply cleans up the copy of the ISL repository that gets cloned
which is no longer needed.
Note: the final call to `make` may return some warnings, which is OK.

```bash
pushd bundles/fr.irisa.cairn.jnimap.isl/native/build/gmp
make
cd ../isl
make
cd ..
make
popd
rm -rf bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/isl/
```

## Test That Everything Works So Far
Before we start modifying the bindings, let's test that everything is working.
Open Eclipse and select "File > Import".
In the Import Wizard, select "General > Projects from Folder or Archive" and click "Next".
To the right of the "Import source" textbox, click the "Directory" button.
In the file picker window, navigate to the repository
(which should be at `~/projects/GeCoS/Tools/gecos-tools-isl/`) and click "Open".
Click the "Deselect All" button on the right,
then select only the `gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl` project.
Note: if you are modifying the Barvinok or PolyLib bindings,
you'll want to import those projects instead.
Click "Finish" to complete the import.

Wait for the project to finish building.
In my version of Eclipse, the progress indicator is on the bottom-right corner of the screen.
Double-clicking this brings up a window with more details.
Once it completes, make sure there are no compilation errors.

Finally, you'll want to test that everything is working.
You can do this however you want, but the steps below are how I did it.

In the "alpha-language" repo, right-click one of the packages and select "New > Xtend Class".
I chose to do this under `bundles/alpha.model/src/alpha.model`.
Name the file anything you want (I chose "TestFile"),
select the option to create the `main` method, then click "Finish".
Write some code to call into ISL in any way you want.
The code below is what I used.
To run the code, right-click the file and select "Run As > Java Application".

```Xtend
package alpha.model

import fr.irisa.cairn.jnimap.isl.ISLBasicSet
import fr.irisa.cairn.jnimap.isl.ISLContext

class TestFile {
	def static void main(String[] args) {
		val mySet = ISLBasicSet.buildFromString(ISLContext.instance, "{ [i]: 0 <= i <= 5 }")
		println(mySet.toString())
	}
}
```

If everything is working correctly, the console should output the set.
At the time of writing, I was getting a lot of errors stating
"ELF load command address/offset not properly aligned".
This ended up being due to the version of PatchELF I was using.
If you get this issue, go back to the [Installing PatchElf](#installing-patchelf) section
and try different releases until this works.

We won't delete this test file just yet,
as it will be useful when testing the newly added bindings.
However, feel free to delete it once everything is done and working.

## Modifying the ISL Bindings
You'll first want to identify what methods you want added.
To do this, you'll want to look at the ISL source code that the bindings are based off of.
The repository and version being checked out by the build script are specified in the file
`bundles/fr.irisa.cairn.jnimap.isl/native/build/isl/versions.mk`.
To look through the code, you can either clone the repo yourself and checkout that commit/tag,
or go to the online version of the Git repo (https://repo.or.cz/isl.git)
and search for the commit/tag being checked out.

Once you've found the methods you want, you'll need to add them to the JNI map.
The file to edit is `bundles/fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`.
In general, you will likely only need to add new function bindings to an existing group.
The names of the groups match the names of the Java classes in the bindings.
For example, if you want to modify the bindings for the `ISLMatrix` Java class,
simply search for the group names `ISLMatrix`.

Most function bindings are made of two parts.
The first is a set of attributes that help specify how to generate the Java method.
There are a handful of common attributes, listed in the table below.
Pick the ones you want.
Note: looking at the JNI Mapper code, it looks like the attributes may be ordered,
so I'd recommend putting things in the same order as everythign else to avoid issues.
To find the source of truth for all bindings, go to the following link and search for "Method:".
https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-jnimapper/-/blob/master/bundles/fr.irisa.cairn.jnimap/src/fr/irisa/cairn/JniMap.xtext

| JNI Map Attribute | Description                                                                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| static            | Generates a `static` method. By default, all generated methods are instance methods.                                                  |
| private           | Generates a `private` method. By default, all generated methods are public.                                                           |
| protected         | Generates a `protected` method. By default, all generated methods are public.                                                         |
| rename=newName    | The generated method will have whatever name you specify on the right-hand side of the equals ("newName" in the example on the left). |

## Generate the New JNI Mapping
As of 11-Jul-2023, these tools don't work the exact way they're supposed to.
Apparently, the JNI Mapping plugin is very sensitive to the version of Eclipse,
and this version may be too new.
Make sure to follow these steps carefully, as small deviations can cause issues.

If Eclipse is still open, close it.

First, we need to make a copy of the `bundles/fr.irisa.cairn.jnimap.isl/src-gen/` directory.
You can put the copy anywhere outside the repo.
The command below is one way to make a copy, and puts the copy just outside the repo.
This assumes you are at the root of the repo.

```bash
cp -r ./bundles/fr.irisa.cairn.jnimap.isl/src-gen/ ../
```

Now, we need to delete all of the Java files from the `src-gen` folder that's in the repo.
The commands below will delete these files.

```bash
rm ./bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/*.java
rm ./bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/platform/*.java
```

Open Eclipse again.
In the Project Explorer, find the JNI map file (`fr.irisa.cairn.jnimap.isl/src/Isl.jnimap`).
Right-click the file and select "Generate JNI Mapping".
If any errors appear, it may be because you didn't delete the Java files.
If so, start this section over.

Give Eclipse a few moments to finish building,
then check if there were any compilation errors.
If there weren't any, then something has likely been fixed since the time of writing,
so try re-running that test Xtext file from the
[Test That Everything Works So Far](#test-that-everything-works-so-far) section.
If that test passes, try using the new functions.
If that works, you can delete the copy of the `src-gen` directory, and you're done!
Skip the rest of this document, and consider making updates to reflect the fix.

The rest of this document assumes Eclipse reported errors (I had 450 of them).

## Fix the JNI Mapping
First, close Eclipse.
In short, we will want to restore the previously saved copy of the `src-gen` folder,
but with the changes that were needed to reflect the new bindings you want.
Then, we will likely need to restore automatic changes to some other files.

The first file we want to get changes from is `ISLNative.java`.
Many lines will likely be chagned here, but we only want to keep the new lines
for the added ISL functions we want to use.
You can use the command below to view all the changes to the file.
Copy these lines to the copied version of the file that's outside the repository.
There should be a single line added per ISL function you added.

```bash
git diff bundles/fr.irisa.cairn.jnimap.isl/src-gen/fr/irisa/cairn/jnimap/isl/ISLNative.java
```

After that, you will want to do the same to the classes
which are supposed to contain these functions.
For example, I was adding the `isl_mat_concat` function (which concatenates two matrices).
Since I put this function in the `ISLMatrix` group,
the method was added to the `ISLMatrix.java` file.
You can use `git diff` again to find the changes to the files you wanted updated,
then copy those changes to the copied version of that file that's outside the repository.

Finally, the two `src-gen` directories need to be swapped.
The commands below will move the newly-generated `src-gen` directory to outside the repo,
then move the original `src-gen` directory (with the edits) back into the repo.
We won't delete the newly-generated one until after the new bindings have been tested.
These commands assume that your terminal are in the root of the repo
and that you made the initial copy of the `src-gen` folder in the same spot as I did.

```bash
mv bundles/fr.irisa.cairn.jnimap.isl/src-gen/ ../src-gen-newer
cp ../src-gen bundles/fr.irisa.cairn.jnimap.isl/
```

Now that the `src-gen` directory should be correct, there are a few C files to fix.
Navigate to the `bundles/fr.irisa.cairn.jnimap.isl/native` directory,
then use the `git status` command.
Look for any C files in this directory.
Any Java classes you've added methods to should have a similarly-named C file
which has been modified to include the functions you added to the JNI map.
Make sure that other parts of such files are not modified negatively.
If there are other files which were modified but shouldn't have been,
use `git restore` to reset the file to what it was before.

## Recompile the GeCoS ISL Tools
Recompile the GeCoS ISL Tools repository using the same steps as before.
See: [Compiling the GeCoS ISL Tools](#compiling-the-gecos-isl-tools).

If you get an error saying that the `javah` command wasn't found,
use `git status` and `git diff` to check if there were any changes to the Makefiles
that aren't supposed to be there.
At the time of writing, it looks like Eclipse may automatically change and break things.
If this is the case, use `git restore` to restore them to their original state,
or manually edit them.

After this step, I recommend running `git status` and checking what files have all changed.
Below is a list of roughly which files should be present.
If there are more, you may run into issues that you need to fix.

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
