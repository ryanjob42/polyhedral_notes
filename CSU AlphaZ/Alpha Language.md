# Alpha Language
How to write Alpha code in a `.ab` file.
This document is exclusive to the older version of Alpha developed at CSU.

- [Declaring External Functions](#declaring-external-functions)
- [Declaring a System](#declaring-a-system)
  - [Alternate Syntax](#alternate-syntax)
- [Variable Declarations](#variable-declarations)
  - [Domains](#domains)
- [Equations](#equations)
  - [Standard Equations](#standard-equations)
  - [Use Equations](#use-equations)
- [Expressions](#expressions)
  - [Using an Index as a Value](#using-an-index-as-a-value)
  - [Case Expressions](#case-expressions)
  - [Dependence Expressions](#dependence-expressions)
  - [Reduction Expressions](#reduction-expressions)

## Declaring External Functions
These look like C function signatures that you'd put straight into a .h file to indicate they'll be linked in later.

```
[returnType] [functionName] ( [argumentTypes] );
```

The `[returnType]` is the data type returned by the function.
Only simple types (`int`, `char`, etc.) are allowed (i.e., no arrays, pointers, structs, etc.).

The `[functionName]` is the name of the function.

The `[argumentTypes]` define the number of arguments and what type each is.
They're in a comma-separated list, have the same type restrictions as the `[returnType]`,
and don't need (or even accept) names.

## Declaring a System
A system is kind of like a block of code.
The format of a system is below, where anything in square brackets is a different part of the language.

```
affine [systemName] [domain]
    input
        [declarations]
    output
        [declarations]
    local
        [declarations]
    let
        [equations]
.
```

The easiest item here is `[systemName]`, which is just an identifier for the system,
and follows the rules you would normally expect for naming something in code.

The `[domain]` is generally used as a parameter for the problem size being worked on.
It could be used for other things, but I'm not sure yet what that would be, and I'm not looking into that now.
See: [domains](#domains).

The various `[declarations]` are used to define the variables being used.
See: [declarations](#variable-declarations).

The `[equations]` are to define the actual calculations being performed.
See: [equations](#equations).

### Alternate Syntax
There is an alternate syntax, which is basically the same,
but renames "input", "output", "local", and "let" to "given", "returns", "using", and "through".
These must be exchagned all together, not individually.
This would look like:

```
affine [systemName] [domain]
    given
        [declarations]
    returns
        [declarations]
    using
        [declarations]
    through
        [equations]
.
```

## Variable Declarations
Within a system, there are three types of variables: inputs, outputs, and locals.
As the names suggest, "input" variables are treated as inputs (or parameters) to the system,
"output" variables are output (or returned) by the system,
and "local" variables are used within the system but discarded after execution.
What distinguishes these three is merely where they appear in the system.
Looking at the [Declaring a System](#declaring-a-system), it should be pretty easy to see how this works.

A variable declaration is formatted as below.
Again, square brackets here represent a different part of the language.

```
[type] [variableName] [domain]
```

The `[type]` is just the data type of the variable.
The normal ones you would expect are present: `int`, `float`, `bool`, `char`, etc.
If you know C/C++, they should be pretty familiar.

The `[variableName]` is just a normal identifier for the variable.
Nothing unexpected here.

The `[domain]` is a bit more complex (and used within a system declaration),
so it'll get [its own section](#domains).

### Domains
Variables in Alpha are generally going to be multidimensional, such as arrays or matrices.
A domain is used to describe the number of dimensions and the regions in which they are valid.
The way domains are described allows you to not only use a size,
but a range of values which can even depend on other dimensions.
This allows you to describe things like trianges, or other shapes.

The general format for a domain is as follows.
Again, square brackets represent something to be described just after.

```
{ [dimensionNames] | [dimensionBounds] }
```

The `[dimensionNames]` is a comma-separated list of names for each dimension.
To get a 0-dimensional domain (i.e., just a single value), leave this empty.
It's important to note: Alpha doesn't care about the name of the dimensions really,
just the relative positioning of them.

The `[dimensionBounds]` is a set of linear inequalities using the names of the dimensions and integer constants.
Inequalities can be `>`, `>=`, `<`, `<=`, or `==`.
Each inequality is separated by a logical and operator: `&&`.

In addition to this, you can combine multiple domains with a logical or operator: `||`.
This represents the union of two domains.

## Equations
Equations are the equivalent of a statement in most languages.
There are two kinds to discuss: [standard equations](#standard-equations) and [use equations](#use-equations).

### Standard Equations
Generally, equations are for setting the value of a variable.
For this, you would use the following syntax, where the square brackets mean something you'd fill in.

```
[lhs] = [expression]
```

The `[lhs]` is a variable name, optionally with index names in square brackets.
The `[expression]` on the right is what value to take on.
See: [expressions](#expressions).

### Use Equations
You're allowed to define multiple systems to make simpler or more modular code.
A "use equation" is how you would "call" the other system.
This is what I think the syntax is supposed to be, but I haven't actually gotten code like this working yet, so YMMV.
This syntax actually uses square brackets, so this time, I'll use curly braces to indicate the parts of the syntax I'll explain.

```
use {systemName} [ {parameterList} ] ( {inputExpressions} ) returns ( {outputVariables} );
```

The `{systemName}` is the name of the system being "called".
Of course, you have to define it yourself.

The `{parameterList}` is the set of expressions which specify the actual values for the domain of the called system.

The `{inputExpressions}` define the values for all of the input variables for the called system.

The `{outputVariables}` indicate what variables (within the caller system) to save the outputs of the callee to.

See: [declaring a system](#declaring-a-system).

## Expressions
You have several of the normal expressions you'd expect for math.
Here are the standard ones, in order of precedence:

- Logical or
- Logical and
- Relational operations (>, <, ==, etc.)
- Addition and subtraction
- Modulo division
- Multiplication and regular division
- Min and max
- Logical not and negation
- One of the following (all with equal precedence):
  - Constants
  - Variables
  - Parentheses
  - [Case expressions](#case-expressions)
  - [Dependence expressions](#dependence-expressions)
  - [Reductions](#reduction-expressions)
  - (some more that I don't feel like listing out)

### Using an Index as a Value
Alpha makes a distinction between variables which have a value
and variables which represent an index.
These two can not be used interchangeably.
For example, you can't do the following:

```
A[i] = i+1;
```

This would give you an error telling you that `i` is not defined.
To work around this, just surround it with square brackets.
Either of the following would work:

```
A[i] = [i]+1;
B[i] = [i+1];
```

### Case Expressions
Case expressions are used to build piecewise expressions.
The most common syntax (that I've seen) is shown below.
Square brackets denote language placeholders to be explained momentarily.
The dots (`...`) indicate that you can keep going with the format for as long as you need.

```
case
    [domain] : [expression];
    [domain] : [expression];
    ...
esac
```

The `[domain]` indicates which indexes to use that `[expression]` for.
Keep in mind that none of the domains can overlap,
and must fully specify the entirety of the domain they describe (i.e., whatever is receiving a value from the case expression).
See: [domains](#domains), [expressions](#expressions).

Something to note: it looks like you can use different kinds of syntax for the case, such as `if..then..else`.
While possible, it seems to me that this isn't really the best choice usually, so I'm not going to look at it right now.

### Dependence Expressions
These are used to transform the current indexes of dimensions into a different set of indexes.
For example, matrix multiplication has a 3D iteration space (with indices `i`, `j`, and `k`), but each matrix access is 2D.
A dependence expression is what you would use to go from the `i,j,k` iteration space to a matrix index (e.g., `i,k`).

The main type of dependence expression is of the following form.
As always, text in square brackets is a placeholer for a different language construct.

```
( [dimensionList] -> [indexExpressions] )
```

The `[dimensionList]` is a comma-separated set of names used to indicate names of the dimensions being used.
In the example of matrix multiplication, this would be `i,j,k`,
as the iteration space is 3D even though all the data spaces 2D.

The `[indexExpressions]` are a set of comma-separated affine expressions
which use those dimensions, integer constants, and operations (`+`, `-`, etc.).
These expressions are used to indicate the point at which to access a variable.
In the matrix multiplication example, this could be `i,k`,
meaning that `i` directly indexes the rows of the array, and `k` directly indexes the columns.

Within a reduction's `[projection]`, this is used as-is.
The `[indexExpressions]` are used to indicate the point in the output to reduce each expression into.
This can also be put before a different expression (with an `@` between them)
to specify how a variable (or other expression) can be accessed.
And yes, you can chain these together.

Something to note: there is a second syntax for this when using it as a reduction's `[projection]`.
If all you are doing is adding dimensions to the reduction,
you can instead put the names of the new dimensions within square brackets.
With the matrix multiplication example, the `[projection]` using the standard notation would be `(i,j,k -> i,j)`.
However, the alternate syntax (called "AShow", where "A" stands for "array" I think) would be `[k]`.

### Reduction Expressions
The form for a reduction is as follows:

```
reduce( [operation], [projection], [expression] )
```

The `[operation]` is an associative operation to perform the reduction over, such as `+` or `max`.

The `[projection]` is a [dependence expression](#dependence-expressions) 

The `[expression]` is the expression that will go inside of the operation and be reduced.

There are two different formats for the `[projection]`.
If all you're doing is adding temporary dimensions to reduce over (e.g., the "k" dimension of matrix multiplication),
you can just write them in square brackets.
You don't actually need to add bounds for these dimensions, as AlphaZ will figure it out auto-magically.

The second, and more complex, format for a `[projection]` is to use parentheses and a right arrow.
This is written something like: `( [lhs] -> [rhs] )`.
The `[lhs]` is a comma-separated list of the dimensions you have, including any temporary dimensions.
The `[rhs]` is a comma-separated list of expressions using those dimensions,
which is what is actually used to indicate the index of the output where the expression is reduced into (I think).
