# Roaring two-value array transition

Status: one local portable experiment commit, pending independent review of the exact commit object.

This packet binds a standalone Verus model to the public checked `RoaringBitmap::deserialize_from` path in `roaring` 0.11.4. It covers exactly one non-run array container with two little-endian `u16` values. The second value is accepted only when it is strictly greater than the first; equality and decrease must return `InvalidData` through the public API.

## Frozen boundaries

- source base: `v0.11.4`, commit `83caaca2ec5ea29e27dc19f930b9450b9a246b5b`
- production feature set: default `std`; the nightly-only `simd` feature is excluded
- finite production bridge: all `65,536` pairs in `0..=255`, plus ten full-width boundary pairs
- formal claim: standalone little-endian decode and three-way ordering transition for arbitrary four input bytes
- result: no counterexample in the bounded production bridge; no production defect or security finding claimed
- reporting boundary: the public issue tracker exists; no private reporting route was established
- excluded behavior: every item listed in `SCOPE.md`

The reviewed proof and harness sources are copied exactly. The harness manifest changes only its local `roaring` dependency from the original artifact layout to this repository-relative path. `evidence/PROVENANCE.md` records the correspondence.

## Reproduce

Use Verus `0.2025.11.30.840fa61` and an offline Cargo cache containing the locked dependencies:

```sh
VERUS="$(command -v verus)" ./scripts/check.sh
```

The checker verifies the one-commit ancestry when run after commit creation, the unchanged production source, the reviewed content hashes, the default-`std` host harness, and the no-cheating executable Verus proof.
