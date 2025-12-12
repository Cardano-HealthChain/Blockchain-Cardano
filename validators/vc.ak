use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
use aiken/interval.{Finite}
use contracts/permission_vc.{VerifiableCredential}

type VCRedeemer {
  RevokeVC { reason: String }
  ExtendVC { new_expiry: Int }
  ConsumeVC
}

validator vc_validator {
  spend(datum_opt: Option<Data>, redeemer_data: Data, _own_ref: OutputReference, self: Transaction) {
    expect Some(datum_data) = datum_opt
    expect datum: VerifiableCredential = datum_data
    expect redeemer: VCRedeemer = redeemer_data
    let extra_signatories = self.extra_signatories
    let validity_range = self.validity_range

    when redeemer is {
      RevokeVC { .. } -> {
         list.has(extra_signatories, datum.issuer)
      }
      
      ExtendVC { .. } -> {
         list.has(extra_signatories, datum.issuer)
      }

      ConsumeVC -> {
         when validity_range.lower_bound.bound_type is {
             Finite(now) -> now > datum.expires_at
             _ -> False
         }
      }
    }
  }
}
