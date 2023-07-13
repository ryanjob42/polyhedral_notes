# Command Descriptions
Provides high-level descriptions of compiler commands.

## Reduction Commands
Commands that apply transformations to reduction expressions.
These are technically a subset of the "Transformation" category,
but both categories are large enough where I wanted to split them.

### Distributivity
`Distributivity.apply()` seems to recursively look through the expression
to find something that can be pulled out.
However, this appears to fail with external functions.

If if finds something that can be pulled out,
it gets passed on to `FactorOutFromReduction.apply()`,
which does the leg work and returns the binary expression
which is the result of factorization.

Then, `Distributivity.apply()` calls itself again with the right-hand side
of that binary expression, trying to pull something else out.

### Factor Out From Reduction
Factor Out from Reduction takes in a dependence expression that's inside a reduction,
checks if it's legal to pull it out of the reduction it's in, and pulls it out if it can.
We refer to the dependence expression to be pulled out as the "target expression".

It's worth noting that this command _must_ be given a dependence expression.
This means it cannot be used to pull out a call to an external function.
However, there's an easy workaround:
make a new equation which just calls the external function and use that inside the reduction.

AlphaZ performs two checks to determine if it is legal to pull out the target expression.
First, it checks the operator being directly applied to the target expression
and the reduction operator.
As long as distributivity holds between these operators, this check passes.
The second check is to ensure the kernel of the reduction's projection function
is inside the kernel of the target expression's function.
In short, this checks that the same value of the target expression is accessed
for all points being reduced to the same value.

### Simplifying Reductions
Looks to be much the same as in the original AlphaZ,
but somehow it actually is able to detect when the residual computation
has a constant number of points and eliminates the reduction.
Looks like there's some post-processing,
and one of those steps is to the [Simplify Expressions](#simplify-expressions) command.

## Transformation Commands
Commands that apply transformations to expressions.
Note: the transformation commands that apply to reduction expressions
are separated out into their own [Reduction Commands](#reduction-commands) category.

### Simplify Expressions
From the header comments, this implements the following:

- remove BinaryExpression when one of the operand is identity
- replace IndexExpression with ConstantExpression when applicable
- replace ReduceExpression with its body when it has scalar domain

The last one is pretty cool!
If a reduction body contains only a single point,
then it replaces the reduction with just that one point!
Technically, it looks at the number of pieces in a "piecewise multi-affine" ISL object,
and if there's only one piece, replaces the reduction expression with a dependence expression.
