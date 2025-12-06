// DID Registry Script
use contracts/common.{Result, Ok, Error}
use aiken/collection/list









pub type Did = ByteArray
pub type Time = Int

pub type Role {
    Resident
    Clinic
    Authority
}

pub type IdentityRecord {
    did: Did,
    role: Role,
    registered_at: Time,
    controller: Did,
    active: Bool
}



pub type RegistryState {
    identities: List<(Did, IdentityRecord)>,
    admin: Did
}

pub type RegistryError {
    Unauthorized { actor: Did }
    AlreadyRegistered { did: Did }
    NotRegistered { did: Did }
    RoleMismatch { expected: Role, actual: Role }
}

pub fn is_admin(state: RegistryState, actor: Did) -> Bool {
    actor == state.admin
}

pub fn register_identity(
    state: RegistryState,
    actor: Did,
    did: Did,
    role: Role,
    controller: Did,
    timestamp: Time,
) -> Result<RegistryState, RegistryError> {
    if !is_admin(state, actor) {
        Error(Unauthorized { actor })
    } else {
        when list.find(state.identities, fn(pair) { pair.1st == did }) is {
            Some(_) -> Error(AlreadyRegistered { did })
            None -> {
                let record = IdentityRecord {
                    did,
                    role,
                    registered_at: timestamp,
                    controller,
                    active: True
                }

                let new_identities = [(did, record), ..state.identities]
                Ok(RegistryState { ..state, identities: new_identities })
            }
        }
    }
}

pub fn deactivate_identity(
    state: RegistryState,
    actor: Did,
    did: Did,
) -> Result<RegistryState, RegistryError> {
    if !is_admin(state, actor) {
        Error(Unauthorized { actor })
    } else {
        when list.find(state.identities, fn(pair) { pair.1st == did }) is {
            Some((_, record)) -> {
                let updated_record = IdentityRecord { ..record, active: False }
                
                let other = list.filter(state.identities, fn(pair) { pair.1st != did })
                let new_identities = [(did, updated_record), ..other]
                
                Ok(RegistryState { ..state, identities: new_identities })
            }

            None -> Error(NotRegistered { did })
        }
    }
}

pub fn transfer_control(
    state: RegistryState,
    actor: Did,
    did: Did,
    new_controller: Did,
) -> Result<RegistryState, RegistryError> {
    when list.find(state.identities, fn(pair) { pair.1st == did }) is {
        Some((_, record)) ->
            if actor != record.controller && !is_admin(state, actor) {
                Error(Unauthorized { actor })
            } else {
                let updated_record = IdentityRecord { ..record, controller: new_controller }
                
                let other = list.filter(state.identities, fn(pair) { pair.1st != did })
                let new_identities = [(did, updated_record), ..other]
                
                Ok(RegistryState { ..state, identities: new_identities })
            }

        None -> Error(NotRegistered { did })
    }
}

pub fn ensure_role(state: RegistryState, did: Did, expected: Role) -> Result<Void, RegistryError> {
    when list.find(state.identities, fn(pair) { pair.1st == did }) is {
        Some((_, record)) ->
            if !record.active {
                Error(NotRegistered { did })
            } else if record.role != expected {
                Error(RoleMismatch { expected, actual: record.role })
            } else {
                Ok(Void)
            }

        None -> Error(NotRegistered { did })
    }
}

pub fn is_active_identity(state: RegistryState, did: Did) -> Bool {
    when list.find(state.identities, fn(pair) { pair.1st == did }) is {
        Some((_, record)) -> record.active
        None -> False
    }
}
