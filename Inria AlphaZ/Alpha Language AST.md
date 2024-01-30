# Alpha Language AST
Some notes about the AST structure of the Alpha language.

## Expressions
These are the different kinds of expressions.

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

### Variable Expressions
Exactly what you expect: it uses a variable.

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
