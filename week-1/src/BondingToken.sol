// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract BondingToken is ERC1363, IERC1363Receiver, IERC1363Spender, Ownable {
    using ERC165Checker for address;
    using SafeERC20 for IERC20;

    address public i_purchaseToken;
    uint256 public s_totalSupply;
    uint256 public constant SLOPE = 1;
    uint256 public constant BASE_PRICE = 0; // initial price when the supply is 0
    uint256 public constant MINIMUM_AMOUNT = 5e18;
    uint256 public constant MAX_SUPPLY = 1_000_000e18;

    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);
    event TokensApproved(address indexed sender, uint256 amount, bytes data);

    constructor(address purchaseToken) ERC20("Bonding Curve Token", "BOND") {
        i_purchaseToken = purchaseToken;
    }

    function costToMint(uint256 numTokens) public view returns (uint256) {
        uint256 a = s_totalSupply * 1e18 + 1e18; // price of the first token to mint
        uint256 l = s_totalSupply * 1e18 + numTokens; // price of the last token to mint
        uint256 cost = numTokens * (a + l) / (2 * 1e18);
        return cost;
    }

    function revenueOnBurn(uint256 numTokens) public view returns (uint256) {
        uint256 a = s_totalSupply * 1e18; // price of the first token to burn
        uint256 l = (s_totalSupply - numTokens) * 1e18; // price of the last token to burn
        uint256 revenue = numTokens * (a + l) / (2 * 1e18);
        return revenue / 1e18;
    }


    function onTransferReceived(address spender, address sender, uint256 amount, bytes memory data)
        public
        override
        returns (bytes4)
    {
        if (_msgSender() != i_purchaseToken && _msgSender() != address(this)) {
            revert InvalidToken();
        }
        if (amount <= MINIMUM_AMOUNT) {
            revert PurchaseTooSmall();
        }

        uint256 mintAmount = abi.decode(data, (uint256));

        emit TokensReceived(spender, sender, amount, data);

        if (_msgSender() == i_purchaseToken) {
            _mint(sender, mintAmount);
            s_totalSupply += mintAmount;
        } else {
            uint256 revenue = revenueOnBurn(amount);
            IERC1363(i_purchaseToken).transfer(sender, revenue); // Does not work: [FAIL. Reason: ERC1363: transfer to non ERC1363Receiver implementer] 
            _burn(_msgSender(), amount);
            s_totalSupply -= amount;
        }

        return IERC1363Receiver.onTransferReceived.selector;
    }

    function burnOnCurve(uint256 numTokens) public {
        uint256 revenue = revenueOnBurn(numTokens);
         _burn(_msgSender(), numTokens);
        // IERC20(i_purchaseToken).transfer(sender, amount);
        IERC1363(i_purchaseToken).transfer(_msgSender(), revenue);
        s_totalSupply -= numTokens;
    }

    function onApprovalReceived(address sender, uint256 amount, bytes memory data) public override returns (bytes4) {
        if (_msgSender() != i_purchaseToken || _msgSender() != address(this)) {
            revert InvalidToken();
        }
        if (amount <= MINIMUM_AMOUNT) {
            revert PurchaseTooSmall();
        }

        emit TokensApproved(sender, amount, data);

        IERC1363(i_purchaseToken).transferFrom(sender, address(this), amount);

        return IERC1363Spender.onApprovalReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1363Receiver).interfaceId || interfaceId == type(IERC1363Spender).interfaceId
            || super.supportsInterface(interfaceId);
    }
}

/*//////////////////////////////////////////////////////////////
                            ERRORS
//////////////////////////////////////////////////////////////*/
/// @notice If no tokens are generated by the purchase, it will revert to save the buyer wasting their tokens
error PurchaseTooSmall();
/// @notice The user has passed a token that is not accepted for this sale
error InvalidToken();
// /// @notice The user has passed a token that is not accepted for this sale
// error ();
