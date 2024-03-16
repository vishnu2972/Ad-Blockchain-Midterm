// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

import "./erc721.sol";
import "./safemath.sol";
import "./ownable.sol";

contract KittyFactory is Ownable {
    using SafeMath for uint256;

    struct Kitty {
        uint256 genes;
        uint64 birthTime;
        uint64 cooldownTime;
    }

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    Kitty[] public kitties;

    mapping (uint256 => address) public kittyToOwner;
    mapping (address => uint256) ownerKittyCount;
    // Assuming you have this mapping defined somewhere as it's used but not declared
    mapping (address => uint256[]) ownerToKitties;

    event NewKitty(uint256 kittyId, uint256 genes);

    modifier onlyOwnerOf(uint kittyId) {
        require(msg.sender == kittyToOwner[kittyId]);
        _;
    }

    function _createKitty(uint256 _genes) internal {
        Kitty memory newKitty = Kitty(_genes, uint64(now), 0);
        uint256 newKittyId = kitties.push(newKitty) - 1;

        kittyToOwner[newKittyId] = msg.sender;
        ownerKittyCount[msg.sender] = ownerKittyCount[msg.sender].add(1);
        ownerToKitties[msg.sender].push(newKittyId); // Add kitty ID to the owner's list of kitties

        emit NewKitty(newKittyId, _genes);
    }

    function getKitty(uint256 _kittyId) public view returns (uint256 genes, uint64 birthTime, uint64 cooldownTime) {
        require(_kittyId < kitties.length, "Kitty does not exist.");
        Kitty storage kitty = kitties[_kittyId];
        return (kitty.genes, kitty.birthTime, kitty.cooldownTime);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createKittyGen0(string _name) public {
        require(ownerKittyCount[msg.sender] == 0);
        uint genes = _generateRandomDna(_name);
        genes = genes - genes % 100;
        _createKitty(genes);
    }

}
