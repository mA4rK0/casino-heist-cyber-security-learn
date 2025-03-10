Briefing is the starting point of your long journey in Casino Heist. we will walk you through the basics of the smart contracts and how you interact with it using Foundry. With that being said, we do recommend you have at least the prerequisite of:

- How the blockchain works
- Smart Contract Basics
- Foundry Basics

## 1. Setup your tools

We are going to use Foundry for all the local Casino Heist, so first you have to install foundry https://book.getfoundry.sh/getting-started/installation

```
1. curl -L https://foundry.paradigm.xyz | bash
2. On a new terminal, type 'foundryup'
```

## 2. Transaction
A way of communicating in the blockchain is through transactions; we can categorize them by these three different transactions.&nbsp;  
&nbsp;  
- *Transaction with/without Ether*&nbsp;  
    A transaction in blockchain may include transferring Ether to a smart contract or an EOA, but we can also do a transaction that doesn't have any Ether, such as calling a function.&nbsp;  
    &nbsp;  
    EOA by default has the ability to receive Ether, but Smart Contract doesn't. A Smart Contract can only receive Ether when they implement either *receive()* or *fallback()* special methods.&nbsp;  
    &nbsp;  
- *Transaction with/without Data*&nbsp;  
    Like all programming languages, some functions might require an input like *uint256*, *address*, *bytes32*, etc. Keep in mind that not all functions require an input to call them, some might just need to be called without any value, some might require value and Ether, and some only Ether and data.&nbsp;  
    &nbsp;  
    Transactions that require data and/or some value are usually meant to execute some logic from a function and change the state of the smart contract.&nbsp;  
    &nbsp;  
- *Transaction between/to EOA (External Owned Account)/Smart Contract*&nbsp;  
    We know that we can directly send a transaction to either an EOA or a Smart Contract, but one thing to understand here is that in Solidity we have special variables that have a type of *address* called *msg.sender* and *tx.origin*.&nbsp;  
    &nbsp;  
    - *msg.sender*&nbsp;  
        This variable allows a smart contract to recognize who is currently interacting with it, for example, let's say we have two smart contracts called *SCA* and *SCB*. When SCA sends a transaction to SCB, SCB recognizes SCA as the *msg.sender*.&nbsp;  
        &nbsp;  
    - *tx.origin*   
        This variable allows a smart contract to recognize the *origin* or the *initiator* of the transaction. Let's see the example that uses 2 smart contracts (SCA & SCB) and an EOA *C*.&nbsp;  
        &nbsp;  
        In SCA exists a function that will send a call to a function in SCB, let's call it *function callB()*. When *C* triggers the function *callB()* from Smart Contract A SCB will be called, and it will have the following value: *msg.sender* since the current interaction is between SCA (sender) and SCB (receiver), SCA will be the *msg.sender*. As for the origin, SCA won't interact with SCB unless the function *callB* is called, the true caller or origin of the transaction is actually and EOA, *C*, thus in this case the *tx.origin* is *C*.&nbsp;  
    &nbsp;  

*Important Note:* smart contracts can call each other using functions, but the initiator or the origin (*tx.origin*) will always be an EOA.&nbsp;  
&nbsp;  

## 3. Writing Foundry Test

In `foundry-casino-heist`, you will see a structure like this

```
__________foundry-casino-heist
    ├── README.md
    ├── cache
    ├── foundry-casino-heist.png
    ├── foundry.toml
    ├── lib
    ├── out
    ├── reading-mats
    ├── script
    ├── src
    └── test
```

You will find every challenge under the `/src/{challenge-name}` directory and every test file under `/test/{challenge-name}.t.sol`. Here is a quick view of `briefing.t.sol`

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Briefing} from "src/Basic/briefing/Briefing.sol";
import {Setup} from "src/Basic/briefing/Setup.sol";

contract BriefingTest is Test{
    Setup public challSetup;
    Briefing public briefing;

    address public deployer = makeAddr("deployer");
    address public player = makeAddr("player");

    function setUp() public{
        vm.startPrank(deployer);
        vm.deal(deployer, 10 ether);
        challSetup = new Setup(0x4e6f77596f754b6e6f7753746f7261676549734e6f7454686174536166652e2e);
        briefing = challSetup.brief();
        vm.stopPrank();
    }

    function testIfSolved() public{
        // Setup for Player
        vm.startPrank(player, player);
        vm.deal(player, 7 ether);

        // Write Exploit here

        vm.stopPrank();
        assertEq(challSetup.isSolved(), true);
    }

}
```

The function `setUp()` is the challenge setup, you don't need to modify anything there, although the private variable is kinda leak there since it's local. Next you will find the `testIfSolved()` function, this is the only function you should modify

```solidity
    function testIfSolved() public{
        // Setup for Player
        vm.startPrank(player, player);
        vm.deal(player, 7 ether);

        // Write Exploit here

        vm.stopPrank();
        assertEq(challSetup.isSolved(), true);
    }
