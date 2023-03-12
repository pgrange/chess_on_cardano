use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{Input, Output, OutputReference, ScriptContext, Spend}
use aiken/transaction/credential.{Script, ScriptCredential}
use aiken/transaction/value.{PolicyId}

type Datum {
  policy_id: PolicyId,
}

validator turn {
  fn(datum: Datum, _redeemer: Void, context: ScriptContext) -> Bool {
    expect Spend(output_reference) = context.purpose

    let self_hash =
      own_validator_script_address_hash(
        context.transaction.inputs,
        output_reference,
      )

    let turn_output = turn_token_output(context, datum.policy_id)

    paid_to_the_turn_contract(self_hash, turn_output)
  }
}

pub type ValidatorHash =
  Hash<Blake2b_224, Script>

pub fn own_validator_script_address_hash(
  inputs: List<Input>,
  output_reference: OutputReference,
) -> ValidatorHash {
  let prout =
    list.find(inputs, fn(input) { input.output_reference == output_reference })
  expect Some(dtc) = prout
  expect ScriptCredential(hash) = dtc.output.address.payment_credential

  hash
}

fn turn_token_output(context, policy_id) -> Output {
  expect [turn_output] = outputs_with_turn_token(context, policy_id)
  let turn_token_quantity =
    value.quantity_of(turn_output.value, policy_id, "turn")
  expect turn_token_quantity = 1
  turn_output
}

fn outputs_with_turn_token(context, policy_id) -> List<Output> {
  list.filter(
    context.transaction.outputs,
    fn(output) { value.quantity_of(output.value, policy_id, "turn") > 0 },
  )
}

fn paid_to_the_turn_contract(turn_contract, turn_output) {
  turn_output.address == credential.from_script(turn_contract)
}
