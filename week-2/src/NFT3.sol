// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFT3 is ERC721, ERC2981, Ownable2Step {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    uint256 public constant MAX_SUPPLY = 20;
    uint256 public constant MINT_PRICE = 0.1 ether;
    uint96 public constant ROYALTY_PERCENT = 250; // basis points
    uint256 public currentSupply;

    bytes32 public immutable i_merkleRoot;

    BitMaps.BitMap private _discountList;
    uint256 private _royalties;

    constructor(address royaltyReceiver, bytes32 _merkleRoot) ERC721("NFT3", "NFT3") {
        _setDefaultRoyalty(royaltyReceiver, ROYALTY_PERCENT);
        i_merkleRoot = _merkleRoot;
    }

    function mint() public payable {
        require(msg.value == MINT_PRICE, "NFT3: insufficient funds");
        require(currentSupply < MAX_SUPPLY, "NFT3: sold out");

        _safeMint(msg.sender, currentSupply + 1);

        (, uint256 royaltyAmount) = royaltyInfo(currentSupply, MINT_PRICE);
        _royalties += royaltyAmount;

        currentSupply++;
    }

    function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable {
        require(msg.value == MINT_PRICE / 2, "NFT3: insufficient funds");
        require(currentSupply < MAX_SUPPLY, "NFT3: sold out");
        require(!_discountList.get(index), "NFT3: already used discount");

        _verifyProof(proof, index);

        // set discount as used
        _discountList.setTo(index, true);

        _safeMint(msg.sender, currentSupply);

        (, uint256 royaltyAmount) = royaltyInfo(currentSupply, MINT_PRICE);
        _royalties += royaltyAmount;

        currentSupply++;
    }

    function _verifyProof(bytes32[] memory proof, uint256 index) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, index))));
        require(MerkleProof.verify(proof, i_merkleRoot, leaf), "Invalid proof");
    }

    function withdrawRoyalties() external {
        (address royaltyReceiver,) = royaltyInfo(currentSupply, MINT_PRICE);
        require(msg.sender == royaltyReceiver, "Only royalty receiever can withdraw");
        require(_royalties > 0, "No royalties to withdraw");

        uint256 amount = _royalties;
        _royalties = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawReserves() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance - _royalties);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool) {
        return interfaceId == type(ERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
}
