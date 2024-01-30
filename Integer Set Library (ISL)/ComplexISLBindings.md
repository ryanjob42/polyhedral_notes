# Help! My ISL Function is Complicated!
This document was created when trying to add a binding which the JNI Mapper does not easily support.
As any such case likely has many nuances unique to that case,
this document will be written as a case study of what has worked.

- [Situation Overview](#situation-overview)
- [Updating the JNI Map File](#updating-the-jni-map-file)
    - [Creating a Result Data Structure](#creating-a-result-data-structure)
    - [Creating a Group for the Data Structure](#creating-a-group-for-the-data-structure)
    - [Creating the Custom C Function](#creating-the-custom-c-function)
    - [Bind the Custom Functions to the Desired Group](#bind-the-custom-functions-to-the-desired-group)
- [Generating and Populating the New Files](#generating-and-populating-the-new-files)
- [Re-Compile the Bindings](#re-compile-the-bindings)

## Situation Overview
For our work, we needed access to the "left Hermite" function from ISL.
This is found in `mat.c` as the `isl_mat_left_hermite` function.
Effectively, this takes in one matrix as input and returns three new matrices.
However, two of them are "returned" by having the user pass in a pointer to a matrix pointer.
The function then creates the two matrices, then updates the matrix pointers (which are being pointed to)
so they point to these new matrices.

At the time of writing, the JNI Mapper does not have a way to directly generate code for this situation.
To get access to this function, we performed the following high-level steps:

1. Update the JNI map file to define:
    1. A new data structure for holding all three of these matrices.
    2. Custom C functions that call isl's left Hermite function, wrap the results in the new data structure, and return that.
    3. New bindings in the `ISLMatrix` Java class to the custom C function.
2. Re-generate the JNI mapping.
3. Make some manual changes to:
    1. Define a C struct for the new data structure.
    2. Define the custom C functions.
    3. Fix the Makefiles so everything gets compiled correctly.
4. Compile the updated bindings.

## Updating the JNI Map File
The first step is to update the JNI map file to describe the changes you want to make.
Part of this will be to auto-generate a handful of files, which will give you somewhere you can implement your changes.
The general steps here are as follows:

1. Create a data structure to wrap the return values we want.
2. Add a new group definition to allow the data structure to be auto-generated.
3. Create the custom C function that calls into isl and returns the new data structure.
4. Add bindings for the custom C function to the desired existing group.

### Creating a Result Data Structure
First, we will define a new structure for the return value we want in Java.
At the time of writing, the existing structures start around line 320.
Our new structure is called `isl_hermite_result` in C, and `ISLHermiteResult` in Java.
It contains three matrices, called `H`, `U`, and `Q` to match the ISL left Hermite function.
Here is what it looks like:

```
struct isl_hermite_result {
	copyOnGet isl_mat* H;
	copyOnGet isl_mat* U;
	copyOnGet isl_mat* Q;
} as ISLHermiteResult;
```

Here is the general format for defining your own:

1. The first line contains (in order):
    1. The `struct` keyword.
    2. The name of the struct in C.
    3. An open curly brace.
2. Give one line for each field you want in the struct. These contain (in order):
    1. The `copyOnGet` keyword.
    2. The data type of the field (in terms of C types).
    3. The name of the field.
3. The last line contains (in order):
    1. A closing curly brace.
    2. The `as` keyword.
    3. The name of the Java class for this data structure.

### Creating a Group for the Data Structure
The JNI Mapper will automatically generate the appropriate C and Java code for the data structure,
but only if there is a non-empty "group" for that structure.
Thus, we need to create a new group so our code gets auto-generated correctly.
To do this, we will define such a group with a function to free the memory being used.
This function is not strictly necessary, but it's a good idea to have it.

Most of the JNI Map file is for group definitions.
At the time of writing, they start around line 500 and go to the end of the file.
Feel free to put your group wherever it makes sense.
Since our data structure is only being used in conjunction with the ISLMatrix Java class,
we put our new group directly above that group.
Here is what our new group looks like:

```
group ISLHermiteResult {
	[rename=free]
	void isl_hermite_result_free(take struct isl_hermite_result* result);
}
```

If you are adding a "free" method for your own structure, you can copy this definition with the following changes:

1. On the first line, replace `ISLHermiteResult` with the Java name from the struct definition (see the last line, after the `as` keyword).
2. On the third line, rename the function from `isl_hermite_result_free` to whatever name makes sense.
    1. To follow the existing naming convention, use the C name for your struct followed by `_free`.
3. Also on the third line, replace the data type of the parameter to be a pointer to the C name for your struct.
    1. That is, replace `isl_hermtie_result*` with the C name for your struct followed by a `*` character to make it a pointer.
4. Also on the third line, change the parameter name (`result`) to whatever makes sense for your data type.

### Creating the Custom C Function
We need a custom C function that calls isl's left Hermite function, wraps the results in our new data structure, and returns that.
This is done inside a "module", which start very near the top of the JNI map file (around line 15 at the time of writing).
By defining the function this way, the JNI mapper will auto-generate any appropriate files and function definitions,
giving you a place to insert your implementation.

It is recommended you see if there's an existing module that matches where you want your functionality.
Since the Hermite function has to deal with matrices, and no such module existed for that yet, we created the `mat` module (short for "matrix").
We wanted two different ways to call the left Hermite function, as one of the arguments (`neg`) is always set to the same value within isl.
One of our functions assumes this, while the other function allows the user to specify it.
Here is what our new module looks like:

```
module mat {
	struct isl_hermite_result* custom_isl_left_hermite(take isl_mat *M);
	struct isl_hermite_result* custom_isl_left_hermite_neg(take isl_mat *M, int neg);
}
```

Here is the general format for defining your own:

1. The first line contains (in order):
    1. The `module` keyword.
    2. The name of the module, which will be used when creating the name of the `.c` and `.h` files for your code.
        1. Specifically, if your module's name is `X`, it will create the files as `ISLUser_X.c` (and `.h`).
    3. An open curly brace.
2. Give one line for each custom function you want to define. These contain (in order):
    1. The C return type of the function.
    2. The C name of the function. Since this is C code, each name should be unique.
    3. An open parenthesis.
    4. A list of parameters for the function, which contain (in order):
        1. An optional `give`, `take`, or `keep` keyword.
            1. `take`: the isl data structure passed in will be destroyed by this function.
            2. `keep`: the isl data structure passed in will not be destroyed.
            3. `give`: a new isl data structure will be created. Note: you probably shouldn't use this one, as the JNI mapper will likely not support the functionaly you're trying to implement. Use at you own risk.
        2. The C data type of the parameter.
        3. The name of the parameter.
    5. A close parenthesis.
    6. A semicolon.
3. The last line contains only a close curly brace.

### Bind the Custom Functions to the Desired Group
Our last step is to bind the custom C functions to the group that we want to use them in.
This way, the JNI mapper will generate the appropriate Java methods in the class we want,
along with the C code needed to make the function accessible via the JNI.

The left Hermite function is applied to a matrix, so we want to add our custom functions to the `ISLMatrix` Java class.
To do this, we simply added the functions to the group for that class.
Here is what our bindings look like, with the "..." representing the pre-existing contents fo the group.

```
group ISLMatrix {
	...
	[rename=leftHermite]
	struct isl_hermite_result* custom_isl_left_hermite(take isl_mat* M);
	[rename=leftHermiteNeg]
	struct isl_hermite_result* custom_isl_left_hermite_neg(take isl_mat* M, int neg);
}
```

Here is the general format for defining a single binding similar to the one above:

1. It must be within the curly braces of the group for the Java class you want to add methods to.
2. The first line contains (in order):
    1. An open square bracket.
    2. If the Java method should be a static method, include the `static` keyword.
    3. The `rename` keyword.
    4. An equals sign.
    5. The name you want for the Java method. These names should be unique within the class, as the JNI mapper doesn't support method overloading (at the time of writing).
    6. A closing square bracket.
3. The second line contains the C function signature that you defined within the module. You can just copy/paste that here.

## Generating and Populating the New Files
Now that we have an updated JNI map file, we can re-generate the JNI mapping.
Note: it is highly recommended to commit just the JNI map changes (to its own branch) at this time,
as the following steps will touch a large number of files, some of which may need to be restored (either in part or in whole).
Re-generating the JNI mapping will automatically create several files and function signatures for us to populate, and update several other files.

The high-level steps here are as follows:

1. In Eclipse, right-click the JNI map file and select "Generate JNI Mapping".
    1. Feel free to ignore the errors.
    2. At the time of writing, this will also modify many files incorrectly. Use Git (or whatever approach works for you) to undo only the bad changes. Note that some of the files with bad changes may also contain good changes, so be careful with this.
2. Modify the necessary files, listed in the second and third lists below.
    1. If the new files weren't generated, then something is wrong with your JNI map file. Make sure you haven't declared a function multiple times, as it doesn't always support that.
3. Re-build all the bindings (commands listed below).

Here are the files that are created or updated, which you do not need to touch:

1. Several `ISL_*_native.c` files were created or updated.
    1. A new one is created for your new data structure. The `*` is the Java class name for the group you created, which should match the struct's definition.
        1. For us, this was `ISL_ISLHermiteResult_native.c` since we created the `ISLHermiteResult` group.
    2. The file for the group you added bindings to will be updated to include the new bindings. The `*` is the Java name of the group you updated.
        1. For us, this was `ISL_ISLMatrix_native.c` since we added bindings to the `ISLMatrix` group.
    3. All of these files will be updated to add an `include` statement for the `ISLUser_*.h` file created for the new module (described later).
        1. For us, this statement was `include "ISLUser_mat.h"`.
2. The `ISL_UserModules.c` file is updated to include the JNI export functions for all new (or updated) modules.
3. A new `.java` file is created because of the newly defined group for your data structure.
    1. For us, this was `ISLHermiteResult.java`.
    2. The file is basically a wrapper around all the JNI calls, including appropriate type and parameter checking.
4. The `.java` file for all updated groups are updated to include the new bindings.
5. The `ISLNative.java` file is updated to define the JNI bindings for all the new functions.

Here are the files that are created or updated, but you will need to modify them:

1. A new `ISLUser_*.h` file is created for the new module you defined.
    1. For us, this was `ISLUser_mat.h` since we added the `mat` module.
    2. Inside the protected region, you will need to define the newly created struct.
        1. You can do this by copying the struct definition from the JNI map file and removing the `copyOnGet` and `as *` parts.
        2. Don't forget that the struct definition needs to end with a semicolon in C.
        3. Note: you can really define this wherever you want, but this is where it made the most sense for us.
2. A new `ISLUser_*.c` file is also created for the new module.
    1. It will be named the same as the previous header file, just replacing `.h` with `.c`.
    2. Inside the protected region at the top, add a function definition for the bindings you've created for the data structure's group.
        1. For us, this was the `isl_hermite_result_free` function.
        2. Again, you can really define this function wherever makes the most sense, but that was this location for us.
        3. Note for future improvement: it may make sense to include this function inside the module definition, that way the signature gets auto-generated.
    3. Inside each function's protected region, you will need to define that function's behavior.
        1. To allocate space for your data structure, we recommend using `isl_alloc_type`. This is defined in `ctx.h`, which should already be imported. It takes in an `isl_context` and the data type you want to allocate, then automatically calls `sizeof` and `malloc`. If `malloc` fails, then the program will crash, so you don't have to worry about that.

Finally, these files were not created or updated, but you will need to manually update them:

1. All of the `native/build/*/Makefile` files (one per each target platform).
    1. At the time of writing, the targets are: Cygwin_32, Linux_64, Macosx_64, and Mingw_32.
    2. 1. The `OBJS` variable needs a `.o` file added for any new `ISL_*_native.c` files which were created, that way they get compiled.
    3. The `EXTRA_OBJS` variable needs a `.o` file added for any new `ISLUser_*.c` files which were created, that way they get compiled.
    4. New build targets need to be created for each `.o` file you specified previously.
        1. It's recommended you just copy/paste similar targets and adjust them accordingly.

## Re-Compile the Bindings
The final step is to re-compile the bindings.
The comands to do this are shown below.
If you've changed where these files are located (which is not supported at the time of writing, as the build hard-codes these paths),
then you will need to change the path in the first command.
Also, for pushing out the final update, you may need to do this build on several different machines (one for each target you want to compile for).
This depends on whether the GitHub action runner is able to automatically do all of these for you or not.

```bash
cd ~/projects/GeCoS/Tools/gecos-tools-isl/bundles/fr.irisa.cairn.jnimap.isl/native/build/gmp/
make
cd ../isl
make
cd ../
make
```
