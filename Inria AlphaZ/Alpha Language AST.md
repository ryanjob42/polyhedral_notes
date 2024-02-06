# Alpha Language AST
Some notes about the AST structure of the Alpha language.

## Expressions
These are the different kinds of expressions,
with the exception of [expression and context domains](#expression-and-context-domains),
which are properties of all other expressions.
All AST nodes for expressions extend the abstract `AlphaExpression` class.

### Expression Domains and Context Domains
From the [Inria AlphaZ wiki](https://gitlab.inria.fr/Alpha/alpha-language/-/wikis/Alpha-Syntax#expression-domains-and-context-domains),
all expressions have both an "expression domain" and a "context domain".
An expression domain is where the expression is well-defined (i.e., it's possible to compute a value).
A context domain is where the expression needs to be evaluated (i.e., the value is (or could be) accessed at any of these points).
For the Alpha program to make sense, the expression domain must be equal to, or a superset of, the context domain.

### Constant Expressions
There are 3 kinds: boolean, integer, and real.
They are exactly what you expect.

```
affine constantExpressions [N]->{:N>0}
    outputs boolean, integer, real: {}
    let boolean = true;
        integer = 7;
        real = 0.3;
.
```

For convenience, there is a base `ConstantExpression` interface (extending `AlphaExpression`)
which all three types of constants extend.
The actual classes are `BooleanExpression`, `IntegerExpression`, and `RealExpression`.

All constants are considered to be 0-dimensional and are accessed by affine maps with an empty range.
For example, in the equation `X[i] = 7`, the constant `7` is being accessed by the funciton `(i -> )@7`.
That empty function (or one like it) will be used as both the context domain and expression domain.

### Variable Expressions
Exactly what you expect: it accesses the value of a variable at some point.
These use the `VariableExpression` class.

The expression domain is the set where the variable itself is defined,
while the context domain is the set of points where the access is valid.
For example, suppose we have the following program:

```
affine variableExpressionExample
    inputs  X: [100]
    outputs Y: [5]
    let     Y[i] = X[2i+4]
.
```

Here, our input `X` is defined for all `0 <= i < 100`, but our output `Y` is only defined for `0 <= i < 5`.
The variable expresion for `X` would have an expression domain of `0 <= i0 < 100`, as that's where `X` is defined.
However, the context domain would be the points `(i0 mod 2 = 0) and (4 <= i0 <= 10)`.
This is because these are the points at which `X` is being accessed at, per the function `2i+4`.

Additionally, that variable expression would be wrapped in a dependence expression.
This dependence would have a context domain of `0 <= i < 3` (as that's where `Y` is defined)
and an expression domain of `-2 <= i < 48` (as that's where `2i+4` would access existing values of `X`).

### Unary, Binary, and Multi-Arg Expressions
Unary expressions are for unary operations.
Looks like the only ones are `not` and `-` (negation).
Note: it looks like sometimes they require you to put parentheses around the operand.

Binary expressions have two operands and an infix operator.
Pretty much what you expect, but allows operations you might not.
For example, `leftVal max rightVal` returns the maximum of `leftVal` and `rightVal`.

Multi-arg expressions are an operator followed by a parenthesized,
comma-separated list of operands.
For example, `+(first, second, third, fourth)` returns the sum
of the four values in parentheses.
It looks like the minimum number of values is one, and there doesn't appear to be a maximum.

### Case Expressions
These are used to partition an equation's domain into non-overlaping subdomains,
where each subdomain is associated with a different expression.
The points within a subdomain take on a value via the subdomain's expression.
The union of all subdomains must equal the equation's domain
(i.e., everything in the original domain must be specified).

You can define as few as one case.
This doesn't seem to be useful, as this one case must define the entire domain,
so you might as well drop the structure of the case statement.

One of the cases is allowed to have a domain of `auto`.
This is effectively just the "default" case,
and will be the case that applies if none of the others do.
That is, this subdomain will be the difference of the original domain
and the union of all other subdomains.

### Dependence Expressions
One way to think of a dependence expression is as a change of basis.
This can be used for accessing a variable (by changing the basis to the domain of the variable, then accessing with the identity function),
or for accessing a constant (by changing the basis to a 0-dimensional domain).

These AST nodes are defined by the `DependenceExpression` class.
This node has two fields: `functionExpr`, which is the dependence function,
and `expr`, which is the child (the thing inside the dependence expression).
In the standard "show" notation, this would be `functionExpr @ expr`.

The expression domain is "the preimage of the expression of its child by the dependence function" (according to the Alpha wiki).
Effectively, this is the set of points which, after applying the dependence function, will access valid points for whatever the child node is.
To reiterate: these points are from _before_ applying the dependence function.

The Alpha wiki doesn't really say what the context domain is,
only that the parent context is "the image of the context domain... by the dependence function".
However, if my understanding is correct (TODO: confirm with someone who actually understands this),
I think the context domain should be just a copy of the parent's context domain,
as the points which need to be accessed doesn't really change.
From looking at Alpha ASTs, it seems that the child's context domain is what gets affected by the dependence function,
and that the "parent context" being referenced here is actually the context domain of the child (or related to it).
