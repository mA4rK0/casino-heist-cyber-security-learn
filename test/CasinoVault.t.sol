// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {CasinoVault} from "src/Common/casino-vault/CasinoVault.sol";
import {Setup} from "src/Common/casino-vault/Setup.sol";

contract CasinoVaultTest is Test {
    Setup public challSetup;
    CasinoVault public casinovault;

    address public deployer = makeAddr("deployer");
    address public player = makeAddr("player");

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, 100 ether);
        challSetup = new Setup{value: 50 ether}();
        casinovault = challSetup.CS();
        vm.stopPrank();
    }

    function testIfSolved() public {
        // Setup for player
        vm.startPrank(player, player);
        vm.deal(player, 1 ether);

        // Write Exploit here

        assertEq(challSetup.isSolved(), true);
    }
}
