///|
pub fn budget(
  max_calls? : Int,
  max_bytes? : Int64,
  expires_at? : Int64,
) -> Budget raise PermitError {
  match max_calls {
    Some(limit) => if limit <= 0 { raise PermitError::InvalidCallLimit(limit) }
    None => ()
  }
  match max_bytes {
    Some(limit) => if limit < 0L { raise PermitError::InvalidByteLimit(limit) }
    None => ()
  }
  match expires_at {
    Some(expiry) => if expiry < 0L { raise PermitError::InvalidExpiry(expiry) }
    None => ()
  }
  { max_calls, max_bytes, expires_at, }
}

///|
pub fn unlimited_budget() -> Budget {
  { max_calls: None, max_bytes: None, expires_at: None, }
}

///|
pub fn Budget::max_calls(self : Budget) -> Int? {
  self.max_calls
}

///|
pub fn Budget::max_bytes(self : Budget) -> Int64? {
  self.max_bytes
}

///|
pub fn Budget::expires_at(self : Budget) -> Int64? {
  self.expires_at
}

///|
fn optional_int_contains(grant : Int?, requested : Int?) -> Bool {
  match (grant, requested) {
    (None, _) => true
    (Some(_), None) => false
    (Some(grant), Some(requested)) => requested <= grant
  }
}

///|
fn optional_int64_contains(grant : Int64?, requested : Int64?) -> Bool {
  match (grant, requested) {
    (None, _) => true
    (Some(_), None) => false
    (Some(grant), Some(requested)) => requested <= grant
  }
}

///|
pub fn budget_contains(grant : Budget, requested : Budget) -> Bool {
  optional_int_contains(grant.max_calls, requested.max_calls) &&
  optional_int64_contains(grant.max_bytes, requested.max_bytes) &&
  optional_int64_contains(grant.expires_at, requested.expires_at)
}

///|
fn union_optional_int(left : Int?, right : Int?) -> Int? {
  match (left, right) {
    (None, _) | (_, None) => None
    (Some(left), Some(right)) => Some(if left >= right { left } else { right })
  }
}

///|
fn union_optional_int64(left : Int64?, right : Int64?) -> Int64? {
  match (left, right) {
    (None, _) | (_, None) => None
    (Some(left), Some(right)) => Some(if left >= right { left } else { right })
  }
}

///|
fn budget_union(left : Budget, right : Budget) -> Budget {
  {
    max_calls: union_optional_int(left.max_calls, right.max_calls),
    max_bytes: union_optional_int64(left.max_bytes, right.max_bytes),
    expires_at: union_optional_int64(left.expires_at, right.expires_at),
  }
}

///|
fn optional_int_text(value : Int?) -> String {
  match value {
    Some(value) => "\{value}"
    None => "*"
  }
}

///|
fn optional_int64_text(value : Int64?) -> String {
  match value {
    Some(value) => "\{value}"
    None => "*"
  }
}

///|
fn Budget::canonical(self : Budget) -> String {
  "calls=" +
  optional_int_text(self.max_calls) +
  ";bytes=" +
  optional_int64_text(self.max_bytes) +
  ";expires=" +
  optional_int64_text(self.expires_at)
}
