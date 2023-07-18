// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import {BondingToken} from "../src/BondingToken.sol";
import {GodToken} from "../src/GodMode.sol";

contract BondingSaleTest is Test {
    BondingToken public bondingToken;
    GodToken public payableToken;
    GodToken public payableTokenRandom;

    address public admin = address(0x0);
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        vm.prank(admin);
        payableToken = new GodToken("USD Coin", "USDC");
        payableTokenRandom = new GodToken("Pepe Token", "PEPE");
        vm.prank(admin);
        payableToken.mint(alice, 1000e18);
        payableTokenRandom.mint(alice, 1000e18);
        assertEq(payableToken.balanceOf(alice), 1000e18);

        vm.prank(admin);
        bondingToken = new BondingToken(address(payableToken));
    }

    function testBondMint() public {
        vm.startPrank(alice);
        uint mintAmount = 10e18;
        uint256 costToMint = bondingToken.costToMint(mintAmount);
        bytes memory data = abi.encode(mintAmount);
        payableToken.transferAndCall(address(bondingToken), costToMint, data);

        uint256 alicePayableBalance = payableToken.balanceOf(alice);
        assertEq(alicePayableBalance, 1000e18 - costToMint);

        uint256 aliceBondBalance = bondingToken.balanceOf(alice);
        assertEq(aliceBondBalance, mintAmount);

        vm.stopPrank();
    }

    function testBondBurn() public {
        vm.startPrank(alice);
        uint mintAmount = 10e18;
        uint256 costToMint = bondingToken.costToMint(mintAmount);
        bytes memory data = abi.encode(mintAmount);
        payableToken.transferAndCall(address(bondingToken), costToMint, data);
        uint256 alicePayableBalanceAfterMint = payableToken.balanceOf(alice);


        uint256 revenueOnBurn = bondingToken.revenueOnBurn(mintAmount);
        // console.log("payableToken.balanceOf(alice)", payableToken.balanceOf(alice));
        // console.log("revenueOnBurn", revenueOnBurn);
        bondingToken.burnOnCurve(mintAmount);
        // bondingToken.transferAndCall(address(bondingToken), mintAmount); // DOES NOT WORK: [FAIL. Reason: ERC1363: transfer to non ERC1363Receiver implementer] 
        assertEq(payableToken.balanceOf(alice), alicePayableBalanceAfterMint + revenueOnBurn);
        assertEq(bondingToken.balanceOf(alice), 0);

        uint256 alicePayableBalance = payableToken.balanceOf(alice);
        assertEq(alicePayableBalance, alicePayableBalanceAfterMint + revenueOnBurn);

        vm.stopPrank();
    }

    function testBondMintWithRandomToken() public {
        vm.startPrank(alice);
        vm.expectRevert();
        payableTokenRandom.transferAndCall(address(bondingToken), 100e18);
        vm.stopPrank();
    }

}
