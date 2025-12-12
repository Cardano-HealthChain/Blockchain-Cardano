use contracts/permission_vc.{VerifiableCredential, Active}

// MOCK DATA
const mock_issuer = #"11111111111111111111111111111111111111111111111111111111"
const mock_subject = #"22222222222222222222222222222222222222222222222222222222"

// TESTS

test simple_validity_check() {
  let vc = VerifiableCredential {
    issuer: mock_issuer,
    subject: mock_subject,
    issued_at: 1000,
    expires_at: 2000,
    status: Active,
    schema_hash: #"aabbcc"
  }
  
  permission_vc.is_valid(vc, 1500) == True
}

test simple_expiration_check() {
  let vc = VerifiableCredential {
    issuer: mock_issuer,
    subject: mock_subject,
    issued_at: 1000,
    expires_at: 2000,
    status: Active,
    schema_hash: #"aabbcc"
  }
  
  permission_vc.is_valid(vc, 2500) == False
}
