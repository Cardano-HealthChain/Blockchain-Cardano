// Clinic Registry Script
use contracts/common.{Result, Ok, Error}
use aiken/collection/list









pub type Did = ByteArray
pub type Time = Int

pub type ClinicRecord {
    approved_by: Did,
    approved_at: Time,
    revoked_at: Option<Time>
}



pub type ClinicRegistry {
    clinics: List<(Did, ClinicRecord)>,
    authority: Did
}

pub type RegistryError {
    Unauthorized { actor: Did }
    AlreadyRegistered { clinic: Did }
    NotRegistered { clinic: Did }
}

fn authorized(registry: ClinicRegistry, actor: Did) -> Bool {
    actor == registry.authority
}

pub fn add_clinic(
    registry: ClinicRegistry,
    actor: Did,
    clinic_did: Did,
    timestamp: Time,
) -> Result<ClinicRegistry, RegistryError> {
    if !authorized(registry, actor) {
        Error(Unauthorized { actor })
    } else {
        when list.find(registry.clinics, fn(pair) { pair.1st == clinic_did }) is {
            Some((_, record)) ->
                when record.revoked_at is {
                    None ->
                        Error(AlreadyRegistered { clinic: clinic_did })

                    Some(_) -> {
                        let new_record = ClinicRecord {
                            approved_by: actor,
                            approved_at: timestamp,
                            revoked_at: None
                        }
                        
                        // Upsert: Remove old, add new
                        let other_clinics = list.filter(registry.clinics, fn(pair) { pair.1st != clinic_did })
                        let new_clinics = [(clinic_did, new_record), ..other_clinics]
                        
                        Ok(ClinicRegistry { ..registry, clinics: new_clinics })
                    }
                }

            None -> {
                let new_record = ClinicRecord {
                    approved_by: actor,
                    approved_at: timestamp,
                    revoked_at: None
                }

                let new_clinics = [(clinic_did, new_record), ..registry.clinics]
                Ok(ClinicRegistry { ..registry, clinics: new_clinics })
            }
        }
    }
}

pub fn revoke_clinic(
    registry: ClinicRegistry,
    actor: Did,
    clinic_did: Did,
    timestamp: Time,
) -> Result<ClinicRegistry, RegistryError> {
    if !authorized(registry, actor) {
        Error(Unauthorized { actor })
    } else {
        when list.find(registry.clinics, fn(pair) { pair.1st == clinic_did }) is {
            Some((_, record)) -> {
                let updated_record = ClinicRecord { ..record, revoked_at: Some(timestamp) }
                
                let other_clinics = list.filter(registry.clinics, fn(pair) { pair.1st != clinic_did })
                let new_clinics = [(clinic_did, updated_record), ..other_clinics]

                Ok(ClinicRegistry { ..registry, clinics: new_clinics })
            }

            None ->
                Error(NotRegistered { clinic: clinic_did })
        }
    }
}

pub fn reinstate_clinic(
    registry: ClinicRegistry,
    actor: Did,
    clinic_did: Did,
    _timestamp: Time,
) -> Result<ClinicRegistry, RegistryError> {
    if !authorized(registry, actor) {
        Error(Unauthorized { actor })
    } else {
        when list.find(registry.clinics, fn(pair) { pair.1st == clinic_did }) is {
            Some((_, record)) ->
                when record.revoked_at is {
                    Some(_) -> {
                         let reinstated = ClinicRecord { ..record, revoked_at: None }
                         
                         let other_clinics = list.filter(registry.clinics, fn(pair) { pair.1st != clinic_did })
                         let new_clinics = [(clinic_did, reinstated), ..other_clinics]
                         
                         Ok(ClinicRegistry { ..registry, clinics: new_clinics })
                    }

                    None ->
                        Ok(registry)
                }

            None ->
                Error(NotRegistered { clinic: clinic_did })
        }
    }
}

pub fn transfer_authority(
    registry: ClinicRegistry,
    actor: Did,
    new_authority: Did,
) -> Result<ClinicRegistry, RegistryError> {
    if !authorized(registry, actor) {
        Error(Unauthorized { actor })
    } else {
        Ok(
            ClinicRegistry {
                clinics: registry.clinics,
                authority: new_authority
            }
        )
    }
}

pub fn is_registered(
    registry: ClinicRegistry,
    clinic_did: Did,
    reference_time: Time,
) -> Bool {
    when list.find(registry.clinics, fn(pair) { pair.1st == clinic_did }) is {
        Some((_, record)) ->
            reference_time >= record.approved_at
                && when record.revoked_at is {
                    Some(_) -> False
                    None -> True
                }

        None ->
            False
    }
}

pub fn next_review_due(registry: ClinicRegistry, clinic_did: Did, interval: Time) -> Option<Time> {
    when list.find(registry.clinics, fn(pair) { pair.1st == clinic_did }) is {
        Some((_, record)) ->
            when record.revoked_at is {
                Some(_) -> None
                None -> Some(record.approved_at + interval)
            }

        None ->
            None
    }
}