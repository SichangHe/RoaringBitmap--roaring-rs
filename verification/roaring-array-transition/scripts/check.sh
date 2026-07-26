#!/bin/sh
set -eu

base='83caaca2ec5ea29e27dc19f930b9450b9a246b5b'
base_tree='44d203ac98e6e491051c5d10a0b2105730db46d6'
packet_rel='verification/roaring-array-transition'
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
packet_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
repo_root=$(git -C "$packet_dir" rev-parse --show-toplevel)
search="$packet_dir/counterexample-search/Cargo.toml"
proof="$packet_dir/verification/array_pair_transition.rs"
scratch=$(mktemp -d /tmp/roaring-array-portable.XXXXXX)
trap 'rm -r -- "$scratch"' EXIT

test "$(git -C "$repo_root" rev-parse "$base^{tree}")" = "$base_tree"
test "$(git -C "$repo_root" rev-parse --abbrev-ref HEAD)" = 'HEAD'
if git -C "$repo_root" show-ref --quiet; then
    exit 1
fi
test "$(git -C "$repo_root" remote get-url upstream)" = 'https://github.com/RoaringBitmap/roaring-rs.git'
test "$(git -C "$repo_root" remote get-url --push upstream)" = 'DISABLED_BY_STAGE1_POLICY'
test "$(git -C "$repo_root" config --local push.default)" = 'nothing'

cat >"$scratch/expected-files" <<'EOF'
verification/roaring-array-transition/README.md
verification/roaring-array-transition/SCOPE.md
verification/roaring-array-transition/counterexample-search/Cargo.lock
verification/roaring-array-transition/counterexample-search/Cargo.toml
verification/roaring-array-transition/counterexample-search/README.md
verification/roaring-array-transition/counterexample-search/src/main.rs
verification/roaring-array-transition/evidence/PROVENANCE.md
verification/roaring-array-transition/scripts/check.sh
verification/roaring-array-transition/verification/README.md
verification/roaring-array-transition/verification/array_pair_transition.rs
EOF

head=$(git -C "$repo_root" rev-parse HEAD)
if test "$head" = "$base"; then
    (cd "$repo_root" && find "$packet_rel" -type f -printf '%p\n' | LC_ALL=C sort) >"$scratch/actual-files"
else
    test "$(git -C "$repo_root" rev-parse HEAD^)" = "$base"
    test "$(git -C "$repo_root" rev-list --count "$base..HEAD")" = '1'
    git -C "$repo_root" diff --name-only "$base" HEAD | LC_ALL=C sort >"$scratch/actual-files"
    test -z "$(git -C "$repo_root" status --porcelain=v1)"
    git -C "$repo_root" diff --check "$base" HEAD
fi
cmp "$scratch/expected-files" "$scratch/actual-files"
git -C "$repo_root" diff --quiet "$base" -- roaring/src

test "$(sha256sum "$packet_dir/SCOPE.md" | awk '{print $1}')" = '565b286889423a9fd1bbe1b104d1f5e5bd54a943085646979b1542771ba17721'
test "$(sha256sum "$packet_dir/counterexample-search/Cargo.lock" | awk '{print $1}')" = 'b1dbd375cac72e2d0085857357cb9561493a3e583998f24c2caf20455044893e'
test "$(sha256sum "$packet_dir/counterexample-search/Cargo.toml" | awk '{print $1}')" = '4453cbe14aae8a7dce6db6789d044b41b687efe9172784c6612ff2dee6a1063f'
test "$(sha256sum "$packet_dir/counterexample-search/README.md" | awk '{print $1}')" = 'bc7f3b955da600de49f90500af8075f4a9b4234dfc61d401585b8c044b9a4524'
test "$(sha256sum "$packet_dir/counterexample-search/src/main.rs" | awk '{print $1}')" = 'fbbc6170f03132ee70f55164667585c6fe7d08739e87531b4d6cc6a0e287259a'
test "$(sha256sum "$packet_dir/verification/README.md" | awk '{print $1}')" = '05f51444393e4163a4d993fb2e03c7d8d646ed7c4d6323a32c9b1fde68d58c26'
test "$(sha256sum "$proof" | awk '{print $1}')" = '4cc52f06b1d700f6ae6e15cfa5bfa19224e64db533a69dd428977c81ea74fc58'
test "$(sha256sum "$repo_root/roaring/src/bitmap/serialization.rs" | awk '{print $1}')" = 'a909a8127a7eb218d3b4c860db7cc34077cc0597631b42ad26dfeffe5d5a928c'
test "$(sha256sum "$repo_root/roaring/src/bitmap/store/array_store/mod.rs" | awk '{print $1}')" = 'd7fa1b3a201c9b09dbeb33b97477be5e70bfab5c6dd49c931da813c8371e8723'
grep -Fqx 'roaring = { path = "../../../roaring" }' "$packet_dir/counterexample-search/Cargo.toml"

