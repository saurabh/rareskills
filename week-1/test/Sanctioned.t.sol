// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import {SanctionedERC20} from "../src/Sanctioned.sol";

// contract SanctionedERC20Test is Test {
//     SanctionedERC20 public sanctionedERC20;
//     address public admin = address(0x0);
//     address public alice = address(0x1);
//     address public bob = address(0x2);

//     function setUp() public {
//         vm.prank(admin);
//         sanctionedERC20 = new SanctionedERC20("SanctionedsanctionedERC20", "STKN");
//         vm.prank(admin);
//         sanctionedERC20.mint(alice, 1e18);
//         assertEq(sanctionedERC20.balanceOf(alice), 1e18);
//     }

//     function testBanAddress() public {
//         vm.prank(admin);
//         sanctionedERC20.banAddress(alice);
//         assertEq(sanctionedERC20.isBanned(alice), true);
//     }

//     function testUnbanAddress() public {
//         vm.prank(admin);
//         sanctionedERC20.unbanAddress(alice);
//         assertEq(sanctionedERC20.isBanned(alice), false);
//     }

//     function testTransfer() public {
//         vm.prank(alice);
//         sanctionedERC20.transfer(bob, 0.5e18);

//         uint256 aliceBalance = sanctionedERC20.balanceOf(alice);
//         assertEq(aliceBalance, 1e18 - 0.5e18);
//         uint256 bobBalance = sanctionedERC20.balanceOf(bob);
//         assertEq(bobBalance, 0.5e18);
//     }

//     function testTransferToBannedAddress() public {
//         vm.prank(admin);
//         sanctionedERC20.banAddress(bob);
//         vm.prank(alice);
//         uint256 aliceBalance = sanctionedERC20.balanceOf(alice);
//         uint256 bobBalance = sanctionedERC20.balanceOf(bob);
//         vm.expectRevert();
//         sanctionedERC20.transfer(bob, 0.5e18);
//         assertEq(aliceBalance, 1e18);
//         assertEq(bobBalance, 0);
//     }

//     function testTransferFromBannedAddress() public {
//         vm.prank(admin);
//         sanctionedERC20.banAddress(alice);
//         vm.prank(alice);
//         uint256 aliceBalance = sanctionedERC20.balanceOf(alice);
//         uint256 bobBalance = sanctionedERC20.balanceOf(bob);
//         vm.expectRevert();
//         sanctionedERC20.transfer(bob, 0.5e18);
//         assertEq(aliceBalance, 1e18);
//         assertEq(bobBalance, 0);
//     }
// }
