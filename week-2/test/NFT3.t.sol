// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFT3.sol";

contract NFTTest is Test {
    NFT3 public nft;

    address public admin = address(0x47);
    address public alice = address(0x1);
    address public bob = address(0x32);

    function setUp() public {
        bytes32 merkleRoot = 0x897d6714686d83f84e94501e5d6f0f38c94b75381b88d1de3878b4f3d2d5014a;
        vm.prank(admin);
        nft = new NFT3(bob, merkleRoot);
    }

    function testUnderpaidMint() public {
        vm.deal(alice, 0.1 ether);
        vm.prank(alice);
        vm.expectRevert();
        nft.mint{value: 0.05 ether}();
    }

    function testNormalMint() public {
        vm.deal(alice, 0.1 ether);
        vm.prank(alice);
        nft.mint{value: 0.1 ether}();
        assertEq(nft.balanceOf(alice), 1);
    }

    function testDiscountedMint() public {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x50bca9edd621e0f97582fa25f616d475cabe2fd783c8117900e5fed83ec22a7c;
        proof[1] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[2] = 0x9005e06090901cdd6ef7853ac407a641787c28a78cb6327999fc51219ba3c880;

        uint256 index = 0;

        vm.deal(alice, 0.1 ether);
        vm.prank(alice);
        nft.mintWithDiscount{value: 0.05 ether}(proof, index);
        assertEq(nft.balanceOf(alice), 1);
    }

    function testWithdrawReserves() public {
        vm.startPrank(alice);
        vm.deal(alice, 0.2 ether);
        nft.mint{value: 0.1 ether}();
        nft.mint{value: 0.1 ether}();
        vm.stopPrank();

        assertEq(address(nft).balance, 0.2 ether);

        vm.prank(admin);
        nft.withdrawReserves();

        assertEq(address(admin).balance, 0.2 ether * (1 - 0.025));
    }

    function testWithdrawRoyalties() public {
        vm.startPrank(alice);
        vm.deal(alice, 0.2 ether);
        nft.mint{value: 0.1 ether}();
        nft.mint{value: 0.1 ether}();
        vm.stopPrank();

        assertEq(address(nft).balance, 0.2 ether);

        vm.prank(bob);
        nft.withdrawRoyalties();

        assertEq(address(bob).balance, 0.2 ether * 0.025);
    }

    function testOwnershipTransfer() public {
        assertEq(nft.owner(), admin);
        vm.prank(admin);
        nft.transferOwnership(alice);
        vm.prank(alice);
        nft.acceptOwnership();
        assertEq(nft.owner(), alice);
    }
}