```

Here is a quick explanation

1. `vm.startPrank(player, player)`, indicating that the `player` will be doing the transaction and make the `tx.origin` to `player` (needed for some challenge).
2. `vm.deal(player, 7 ether)`, supply the `player` with the required ether to solve the lab
3. `// Write Exploit here`, from this line until `vm.stopPrank()` is where you are going to write your Exploit.
4. `vm.stopPrank()`, indicating stop using the `player` as the EOA
5. `assertEq(challSetup.isSOlved(), true)`, check whether `player` solved the lab or not.

Now let's do a quick start on solving this challenge, to solve `briefing` here is what we need

1. call `verifyCall()` 
2. call `putSomething(uint256,string,address)` with the correct values
3. call `firstDeposit()` and give some ether through that function
4. send some ether through the `receive() external payable` special function
5. finalize everything by calling `finalize()`

Let's do it one by one.

## Solving Briefing

### `verifyCall()`

To call something using the test, we can simply add

```solidity
contract.function{value: etherAmount}(param);
```

The `briefing contract` has already been declared in the `setUp()` function as `briefing`

```solidity
    Briefing public briefing;

    function setUp(){
        ...
        briefing = challSetup.brief();
        ...
    }
```

so to call it we can simply add this line under `// Write exploit here` and let's print the `completeCall` variable value using `console.log`

```solidity
    briefing.verifyCall();
    console.log("completeCall: ", briefing.completedCall());
```

### `putSomething(uint,string,address)`

the next function that we need to call is `putSomething(uint,string,address)`, if we see the contract we know that it expected some value in order for the `completeInputation` variable to become true, we can add this line to satisfy the requirements

```solidity
    briefing.putSomething(1337, "Casino Heist Player", address(player));
    console.log("completedInputation: ", briefing.completedInputation());
```

### `firstDeposit()`

The function `firstDeposit` is marked `payable`, which mean this function can handle ether, which mean (again) we can send ether to this function, here is how we can do that.

```solidity
    briefing.firstDeposit{value: 5 ether}();
    console.log("completedDeposit: ", briefing.completedDeposit());
```

### Sending Ether directly to the contract

Smart contract not always can handle Ether directly, in order to do so, they need a special function called `receive()` or `fallback()`. In this case, `Briefing Contract` has `receive()`, which mean we can directly send the ether to the contract. In order for `completedTransfer()` to become true, we need to send exactly 1 ether.

```solidity
    payable(briefing).call{value: 1 ether}("");
    console.log("completedTransfer: ", briefing.completedTransfer());
```

### Finalize & Storage Variables

Well since it's local, you can directly see the value of the `_secretPhrase` when the `Setup contract` is initialized, yes that random hex. But let's learn how to read them, first thing first we need to determine in which slot is the `secretPhrase` stored in `Briefing contract`, we can use this command below

```bash
forge inspect Briefing storage-layout --pretty

╭---------------------+---------+------+--------+-------+------------------------------------------╮
| Name                | Type    | Slot | Offset | Bytes | Contract                                 |
+==================================================================================================+
| secretPhrase        | bytes32 | 0    | 0      | 32    | src/Basic/briefing/Briefing.sol:Briefing |
|---------------------+---------+------+--------+-------+------------------------------------------|
| completedCall       | bool    | 1    | 0      | 1     | src/Basic/briefing/Briefing.sol:Briefing |
|---------------------+---------+------+--------+-------+------------------------------------------|
| completedInputation | bool    | 1    | 1      | 1     | src/Basic/briefing/Briefing.sol:Briefing |
|---------------------+---------+------+--------+-------+------------------------------------------|
| completedTransfer   | bool    | 1    | 2      | 1     | src/Basic/briefing/Briefing.sol:Briefing |
|---------------------+---------+------+--------+-------+------------------------------------------|
| completedDeposit    | bool    | 1    | 3      | 1     | src/Basic/briefing/Briefing.sol:Briefing |
|---------------------+---------+------+--------+-------+------------------------------------------|
| completedBriefing   | bool    | 1    | 4      | 1     | src/Basic/briefing/Briefing.sol:Briefing |
╰---------------------+---------+------+--------+-------+------------------------------------------╯
```

From there, we can see that `secretPhrase` with its' datatype `bytes32` is stored at slot 0, we can then fetch this using

```solidity
    bytes32 sp = vm.load(address(briefing), 0);
```

and use it to call `finalize(bytes32)` like this

```solidity
    briefing.Finalize(sp);
    console.log("completedInputation: ", briefing.completedBriefing());
```

Let's try to combine them all and see if we solve the lab

```bash
$ forge test --mp test/Briefing.t.sol -vvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/Briefing.t.sol:BriefingTest
[PASS] testIfSolved() (gas: 79947)
Logs:
  completedCall:  true
  completedInputation:  true
  completedInputation:  true
  completedInputation:  true
  completedInputation:  true
```