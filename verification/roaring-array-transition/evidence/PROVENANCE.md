# Reproducibility provenance

## Source identity

- package: `roaring` 0.11.4
- release commit: `83caaca2ec5ea29e27dc19f930b9450b9a246b5b`
- release tree: `44d203ac98e6e491051c5d10a0b2105730db46d6`
- crate archive SHA-256: `1dedc5658c6ecb3bdb5ef5f3295bb9253f42dcf3fd1402c03f6b1f7659c3c4a9`
- `roaring/src/bitmap/serialization.rs` SHA-256: `a909a8127a7eb218d3b4c860db7cc34077cc0597631b42ad26dfeffe5d5a928c`
- `roaring/src/bitmap/store/array_store/mod.rs` SHA-256: `d7fa1b3a201c9b09dbeb33b97477be5e70bfab5c6dd49c931da813c8371e8723`

## Reviewed-content correspondence

The pre-commit packet passed independent read-only review with frozen manifest SHA-256 `90bf1b43d315da12b3201591cb924e9f07fab6f4beb4abf463b4a81ae391a11d`.

These files are exact copies from that packet:

- `SCOPE.md`: `565b286889423a9fd1bbe1b104d1f5e5bd54a943085646979b1542771ba17721`
- `counterexample-search/Cargo.lock`: `b1dbd375cac72e2d0085857357cb9561493a3e583998f24c2caf20455044893e`
- `counterexample-search/README.md`: `bc7f3b955da600de49f90500af8075f4a9b4234dfc61d401585b8c044b9a4524`
- `counterexample-search/src/main.rs`: `fbbc6170f03132ee70f55164667585c6fe7d08739e87531b4d6cc6a0e287259a`
- `verification/README.md`: `05f51444393e4163a4d993fb2e03c7d8d646ed7c4d6323a32c9b1fde68d58c26`
- `verification/array_pair_transition.rs`: `4cc52f06b1d700f6ae6e15cfa5bfa19224e64db533a69dd428977c81ea74fc58`

The reviewed harness manifest had SHA-256 `cdc1739d8c9e6c0cba5f40e285c4312589236e256b612400087d96f04fd48cd4`. The portable manifest has SHA-256 `4453cbe14aae8a7dce6db6789d044b41b687efe9172784c6612ff2dee6a1063f`; its only textual change is the `roaring` dependency path from the prior artifact layout to `../../../roaring` in this repository.

## Reviewed result and limits

- finite production search: no counterexample in `65,536` exhaustive low-byte pairs plus ten full-width boundary pairs
- Verus: `8 verified, 0 errors` with `--no-cheating --compile`; native executable passed
- Verus version: `0.2025.11.30.840fa61`
- verifier executable SHA-256 used for the reviewed run: `59659856b1cc28264a8d21dc11707feb435f801ff386949d60c7ab5a995e7365`
- host boundary: default `std` only; nightly-only `simd` excluded
- route boundary: public ordinary issue tracker only; no private route established
- claim boundary: bounded no-defect result, not a production refinement proof or security claim

The exact portable commit identity, patch, bundle, tree listing, and checksums are frozen outside the commit to avoid self-reference.
