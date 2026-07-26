# Counterexample search

This executable calls the pinned public checked `RoaringBitmap::deserialize_from` path with one non-run, two-value array container.

It exhausts all `65,536` ordered pairs whose high bytes are zero and checks ten selected full-width boundary pairs. The independent oracle classifies the second-value transition as accepted, duplicate, or out of order. Accepted cases must decode to exactly the two input values; rejected cases must expose the corresponding `InvalidData` reason.

This finite search is direct production evidence only for the domain in `SCOPE.md`. It is not a proof over all `u16` pairs.
