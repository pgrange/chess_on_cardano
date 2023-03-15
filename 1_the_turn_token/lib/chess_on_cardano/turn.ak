use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{InlineDatum, Output, ScriptContext}
use aiken/transaction/credential.{Address, VerificationKey}
use aiken/transaction/value.{PolicyId}

pub type TurnDatum {
  next_player: Hash<Blake2b_224, VerificationKey>,
  other_player: Hash<Blake2b_224, VerificationKey>,
  policy_id: PolicyId,
}

pub fn turn_token_output(context, policy_id) -> Output {
  expect [turn_output] = outputs_with_turn_token(context, policy_id)
  let turn_token_quantity =
    value.quantity_of(turn_output.value, policy_id, "turn")
  expect turn_token_quantity = 1
  turn_output
}

fn outputs_with_turn_token(context: ScriptContext, policy_id) -> List<Output> {
  list.filter(
    context.transaction.outputs,
    fn(output) { value.quantity_of(output.value, policy_id, "turn") > 0 },
  )
}

pub fn paid_to_the_turn_contract(turn_contract: Address, turn_output: Output) {
  turn_output.address == turn_contract
}

fn output_datum(turn_output: Output) -> TurnDatum {
  expect InlineDatum(data) = turn_output.datum
  expect datum: TurnDatum = data
  datum
}

pub fn policy_id_in_datum(turn_output: Output, policy_id) {
  output_datum(turn_output).policy_id == policy_id
}

pub fn next_player_is(
  turn_output: Output,
  next_player: Hash<Blake2b_224, VerificationKey>,
) {
  let out_datum = output_datum(turn_output)
  next_player == out_datum.next_player
}

pub fn other_player_is(
  turn_output: Output,
  other_player: Hash<Blake2b_224, VerificationKey>,
) {
  let out_datum = output_datum(turn_output)
  other_player == out_datum.other_player
}
