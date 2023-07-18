# Function Quick Guide
A quick guide to some helpful functions in ISL.
These are broken up by the type they work with.
If a function works with multiple types, I put it in the sections that make the most sense to me.
This sometimes results in duplicates, which is OK.
If there isn't an exactly equivalent function, but one that's close,
I just put that one down.

- [Matrices](#matrices)
- [Sets](#sets)

## Matrices

| Description  | ISL Function                             | Java Bindings                | ISLPy Bindings                 |
| ------------ | ---------------------------------------- | ---------------------------- | ------------------------------ |
| Column Count | `isl_mat.c: isl_mat_cols(mat)`           | `ISLMatrix.getNbCols()`      | [`Mat.cols()`][1.1]            |
| Concatenate  | `isl_mat.c: isl_mat_concat(top, bottom)` | `ISLMatrix.concat(bottom)`   | [`Mat.concat(bottom)`][1.2]    |
| Drop Rows    | `isl_mat.c: isl_drop_rows(mat, row, n)`  | `ISLMatrix.dropRows(row, n)` | [`Mat.drop_rows(row, n)`][1.3] |
| Row Rank     | `isl_mat.c: isl_mat_rank(mat)`           | `ISLMatrix.rank()`           | [`Mat.rank()`][1.4]            |

[1.1]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.cols
[1.2]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.concat
[1.3]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.drop_rows
[1.4]: https://documen.tician.de/islpy/ref_fundamental.html#islpy.Mat.rank

## Sets
Note: in general, these functions also work for basic sets.

| Description         | ISL Function                                                | Java Bindings                 | ISLPy Bindings                     |
| ------------------- | ----------------------------------------------------------- | ----------------------------- | ---------------------------------- |
| Convex Hull         | `isl_convex_hull.c: isl_set_convex_hull(set)`               | `ISLSet.convexHull()`         | [`Set.convex_hull()`][2.1]         |
| Get Basic Set At    | `???: isl_basic_set_list_get_basic_set(set, idx)`*          | `ISLSet.getBasicSetAt(index)` | [`Set.get_basic_sets()`][2.2]      |
| Get Basic Set List  | `isl_map.c: isl_set_get_basic_set_list(set)`                | `ISLSet.getBasicSets()`       | [`Set.get_basic_set_list()`][2.3]  |
| Is Equal            | `isl_map.c: isl_set_is_equal(set1, set2)`                   | `ISLSet.isEqual(set)`         | [`Set.is_equal(set)`][2.4]         |
| Make Disjoint       | `isl_map_subtract.c: isl_set_make_disjoint(set)`            | `ISLSet.makeDisjoint()`       | [`Set.make_disjoint()`][2.5]       |
| Remove Redundancies | `isl_convex_hull.c: isl_basic_set_remove_redundancies(set)` | `ISLSet.removeReduncancies()` | [`Set.remove_redundancies()`][2.6] |

*Note: I found several cases of the function `isl_basic_set_list_get_basic_set(set, idx)`, but could not find where it was declared.

[2.1]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.convex_hull
[2.2]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.get_basic_sets
[2.3]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.get_basic_set_list
[2.4]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.is_equal
[2.5]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.make_disjoint
[2.6]: https://documen.tician.de/islpy/ref_set.html#islpy.BasicSet.remove_redundancies
