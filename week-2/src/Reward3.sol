// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Reward3 is ERC20, Ownable2Step {
    address public stakingAddress;

    constructor() ERC20("Reward3", "RW3") {}

    function setStakingAddress(address _stakingAddress) external onlyOwner {
        stakingAddress = _stakingAddress;
    }

    function mintStakingRewards(address account, uint256 amount) external {
        require(msg.sender == stakingAddress, "Only staking contract can mint");
        _mint(account, amount);
    }
}