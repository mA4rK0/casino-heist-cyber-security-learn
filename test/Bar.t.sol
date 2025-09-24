// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Bar} from "src/Common/bar/Bar.sol";
import {Setup} from "src/Common/bar/Setup.sol";

contract BarTest is Test {
    Setup public challSetup;
    Bar public bar;

    address public deployer = makeAddr("deployer");
    address public player = makeAddr("player");

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, 10 ether);
        challSetup = new Setup();
        bar = challSetup.bar();
        vm.stopPrank();
    }

    function testIfSolved() public {
        // Player register
        vm.startPrank(player, player); // Set both msg.sender dan tx.origin
        vm.deal(player, 1 ether);
        bar.register{value: 1 ether}();
        vm.stopPrank();

        assertEq(bar.balance(player), 1 ether, "Player should have 1 ether balance");

        // Owner add player as member
        vm.startPrank(deployer, deployer);
        bar.addMember(player);
        vm.stopPrank();

        assertTrue(bar.barMember(player), "Player should be a member");

        // Player get drink and check solution
        vm.startPrank(player, player);
        bar.getDrink();
        challSetup.solvedByPlayer();
        vm.stopPrank();

        assertEq(bar.beerGlass(player), 1, "Player should have 1 beer glass");
        assertTrue(challSetup.isSolved(), "Challenge should be solved");
    }
}
