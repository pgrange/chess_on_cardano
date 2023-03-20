import { Lucid } from "https://deno.land/x/lucid@0.8.3/mod.ts";
import { command, run, string, positional } from "npm:cmd-ts";
 
const lucid = await Lucid.new(undefined, "Preview");

async function generate_player_keys(player) {
    console.log(`generating private key for player ${player}`)
    const privateKey = lucid.utils.generatePrivateKey();
    await Deno.writeTextFile(`${player}.sk`, privateKey);
    
    console.log(`extracting address for player ${player}`)
    const address = await lucid
        .selectWalletFromPrivateKey(privateKey)
        .wallet.address();
    await Deno.writeTextFile(`${player}.addr`, address);
}




const app = command({
  name: 'generate_key',
  args: {
    key_name: positional({ type: string, displayName: 'key name' }),
  },
  handler: ({ key_name }) => {
    generate_player_keys(key_name);
  },
});

run(app, Deno.args);

