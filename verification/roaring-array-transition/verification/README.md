# Executable Verus harness

`array_pair_transition.rs` models only the selected two-value array-container transition.

For arbitrary four input bytes it proves:

- each `u16` equals the mathematical little-endian decode
- the second value is accepted exactly when it is greater than the first
- equality is classified only as duplicate
- decrease is classified only as out of order
- the three outcomes are mutually exclusive and exhaustive

The harness contains no assumptions, admits, external bodies, or assumed specifications. Verus compiles it to a native executable, whose `main` exercises accepted, duplicate, and descending full-width cases.

The proof is standalone. Its connection to the pinned production path is the finite differential executable in `counterexample-search`, not a formal refinement proof of `RoaringBitmap::deserialize_from` or `ArrayStore::try_from`.
