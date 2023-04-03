import {
    C,
    Blockfrost,
    Lucid,
    MintingPolicy,
    PolicyId,
    TxHash,
    toHex,
    Unit,
    SpendingValidator,
    fromHex,
    Data,
    Constr,
    utf8ToHex
} from "https://deno.land/x/lucid/mod.ts";
const { Address } = C;
import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";



const white = Address.from_bech32(await Deno.readTextFile("./white.addr"))
const black = Address.from_bech32(await Deno.readTextFile("./white.addr"))
console.log("white and black addresses loaded")

function fromText(text: string): string {
    return toHex(new TextEncoder().encode(text));
}

const lucid = await Lucid.new(
    new Blockfrost(
        "https://cardano-preview.blockfrost.io/api/v0",
        "previewEyB71KnTiaIv2OR8FWlnoCAh7hsIEGxq",
    ),
    "Preview",
);


lucid.selectWalletFromPrivateKey(await Deno.readTextFile("./white.sk"));

const { paymentCredential } = lucid.utils.getAddressDetails(
    await lucid.wallet.address(),
);

const policyId: PolicyId = lucid.utils.mintingPolicyToId(await mintingPolicy());
const mint = await mintBoard(white, black, policyId, await turn_contract());

await lucid.awaitTx(mint);

console.log(`Board minted
    Tx ID: ${mint}
`);

async function mintingPolicy(): Promise<SpendingValidator> {
    const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators.find(element => element.title == "mint_board.mint_board");
    return {
        type: "PlutusV2",
        script: toHex(cbor.encode(fromHex(validator.compiledCode))),
    };
}

async function turn_contract(): Promise<SpendingValidator> {
    const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators.find(element => element.title == "turn.turn");
    const validator2 = {
        type: "PlutusV2",
        script: toHex(cbor.encode(fromHex(validator.compiledCode))),
    };

    return lucid.utils.validatorToAddress(validator2)
}

function toHexString(byteArray) {
    return Array.from(byteArray, function (byte) {
        return ('0' + (byte & 0xFF).toString(16)).slice(-2);
    }).join('')
}

export async function mintBoard(white, black, policyId, turn_contract): Promise<TxHash> {



    const TurnDatum = Data.Object({
        player: Data.Bytes(),
        nextPlayer: Data.Bytes(),
        policyId: Data.Bytes(),
    });

    type TurnDatum = Data.Static<typeof TurnDatum>;

    const turnDatum = Data.to<TurnDatum>(
        { player: toHexString(white.to_bytes()), nextPlayer: toHexString(black.to_bytes()), policyId: policyId },
        TurnDatum,
    );

    //TODO make this fucking address serializable
    // See https://github.com/spacebudz/lucid/blob/2d73e7d71d180c3aab7db654f3558279efb5dbb5/src/plutus/data.ts#L264
    // const dtc = toHexString(white.to_bytes())
    // console.log(dtc)
    // console.log(`white is what? ${dtc instanceof String}`)
    // Data.to(dtc)

    // See https://lucid.spacebudz.io/docs/overview/about-lucid/


    const Redeemer = Data.Object({
        // white: Data.Bytes({ minLength: 28, maxLength: 28 }),
        // black: Data.Bytes({ minLength: 28, maxLength: 28 }),
        white: Data.Bytes(),
        black: Data.Bytes(),
    });

    type Redeemer = Data.Static<typeof Redeemer>;


    const redeemer = Data.to<Redeemer>(
        { white: toHexString(white.to_bytes()), black: toHexString(black.to_bytes()) },
        Redeemer
    );


    const unit: Unit = policyId + fromText("turn");


    const tx = await lucid
        .newTx()
        .mintAssets({ [unit]: 1n }, redeemer)
        .payToContract(turn_contract, { inline: turnDatum }, { [unit]: 1n })
        .attachMintingPolicy(mintingPolicy)
        .complete();

    const signedTx = await tx.sign().complete();

    const txHash = await signedTx.submit();

    return txHash;
}