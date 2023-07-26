// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Reward3} from "./Reward3.sol";

contract Staking3 is IERC721Receiver {
    struct Deposit {
        uint256 tokenId;
        uint256 timestamp;
    }

    mapping(address => Deposit[]) public depositInfo;
    address private _nftAddress;
    address private _tokenAddress;

    uint256 public rewardAmount = 10;

    constructor(address nftAddress, address tokenAddress) {
        _nftAddress = nftAddress;
        _tokenAddress = tokenAddress;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
        depositInfo[from].push(Deposit(tokenId, block.timestamp));
        return IERC721Receiver.onERC721Received.selector;
    }

    function withdrawStakingRewards() public {
        require(depositInfo[msg.sender].length > 0, "No NFT staked.");
        Reward3 rewardToken = Reward3(_tokenAddress);
        rewardToken.mintStakingRewards(msg.sender, rewardAmount * depositInfo[msg.sender].length);
    }

    function withdrawNFT(uint256 index) public {
        require(depositInfo[msg.sender].length > index, "Invalid index.");
        Deposit memory deposit = depositInfo[msg.sender][index];
        require(deposit.timestamp + 1 days < block.timestamp, "Staking: NFT is still locked");

        // If the NFT to be withdrawn is not at the end of the array, move the last element to its place
        if (index != depositInfo[msg.sender].length - 1) {
            depositInfo[msg.sender][index] = depositInfo[msg.sender][depositInfo[msg.sender].length - 1];
        }

        // pay staking rewards
        Reward3 rewardToken = Reward3(_tokenAddress);
        rewardToken.mintStakingRewards(msg.sender, rewardAmount * depositInfo[msg.sender].length);
        
        // Pop the last element.
        depositInfo[msg.sender].pop();
        
        ERC721(_nftAddress).safeTransferFrom(address(this), msg.sender, deposit.tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId;
    }
}
