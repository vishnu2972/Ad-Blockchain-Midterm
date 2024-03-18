// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

import "./KittyFactory.sol";
import "./erc721.sol";
import "./safemath.sol";
import "./ownable.sol";

contract KittyOwnership is KittyFactory, ERC721 {
    using SafeMath for uint256;

    mapping (uint => address) kittyApprovals;


    function balanceOf(address owner) external view returns (uint256) {
        return ownerKittyCount[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return kittyToOwner[tokenId];
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        ownerKittyCount[to] = ownerKittyCount[to].add(1);
        ownerKittyCount[from] = ownerKittyCount[from].sub(1);
        kittyToOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external payable {
        require (kittyToOwner[tokenId] == msg.sender || kittyApprovals[tokenId] == msg.sender);
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external payable onlyOwnerOf(tokenId) {
        kittyApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }
}
