# Scope

Status: one transition selected after bounded source inspection and before the pre-edit search.

## Included

- canonical `RoaringBitmap/roaring-rs` release `0.11.4` at tag commit `83caaca2ec5ea29e27dc19f930b9450b9a246b5b`
- public checked `RoaringBitmap::deserialize_from` with exactly one non-run array container
- encoded container cardinality exactly two and container key zero
- the single `ArrayStore::try_from` transition from the first decoded `u16` to the second
  - lower second value becomes `OutOfOrder`, then public `InvalidData`
  - equal second value becomes `Duplicate`, then public `InvalidData`
  - greater second value is accepted as `Store::Array`
- little-endian decoding of those two values
- a standalone executable Verus transition model plus focused host checks against the pinned public production path

## Excluded

- array containers of any cardinality other than two
- run and bitmap containers, array/bitmap threshold selection, multiple containers, nonzero keys, and offset tables
- cookie acceptance, container-count arithmetic, key ordering, truncation outside the four selected value bytes, and trailing-byte policy
- full bitmap deserialization, reserialization, or set-equivalence claims
- `RoaringTreemap`, set operations, mutation APIs, rank/select, range insertion, allocation, performance, denial-of-service, and unsafe-code claims
- unrelated source changes, publication, contact, forks, commits, pushes, issues, pull requests, reviewers, and evaluators

The finite production bridge exhausts every ordered pair in `0..=255`, expressed as little-endian `u16` values with zero high bytes, and checks selected full-width boundary pairs. The proof models the selected transition for arbitrary four input bytes.
