///|
fn normalize_path(input : String) -> String raise ScopeError {
  let trimmed = input.trim().to_owned()
  if trimmed is "" {
    raise ScopeError::EmptyPath
  }
  if trimmed.has_prefix("/") ||
    trimmed.has_prefix("\\") ||
    (trimmed.length() >= 2 && trimmed[1] == ':') {
    raise ScopeError::AbsolutePath(input)
  }
  if trimmed.contains("\\") {
    raise ScopeError::AmbiguousSeparator(input)
  }
  let segments : Array[String] = []
  for view in trimmed.split("/") {
    let segment = view.to_owned()
    if segment is "" || segment is "." {
      continue
    }
    if segment is ".." {
      raise ScopeError::ParentTraversal(input)
    }
    segments.push(segment)
  }
  if segments.is_empty() {
    "."
  } else {
    segments.join("/")
  }
}

///|
pub fn path_exact(input : String) -> PathScope raise ScopeError {
  { canonical: normalize_path(input), tree: false, }
}

///|
pub fn path_tree(input : String) -> PathScope raise ScopeError {
  { canonical: normalize_path(input), tree: true, }
}

///|
pub fn PathScope::canonical(self : PathScope) -> String {
  if self.tree {
    if self.canonical is "." {
      "**"
    } else {
      self.canonical + "/**"
    }
  } else {
    self.canonical
  }
}

///|
pub fn PathScope::is_tree(self : PathScope) -> Bool {
  self.tree
}

///|
pub fn path_contains(grant : PathScope, requested : PathScope) -> Bool {
  if !grant.tree {
    return !requested.tree && grant.canonical == requested.canonical
  }
  if grant.canonical is "." {
    return true
  }
  requested.canonical == grant.canonical ||
  requested.canonical.has_prefix(grant.canonical + "/")
}
