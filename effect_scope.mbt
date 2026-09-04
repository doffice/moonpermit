///|
fn contained_or(reason : String, condition : Bool) -> Containment {
  if condition {
    Containment::Contained
  } else {
    Containment::NotContained(reason~)
  }
}

///|
pub fn effect_contains(
  grant : EffectScope,
  requested : EffectScope,
) -> Containment {
  match (grant, requested) {
    (FileRead(grant), FileRead(requested)) =>
      contained_or(
        "file read path is outside the grant",
        path_contains(grant, requested),
      )
    (FileWrite(grant), FileWrite(requested)) =>
      contained_or(
        "file write path is outside the grant",
        path_contains(grant, requested),
      )
    (FileDelete(grant), FileDelete(requested)) =>
      contained_or(
        "file delete path is outside the grant",
        path_contains(grant, requested),
      )
    (ProcessExec(grant), ProcessExec(requested)) =>
      contained_or(
        "process executable or arguments exceed the grant",
        command_contains(grant, requested),
      )
    (NetworkSend(grant), NetworkSend(requested)) =>
      contained_or(
        "network host, method, or data class exceeds the grant",
        network_contains(grant, requested),
      )
    (SecretRead(grant), SecretRead(requested)) =>
      contained_or(
        "secret identifier is not granted",
        grant != "" && requested != "" && grant == requested,
      )
    _ => Containment::NotContained(reason="effect kinds differ")
  }
}

///|
pub fn EffectScope::canonical(self : EffectScope) -> String {
  match self {
    FileRead(path) => "fs.read:" + path.canonical()
    FileWrite(path) => "fs.write:" + path.canonical()
    FileDelete(path) => "fs.delete:" + path.canonical()
    ProcessExec(command) => "process.exec:" + command.canonical()
    NetworkSend(network) => "network.send:" + network.canonical()
    SecretRead(name) =>
      if name is "" {
        "secret.read:<invalid>"
      } else {
        "secret.read:" + name
      }
  }
}
