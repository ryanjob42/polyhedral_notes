# Feature Comparison
A comparison of the features available in the two different versions of AlphaZ.
I have not verified if any of these commabnds work, only that they claim to exist.

- [Core Commands](#core-commands)
- [Reduction Commands](#reduction-commands)
- [Transformation Commands](#transformation-commands)
- [Utility Commands](#utility-commands)
- [Analysis Commands](#analysis-commands)
- [Calculator Commands](#calculator-commands)
- [Code Generation Commands](#code-generation-commands)
- [Target Mapping](#target-mapping)

## Core Commands
Commands that are useful to the basic operation of the AlphaZ compiler.
The `RenameVariable` and `WriteToFile` commands should be categorized as "Utility" commands,
but since they're the only "Utility" commands common to both, I put them here.

| Command                  | CSU AlphaZ | Inria AlphaZ | Notes                                                                          |
| ------------------------ | :--------: | :----------: | ------------------------------------------------------------------------------ |
| ASave, Save              |     X      |      X       |                                                                                |
| ASaveSystem, SaveSystem  |     X      |              |                                                                                |
| AShow, Show              |     X      |      X       |                                                                                |
| CheckProgram             |     X      |      X       |                                                                                |
| CheckSystem              |     X      |              |                                                                                |
| PrintAST                 |     X      |      X       |                                                                                |
| ReadAlpha, ReadAlphabets |     X      |      X       |                                                                                |
| ReadAlphaBundle          |            |      X       | Reads a whole folder of Alpha files.                                           |
| RenameVariable           |     X      |      X       | Inria AlphaZ categorizes this as a "Utility" command.                          |
| WriteToFile              |     X      |      X       | Writes a string to a file. Both AlphaZ categorize this as a "Utility" command. |

## Reduction Commands
Commands that apply transformations to reduction expressions.
These are technically a subset of the "Transformation" category,
but both categories are large enough where I wanted to split them.

| Command                    | CSU AlphaZ | Inria AlphaZ | Notes                                                                                                   |
| -------------------------- | :--------: | :----------: | ------------------------------------------------------------------------------------------------------- |
| DetectReductions           |     X      |              |                                                                                                         |
| Distributivity             |            |      X       | Automatically applies the `FactorOutFromReduction` command.                                             |
| FactorOutFromReduction     |     X      |      X       | CSU AlphaZ does not check legality, but Inria AlphaZ does.                                              |
| ForceCoB                   |     X      |              |                                                                                                         |
| HigherOrderOperations      |            |      X       | Converts a summation reduction into a multiplication (if legal).                                        |
| HoistOutOfReduction        |            |      X       | Converts a reduction of the form `reduce(op, f, E1 op E2)` to `reduce(op, f, E1) op reduce(op, f, E2)`. |
| Idempotence                |            |      X       | No clue what this does.                                                                                 |
| MergeReductions            |     X      |              |                                                                                                         |
| NormalizeReduction         |     X      |      X       |                                                                                                         |
| PermutationCaseReduce      |     X      |      X       |                                                                                                         |
| ReductionComposition       |     X      |      X       |                                                                                                         |
| Reduction Decomposition    |     X      |      X       |                                                                                                         |
| SameOperatorSimplification |            |      X       | Automatically applies the `HoistOutOfReduction` command.                                                |
| SerializeReduction         |     X      |              |                                                                                                         |
| Simplifying Reductions     |     X      |      X       |                                                                                                         |
| SplitReductionBody         |     X      |              |                                                                                                         |
| TransformReductionBody     |     X      |              |                                                                                                         |

## Transformation Commands
Commands that apply transformations to expressions.
Note: the transformation commands that apply to reduction expressions
are separated out into their own [Reduction Commands](#reduction-commands) category.

| Command                                                                                                                  | CSU AlphaZ | Inria AlphaZ | Notes                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------ | :--------: | :----------: | --------------------------------------------------------------------------------------- |
| AddLocal, AddLocalUnique                                                                                                 |     X      |              |                                                                                         |
| alignDimVariable                                                                                                         |     X      |              |                                                                                         |
| ApplySTMap                                                                                                               |     X      |              |                                                                                         |
| CoB, ChangeOfBasis                                                                                                       |     X      |      X       |                                                                                         |
| createFreeScheduler                                                                                                      |     X      |              |                                                                                         |
| Inline, InlineForce, <br/> InlineAll, InlineAllForce, <br/> InlineSubsystem                                              |     X      |              | There may be some semi-equivalent commands in Inria AlphaZ, but with different names.   |
| LiftAutoRestrict                                                                                                         |            |      X       |                                                                                         |
| Merge                                                                                                                    |     X      |              |                                                                                         |
| monoparametricTiling_noOutlining, <br/> monoparametricTiling_Outlining, <br/> monoparametricTiling_Outlining_noSubsystem |     X      |              |                                                                                         |
| Normalize, DeepNormalize                                                                                                 |     X*     |      X       | *DeepNormalize is only available in Inria AlphaZ, but it does basically the same thing. |
| OutlineSubSystem                                                                                                         |     X      |              |                                                                                         |
| PropagateSimpleEquations                                                                                                 |            |      X       | Might be similar to the CSU AlphaZ "InlineAll" command.                                 |
| reduceDimVariable                                                                                                        |     X      |              |                                                                                         |
| RemoveUnusedVariables, RemoveUnusedEquations                                                                             |     X      |      X       |                                                                                         |
| setCoBPreprocess                                                                                                         |     X      |              |                                                                                         |
| setMinParamValues                                                                                                        |     X      |              |                                                                                         |
| setRatio                                                                                                                 |     X      |              |                                                                                         |
| setTileGroup                                                                                                             |     X      |              |                                                                                         |
| Simplify, SimplifyExpressions                                                                                            |     X      |      X       | I'm only assuming these commands are the same, I haven't double checked. TODO.          |
| Split                                                                                                                    |     X      |              |                                                                                         |
| SplitUnion, SplitUnionIntoCase                                                                                           |     X      |      X       | I'm only assuming these commands are the same, I haven't double checked. TODO.          |
| SubstituteByDef                                                                                                          |            |      X       | Might be similar to some of the CSU AlphaZ "Inline" commands.                           |
| UniformizeInContext                                                                                                      |     X      |              |                                                                                         |

## Utility Commands
Miscellaneous commands for operating the AlphaZ compiler.
The `RenameVariable` and `WriteToFile` commands should be categorized here,
but they're the only commands common to both compilers, 
so I categorized them as "Core" commands.
This way, I can break up the "Utility" commands per compiler.

The table below lists the CSU AlphaZ "Utility" commands.

| Command           | Notes                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| parseIntegerArray |                                                                                                                                |
| print             | Inria AlphaZ is supposed to be programmed via Groovy, which has its own standard library function for printing to the console. |
| readDomain        |                                                                                                                                |
| readFunction      |
| renameSystem      |
| stringListToArray |
| True, False       | Inria AlphaZ is supposed to be programmed via Groovy, which has its own support for boolean literals.                          |

The table below lists the Inria AlphaZ "Utility" commands.
These are all for specifying individual parts of a program.
CSU AlphaZ typically implements this by having the function accept a string
with either a name or an AST node ID.

| Command       | Notes                                                |
| ------------- | ---------------------------------------------------- |
| GetEquation   |                                                      |
| GetExpression |                                                      |
| GetNode       |                                                      |
| GetRoot       | Gets a specific "root" (file?) from an Alpha bundle. |
| GetSystem     | Gets a specific system from an Alpha "root".         |
| GetSystemBody | Gets only the "while" and "let" parts of the system. |
| GetVariable   |                                                      |

## Analysis Commands
The table below lists the "Analysis" commands.
These are all exclusive to the CSU AlphaZ.

| Command                  | Notes |
| ------------------------ | ----- |
| BuildPRDG                |       |
| ExportPRDG               |       |
| Farkas1DScheduler        |       |
| FarkasMDScheduler        |       |
| PlutoScheduler           |       |
| printScheduledStatements |       |
| revertPRDGEdges          |       |
| VerifyTargetMapping      |       |

## Calculator Commands
The table below lists the "Calculator" commands.
These are all exclusive to CSU AlphaZ.

| Command           | Notes |
| ----------------- | ----- |
| compose           |       |
| difference        |       |
| image             |       |
| intersection      |       |
| inverse           |       |
| inverseInContext  |       |
| isEmpty           |       |
| isEquivalent      |       |
| join              |       |
| preImage          |       |
| readDomain        |       |
| readFunction      |       |
| simplifyInContext |       |
| union             |       |

## Code Generation Commands
The table below lists the "Code Generation" commands.
These are all exclusive to CSU AlphaZ.
Inria AlphaZ does not implement its own code generator.
As a workaround, you must apply the desired functions to the Inria Alpha program
(using the Inria AlphaZ compiler), save the program to a file,
then read that file into CSU AlphaZ and use
CSU AlphaZ commands to set schedules and generate code.

| Command                                 | Notes |
| --------------------------------------- | ----- |
| addRecursionDepthForPCOT                |       |
| createCGOptionForHybridScheduledC       |       |
| createCGOptionForHybridScheduledCGPU    |       |
| createCGOptionForScheduledC             |       |
| createCGOptionForWriteC                 |       |
| createCGOptionsForPCOT                  |       |
| createTiledCGOptionForScheduledC        |       |
| generateFMPPCode                        |       |
| generateMakefile                        |       |
| generateMakefileInternal                |       |
| generatePCOTCode                        |       |
| generateScanC                           |       |
| generateScheduledCode                   |       |
| generateVerificationCode                |       |
| generateWrapper                         |       |
| generateWriteC                          |       |
| getDefaultCodeGenOptions                |       |
| setCGOptionDisableNormalize_depreciated |       |
| setCGOptionFlattenArrays                |       |
| setTiledCGOptionOptimize                |       |
| setVecOptionForTiledC                   |       |
| setVecVarForTiledC                      |       |
| setVecVarsForTiledC                     |       |

## Target Mapping
The table below lists the "Target Mapping" commands.
These are all exclusive to the CSU AlphaZ.

| Command                                   | Notes |
| ----------------------------------------- | ----- |
| CreateSpaceTimeLevel                      |       |
| listMemoryMaps                            |       |
| listSpaceTimeMaps                         |       |
| setBandForTiling                          |       |
| setDefaultDTilerConfiguration             |       |
| setMemoryMap                              |       |
| setMemorySpace                            |       |
| setMemorySpaceForUseEquationOptimization  |       |
| setOrderingDimensions                     |       |
| setParallel                               |       |
| setSchedule                               |       |
| setSpaceTimeMap                           |       |
| setSpaceTimeMapForMemoryAllocation        |       |
| setSpaceTimeMapForMemoryFree              |       |
| setSpaceTimeMapForUseEquationOptimization |       |
| setSpaceTimeMapForValueCopy               |       |
| setStatementOrdering                      |       |
| setSubTilingWithinBand                    |       |
