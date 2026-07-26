use roaring::RoaringBitmap;
use std::cmp::Ordering;
use std::io::ErrorKind;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum Outcome {
    Accepted,
    Duplicate,
    OutOfOrder,
}

fn encoded_pair(first: u16, second: u16) -> [u8; 13] {
    let [first_lo, first_hi] = first.to_le_bytes();
    let [second_lo, second_hi] = second.to_le_bytes();
    [
        0x3b, 0x30, 0, 0, // one-container run-cookie header
        0, // the container is not a run container
        0, 0, // container key
        1, 0, // encoded cardinality is two minus one
        first_lo, first_hi, second_lo, second_hi,
    ]
}

fn oracle(first: u16, second: u16) -> Outcome {
    match second.cmp(&first) {
        Ordering::Greater => Outcome::Accepted,
        Ordering::Equal => Outcome::Duplicate,
        Ordering::Less => Outcome::OutOfOrder,
    }
}

fn production(first: u16, second: u16) -> Result<Outcome, String> {
    match RoaringBitmap::deserialize_from(&encoded_pair(first, second)[..]) {
        Ok(bitmap) => {
            let actual: Vec<u32> = bitmap.iter().collect();
            let expected = vec![u32::from(first), u32::from(second)];
            if actual != expected {
                return Err(format!(
                    "accepted pair ({first}, {second}) decoded as {actual:?}"
                ));
            }
            Ok(Outcome::Accepted)
        }
        Err(error) => {
            if error.kind() != ErrorKind::InvalidData {
                return Err(format!(
                    "pair ({first}, {second}) returned unexpected error kind {:?}",
                    error.kind()
                ));
            }
            let message = error.to_string();
            if message.contains("Duplicate element") {
                Ok(Outcome::Duplicate)
            } else if message.contains("out of order") {
                Ok(Outcome::OutOfOrder)
            } else {
                Err(format!(
                    "pair ({first}, {second}) returned unexpected InvalidData: {message}"
                ))
            }
        }
    }
}

fn check(first: u16, second: u16) -> Result<(), String> {
    let expected = oracle(first, second);
    let actual = production(first, second)?;
    if actual == expected {
        Ok(())
    } else {
        Err(format!(
            "counterexample ({first}, {second}): expected {expected:?}, got {actual:?}"
        ))
    }
}

fn main() -> Result<(), String> {
    let mut exhaustive_cases = 0u64;
    for first in 0u16..=u8::MAX.into() {
        for second in 0u16..=u8::MAX.into() {
            check(first, second)?;
            exhaustive_cases += 1;
        }
    }

    let boundary_pairs = [
        (0, 0),
        (0, 1),
        (1, 0),
        (255, 256),
        (256, 255),
        (4095, 4096),
        (4096, 4095),
        (65534, 65535),
        (65535, 65534),
        (65535, 65535),
    ];
    for (first, second) in boundary_pairs {
        check(first, second)?;
    }

    println!("status=no-counterexample");
    println!("exhaustive_cases={exhaustive_cases}");
    println!("boundary_cases={}", boundary_pairs.len());
    Ok(())
}
