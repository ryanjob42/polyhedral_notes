# Function Quick Guide
A quick guide to some helpful functions in ISL.
These are broken up by the type they work with.
If a function works with multiple types, I put it in the sections that make the most sense to me.
This sometimes results in duplicates, which is OK.
If there isn't an exactly equivalent function, but one that's close,
I just put that one down.

- [Sets](#sets)

## Sets

| Description        | ISL Function                                       | Java Bindings                 | ISLPy Bindings                  |
| ------------------ | -------------------------------------------------- | ----------------------------- | ------------------------------- |
| Convex Hull        | `isl_convex_hull.c: isl_set_convex_hull(set)`      | `ISLSet.convexHull()`         | [`Set.convex_hull()`][1]        |
| Get Basic Set At   | `???: isl_basic_set_list_get_basic_set(set, idx)`* | `ISLSet.getBasicSetAt(index)` | [`Set.get_basic_sets()`][2]     |
| Get Basic Set List | `isl_map.c: isl_set_get_basic_set_list(set)`       | `ISLSet.getBasicSets()`       | [`Set.get_basic_set_list()`][3] |
| Is Equal           | `isl_map.c: isl_set_is_equal(set1, set2)`          | `ISLSet.isEqual(set)`         | [`Set.is_equal(set)`][4]        |
| Make Disjoint      | `isl_map_subtract.c: isl_set_make_disjoint(set)`   | `ISLSet.makeDisjoint()`       | [`Set.make_disjoint()`][5]      |

*Note: I found several cases of the function `isl_basic_set_list_get_basic_set(set, idx)`, but could not find where it was declared.

[1]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.convex_hull
[2]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.get_basic_sets
[3]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.get_basic_set_list
[4]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.is_equal
[5]: https://documen.tician.de/islpy/ref_set.html#islpy.Set.make_disjoint
