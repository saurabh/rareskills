// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import {GodToken} from "../src/GodMode.sol";

// contract GodTokenTest is Test {
//     GodToken public godToken;
//     address public admin = address(0x0);
//     address public alice = address(0x1);
//     address public bob = address(0x2);

//     function setUp() public {
//         vm.prank(admin);
//         godToken = new GodToken("God Mode Token", "GOD");
//         vm.prank(admin);
//         godToken.mint(alice, 1e18);
//         assertEq(godToken.balanceOf(alice), 1e18);
//     }

//     function testTransfer() public {
//         vm.prank(alice);
//         godToken.transfer(bob, 0.5e18);

//         uint256 aliceBalance = godToken.balanceOf(alice);
//         assertEq(aliceBalance, 1e18 - 0.5e18);
//         uint256 bobBalance = godToken.balanceOf(bob);
//         assertEq(bobBalance, 0.5e18);
//     }

//     function testTransferFromGod() public {
//         vm.prank(admin);
//         godToken.godTransfer(alice, bob, 1e18);
//         vm.prank(alice);
//         uint256 aliceBalance = godToken.balanceOf(alice);
//         uint256 bobBalance = godToken.balanceOf(bob);
//         assertEq(aliceBalance, 0);
//         assertEq(bobBalance, 1e18);
//     }
// }
