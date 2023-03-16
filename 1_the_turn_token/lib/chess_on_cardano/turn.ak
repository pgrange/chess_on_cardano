use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{InlineDatum, Output, ScriptContext}
use aiken/transaction/credential.{Address, VerificationKey}
use aiken/transaction/value.{PolicyId}

pub type TurnDatum {
  player: Hash<Blake2b_224, VerificationKey>,
  next_player: Hash<Blake2b_224, VerificationKey>,
  policy_id: PolicyId,
}

// Finds the output (or fail) which spends the turn token
pub fn output(context, policy_id) -> Output {
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

// Validates a turn output:
// the output must be paid to the turn contract
// the policyid must be in the datum for later use
// the player whose turn it is must be the expected_player
// the next player must be the expected_next_player
pub fn validate_output(
  output,
  turn_address,
  policy_id,
  expected_player,
  expected_next_player,
) {
  let turn_datum = datum(output)
  paid_to_the_turn_contract(turn_address, output) && policy_id_in_datum(
    turn_datum,
    policy_id,
  ) && player_is(turn_datum, expected_player) && next_player_is(
    turn_datum,
    expected_next_player,
  )
}

fn paid_to_the_turn_contract(turn_address: Address, output: Output) {
  output.address == turn_address
}

fn policy_id_in_datum(datum: TurnDatum, policy_id) {
  datum.policy_id == policy_id
}

fn player_is(
  turn_datum: TurnDatum,
  next_player: Hash<Blake2b_224, VerificationKey>,
) {
  next_player == turn_datum.player
}

fn next_player_is(
  turn_datum: TurnDatum,
  other_player: Hash<Blake2b_224, VerificationKey>,
) {
  other_player == turn_datum.next_player
}

fn datum(turn_output: Output) -> TurnDatum {
  expect InlineDatum(data) = turn_output.datum
  expect datum: TurnDatum = data
  datum
}

// Checks that the transaction is signed by player
pub fn signed_by_player(context: ScriptContext, player) {
  list.has(context.transaction.extra_signatories, player)
}
