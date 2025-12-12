use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
use contracts/clinic_registry.{ClinicRegistry, Did}
use contracts/common.{Result, Ok, Error}

type ClinicRedeemer {
  AddClinic { clinic_did: Did, timestamp: Int }
  RevokeClinic { clinic_did: Did, timestamp: Int }
  ReinstateClinic { clinic_did: Did, timestamp: Int }
  TransferAuthority { new_authority: Did }
}

validator clinic_validator {
  spend(datum_opt: Option<Data>, redeemer_data: Data, _own_ref: OutputReference, self: Transaction) {
    expect Some(datum_data) = datum_opt
    expect datum: ClinicRegistry = datum_data
    expect redeemer: ClinicRedeemer = redeemer_data
    let extra_signatories = self.extra_signatories

    when redeemer is {
      AddClinic { clinic_did, timestamp } ->
        clinic_registry.add_clinic(datum, datum.authority, clinic_did, timestamp) 
          |> is_authorized(extra_signatories, datum.authority)

      RevokeClinic { clinic_did, timestamp } ->
        clinic_registry.revoke_clinic(datum, datum.authority, clinic_did, timestamp)
          |> is_authorized(extra_signatories, datum.authority)
      
      ReinstateClinic { clinic_did, timestamp } -> 
        clinic_registry.reinstate_clinic(datum, datum.authority, clinic_did, timestamp)
          |> is_authorized(extra_signatories, datum.authority)

      TransferAuthority { new_authority } ->
         clinic_registry.transfer_authority(datum, datum.authority, new_authority)
          |> is_authorized(extra_signatories, datum.authority)
    }
  }
}

fn is_authorized(
  result: Result<ClinicRegistry, clinic_registry.RegistryError>,
  signatories: List<Did>,
  authority: Did,
) -> Bool {
  when result is {
    Ok(_) -> list.has(signatories, authority)
    Error(_) -> False
  }
}
