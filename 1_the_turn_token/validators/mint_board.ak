use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{InlineDatum, Mint, ScriptContext}
use aiken/transaction/credential.{VerificationKey}
use chess_on_cardano/turn.{
  TurnDatum, paid_to_the_turn_contract, policy_id_in_datum, turn_token_output,
}

type Redeemer {
  white: Hash<Blake2b_224, VerificationKey>,
  black: Hash<Blake2b_224, VerificationKey>,
}

validator mint_board(turn_contract_hash: ByteArray) {
  fn(redeemer: Redeemer, context: ScriptContext) -> Bool {
    let turn_contract = credential.from_script(turn_contract_hash)
    expect Mint(policy_id) = context.purpose
    let turn_output = turn_token_output(context, policy_id)

    let datum = turn_datum(turn_output)

    white_start_then_black(datum, redeemer) && paid_to_the_turn_contract(
      turn_contract,
      turn_output,
    ) && policy_id_in_datum(turn_output, policy_id)
  }
}

fn white_start_then_black(datum: TurnDatum, redeemer) {
  //TODO extract to turn library
  datum.next_player == redeemer.white && datum.other_player == redeemer.black
}

fn turn_datum(turn_output) -> TurnDatum {
  expect InlineDatum(data) = turn_output.datum
  expect turn_datum: TurnDatum = data
  turn_datum
}
