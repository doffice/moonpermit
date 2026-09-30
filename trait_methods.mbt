///|
// Keep derived methods explicit for MoonBit 0.10.14 and preserve the public API.
pub extend DataClass with Eq::{equal, not_equal}

///|
pub extend DataClass with @debug.Debug::{to_repr}

///|
pub extend DataClass with ToJson::{to_json}

///|
pub extend PathScope with Eq::{equal, not_equal}

///|
pub extend PathScope with @debug.Debug::{to_repr}

///|
pub extend PathScope with ToJson::{to_json}

///|
pub extend CommandScope with Eq::{equal, not_equal}

///|
pub extend CommandScope with @debug.Debug::{to_repr}

///|
pub extend CommandScope with ToJson::{to_json}

///|
pub extend HostScope with Eq::{equal, not_equal}

///|
pub extend HostScope with @debug.Debug::{to_repr}

///|
pub extend HostScope with ToJson::{to_json}

///|
pub extend NetworkScope with Eq::{equal, not_equal}

///|
pub extend NetworkScope with @debug.Debug::{to_repr}

///|
pub extend NetworkScope with ToJson::{to_json}

///|
pub extend EffectScope with Eq::{equal, not_equal}

///|
pub extend EffectScope with @debug.Debug::{to_repr}

///|
pub extend EffectScope with ToJson::{to_json}

///|
pub extend ScopeError with Eq::{equal, not_equal}

///|
pub extend ScopeError with @debug.Debug::{to_repr}

///|
pub extend ScopeError with ToJson::{to_json}

///|
pub extend Containment with Eq::{equal, not_equal}

///|
pub extend Containment with @debug.Debug::{to_repr}

///|
pub extend Containment with ToJson::{to_json}

///|
pub extend Budget with Eq::{equal, not_equal}

///|
pub extend Budget with @debug.Debug::{to_repr}

///|
pub extend Budget with ToJson::{to_json}

///|
pub extend EffectRequest with Eq::{equal, not_equal}

///|
pub extend EffectRequest with @debug.Debug::{to_repr}

///|
pub extend EffectRequest with ToJson::{to_json}

///|
pub extend Grant with Eq::{equal, not_equal}

///|
pub extend Grant with @debug.Debug::{to_repr}

///|
pub extend Grant with ToJson::{to_json}

///|
pub extend Permit with Eq::{equal, not_equal}

///|
pub extend Permit with @debug.Debug::{to_repr}

///|
pub extend Permit with ToJson::{to_json}

///|
pub extend DiffEntry with Eq::{equal, not_equal}

///|
pub extend DiffEntry with @debug.Debug::{to_repr}

///|
pub extend DiffEntry with ToJson::{to_json}

///|
pub extend PermitDiff with Eq::{equal, not_equal}

///|
pub extend PermitDiff with @debug.Debug::{to_repr}

///|
pub extend PermitDiff with ToJson::{to_json}

///|
pub extend PermitError with Eq::{equal, not_equal}

///|
pub extend PermitError with @debug.Debug::{to_repr}

///|
pub extend PermitError with ToJson::{to_json}

///|
pub extend Verdict with Eq::{equal, not_equal}

///|
pub extend Verdict with @debug.Debug::{to_repr}

///|
pub extend Verdict with ToJson::{to_json}

///|
pub extend ReasonCode with Eq::{equal, not_equal}

///|
pub extend ReasonCode with @debug.Debug::{to_repr}

///|
pub extend ReasonCode with ToJson::{to_json}

///|
pub extend Receipt with Eq::{equal, not_equal}

///|
pub extend Receipt with @debug.Debug::{to_repr}

///|
pub extend Receipt with ToJson::{to_json}

///|
pub extend DelegationReceipt with Eq::{equal, not_equal}

///|
pub extend DelegationReceipt with @debug.Debug::{to_repr}

///|
pub extend DelegationReceipt with ToJson::{to_json}

///|
pub extend AuditEventKind with Eq::{equal, not_equal}

///|
pub extend AuditEventKind with @debug.Debug::{to_repr}

///|
pub extend AuditEventKind with ToJson::{to_json}

///|
pub extend AuditEvent with Eq::{equal, not_equal}

///|
pub extend AuditEvent with @debug.Debug::{to_repr}

///|
pub extend AuditEvent with ToJson::{to_json}

///|
pub extend ProofCheckKind with Eq::{equal, not_equal}

///|
pub extend ProofCheckKind with @debug.Debug::{to_repr}

///|
pub extend ProofCheckKind with ToJson::{to_json}

///|
pub extend ProofCheckStatus with Eq::{equal, not_equal}

///|
pub extend ProofCheckStatus with @debug.Debug::{to_repr}

///|
pub extend ProofCheckStatus with ToJson::{to_json}

///|
pub extend ProofCheck with Eq::{equal, not_equal}

///|
pub extend ProofCheck with @debug.Debug::{to_repr}

///|
pub extend ProofCheck with ToJson::{to_json}

///|
pub extend AuthorizationProof with Eq::{equal, not_equal}

///|
pub extend AuthorizationProof with @debug.Debug::{to_repr}

///|
pub extend AuthorizationProof with ToJson::{to_json}

///|
pub extend CheckedAuthorization with Eq::{equal, not_equal}

///|
pub extend CheckedAuthorization with @debug.Debug::{to_repr}

///|
pub extend CheckedAuthorization with ToJson::{to_json}

///|
pub extend AuditIssueCode with Eq::{equal, not_equal}

///|
pub extend AuditIssueCode with @debug.Debug::{to_repr}

///|
pub extend AuditIssueCode with ToJson::{to_json}

///|
pub extend AuditFinding with Eq::{equal, not_equal}

///|
pub extend AuditFinding with @debug.Debug::{to_repr}

///|
pub extend AuditFinding with ToJson::{to_json}

///|
pub extend AuditReport with Eq::{equal, not_equal}

///|
pub extend AuditReport with @debug.Debug::{to_repr}

///|
pub extend AuditReport with ToJson::{to_json}
