///|
fn path_intersection(left : PathScope, right : PathScope) -> PathScope? {
  if path_contains(left, right) {
    Some(right)
  } else if path_contains(right, left) {
    Some(left)
  } else {
    None
  }
}

///|
fn command_intersection(
  left : CommandScope,
  right : CommandScope,
) -> CommandScope? {
  if command_contains(left, right) {
    Some(right)
  } else if command_contains(right, left) {
    Some(left)
  } else {
    None
  }
}

///|
fn host_intersection(left : HostScope, right : HostScope) -> HostScope? {
  if host_contains(left, right) {
    Some(right)
  } else if host_contains(right, left) {
    Some(left)
  } else {
    None
  }
}

///|
fn data_class_intersection(left : DataClass, right : DataClass) -> DataClass {
  if data_class_rank(left) <= data_class_rank(right) {
    left
  } else {
    right
  }
}

///|
fn network_intersection(
  left : NetworkScope,
  right : NetworkScope,
) -> NetworkScope? {
  guard host_intersection(left.host, right.host) is Some(host) else {
    return None
  }
  let methods : Array[String] = []
  for http_method in left.methods {
    if right.methods.contains(http_method) {
      methods.push(http_method)
    }
  }
  if methods.is_empty() {
    return None
  }
  Some({
    host,
    methods,
    max_data_class: data_class_intersection(
      left.max_data_class,
      right.max_data_class,
    ),
  })
}

///|
pub fn effect_intersection(
  left : EffectScope,
  right : EffectScope,
) -> EffectScope? {
  match (left, right) {
    (FileRead(left), FileRead(right)) =>
      path_intersection(left, right).map(path => EffectScope::FileRead(path))
    (FileWrite(left), FileWrite(right)) =>
      path_intersection(left, right).map(path => EffectScope::FileWrite(path))
    (FileDelete(left), FileDelete(right)) =>
      path_intersection(left, right).map(path => EffectScope::FileDelete(path))
    (ProcessExec(left), ProcessExec(right)) =>
      command_intersection(left, right).map(command => {
        EffectScope::ProcessExec(command)
      })
    (NetworkSend(left), NetworkSend(right)) =>
      network_intersection(left, right).map(network => {
        EffectScope::NetworkSend(network)
      })
    (SecretRead(left), SecretRead(right)) =>
      if left != "" && left == right {
        Some(EffectScope::SecretRead(left))
      } else {
        None
      }
    _ => None
  }
}

///|
fn optional_int_min(left : Int?, right : Int?) -> Int? {
  match (left, right) {
    (None, value) | (value, None) => value
    (Some(left), Some(right)) => Some(if left <= right { left } else { right })
  }
}

///|
fn optional_int64_min(left : Int64?, right : Int64?) -> Int64? {
  match (left, right) {
    (None, value) | (value, None) => value
    (Some(left), Some(right)) => Some(if left <= right { left } else { right })
  }
}

///|
pub fn budget_intersection(left : Budget, right : Budget) -> Budget {
  {
    max_calls: optional_int_min(left.max_calls, right.max_calls),
    max_bytes: optional_int64_min(left.max_bytes, right.max_bytes),
    expires_at: optional_int64_min(left.expires_at, right.expires_at),
  }
}
