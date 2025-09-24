// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IBetterERC20} from "src/Common/unlimited-credit-line/BetterERC20.sol";
import {NewBank} from "src/Common/unlimited-credit-line/NewBank.sol";
import {Setup} from "src/Common/unlimited-credit-line/Setup.sol";

contract UnlimitedCreditLineTest is Test {
    Setup public challSetup;
    IBetterERC20 public BERC20;
    NewBank public NB;

    address public deployer = makeAddr("deployer");
    address public player = makeAddr("player");

    uint256 initialSupply = 1000000000000000000000;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, 100 ether);
        challSetup = new Setup(initialSupply);
        NB = challSetup.NB();
        vm.stopPrank();
    }

    function testIfSolved() public {
        // Setup for Player
        vm.startPrank(player, player);
        vm.deal(player, 1 ether);

        // Write Exploit here

        vm.stopPrank();
        assertEq(challSetup.isSolved(), true);
    }
}
