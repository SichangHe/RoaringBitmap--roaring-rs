use vstd::prelude::*;

verus! {

pub const ACCEPTED: u8 = 0;
pub const DUPLICATE: u8 = 1;
pub const OUT_OF_ORDER: u8 = 2;

pub struct Transition {
    pub first: u16,
    pub second: u16,
    pub outcome: u8,
}

pub open spec fn decode_le_spec(low: u8, high: u8) -> int {
    low as int + (high as int) * 256
}

pub open spec fn outcome_spec(first: u16, second: u16) -> u8 {
    if second < first {
        OUT_OF_ORDER
    } else if second == first {
        DUPLICATE
    } else {
        ACCEPTED
    }
}

fn decode_le(low: u8, high: u8) -> (value: u16)
    ensures
        value as int == decode_le_spec(low, high),
{
    let low_word = low as u16;
    let high_word = high as u16;
    assert((high_word as int) * 256 + low_word as int <= u16::MAX as int);
    high_word * 256u16 + low_word
}

fn step(first: u16, second: u16) -> (outcome: u8)
    ensures
        outcome == outcome_spec(first, second),
        (outcome == ACCEPTED) == (first < second),
        (outcome == DUPLICATE) == (first == second),
        (outcome == OUT_OF_ORDER) == (second < first),
{
    if second < first {
        OUT_OF_ORDER
    } else if second == first {
        DUPLICATE
    } else {
        ACCEPTED
    }
}

fn decode_and_step(
    first_low: u8,
    first_high: u8,
    second_low: u8,
    second_high: u8,
) -> (result: Transition)
    ensures
        result.first as int == decode_le_spec(first_low, first_high),
        result.second as int == decode_le_spec(second_low, second_high),
        result.outcome == outcome_spec(result.first, result.second),
        (result.outcome == ACCEPTED) == (result.first < result.second),
        (result.outcome == DUPLICATE) == (result.first == result.second),
        (result.outcome == OUT_OF_ORDER) == (result.second < result.first),
{
    let first = decode_le(first_low, first_high);
    let second = decode_le(second_low, second_high);
    let outcome = step(first, second);
    Transition { first, second, outcome }
}

proof fn every_pair_has_exactly_one_outcome(first: u16, second: u16)
    ensures
        outcome_spec(first, second) == ACCEPTED
            || outcome_spec(first, second) == DUPLICATE
            || outcome_spec(first, second) == OUT_OF_ORDER,
        !(outcome_spec(first, second) == ACCEPTED
            && outcome_spec(first, second) == DUPLICATE),
        !(outcome_spec(first, second) == ACCEPTED
            && outcome_spec(first, second) == OUT_OF_ORDER),
        !(outcome_spec(first, second) == DUPLICATE
            && outcome_spec(first, second) == OUT_OF_ORDER),
{
}

fn main() {
    let accepted = decode_and_step(0xff, 0, 0, 1);
    assert(accepted.first == 255);
    assert(accepted.second == 256);
    assert(accepted.outcome == ACCEPTED);

    let duplicate = decode_and_step(0xff, 0xff, 0xff, 0xff);
    assert(duplicate.first == u16::MAX);
    assert(duplicate.second == u16::MAX);
    assert(duplicate.outcome == DUPLICATE);

    let descending = decode_and_step(0, 1, 0xff, 0);
    assert(descending.first == 256);
    assert(descending.second == 255);
    assert(descending.outcome == OUT_OF_ORDER);

    proof {
        every_pair_has_exactly_one_outcome(accepted.first, accepted.second);
        every_pair_has_exactly_one_outcome(duplicate.first, duplicate.second);
        every_pair_has_exactly_one_outcome(descending.first, descending.second);
    }
}

}
