use aiken/list
use aiken/transaction.{OutputReference, ScriptContext}
use aiken/transaction/credential.{Address, ScriptCredential}

pub fn own_validator_script_address(
  context: ScriptContext,
  output_reference: OutputReference,
) -> Address {
  let inputs = context.transaction.inputs

  expect Some(input) =
    list.find(inputs, fn(input) { input.output_reference == output_reference })
  expect ScriptCredential(hash) = input.output.address.payment_credential

  credential.from_script(hash)
}
