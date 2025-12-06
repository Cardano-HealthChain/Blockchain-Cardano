// Permission/VC Script
use contracts/common.{Result, Ok, Error}





use aiken/collection/list

pub type Did = ByteArray
pub type Time = Int
pub type Hash = ByteArray


pub type CredentialStatus {
    Active
    Revoked { revoked_at: Time, reason: String }
}

pub type VerifiableCredential {
    issuer: Did,
    subject: Did,
    issued_at: Time,
    expires_at: Time,
    status: CredentialStatus,
    schema_hash: Hash
}

pub type CredentialError {
    UnauthorizedIssuer { issuer: Did }
    Expired { at: Time }
    AlreadyRevoked { revoked_at: Time }
    InvalidValidityRange { issued_at: Time, expires_at: Time }
}

fn is_trusted_issuer(issuer: Did, trusted: List<Did>) -> Bool {
    list.has(trusted, issuer)
}

pub fn issue_vc(
    issuer: Did,
    subject: Did,
    issued_at: Time,
    expires_at: Time,
    schema_hash: Hash,
    trusted_issuers: List<Did>,
) -> Result<VerifiableCredential, CredentialError> {
    if !is_trusted_issuer(issuer, trusted_issuers) {
        Error(UnauthorizedIssuer { issuer })
    } else if issued_at >= expires_at {
        Error(InvalidValidityRange { issued_at, expires_at })
    } else {
        Ok(
            VerifiableCredential {
                issuer,
                subject,
                issued_at,
                expires_at,
                schema_hash,
                status: Active
            },
        )
    }
}

pub fn revoke_vc(
    vc: VerifiableCredential,
    actor: Did,
    timestamp: Time,
    reason: String,
) -> Result<VerifiableCredential, CredentialError> {
    when vc.status is {
        Active ->
            if actor != vc.issuer {
                Error(UnauthorizedIssuer { issuer: actor })
            } else if timestamp < vc.issued_at {
                Error(InvalidValidityRange { issued_at: vc.issued_at, expires_at: timestamp })
            } else {
                Ok(
                    VerifiableCredential {
                        issuer: vc.issuer,
                        subject: vc.subject,
                        issued_at: vc.issued_at,
                        expires_at: vc.expires_at,
                        status: Revoked { revoked_at: timestamp, reason },
                        schema_hash: vc.schema_hash
                    }
                )
            }

        Revoked { revoked_at, .. } ->
            Error(AlreadyRevoked { revoked_at })
    }
}

pub fn extend_vc(
    vc: VerifiableCredential,
    actor: Did,
    new_expiry: Time,
) -> Result<VerifiableCredential, CredentialError> {
    if actor != vc.issuer {
        Error(UnauthorizedIssuer { issuer: actor })
    } else if new_expiry <= vc.expires_at {
        Error(InvalidValidityRange { issued_at: vc.issued_at, expires_at: new_expiry })
    } else {
        Ok(
            VerifiableCredential {
                issuer: vc.issuer,
                subject: vc.subject,
                issued_at: vc.issued_at,
                expires_at: new_expiry,
                status: vc.status,
                schema_hash: vc.schema_hash
            }
        )
    }
}

pub fn is_active(vc: VerifiableCredential) -> Bool {
    when vc.status is {
        Active -> True
        Revoked { .. } -> False
    }
}

pub fn is_valid(vc: VerifiableCredential, current_time: Time) -> Bool {
    is_active(vc) && current_time >= vc.issued_at && current_time <= vc.expires_at
}

pub fn assert_valid(vc: VerifiableCredential, current_time: Time) -> Result<Void, CredentialError> {
    if !is_active(vc) {
        when vc.status is {
            Revoked { revoked_at, .. } ->
                Error(AlreadyRevoked { revoked_at })

            Active ->
                Error(Expired { at: current_time })
        }
    } else if current_time < vc.issued_at || current_time > vc.expires_at {
        Error(Expired { at: current_time })
    } else {
        Ok(Void)
    }
}