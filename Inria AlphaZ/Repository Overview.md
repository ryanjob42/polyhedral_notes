# Repository Overview
This document aims to summarize several important parts of the alpha-language repository,
making it easier for new users to navigate and re-use existing functionality.

## Table of Contents
* [Table of Contents](#table-of-contents)
* [Main Structure](#main-structure)
    * [GitHub Workflows](#github-workflows)
    * [Main Source Code](#main-source-code)
    * [Unit Tests](#unit-tests)
* [Important Classes](#important-classes)
    * [The Visitor and Visitable Classes](#the-visitor-and-visitable-classes)
    * [Matrix Classes](#matrix-classes)
    * [Converting Sets or Affine Expressions to (or from) Matrices](#converting-sets-or-affine-expressions-to-or-from-matrices)
* [The Alpha Language's Grammar](#the-alpha-languages-grammar)
* [How the Groovy Commands are Supposed to Exist](#how-the-groovy-commands-are-supposed-to-exist)

## Main Structure
At the top-level, there are three important folders you should be aware of:
the GitHub workfows, the main source code, and the unit tests.

### GitHub Workflows
The configuration files for the GitHub workflows are defined in `.github/workflows`.
Each time you create, update, or merge a pull request, an action runner starts up,
builds the code, runs the unit tests, and collects Code Climate statistics.
Additionally, when a PR is merged, it'll deploy the code to update the CSU pre-installed version of Eclipse with AlphaZ.

In day-to-day use, you won't need to touch the files.
However, if you create a new unit test class, you need to manually add it to the `build.yml` file.
This is what tells the action runner to automatically run all the tests.
To add your new test file, start by looking for the lines that start with `org.junit.runner.JUnitCore`.
Add a new line which starts with that followed by the fully qualified class name of the new unit testing class
(i.e., the package name followed by the class name).

### Main Source Code
The main source code is found within the `bundles` folder.
There are a variety of projects here, but the vast majority of what you'd be using is within `alpha.model`.
This is where most (if not all) the AlphaZ optimizations reside, hence its usefulness.

The `alpha.model.xtext` project might also be useful to reference sometimes.
This is where the definition of the Alpha language resides, including the grammar, abstract syntax tree, and parser.
Unless you're changing the actual Alpha language, you likely won't need to touch any of these.

There are a variety of different projects, but you likely won't need to even look at them.

### Unit Tests
All of the unit tests are found in the `tests` folder.
The package structure inside here makches the structure of the `bundles` folder,
other than adding `.tests` to the package names (and `Test` to the class names).

Remember: if you add a new unit test class, you need to add it to the GitHub workflow `build.yml` file.
See [GitHub Workflows](#github-workflows) for more info.


## Important Classes
This section contains information on some of the important classes (or groups of classes) you should be aware of.

### The Visitor and Visitable Classes
For any compiler or optimizer, the [Visitor Pattern](https://en.wikipedia.org/wiki/Visitor_pattern) is very useful.
It allows you to programmatically navigate the abstract syntax tree of an Alpha system and act on what's there.
To implement this, there are two kinds of classes: visitors and visitables.
The primary definitions of these are found in `alpha.model/model/alpha.xcore`.

The nodes of the AST should implement some kind of "visitable".
There are two main kinds to work with: `AlphaVisitable` and `AlphaExpressionVisitable`.
In general, the highl-level things such as systems, variables, and equations are `AlphaVisitable`.
As the name suggests, the various kinds of expressions (e.g. reductions or cases) are `AlphaExpressionVisitable`.
A third kind of visitable, `AlphaCompleteVisitable`, is the parent to both.

There is a "visitor" which goes along with each of these "visitables".
These are interfaces which, when implemented, allow you to navigate the parts of the AST.
The `AlphaVisitor` allows you to navigate `AlphaVisitable` nodes,
and the `AlphaExpressionVisitor` navigates the `AlphaExpressionVisitable` nodes.
There isn't an interface for the complete visitor, but we'll discuss that later.
For each kind of node, the visitor has three methods: `visit`, `in`, and `out`.
The `visit` method effectively performs a depth-first search over the nodes of the AST.
The intent is that these call the `in` method for that node,
then the `visit` method for all of that node's children,
and finally the `out` method for that node.

There are some existing abstract classes which make implementing visitors a lot less tedious:
`AbstractAlphaVisitor`, `AbstractAlphaExpressionVisitor`, and `AbstractAlphaCompleteVisitor`.
These will automatically call the appropriate `visit` methods,
which automatically call the necessary `in`, `visit`, and `out` methods to navigate the AST.
This also has default implementations of all the `in` and `out` methods which don't do anything.
The easiest way to implement your own visitor is to simply inherit from one of these three classes,
then override the `in` and/or `out` methods for nodes you want to operate on.
Typically, you'll want the `out` method, as that'll be reached only after the children have been operated on.

There is one additional pair of visitable and visitor for calculator expressions.
These are basically the same as mentioned before, but are kept separate.

### Matrix Classes
There are three different ways you could operate on matrices in this repo:
isl matrices, Alpha matrices, and 2D arrays.

The `gecos-tools-isl` library provides an `ISLMatrix` class.
This is how you'd have a matrix interact with `isl` objects.
There are a number of useful and efficient functions implemented by `isl`,
but if you need something that they haven't implemented (or which hasn't been imported into the JNI bindings),
adding that functionality can be anywhere from tedious to a major hassle.

Alpha has its own matrix class, which is primarily defined in `alpha.model/model/alpha-matrix.xcore`.
This class itself is pretty minimal, but there are a lot of functions outside the class that make it powerful.
Something to note is that it has its own definition of a `Space`.
These spaces are intended to be "set" spaces, meaning they only have parameters and indexes.
While there is functionality to convert the matrix into an affine expression (which has a map space),
you will need to be careful how the output dimensions are managed (if you care about that).

If you're working with matrices, it is worth looking both at what's available in the `ISLMatrix` class
and the `MatrixOperations` class (found in `alpha.model/src/alpha/model/matrix/`).
The latter is primarily for working with Xtend/Java arrays and the Alpha `Matrix` class.
Since this found inside the alpha-language repository, adding new functionality is very easy.

Here are the ways you can convert between matrices.
The only one-step conversions are to/from arrays.
Converting between the isl and Alpha matrices currently requires going through an array.

```java
// Converting to an array:
long[][] myArray = myIslMatrix.toLongMatrix();
long[][] myArray = myAlphaMatrix.toArray()

// Converting to an isl matrix:
ISLMatrix myIslMatrix = ISLMatrix.buildFromLongMatrix(myArray);
ISLMatrix myIslMatrix = ISLMatrix.buildFromLongMatrix(myAlphaMatrix.toArray());

// Converting to an Alpha matrix:
Matrix myAlphaMatrix = MatrixOperations.toMatrix(myArray, paramNames, indexNames);
Matrix myAlphaMatrix = MatrixOperations.toMatrix(myIslMatrix.toLongMatrix(), paramNames, indexNames);
```

Note: there is a redundant function, `DomainOperations.toLongArray(...)`, which converts an Alpha matrix to an array.
They seem to do the exact same thing.

### Converting Sets or Affine Expressions to (or from) Matrices
If you're looking to convert affine expressions (typically `ISLMultiAff`) or sets to (or from) matrices,
there are a couple of pre-built ways to do this.

The `ISLMultiAff` class has method for converting to/from sets or basic sets.

The `ISLSet` and `ISLBasicSet` classes have methods to construct them from `ISLAff` objects, but not the other way around.

The `ISLBasicSet` class also has a method `fromConstraintMatrices(...)` to build it from a couple of `ISLMatrix` objects.

The `DomainOperations` class (found in `alpha.model/src/alpha/model/util/`) has methods to convert sets (basic and not) into `ISLMatrix` objects.

The `AffineFunctionOperations` class (found in `alpha.model/src/alpha/model/util/`) has methods for converting
sets or expressions to/from the Alpha matrix class.

## The Alpha Language's Grammar
The Alpha language is defined via [Xtext](https://eclipse.dev/Xtext/).
The file for this definition can be found at `bundles/alpha.model.xtext/src/alpha/Alpha.xtext`.
Other files in the `alpha.model.xtext` package are how the alpha code gets parsed,
but I haven't investigated enough to determine how this all gets done.

There is another file which defines the classes that make up the AST.
This file is found at `bundles/alpha.model/model/alpha.xcore`.
Warning: this doesn't 1-for-1 line up with the Xtext definition, but it's pretty close.

## How the Groovy Commands are Supposed to Exist
Currently, the Groovy scripting interface doesn't work,
but it's still useful for finding the classes that line up with various AlphaZ functions and optimizations.

The Groovy scripts are supposed to work by inheriting a base class called `AlphaScript`, then using the functions it exposes.
This base class is found in the package `alpha.commands.groovy` as the file `src-gen/alpha.commands.groovy/AlphaScript.groovy`.
From this file, we can see that all these functions merely call other functions in the `alpha.commands` package.
Similar to the CSU AlphaZ, there is a class for each command category, and each command is implemented as a static function.
Also similarly, a few of these functions are implemented right there,
but most of these static functions just call other functions from other packages.
