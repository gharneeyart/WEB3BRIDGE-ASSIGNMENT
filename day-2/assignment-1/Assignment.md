### Assignment 1

## requirements

**1.** Where are your structs, mappings and arrays stored.

**Structs**: When a struct is declared as a state variable, it is stored in storage (permanent blockchain state). If a struct is created inside a function without referencing state, it lives in memory (temporary, disappears after execution).

**Mappings**
Mappings are always stored in storage.
They represent part of the contract’s world state and cannot exist in memory in a meaningful way because they rely on persistent key → value storage.

**Arrays**
Arrays can live in three places, depending on context:
- Storage: state variable arrays (permanent, on-chain)
- Memory: temporary arrays created inside functions
- Calldata: read-only arrays passed into external functions (gas-efficient)

**2.** How they behave when executed or called.

**Storage** holds the contract’s permanent state on the blockchain. When a function is called, it reads existing values directly from storage. If the function modifies a storage variable, the change is written permanently and remains after execution ends. Storage operations are the most gas-expensive because they update on-chain data.

**Memory** is a temporary data location created when a function starts executing. It is used for intermediate calculations and temporary variables. Data in memory can be modified during execution but is automatically deleted once the function finishes. It does not persist on the blockchain.

**Calldata** stores input arguments for external function calls. It is read-only and cannot be modified during execution. Calldata is gas-efficient because it avoids copying data into memory. Like memory, it exists only for the duration of the function call and is discarded afterward.

**3** Why don't you need to specify memory or storage with mappings

Mappings can only exist in storage. They represent permanent key–value relationships that must persist on the blockchain, and the EVM calculates where each value lives using a hash of the key and the contract’s storage layout. That mechanism only works with persistent state, not temporary locations like memory or calldata, so Solidity fixes the data location automatically.

### Assignment 2

## requirements

- Look up ERC20 standard `Understand it like your life depends on it, because it does.`
- Write in Code the complete ERC20 implementation from scratch without using any libraries.
