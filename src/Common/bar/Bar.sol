// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { console } from "forge-std/Test.sol";

contract Bar{

    address public owner;
    mapping(address => bool) public barMember;
    mapping(address => uint) public beerGlass;
    mapping(address => uint256) public balance;

    constructor(address _owner) payable {
        owner = _owner;
    }

    function register() public payable isHuman {
        require(msg.value >= 1e18, "Need 1 ether deposit.");
        balance[msg.sender] += msg.value;
    }

    function addMember(address _addMember) public isHuman onlyOwner {
        require(balance[_addMember] > 0, "You need to deposit some money to become a member.");
        barMember[_addMember] = true;
    }

    function getDrink() public isHuman onlyMember {
        require(balance[msg.sender] > 0, "You need to deposit some money.");
        beerGlass[msg.sender]++;
    }

    modifier isHuman(){
        console.log(tx.origin);
        console.log(msg.sender);
        require(msg.sender == tx.origin, "Only Human Allowed in this Bar!");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only Owner can add Member!");
        _;
    }

    modifier onlyMember() {
        require(barMember[msg.sender], "Only members can get drinks!");
        _;
    }

    receive() external payable {
        balance[msg.sender] += msg.value;
    }
    
} 