use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
use contracts/did_registry.{Did, RegistryState}
use contracts/common.{Result, Ok, Error}

type DidRedeemer {
  RegisterIdentity { did: Did, role: did_registry.Role, controller: Did, timestamp: Int }
  DeactivateIdentity { did: Did }
  TransferControl { did: Did, new_controller: Did }
}

validator did_validator {
  spend(datum_opt: Option<Data>, redeemer_data: Data, _own_ref: OutputReference, self: Transaction) {
     expect Some(datum_data) = datum_opt
     expect datum: RegistryState = datum_data
     expect redeemer: DidRedeemer = redeemer_data
     let extra_signatories = self.extra_signatories
     
     when redeemer is {
       RegisterIdentity { did, role, controller, timestamp } ->
         did_registry.register_identity(datum, datum.admin, did, role, controller, timestamp)
           |> is_authorized(extra_signatories, datum.admin)

       DeactivateIdentity { did } ->
         did_registry.deactivate_identity(datum, datum.admin, did)
           |> is_authorized(extra_signatories, datum.admin)

       TransferControl { did, new_controller } ->
         did_registry.transfer_control(datum, datum.admin, did, new_controller)
            |> is_authorized(extra_signatories, datum.admin)
     }
  }
}

fn is_authorized(
  result: Result<RegistryState, did_registry.RegistryError>,
  signatories: List<Did>,
  authority: Did,
) -> Bool {
  when result is {
    Ok(_) -> list.has(signatories, authority)
    Error(_) -> False
  }
}
