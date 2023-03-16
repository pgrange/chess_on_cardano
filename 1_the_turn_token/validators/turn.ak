use aiken/transaction.{ScriptContext, Spend}
use chess_on_cardano/turn.{TurnDatum}
use chess_on_cardano/utils.{own_validator_script_address}

validator turn {
  fn(datum: TurnDatum, _redeemer: Void, context: ScriptContext) -> Bool {
    expect Spend(spent) = context.purpose
    let turn_address = own_validator_script_address(context, spent)

    let turn_output = turn.output(context, datum.policy_id)

    turn.validate_output(
      turn_output,
      turn_address,
      datum.policy_id,
      datum.next_player,
      datum.player,
    ) && turn.signed_by_player(context, datum.player)
  }
}
