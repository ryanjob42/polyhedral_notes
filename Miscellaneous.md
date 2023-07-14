# Miscellaneous
This document is for miscellaneous notes, which probably should be sorted later.

## Indices and Parameters
The space in which a polyhedron lives is defined by indices and parameters.
At a surface level, these can be thought of as both being the dimensions of space
in which the polyhedron exists.

## Constraint Representation of Polyhedra
_Also called "half-space" representation._

One way to represent a polyhedron is through the use of constraints,
which may either be an equality or an inequality.
For example, an inequality constraint could be: $0 \le i \le 10$.

A common way to describe a polyhedron's constraints is through set notation.
Using this notation, you would describe a polyhedron as being the set of all points
such that all the constraints are satisfied.
Below is an example of a triangle which is defined through set notation using constraints.
In this example, $i$ and $j$ are indices.

$$
\bigl\{ [i,j]: 0 \le i \le 10 \text{ and } i \le j \le 10 \bigr\}
$$

Often, it is convenient (or necessary) to write constraints as only a single equality or inequality.
In this case, we would separate the constraint $0 \le i \le 10$ in two: $0 \le i$ and $i \le 10$.
Let's see that same example again, but with this restriction.

$$
\bigl\{ [i,j]: 0 \le i \text{ and } i \le 10 \text{ and } i \le j \text{ and } j \le 10 \bigr\}
$$

With constraints like this, it is easier to see why the constraint representation
may also be called the "half-space" representation.
Each constraint defines a hyperplane.
Inequality constraints dictate that the polyhedron is on one side of the hyperplane (inclusive of the hyperplane itself).
The two sides of the hyperplane are called "half-spaces".
Equality constraints also form hyperplanes, but dictate that the polyhedron fully resides on the hyperplane.

While these constraints are easy to read and write in this way, manipulating equations like this can be tricky.
However, linear algebra gives us many useful tools for manipulating systems of equations (and inequalities).
By writing the coefficients as a matrix and the variables (indices and parameters) as a column vector,
we can describe a polyhedron (still using set notation) as below.
Here, $x$ is a column vector for the indexes, $A$ and $C$ are matrices of coefficients,
and $b$ and $d$ are column vectors of constants.

$$
\bigl\{ x \in \mathbb{Q}^n \mid Ax=b \text{ and } Cx \ge d \bigr\}
$$

The above definition is considered to be _non-homogenous_.
To achieve the _homogenous_ form, one side of the equality (or inequality) should be 0.
With this form, you essentially add another dimension which is just for your constants.
This adds one row to each column vector and one column to each matrix.
Here, $A'$ is $A$ but with one more column for the constants in $b$ (negated),
and $C'$ is $C$ but with one more column for the constants in $d$ (negated).

$$
\left\{ x' \in \mathbb{Q}^{n+1} \mid A'x' = 0 \text{ and } C'x' = 0 \right\}
$$

## Vector-Ray-Line Representation of Polyhedra
_Also called the "Minkowski" representation._

Another way to describe a polyhedron is as a combination of vertices, rays, and lines.

A ___vertex___ is a point in space.
Any linear combination of the vertices where the scalar coefficients sum to 1
is considered to be part of the polyhedron.

A ___ray___ is a direction where, from any point in the polyhedron,
you can scale the direction by a non-negative coefficient
and the point you end at is still considered to be within the polyhedron.
If a ray is defined, then the polyhedron is unbounded in that direction
(i.e., you can keep following the ray forever and never leave).

A ___line___ is like a ray, but negative coefficients are also allowed.
This means that you can follow it in either direction forever and never leave the polyhedron.
Note: do not confuse this with a line segment.

Representing a polyhedron in this way is very similar to the matrix representation
of a polyhedron in the constraint representation.
Here, $\lambda$, $\mu$, and $\v$ are free-valued column vectors.
$L$, $R$, and $V$ are matrices where each column represents a line, ray, or vector (respectively)
used to define the polyhedron.

$$
\left\{ x \in \mathbb{Q}^n \mid x = L \lambda + R \mu + V v \text{ where } \mu \ge 0 \text{ and } v \ge 0 \text{ and } \sum_i v_i = 1 \right\}
$$

This representation also has a homogenous form.
Here, $x'$ is $x$ but with an additional row for a 1,
$L'$ is $L$ but with an additional row of all 0's.
$R'$ is formed by adding a row of 0's to $R$, adding a row of 1's to $V$, then concatenating the two side-by-side.
Effectively, vertices and rays are merged together.

$$
\left\{ x' \in \mathbb{Q}^{n+1} \mid x' = L' \lambda' + R' \mu' \text{ where } \mu' \ge 0 \right\}
$$

### Why Can Vertices and Rays be Merged?
TBD
