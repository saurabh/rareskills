// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SanctionedERC20 is ERC20, Ownable {
    mapping(address => bool) private _isBanned;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function banAddress(address account) public onlyOwner {
        _isBanned[account] = true;
    }

    function unbanAddress(address account) public onlyOwner {
        _isBanned[account] = false;
    }

    function isBanned(address account) public view returns (bool) {
        return _isBanned[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!_isBanned[from], "ERC20: transfer from banned address");
        require(!_isBanned[to], "ERC20: transfer to banned address");
    }
}
