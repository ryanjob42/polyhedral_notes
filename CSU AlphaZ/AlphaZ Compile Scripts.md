# AlphaZ Compile Scripts
How to write a compile script (`.cs` file) for the AlphaZ compiler.
This document is exclusive to the older version of AlphaZ developed at CSU.

- [Reading a Program](#reading-a-program)
- [Writing a Program](#writing-a-program)
- [Building the Code](#building-the-code)
- [Checking for Errors](#checking-for-errors)
- [Cleaning Up the Program](#cleaning-up-the-program)
- [Defining a Schedule](#defining-a-schedule)
- [Parallelization Within a Schedule](#parallelization-within-a-schedule)
- [Scheduling Memory Reuse](#scheduling-memory-reuse)
- [Identifying an Equation or Expression](#identifying-an-equation-or-expression)
- [Decomposing a Reduction](#decomposing-a-reduction)
- [Factoring an Expression Out of a Reduction](#factoring-an-expression-out-of-a-reduction)

## Reading a Program
The first thing you will generally need to do is read your actual Alpha program.
This is done with the `ReadAlphabets(fileName)` command,
saving the return value to a variable (ususally called `program` or `prog`).

```
program = ReadAlphabets("myAlphaFile.ab");
```

## Writing a Program
At some point, you'll likely want AlphaZ to give you some output about your program.
There are a variety of ways to do this based on what kind of file you want.

If you want an Alpha program, you can use the below commands.
This may be useful if you use AlphaZ to transform your program
and you want the results still in Alpha.

- `Show(program)` prints your program to the console.
- `Save(program, filePath)` will output the result of `Show` to the specified file path.
- There are also versions of these called `AShow` and `ASave` which use the array syntax.

If you want the AST of the program, you can use the below command.

- `PrintAST(program)` prints the AST of your program to the console.

If you want a C program, you can use one of the below commands.

- `generateWriteC(program, system, outDir)` will directly translate the Alpha program to C.
- `generateScheduledCode(program, system, outDir)` is like `generateWriteC`, but is necessary if you use AlphaZ to set the schedule for your code.
  - `generateWriteC` will ignore your schedule.

There's some other commands you'll likely want to use if you're generating a C program.

- `generateWrapper(program, system, outDir)` creates a C program which accepts the inputs to your Alpha system via the command line, then calls your Alpha system.
- `generateVerificationCode(program, system, outDir)` creates a C program is used to verify that your program is correct.
- `generateMakefile(program, system, outDir, includeVerifyTargets)` generates a makefile which can compile any of the C code.
  - The `includeVerifyTargets` is a boolean (`true` or `false`) which indicates whether or not to include the `verify` and `verify-rand` targets in the file.

## Building the Code
If you use the generated makefile, you can build the code very easily.
In general, you will only need the commands `make` to build all the targets
or `make clean` to delete all of the built code.
The makefile will always include the targets `plain`, `check`, and `clean`.
If you specify that the verification targets are to be created as well (see [Writing a Program](#writing-a-program)),
the `verify` and `verify-rand` targets will be present also.

The `plain` target builds a program where you give the size parameters as command-line arguments,
then specify the value of each input via prompts on the command line (during program execution).
The wrapper code will time how long it takes to run your C code,
then print this to the console.

The `check` target is mostly the same as the `plain` target,
but also prints out the values of all the program outputs.

The `verify` target is executed the same way as the `plain` target,
where you specify the size parameters as command-line arguments,
then specify each input value as prompted.
However, this program will execute both the main C code and the verification C code,
then it compares the outputs of each to ensure they are the same.
In the case of floating point numbers, the values are not checked for exact equality,
as some amount of error is to be expected.
The program takes the absolute value of the difference of the two programs
for any given output, then checks to make sure this is less than some small epsilon.
After printing the timing information,
the wrapper prints out each output variable name and indicates whether
the two programs produced the same results.
If they did not produce the same results,
the wrapper prints extra information about the errors
(the number of errors if the output is an array, or expected and actual values if it's a scalar).

The `verify-rand` target is nearly the same as the `verify` target,
except it generates random numbers to use as the inputs to the program.
You still need to specify the size parameters via the command line.

In the wrapper file, there is code which runs if compiled with a `TIMING` flag.
When this flag is defined, any time the C code (or verification C code) is run,
the size parameters and execution time will be written out to a file, separated by tabs.
All writes to the files are appends, so you can run the program many times in a row
and all data will be preserved.
Since this is a tab-separated file, it's very easy to import into your favorite spreadsheet program.
For the main C code, the data is appended to the file `trace.dat`.
For the verification C code, the data is appended to the file `trace_verify.dat`.
To add the `TIMING` flag, I'd recommend you modify the Makefile
and add `-DTIMING` either to the targets you want,
or to the `CFLAGS` variable (if you want all targets to be compiled with this flag).

## Checking for Errors
AlphaZ doesn't check for some errors in your code by default.
To check for errors, you can use the `CheckProgram(program)` command.
Any warnings or errors it finds will be printed to the console,
but the script won't terminate.
In fact, it'll actually still generate outputs if you have those commands after `CheckProgram`,
even if errors were found.

The following checks are considered "errors":

- A variable is undefined for some part of its domain.
  - AlphaZ will report the part of the domain which is unspecified.
- A variable has multiple dimensions.
- A case statement has overlapping domains.
  - AlphaZ will report the domains which overlap.

The following checks are considered "warnings":

- A variable is unused.
- The domain of an expression is empty.
  - E.g., if `A` is defined from 0 to `N`, but you try to access element `N+1`.
- A variable is undefined (or has an empty domain) for some values of the system's domain parameters.
  - AlphaZ reports the variable and what range of parameters make it undefined.

## Cleaning Up the Program
AlphaZ has a handful of commands you can use to clean up your program.

- `Normalize(program)` has a set of normalization rules which are used to simplify the structure of your program.
  - For more details, see: https://www.cs.colostate.edu/AlphaZ/wiki/doku.php?id=normalize
- `NormalizeReduction(program, system, equationName)` will put a reduction into a normalized form.
  - One of the handy normalizations is to split nested reductions into separate variables.
  - For more details, see: https://www.cs.colostate.edu/AlphaZ/wiki/doku.php?id=reduction_tutorial#normalize_reduction
- `RemoveUnusedVariables(program)` removes all unused variables in a program.
  - Optionally, you can also specify a system to focus on, after the program.
- `RenameVariable(program, system, originalName, newName)` renames a variable.
- `RenameSystem(program, originalName, newName)` renames a system.

## Defining a Schedule
After defining what calculations a program must perform,
you'll often want to define the order in which points of the iteration space are visited.
This is done by defining a schedule, or a "space time map" in AlphaZ terms.
The mapping is defined just like a standard dependence expression in Alpha.
The following example sets the schedule for a 3D variable `myVar`
to a simple 3D schedule `(i,j,k -> i,j,k)`.

```
setSpaceTimeMap(program, system, "myVar", "(i,j,k -> i,j,k)");
```

Now, suppose your Alpha program has multiple variables
which can get scheduled to the same timestamp.
You can set the order in which the variables are evaluated with another command.
The command dictates that the variable `foo` should be evaluated
before the variable `bar` if they occur within the same time step.

```
setStatementOrdering(program, system, "foo", "bar");
```

The standard `generateWriteC` command will completely ignore your schedule.
To actually generate your scheduled code, you'll want the `generateScheduledCode` command.
See the example below.

```
generateScheduledCode(program, system, outDir);
```

## Parallelization Within a Schedule
If you're scheduling code and some dimensions of the schedule can be done in parallel,
you can have AlphaZ generate the OpenMP pragmas needed for parallelizing them.
One of the ways to do so is with the `setParallel` command.
You can specify a list of indices of schedule dimensions to parallelize.
Indexes start at 0 and go from left to right.
If the schedule is `(i,j,k -> i,j,k)`, the example below parallelizes the `i` and `j` loops.
Note: this has a "orderingPrefix" parameter (the empty string below),
but the documentation doesn't explain this in a way I understand.
TODO: figure out what the ordering prefix does.

```
setParallel(program, system, "", "0,1");
```

## Scheduling Memory Reuse
With some Alpha programs, it's useful to describe equations as using more memory than necessary.
For example, it's easy to write a stencil computation to save all values from all time steps,
even though you only need the current and previous time step.
Instead of allocating all that extra memory,
you can use a memory map to specify exactly how memory gets reused
and thus reduce the amount of memory that needs to be allocated.

Specifying the memory map is done through a dependence expression
which transforms indexes from the Alpha program to their actual storage indexes
in the final scheduled C program.
In theory, you can also change the name of this variable,
but this seems to be currently broken.

The example below maps the 3D Alpha variable `source`
to a 2D memory location called `destination` by simply dropping the `k` index.
Note: since renaming seems to be broken, you should specify the same name
for both the source and destination.

```
setMemoryMap(program, system, "source", "destination", "(i,j,k -> i,j)");
```

Looking at the AlphaZ command reference, there appears to be a `setMemorySpace` command.
The document says it can be used to allow variables to share the same memory space.
The signature for `setMemoryMap` also calls the desination parameter `memorySpace`,
so I'm wondering if you're supposed to use this command first if you want to rename a variable?
Otherwise, you might just be limited only to using desinations which have already been declared?
This makes sense to me, but it's hard to tell.
TODO: investigate this further.

## Identifying an Equation or Expression
For some commands, you need to specify a "nodeId".
This is a string of comma-separated indexes which indicate the index of the system,
index of the equation in the system, index of the top-level expression in the equation,
and so on.
You could figure this out by hand, or you could just print out the AST.
Below shows an example of an Alpha program, the compiler script to print the AST,
and the output of printing said AST.
Notice the lines which start with `nodeId`.
If you want an easy way to find the "nodeId" of something, just look for this.

```
affine Example {|}
input 	int X {|};
output	int Y {|};
let		Y = X + 1;
.
--------------------------------------
program = ReadAlphabets("Example.ab");
PrintAST(program);
--------------------------------------
_Program
   |_AffineSystem
   |   |nodeId = (0)
   |   |_Example
   |   |_ParameterDomain
   |   |   |+-- {|}
   |   |_VariableDeclaration
   |   |   |+-- X
   |   |   |+-- {|}
   |   |   |+-- int
   |   |_VariableDeclaration
   |   |   |+-- Y
   |   |   |+-- {|}
   |   |   |+-- int
   |   |_StandardEquation
   |   |   |nodeId = (0,0)
   |   |   |+-- Y
   |   |   |_BinaryExpression
   |   |   |   |+--expression--{|}
   |   |   |   |+--context--{|}
   |   |   |   |nodeId = (0,0,0)
   |   |   |   |+-- ADD
   |   |   |   |_DependenceExpression
   |   |   |   |   |+--expression--{|}
   |   |   |   |   |+--context--{|}
   |   |   |   |   |nodeId = (0,0,0,0)
   |   |   |   |   |+-- (->)
   |   |   |   |   |_VariableExpression
   |   |   |   |   |   |+--expression--{|}
   |   |   |   |   |   |+--context--{|}
   |   |   |   |   |   |nodeId = (0,0,0,0,0)
   |   |   |   |   |   |+-- X
   |   |   |   |_DependenceExpression
   |   |   |   |   |+--expression--{|}
   |   |   |   |   |+--context--{|}
   |   |   |   |   |nodeId = (0,0,0,1)
   |   |   |   |   |+-- (->)
   |   |   |   |   |_IntegerExpression
   |   |   |   |   |   |+--expression--{|}
   |   |   |   |   |   |+--context--{|}
   |   |   |   |   |   |nodeId = (0,0,0,1,0)
   |   |   |   |   |   |+-- 1
   |   |   |   |   |   |_FastISLDomain
```

## Decomposing a Reduction
Alpha lets you write a reduction over multiple dimensions.
There is also a command you can use
if you want to "decompose" this into a reduction of a reduction.
The format for this command is below.
Note: after running the command, it's a good idea to normalize this reduction,
then the program as a whole.

```
ReductionDecomposition(program, nodeId, outerReductionProjection, innerReductionProjection);
```

Let's walk through the [reduction decomposition example](https://www.cs.colostate.edu/AlphaZ/wiki/doku.php?id=reduction_tutorial#reduction_decomposition).
The equation we will be working with is below.
Effectively, given some 2D input `X`, it produces a 1D output `Y`.
Each `Y[i]` is the reduction of a rectange of points in `X`,
and as `i` increases, the rectange gets shorter and wider.

$$
Y[i] = \min_{\substack{0 \le j \le i \\ 0 \le k < N-i}} \{ X[j,k] \}
$$

The Alpha program for this equation is below.
```
affine  RDExample {N|N>2}
input   int X {j,k|0<=(j,k)<N};
output  int Y {i|0<=i<N};
let     Y[i] = reduce(max, (i,j,k -> i), {|0<=j<=i && 0<=k<N-i}: X[j,k]);
.
```

The goal of the example is to simplify the reduction,
which exploits reuse to reduce the computational complexity of the program.
However, the command to do this doesn't like this equation as written.
Part of the solution is to "decompose" the reduction into a reduction of reductions.
If we do this, then normalize the program (see [Cleaning Up the Program](#cleaning-up-the-program)),
AlphaZ will simplify the reduction for us.

As shown above, the `ReductionDecomposition(...)` command needs two projection functions.
The first is the projection for the outer reduction, and the second is for the inner.
When composed, these should produce the original projection function.
You'll also need the ID for the AST node of the reduction you want to decompose
(see [Identifying an Equation or Expression](#identifying-an-equation-or-expression)).
For our example, let's use `(i,k -> i)` as the projection function for the outer reduction,
and `(i,j,k -> i,k)` as the projection function for the inner reduction.
When composed, these produce the original projection: `(i,j,k -> i)`.
Below is the compile script which decomposes the reduction,
then normalizes it so the inner reduction is listed as its own equation.

```
program = ReadAlphabets("RDExample.ab");
system = "RDExample";
ReductionDecomposition(program, "0,0,0", "(i,k->i)", "(i,j,k->i,k)");
NormalizeReduction(program, system, "Y");
Normalize(program);
```

## Factoring an Expression Out of a Reduction
With some reductions, there is a term that can be pulled out ("factored out")
because it is constant for the entire body of the expression.
If this is the case, you can use the command below,
where the "nodeId" refers to the expression you want to factor out.
Note: it's a good idea to normalize the program afterwards.

```
FactorOutFromReduction(program, nodeId);
```

Take the example Alpha program below.
Here, the `A[i]` term can be extracted out of the reduction.

```
affine  FactorExample {N|N>0}
input   int A, B {i | 0<=i<N};
output  int C {i | 0<=i<N};
let     C[i] = reduce(max, (i,j -> i), {|j<=i}: A[i]+B[j]);
.
```

Here is the compile scrip that pulls out the `A[i]` term,
followed by normalizing and printing the Alpha program.

```
program = ReadAlphabets("FactorExample.ab");
FactorOutFromReduction(program, "0,0,0,0,0,0");
Normalize(program);
AShow(program);
```

Here is the Alpha program that this produces.

```
affine test08 {N|N>=1}
input   int A {i|i>=0 && N>=i+1};
        int B {i|i>=0 && N>=i+1};
output  int C {i|i>=0 && N>=i+1};
let     C[i] = (reduce(max, (i,j->i), {|i>=j} : B[j]) + A);
.
```
