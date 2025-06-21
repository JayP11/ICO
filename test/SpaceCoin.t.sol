// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SpaceCoin} from "../src/SpaceCoin.sol";

contract SpaceCoinTest is Test {
    SpaceCoin public spaceCoin;

    address public owner = address(1);
    address public user = address(12);
    address public recipient = address(123);

    address public treasury = address(2);
    address public icoContract = address(3);

    function setUp() public {
        vm.prank(owner);
        spaceCoin = new SpaceCoin(treasury, icoContract);
    }

    function testMinting() public view {
        assertEq(spaceCoin.totalSupply(), 500000 ether);
        assertEq(spaceCoin.balanceOf(icoContract), 150000 ether);
        assertEq(spaceCoin.balanceOf(treasury), 350000 ether);
    }

    function testOwnerSetCorrectly() public view {
        assertEq(spaceCoin.owner(), owner);
    }

    function testsetTaxEnabled() public {
        vm.prank(user);
        vm.expectRevert("Not an Owner");
        spaceCoin.setTaxEnabled(true);

        vm.prank(owner);
        spaceCoin.setTaxEnabled(true);
        assertTrue(spaceCoin.isTaxEnabled());

        vm.prank(owner);
        spaceCoin.setTaxEnabled(false);
        assertFalse(spaceCoin.isTaxEnabled());
    }

    function testTransferWithoutTest() public {
        vm.prank(icoContract);
        spaceCoin.transfer(user, 100 ether);

        vm.prank(user);
        spaceCoin.transfer(recipient, 10 ether);

        assertEq(spaceCoin.balanceOf(recipient), 10 ether);
    }

    function testTransferWithTest() public {
        vm.prank(icoContract);
        spaceCoin.transfer(user, 1000 ether);

        vm.prank(owner);
        spaceCoin.setTaxEnabled(true);
        vm.prank(user);
        spaceCoin.transfer(recipient, 500 ether);

        assertEq(spaceCoin.balanceOf(recipient), 490 ether);
        assertEq(spaceCoin.balanceOf(treasury), 350_000 ether + 10 ether);
    }

    function testTaxNotAppliedOnMint() public view {
        assertEq(spaceCoin.balanceOf(treasury), 350_000 ether);
    }
}
