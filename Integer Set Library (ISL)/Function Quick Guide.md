# Function Quick Guide
A quick guide to some helpful functions in ISL.
These are broken up by the type they work with.
If a function works with multiple types, I put it in the sections that make the most sense to me.
This sometimes results in duplicates, which is OK.
If there isn't an exactly equivalent function, but one that's close,
I just put that one down.

* [Affine Expressions](#affine-expressions)
* [Constraints](#constraints)
* [Matrices](#matrices)
* [Sets](#sets)

## Affine Expressions
Flat range product - basically, concatenate two affine expressions. E.g., "\[i,j] -> \[i+j]" with "\[i,j] -> \[i-j]" becomes "\[i,j] -> \[i+j, i-j]".

## Constraints

| Description         | ISL Function                                                                    | Java Bindings                                   | ISLPy Bindings                                        |
| ------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------- | ----------------------------------------------------- |
| Involves Dimensions | `isl_constraint.c: isl_constraint_involves_dims(constraint, dimType, first, n)` | `ISLConstraint.involvesDims(dimtype, first, n)` | [`Constraint.involves_dims(dim_type, first, n)`][1.1] |
| Is Equality         | `isl_constraint.c: isl_constraint_is_equality(constraint)`                      | `ISLConstraint.isEquality()`                    | [`Constraint.is_equality()`][1.2]                     |

[1.1]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Constraint.involves_dims
[1.2]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Constraint.is_equality

## Matrices

| Description  | ISL Function                             | Java Bindings                 | ISLPy Bindings                 |
| ------------ | ---------------------------------------- | ----------------------------- | ------------------------------ |
| Column Count | `isl_mat.c: isl_mat_cols(mat)`           | `ISLMatrix.getNbCols()`       | [`Mat.cols()`][2.1]            |
| Concatenate  | `isl_mat.c: isl_mat_concat(top, bottom)` | `ISLMatrix.concat(bottom)`*   | [`Mat.concat(bottom)`][2.2]    |
| Drop Rows    | `isl_mat.c: isl_drop_rows(mat, row, n)`  | `ISLMatrix.dropRows(row, n)`* | [`Mat.drop_rows(row, n)`][2.3] |
| Row Rank     | `isl_mat.c: isl_mat_rank(mat)`           | `ISLMatrix.rank()`            | [`Mat.rank()`][2.4]            |

*Note: I added this manually, so it is likely not present in the ISL bindings normally.

[2.1]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.cols
[2.2]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.concat
[2.3]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.drop_rows
[2.4]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.rank

## Sets
Note: in general, these functions also work for basic sets.

| Description         | ISL Function                                                | Java Bindings                 | ISLPy Bindings                     |
| ------------------- | ----------------------------------------------------------- | ----------------------------- | ---------------------------------- |
| Convex Hull         | `isl_convex_hull.c: isl_set_convex_hull(set)`               | `ISLSet.convexHull()`         | [`Set.convex_hull()`][3.1]         |
| Dimension Count     | `isl_map.c: isl_basic_set_dim(set, dimType)`                | `ISLSet.dim(dimType)`         | [`Set.dim(dim_type)`][3.2]         |
| Get Basic Set At    | `???: isl_basic_set_list_get_basic_set(set, idx)`*          | `ISLSet.getBasicSetAt(index)` | [`Set.get_basic_sets()`][3.3]      |
| Get Basic Set List  | `isl_map.c: isl_set_get_basic_set_list(set)`                | `ISLSet.getBasicSets()`       | [`Set.get_basic_set_list()`][3.4]  |
| Is Bounded          | `isl_convex_hull.c: isl_set_is_bounded(set)`                | `ISLSet.isBounded()`**        | [`Set.is_bounded()`][3.5]          |
| Is Equal            | `isl_map.c: isl_set_is_equal(set1, set2)`                   | `ISLSet.isEqual(set)`         | [`Set.is_equal(set)`][3.6]         |
| Make Disjoint       | `isl_map_subtract.c: isl_set_make_disjoint(set)`            | `ISLSet.makeDisjoint()`       | [`Set.make_disjoint()`][3.7]       |
| Remove Redundancies | `isl_convex_hull.c: isl_basic_set_remove_redundancies(set)` | `ISLSet.removeReduncancies()` | [`Set.remove_redundancies()`][3.8] |

*Note: I found several cases of the function `isl_basic_set_list_get_basic_set(set, idx)`, but could not find where it was declared.

**Note: I added this manually, so it is likely not present in the ISL bindings normally.

[3.1]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.convex_hull
[3.2]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Space.dim
[3.3]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.get_basic_sets
[3.4]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.get_basic_set_list
[3.5]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.is_bounded
[3.6]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.is_equal
[3.7]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.make_disjoint
[3.8]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.remove_redundancies
