///|
fn normalize_host(input : String) -> String raise ScopeError {
  let lowered = input.trim().to_owned().to_lower()
  let host = match lowered.strip_suffix(".") {
    Some(without_dot) => without_dot.to_owned()
    None => lowered
  }
  if host is "" || host.has_prefix(".") || host.has_suffix(".") {
    raise ScopeError::InvalidHost(input)
  }
  for char in host {
    if !(char.is_ascii_alphabetic() ||
      char.is_ascii_digit() ||
      char == '-' ||
      char == '.') {
      raise ScopeError::InvalidHost(input)
    }
  }
  for label_view in host.split(".") {
    let label = label_view.to_owned()
    if label is "" || label.has_prefix("-") || label.has_suffix("-") {
      raise ScopeError::InvalidHost(input)
    }
  }
  host
}

///|
pub fn host_exact(input : String) -> HostScope raise ScopeError {
  { canonical: normalize_host(input), subdomains: false, }
}

///|
pub fn host_and_subdomains(input : String) -> HostScope raise ScopeError {
  { canonical: normalize_host(input), subdomains: true, }
}

///|
pub fn HostScope::canonical(self : HostScope) -> String {
  self.canonical
}

///|
pub fn HostScope::includes_subdomains(self : HostScope) -> Bool {
  self.subdomains
}

///|
pub fn host_contains(grant : HostScope, requested : HostScope) -> Bool {
  if !grant.subdomains {
    return !requested.subdomains && grant.canonical == requested.canonical
  }
  requested.canonical == grant.canonical ||
  requested.canonical.has_suffix("." + grant.canonical)
}

///|
fn normalize_method(input : String) -> String raise ScopeError {
  let http_method = input.trim().to_owned().to_upper()
  if http_method is "" {
    raise ScopeError::InvalidMethod(input)
  }
  for char in http_method {
    if !(char.is_ascii_uppercase() || char == '-') {
      raise ScopeError::InvalidMethod(input)
    }
  }
  http_method
}

///|
pub fn network_scope(
  host : HostScope,
  methods : Array[String],
  max_data_class : DataClass,
) -> NetworkScope raise ScopeError {
  if methods.is_empty() {
    raise ScopeError::EmptyMethodSet
  }
  let normalized : Array[String] = []
  for input in methods {
    let http_method = normalize_method(input)
    if !normalized.contains(http_method) {
      normalized.push(http_method)
    }
  }
  normalized.sort()
  { host, methods: normalized, max_data_class, }
}

///|
fn data_class_rank(classification : DataClass) -> Int {
  match classification {
    Public => 0
    Internal => 1
    Confidential => 2
    Secret => 3
  }
}

///|
fn DataClass::canonical(self : DataClass) -> String {
  match self {
    Public => "public"
    Internal => "internal"
    Confidential => "confidential"
    Secret => "secret"
  }
}

///|
pub fn network_contains(grant : NetworkScope, requested : NetworkScope) -> Bool {
  if !host_contains(grant.host, requested.host) {
    return false
  }
  for http_method in requested.methods {
    if !grant.methods.contains(http_method) {
      return false
    }
  }
  data_class_rank(requested.max_data_class) <=
  data_class_rank(grant.max_data_class)
}

///|
fn NetworkScope::canonical(self : NetworkScope) -> String {
  let host = if self.host.subdomains {
    self.host.canonical + "+subdomains"
  } else {
    self.host.canonical
  }
  host + "[" + self.methods.join(",") + "]<=" + self.max_data_class.canonical()
}
