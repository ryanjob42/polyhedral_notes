# Integer Set Library (ISL)
Some notes about the Integer Set Library (ISL) by Sven Verdoolaege.
Since I'm currently working with the JNI Java bindings, these notes will likely reflect that
as opposed to the native C or the ISLPy Python bindings.

- [Sources of Information](#sources-of-information)
- [ISL Give, Take, Keep, and Null](#isl-give-take-keep-and-null)

## Sources of Information
TL;DR: See the table below for some handy links.
My favorites are in bold italics.
The list as a whole is alphabetical by description
(assuming I've maintained it properly).

ISL itself has a SourceForge page with zips of all the distributions,
as well as links to a manual, tutorial, and a user guide.
I personally use the user guide most out of the three,
but it looks to be the same as the manual, which is a PDF instead of an HTML page.
There is a separate page for the Git repository where you can view the code very easily.
Just keep in mind that the absolute latest changes may not be reflected
in a release or in the bindings for another language.

ISLPy is an easy-to-use Python library which provides bindings into the native C code of ISL itself.
They have a GitHub page with the source code and another site with documentation.
If you're using this in a Jupyter notebook, you'll likely want to display some images.
ISLPlot is a great library for 2D drawings, and works OK for 3D drawings.
Louis Narmour's "simplifying-reductions" GitHub page has some better code for 3D drawings,
along with plenty of examples on how to use ISLPy and the drawing tools.

The "gecos-tools-isl" repository/plugin provides Java bindings to the ISL C code
using the Java Native Interface (JNI).
The repository has some other bindings, but the ISL ones are in their own package.

| Description                                      | Link                                                                                                      |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| GeCoS Tools ISL JNI Package                      | https://gitlab.inria.fr/gecos/gecos-tools/gecos-tools-isl/-/tree/master/bundles/fr.irisa.cairn.jnimap.isl |
| ***ISL Git Repository***                         | https://repo.or.cz/w/isl.git                                                                              |
| ISL SourceForge Page                             | https://libisl.sourceforge.io/                                                                            |
| ISL User Guide                                   | https://libisl.sourceforge.io/user.html                                                                   |
| ISLPlot GitHub Page                              | https://github.com/tobiasgrosser/islplot                                                                  |
| ***ISLPy Documentation Site***                   | https://documen.tician.de/islpy/                                                                          |
| ISLPy GitHub Page                                | https://github.com/inducer/islpy                                                                          |
| ***Louis's Simplifying Reductions GitHub Page*** | https://github.com/lnarmour/simplifying-reductions                                                        |

## ISL Give, Take, Keep, and Null
In the ISL C code, there are four commonly used attributes.
In the code, they appear as `__isl_give`, `__isl_keep`, `__isl_take`, and `__isl_null`.
These are macros (defined in `extract_interface.cc`)
which indicate how ISL handles the underlying pointers.
See the following link for the official documentation,
but I'll quickly cover their meaning.
https://libisl.sourceforge.io/user.html#Memory-Management

The attribute `__isl_give` means that a new object is returned.
Usually this attribute is for the return type of a function,
but sometimes it's used for a function argument.
In this case, this probably means the argument is intended to be an output of the function.

The attribute `__isl_take` means that ISL will destroy the object.
It appears to only be used for function arguments.
Attempting to use an object after providing it as this kind of argument will result in errors.
If you want to keep using it, you must make a copy using the `.copy()` method.

The attribute `__isl_keep` means that ISL will neither create nor destroy an object.
It appears to only be used for function arguments.
Data may be read from the object, but ISL will not destroy it,
meaning you are free to continue using it.

The attribute `__isl_null` means a `null` value is returned.
This appears to be used as the return type for functions which free memory.
