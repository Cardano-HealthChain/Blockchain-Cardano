use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
use contracts/on_chain_anchor
use contracts/common.{Ok, Error}

// Datum is the Anchor data
type AnchorDatum = on_chain_anchor.Anchor

validator anchor_validator {
  spend(datum_opt: Option<Data>, _redeemer: Data, _own_ref: OutputReference, self: Transaction) {
     expect Some(datum_data) = datum_opt
     expect datum: AnchorDatum = datum_data
     
     // Owner must sign to consume (burn/move) the UTxO
     on_chain_anchor.verify_anchor_did(datum, datum.did) 
        |> fn(res) {
             when res is {
               Ok(_) -> list.has(self.extra_signatories, datum.did)
               Error(_) -> False
             }
           }
  }
}
