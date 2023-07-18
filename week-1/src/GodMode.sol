// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodToken is ERC1363, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @dev See {IERC20-transfer}.
    /// @notice allows God to transfer tokens between any accounts
    function godTransfer(address from, address to, uint256 amount) public onlyOwner {
        _transfer(from, to, amount);
    }

    // /// @dev See {IERC20-transfer}.
    // /// @notice allows God to transfer tokens between any accounts OR default transfer behaviour.
    // function transferFrom(address from, address to, uint256 amount) public virtual override(ERC20, IERC20) returns (bool) {
    //     if (msg.sender == owner()) {
    //         _transfer(from, to, amount);
    //     } else {
    //         address spender = _msgSender();
    //         _spendAllowance(from, spender, amount);
    //         _transfer(from, to, amount);
    //     }
    //     return true;
    //
}
