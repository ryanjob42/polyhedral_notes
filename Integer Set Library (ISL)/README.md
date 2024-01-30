# Integer Set Library (ISL)
Some notes about the Integer Set Library (ISL) by Sven Verdoolaege.
Since I'm currently working with the JNI Java bindings, these notes will likely reflect that
as opposed to the native C or the ISLPy Python bindings.

- [Sources of Information](#sources-of-information)
- [ISL Give, Take, Keep, and Null Attributes](#isl-give-take-keep-and-null-attributes)
- [Context Objects](#context-objects)
- [Space Objects](#space-objects)
- [Dimension Types](#dimension-types)
- [Basic Sets](#basic-sets)
- [Sets](#sets)
- [Constraints](#constraints)

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

## ISL Give, Take, Keep, and Null Attributes
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

## Context Objects
I don't understand this yet.
TODO: investigate and flesh out.

## Space Objects
Any time you're working with sets or relations (maps) in ISL,
the "space" they exist in must be defined.

The space of a set defines any parameters
and the indices that values in the set are defined over.
For example, the parameterized set `[N] -> { [i]: 0<i<N }` has a space `[N] -> { [i] }`.
This means that there is a single parameter, `N`,
and the space is 1-dimensional with that dimension being called `i`.

The space of a map is pretty much the same,
but differentiates between indexes for the input and output of the map,
as the number of indexes and labels of the indexes may differ.
For example, the map `[N] -> { [x] -> [i,j] : i=x, j=N }` 
has the space `[N] -> { [x] -> [i,j] }`.
This means that there is a single parameter `N`,
a single input index `x`, and two output indexes `i` and `j`.

## Dimension Types
Within a space, there are several different types of dimensions.
The main types of dimensions are as follows:

| Dimension Type | Enum Name       | Notes                                                                                            |
| -------------- | --------------- | ------------------------------------------------------------------------------------------------ |
| All            | `isl_dim_all`   | For spaces, returns the sum of parameters, inputs, and outputs. For sets/maps, also adds div.    |
| Constants      | `isl_dim_cst`   | This is always 1. See: `isl_map.c: isl_basic_map_dim(bmap, dimType)`. Not applicable for spaces. |
| Parameters     | `isl_dim_param` | Does not decrease if you have a constraint such as `N=15`.                                       |
| Inputs         | `isl_dim_in`    | This appears to always be 0 for sets, so only really makes sense for maps.                       |
| Outputs        | `isl_dim_out`   | For sets, this is the number of indices.                                                         |
| Set            | `isl_dim_set`   | A pseudonym for "outputs" intended only for use with sets (set indices are considered outputs).  |
| Div            | `isl_dim_div`   | I'm not sure what this is, but it doesn't apply to spaces.                                       |

In the C code, the dimension types are defined as an enumeration.
However, in the Java bindings, the dimension types are implemented as a class
which contains the integer value and a string for the name of the dimension type.
The class has a set of constant integers defined, which match the enum values of the C code.
These are written in all uppercase letters (e.g., `ISL_DIM_OUT`).
Typically, you will need an actual instance of the class.
There are static fields which contain the actual instances,
and are written in all lowercase letters (e.g., `isl_dim_out`).

## Basic Sets
Implemented as a map in the C code.

Contains two matrices: one for the inequality constraints
and one for the equality constraints.
In the Inria AlphaZ repo, the `DomainOperations` class
has some useful methods for retrieving these matrices.

## Sets
ISL Set objects appear to be a union of other sets, including basic sets.

If you want the basic sets that make up the union,
you can use `isl_set_get_basic_set_list(set)` function in `isl_map.c`.

Sets aren't necessarily disjoint.
This means, if you get the sets that make up this set, some of them may overlap.
To get a version of the set that's disjoint,
you can use the `isl_set_make_disjoint(set)` function in `isl_map_subtract.c`.

There are two functions for checking set equality.
They are named `isl_set_plain_is_equal(set1, set2)` and `isl_set_is_equal(set1, set2)`.
The "plain" function does a quick check only on the underlying structure of the set
(e.g., the coefficients of the equations) to see if they are the same set.
The non-plain function performs a more thorough check to determine if
the two sets are equivalent, even if the underlying structures differ.

## Constraints
Any set or map (including the basic ones) is likely to be defined
as a set of constraints in a given space.
These constraints can be either equality constraints (e.g., `k=i+j`)
or inequality constraints (e.g., `0<=i<=N`).
If you have a constraint and want to determine which it is,
you can use the `isl_constraint_is_equality(constraint)` function in `isl_constraint.c`.
In the Java bindings, this is `ISLConstraint.isEquality()`.
In the Python bindings, this is `Constraint.is_equality()`.

When working with constraints, you may want to determine if some of the indices are constrained by this constraint.
This is done with the `isl_constraint_involves_dims(constraint, dimType, first, n)` function in `isl_constraint.c`.
The `dimType` argument is used to specify which [dimension type](#dimension-types) you are looking for.
The `first` argument is the 0-based index of the first dimension to check if it is used.
The `n` argument is the number of dimensions to check (including the `first` one) to see if it is used.
Returns `true` if any of the `n` indices (starting at `first`) are used,
and `false` if none of them are used.

For example, say you have the set `[N]->{[i,j,k]: 0<=i<=N and 0<=j<=i and k=i+j}`.
To check if a constraint involves `k`, you would call `isl-constraint_involves_dims(constraint, isl_dim_set, 2, 1)`.
This will check constraints starting at index 2, and only check a single constraint.
To check if a constraint involves any of the indices, you would call `isl-constraint_involves_dims(constraint, isl_dim_set, 0, 3)`.
This will start checking at index 0, and check a total of 3 indices.