private_pattern='/ss''d1/|/ho''me/|/Us''ers/|[A-Za-z]:\\Us''ers\\|work_''logs|vl_''experiments'
credential_pattern='gh''[pousr]_[[:alnum:]]{20,}|github_''pat_|AK''IA[0-9A-Z]{16}|PRIVATE K''EY-----|Authoriza''tion:[[:space:]]|pass''word[[:space:]]*=|to''ken[[:space:]]*='
unfinished_pattern='TO''DO|FIX''ME|T''BD|W''IP|PLACE''HOLDER|unimplemented![(]|todo![(]'
url_value_pattern="ht""tps?://[^\"'[:space:]]+"
if rg -n -i "$private_pattern" "$packet_dir"; then
    exit 1
fi
if rg -n -i "$credential_pattern" "$packet_dir"; then
    exit 1
fi
if rg -n "$unfinished_pattern" "$packet_dir"; then
    exit 1
fi
(cd "$packet_dir" && rg --no-filename -o "$url_value_pattern" . | LC_ALL=C sort) >"$scratch/actual-urls"
{
    printf '%s\n' 'ht''tps://github.com/RoaringBitmap/roaring-rs.git'
    printf '%s\n' 'ht''tps://github.com/rust-lang/crates.io-index'
    printf '%s\n' 'ht''tps://github.com/rust-lang/crates.io-index'
} >"$scratch/expected-urls"
cmp "$scratch/expected-urls" "$scratch/actual-urls"

sh -n "$0"
cargo fmt --check --manifest-path "$search" -- --config use_small_heuristics=Default
env CARGO_TARGET_DIR="$scratch/search-target" cargo clippy --quiet --offline --locked --no-deps --all-targets --manifest-path "$search" -- -D warnings >"$scratch/search-clippy.stdout" 2>&1
env CARGO_TARGET_DIR="$scratch/search-target" cargo test --quiet --offline --locked --manifest-path "$search" >"$scratch/search-test.stdout" 2>&1
env CARGO_TARGET_DIR="$scratch/search-target" cargo run --quiet --offline --release --locked --manifest-path "$search" >"$scratch/search.stdout"
grep -Fq 'status=no-counterexample' "$scratch/search.stdout"
grep -Fq 'exhaustive_cases=65536' "$scratch/search.stdout"
grep -Fq 'boundary_cases=10' "$scratch/search.stdout"

if rg -n '\b(assume|admit|external_body|assume_specification)\b' "$proof"; then
    exit 1
fi
verus_bin=${VERUS:-}
test -n "$verus_bin"
test -x "$verus_bin"
"$verus_bin" --version >"$scratch/verus-version.stdout"
grep -Fq '0.2025.11.30.840fa61' "$scratch/verus-version.stdout"
mkdir -p "$scratch/proof"
cp "$proof" "$scratch/proof/"
(cd "$scratch/proof" && "$verus_bin" --no-cheating --compile array_pair_transition.rs >verus.stdout && ./array_pair_transition)
grep -Fq 'verification results:: 8 verified, 0 errors' "$scratch/proof/verus.stdout"

if test "$head" != "$base"; then
    test -z "$(git -C "$repo_root" status --porcelain=v1)"
fi
printf '%s\n' 'portable_checks=pass'
