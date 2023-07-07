# Repository Overview
Some notes about the alpha-language repo.
This is for the Inria AlphaZ (not the CSU AlphaZ).

## How the Groovy Commands are Supposed to Exist
Currently, the Groovy scripting interface doesn't work at all,
but it's implemented as if it works, so it makes a good
jumping-off point for where to look.

The Groovy scripts are supposed to work by inheriting
a base class called `AlphaScript`, then using the functions it exposes.
This base class is found in the package `alpha.commands.groovy`
as the file `src-gen/alpha.commands.groovy/AlphaScript.groovy`.
From this file, we can see that all these functions
merely call other functions in the `alpha.commands` package.
Similar to the CSU AlphaZ, there is a class for each command category,
and each command is implemented as a static function.
Also similarly, a few of these functions are implemented right there,
but most of these static functions just call other functions
in a variety of other packages.
