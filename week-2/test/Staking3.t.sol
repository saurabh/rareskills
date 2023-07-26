// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import {NFT3} from "../src/NFT3.sol";
import {Staking3} from "../src/Staking3.sol";
import {Reward3} from "../src/Reward3.sol";

contract NFTStaking is Test {
    NFT3 public nft;
    Staking3 public staking;
    Reward3 public rewardToken;

    address public admin = address(0x47);
    address public alice = address(0x1);
    address public bob = address(0x32);

    function setUp() public {
        bytes32 merkleRoot = 0x897d6714686d83f84e94501e5d6f0f38c94b75381b88d1de3878b4f3d2d5014a;
        vm.prank(admin);
        nft = new NFT3(bob, merkleRoot);
        rewardToken = new Reward3();
        staking = new Staking3(address(nft), address(rewardToken));
        rewardToken.setStakingAddress(address(staking));
    }

    function testStaking() public {
        vm.deal(alice, 0.1 ether);
        vm.prank(alice);
        nft.mint{value: 0.1 ether}();
        assertEq(nft.balanceOf(alice), 1);

        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);
        assertEq(nft.balanceOf(alice), 0);
    }

    function testWithdrawRewards() public {
        vm.deal(alice, 0.1 ether);
        vm.startPrank(alice);
        nft.mint{value: 0.1 ether}();
        assertEq(nft.balanceOf(alice), 1);

        nft.safeTransferFrom(alice, address(staking), 1);
        assertEq(nft.balanceOf(alice), 0);

        // ( uint256 tokenId, uint256 timestamp) = staking.depositInfo(alice, 0);
        // console.log("staking.depositInfo(alice)", tokenId, timestamp);

        staking.withdrawStakingRewards();
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(alice), 10);
    }

    function testWithdrawRewardsforMultipleStakes() public {
        vm.deal(alice, 0.3 ether);
        vm.startPrank(alice);
        nft.mint{value: 0.1 ether}();
        nft.mint{value: 0.1 ether}();
        nft.mint{value: 0.1 ether}();
        assertEq(nft.balanceOf(alice), 3);

        nft.safeTransferFrom(alice, address(staking), 1);
        nft.safeTransferFrom(alice, address(staking), 2);
        nft.safeTransferFrom(alice, address(staking), 3);
        assertEq(nft.balanceOf(alice), 0);

        staking.withdrawStakingRewards();
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(alice), 30);
    }

    function testWithdrawStake() public {
        vm.deal(alice, 0.1 ether);
        vm.startPrank(alice);
        nft.mint{value: 0.1 ether}();
        assertEq(nft.balanceOf(alice), 1);

        nft.safeTransferFrom(alice, address(staking), 1);
        assertEq(nft.balanceOf(alice), 0);
        vm.warp(block.timestamp + 1 days + 1 seconds);

        staking.withdrawNFT(0);
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(alice), 10);
        assertEq(nft.balanceOf(alice), 1);
    }

    function testWithdrawStakeMultipleStakes() public {
        vm.deal(alice, 0.3 ether);
        vm.startPrank(alice);
        nft.mint{value: 0.1 ether}();
        nft.mint{value: 0.1 ether}();
        nft.mint{value: 0.1 ether}();
        assertEq(nft.balanceOf(alice), 3);

        nft.safeTransferFrom(alice, address(staking), 1);
        nft.safeTransferFrom(alice, address(staking), 2);
        nft.safeTransferFrom(alice, address(staking), 3);
        assertEq(nft.balanceOf(alice), 0);
        vm.warp(block.timestamp + 1 days + 1 seconds);

        staking.withdrawNFT(2);
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(alice), 30);
        assertEq(nft.balanceOf(alice), 1);
    }

}