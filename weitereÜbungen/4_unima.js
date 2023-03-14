// Ethers JS: First interaction with (not) UniMa blockchain.
////////////////////////////////////////////////////////////

// Exercise 0. Load dependencies and network provider.
//////////////////////////////////////////////////////


// a. Require the `dotenv` and `ethers` packages.
// Hint: As you did multiple times now.

// Your code here!
require('dotenv').config();
const ethers = require('ethers');

// Exercise 1. Create a JSON RPC Provider for the (not) UniMa Blockchain.
/////////////////////////////////////////////////////////////////////////

// It seems we cannot (yet) call our blockchain the official Uni Mannheim
// blockchain, so we will reference it throughtout the exercises as the
// (not) UniMa Blockchain.

// a. Add the RPC endpoints to the .env with names:
// - NOT_UNIMA_URL_1
// - NOT_UNIMA_URL_2

// Hint: you find the RPC endpoints on the slides in ILIAS.

// b. Create the JSON RPC provider object.
// Hint: only accessible within UniMa network.

// Your code here!
const unimaUrl = process.env.NOT_UNIMA_URL_1
const provider = new ethers.providers.JsonRpcProvider(unimaUrl);
// Exercise 2. Let's query the provider.
////////////////////////////////////////

// (not) UniMa Blockchain si too long. Let's call it NUMA.
// Print to console the network name, chain id, and block number of NUMA.
const network = async () => {
    const Numa = await provider.getNetwork();
    console.log(Numa.name);
    console.log(Numa.chainId);

    const NumaBlock = await provider.getBlock();
    console.log(NumaBlock.number);
}
network();
    // Your code here!




// Exercise 3. Connect a signer to the (not) UniMa blockchain.
//////////////////////////////////////////////////////////////

// a. Use the same non-sensitive private key used in 3_signer.js.

// Your code here!
const signer = new ethers.Wallet(process.env.METAMASK_1_PRIVATE_KEY,provider);
// b. Print the next nonce necessary to send a transaction.
// Hint: .getNonce()


    // Your code here!
const getNonce = async () => {
    let nonce = await signer.getNonce();
    console.log(nonce);
}
//getNonce();

// Checkpoint. Is the nonce in the (not) Unima blockchain different
// than in Goerli?


// Exercise 4. Check gas.
/////////////////////////

// a. Let's get some gas from the faucet. What is the faucet's address? 
// Check the slides in ILIAS.
// Hint: only accessible within UniMa network.

// b. Check your balance on UniMa network.
const checkBalance = async () => {
    let balance = await provider.getBalance(signer.address);
    console.log(ethers.utils.formatEther(balance));
}
checkBalance();
   // Your code here!


// Exercise 5. Send a transaction.
//////////////////////////////////
const account2 = process.env.METAMASK_2_ADDRESS

// Send some Ether from one of your accounts to another one on NUMA.
const sendTransaction = async () => {
    let b1before = await provider.getBalance(signer.address);
    let b2before = await provider.getBalance(account2);
    console.log(`Balance of account 1 before: ${ethers.utils.formatEther(b1before)}`);
    console.log(`Balance of account 2 before: ${ethers.utils.formatEther(b2before)}`);

    let tx = await signer.sendTransaction(
        {
            to : account2,
            value : ethers.utils.parseEther('0.05')
        }
    );

    await tx.wait();
    console.log(tx);

    let b1after = await provider.getBalance(signer.address);
    let b2after = await provider.getBalance(account2);
    console.log(`Balance of account 1 before: ${ethers.utils.formatEther(b1after)}`);
    console.log(`Balance of account 2 before: ${ethers.utils.formatEther(b2after)}`);

}

sendTransaction();

// Checkpoint. Can you send your ETH from NUMA to Goerli?

