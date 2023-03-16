use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{Mint, ScriptContext}
use aiken/transaction/credential.{VerificationKey}
use chess_on_cardano/turn

type Redeemer {
  white: Hash<Blake2b_224, VerificationKey>,
  black: Hash<Blake2b_224, VerificationKey>,
}

validator mint_board(turn_contract_hash: ByteArray) {
  fn(redeemer: Redeemer, context: ScriptContext) -> Bool {
    let turn_address = credential.from_script(turn_contract_hash)
    expect Mint(policy_id) = context.purpose

    let turn_output = turn.output(context, policy_id)

    turn.validate_output(
      turn_output,
      turn_address,
      policy_id,
      redeemer.white,
      redeemer.black,
    )
  }
}
