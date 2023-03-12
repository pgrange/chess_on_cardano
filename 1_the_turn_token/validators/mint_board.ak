use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{InlineDatum, Mint, Output, ScriptContext}
use aiken/transaction/credential.{VerificationKey}
use aiken/transaction/value.{PolicyId}

type Redeemer {
  white: Hash<Blake2b_224, VerificationKey>,
  black: Hash<Blake2b_224, VerificationKey>,
}

type TurnDatum {
  next_player: Hash<Blake2b_224, VerificationKey>,
  other_player: Hash<Blake2b_224, VerificationKey>,
  policy_id: PolicyId,
}

validator mint_board(turn_contract: ByteArray) {
  fn(redeemer: Redeemer, context: ScriptContext) -> Bool {
    expect Mint(policy_id) = context.purpose
    let turn_output = turn_token_output(context, policy_id)

    let datum = turn_datum(turn_output)

    white_start_then_black(datum, redeemer) && paid_to_the_turn_contract(
      turn_contract,
      turn_output,
    ) && policy_id_in_datum(datum, policy_id)
  }
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

fn white_start_then_black(datum: TurnDatum, redeemer) {
  datum.next_player == redeemer.white && datum.other_player == redeemer.black
}

fn policy_id_in_datum(datum, policy_id) {
  datum.policy_id == policy_id
}

fn turn_datum(turn_output) -> TurnDatum {
  expect InlineDatum(data) = turn_output.datum
  expect turn_datum: TurnDatum = data
  turn_datum
}
