// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SpaceCoin} from "../src/SpaceCoin.sol";
import {ICO} from "../src/Ico.sol";

contract SpaceCoinTest is Test {
    ICO public ico;
    SpaceCoin public spaceCoin;
    address public owner;
    address public treasury = address(0xBEEF);
    address public user = address(0xABCD);
    address public user2 = address(0xABCDEF);

    function setUp() public {
        owner = address(this);
        ico = new ICO(treasury);
        spaceCoin = ico.spaceCoin();
    }

    function testMinting() public view {
        assertEq(address(ico.spaceCoin()), address(spaceCoin));
        assertEq(spaceCoin.balanceOf(address(ico)), 150000 ether);
        assertEq(spaceCoin.balanceOf(treasury), 350000 ether);
        assertEq(spaceCoin.totalSupply(), 500000 ether);
        assertEq(uint8(ico.phase()), 0);
    }

    function testOnlyOwnerCanPause() public {
        vm.prank(user);
        vm.expectRevert("Not an Owner");
        ico.setPauseStatus(true);

        vm.prank(owner);
        ico.setPauseStatus(true);
        assertTrue(ico.fundRaisingPaused());
        assertTrue(ico.redemptionPaused());
    }

    function testAdvancePhase() public {
        vm.prank(user);
        vm.expectRevert("Not an Owner");

        ico.advancePhase();
        vm.startPrank(owner);
        assertEq(uint8(ico.phase()), 0);
        ico.advancePhase();
        assertEq(uint8(ico.phase()), 1);
        ico.advancePhase();
        assertEq(uint8(ico.phase()), 2);
        vm.expectRevert("Open phase");
        ico.advancePhase();
        assertEq(uint8(ico.phase()), 2);
    }

    function testFundraisingRevertsWhenPaused() public {
        // Add contributor and give them ETH
        ico.addPrivateContributor(user);
        vm.deal(user, 2 ether);

        // Owner pauses fundraising
        ico.setPauseStatus(true);

        // Try to contribute => should fail
        vm.expectRevert("Fundraising paused");
        vm.prank(user);
        ico.contribute{value: 1 ether}();
    }

    function testOnlyOwnerCanAddPrivateContributor() public {
        ico.addPrivateContributor(user);
        vm.deal(user, 1 ether);

        vm.prank(user);
        ico.contribute{value: 1 ether}();

        assertEq(ico.totalRaised(), 1 ether);
    }

    function testContribute() public {
        // address alice = address(98);
        // address c1 = address(0xC1);
        // address c2 = address(0xC2);
        // address c3 = address(0xC3);
        // address c4 = address(0xC4);
        // address c5 = address(0xC5);
        // address c6 = address(0xC6);
        // address c7 = address(0xC7);
        // address c8 = address(0xC8);
        // address c9 = address(0xC9);
        // address c10 = address(0xCA);
        // address c11 = address(0xCB); // will exceed SEED cap

        // address[11] memory contributors = [
        //     c1,
        //     c2,
        //     c3,
        //     c4,
        //     c5,
        //     c6,
        //     c7,
        //     c8,
        //     c9,
        //     c10,
        //     c11
        // ];

        // for (uint i = 0; i < 11; i++) {
        //     ico.addPrivateContributor(contributors[i]);
        //     vm.deal(contributors[i], 2000 ether);
        // }

        // First 10 contributors contribute exactly 1500 ETH each = 15000 ETH
        // vm.prank(c1);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c2);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c3);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c4);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c5);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c6);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c7);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c8);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c9);
        // ico.contribute{value: 1500 ether}();
        // vm.prank(c10);
        // ico.contribute{value: 1500 ether}();

        // assertEq(ico.totalRaised(), 15000 ether);

        // vm.prank(c11);
        // vm.expectRevert("SEED limit exceeding");
        // ico.contribute{value: 1 ether}();

        // ico.advancePhase(); // To GENERAL

        // ico.addPrivateContributor(alice);
        // vm.deal(alice, 2000 ether);
        // vm.prank(alice);
        // vm.expectRevert("Individual GENERAL limit exceeding");
        // ico.contribute{value: 1000 ether}();

        // vm.prank(alice);
        // ico.contribute{value: 1000 ether}();

        // assertEq(ico.totalRaised(), 15000 ether);

        // ico.advancePhase(); // to OPEN

        // address rich = address(0xDEAD);
        // vm.deal(rich, 31000 ether);
        // address rich2 = address(343);
        // vm.deal(rich2, 10 ether);

        // vm.prank(rich);
        // ico.contribute{value: 29999 ether}();

        // vm.prank(rich2);
        // ico.contribute{value: 29000 ether}(); // OK

        // vm.prank(rich2);
        // vm.expectRevert("OPEN limit exceeding");
        // ico.contribute{value: 1 ether}(); // Exceeds 30000
    }

    // function testRedemptionFailWhenPause() public{
    //     ico.advancePhase();
    //     ico.advancePhase();

    //     // ico.addPrivateContributor(user);
    //     vm.prank(user);
    //     vm.deal(user, 100 ether);

    //     vm.prank(owner);
    //     ico.setPauseStatus(true);
    //     ico.redemption();
    // }
}
