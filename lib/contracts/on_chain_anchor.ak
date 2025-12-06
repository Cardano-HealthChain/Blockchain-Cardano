use contracts/common.{Result, Ok, Error}

// On-Chain Anchor Service








pub type Did = ByteArray
pub type Hash = ByteArray
pub type Time = Int


fn and_then(r: Result<a, e>, f: fn(a) -> Result<b, e>) -> Result<b, e> {
  when r is {
    Ok(a) -> f(a)
    Error(e) -> Error(e)
  }
}


pub type Anchor {
    data_hash: Hash,
    did: Did,
    timestamp: Time,
    expires_at: Option<Time>
}

pub type AnchorError {
    HashMismatch { expected: Hash, actual: Hash }
    DidMismatch { expected: Did, actual: Did }
    Expired { at: Time }
    InvalidExpiry { expires_at: Time, timestamp: Time }
}

pub fn create_anchor(
    data_hash: Hash,
    did: Did,
    timestamp: Time,
    expires_at: Option<Time>,
) -> Result<Anchor, AnchorError> {
    when expires_at is {
        Some(expiry) ->
            if expiry <= timestamp {
                Error(InvalidExpiry { expires_at: expiry, timestamp })
            } else {
                Ok(Anchor { data_hash, did, timestamp, expires_at })
            }

        None ->
            Ok(Anchor { data_hash, did, timestamp, expires_at })
    }
}

pub fn verify_anchor_hash(anchor: Anchor, expected_hash: Hash) -> Result<Void, AnchorError> {
    if anchor.data_hash == expected_hash {
        Ok(Void)
    } else {
        Error(HashMismatch { expected: expected_hash, actual: anchor.data_hash })
    }
}

pub fn verify_anchor_did(anchor: Anchor, expected_did: Did) -> Result<Void, AnchorError> {
    if anchor.did == expected_did {
        Ok(Void)
    } else {
        Error(DidMismatch { expected: expected_did, actual: anchor.did })
    }
}

pub fn assert_anchor_fresh(anchor: Anchor, current_time: Time) -> Result<Void, AnchorError> {
    when anchor.expires_at is {
        Some(expiry) ->
            if current_time <= expiry {
                Ok(Void)
            } else {
                Error(Expired { at: current_time })
            }

        None ->
            Ok(Void)
    }
}

pub fn verify_anchor(
    anchor: Anchor,
    expected_hash: Hash,
    expected_did: Did,
    current_time: Time,
) -> Result<Void, AnchorError> {
    anchor
        |> verify_anchor_hash(expected_hash)
        |> and_then(fn(_) { verify_anchor_did(anchor, expected_did) })
        |> and_then(fn(_) { assert_anchor_fresh(anchor, current_time) })
}