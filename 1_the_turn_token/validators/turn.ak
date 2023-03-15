use aiken/transaction.{ScriptContext, Spend}
use chess_on_cardano/turn.{
  TurnDatum, next_player_is, other_player_is, paid_to_the_turn_contract,
  policy_id_in_datum, turn_token_output,
}
use chess_on_cardano/utils.{own_validator_script_address}

validator turn {
  fn(datum: TurnDatum, _redeemer: Void, context: ScriptContext) -> Bool {
    expect Spend(spent) = context.purpose

    let turn_address = own_validator_script_address(context, spent)

    let turn_output = turn_token_output(context, datum.policy_id)

    paid_to_the_turn_contract(turn_address, turn_output) && policy_id_in_datum(
      turn_output,
      datum.policy_id,
    ) && next_player_is(turn_output, datum.other_player) && other_player_is(
      turn_output,
      datum.next_player,
    )
    //TODO: signed by the appropriate player
  }
}
