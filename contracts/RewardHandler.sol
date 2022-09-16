// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CalestialBodies.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @custom:security-contact teamcybersnoopz@gmail.com
contract RewardHandler is Ownable {
    using ECDSA for bytes32;

    address public signer;
    CalestialBodies public nftCollection;
    mapping(uint256 => bool) isNonceUsed;

    event Rewarded(address participant, uint256 tokenId);

    error InvalidSignature();
    error NonceUsed();

    constructor(CalestialBodies nftCollection_) {
        nftCollection = nftCollection_;
    }

    function setSigner(address signer_) public onlyOwner {
        signer = signer_;
    }

    function receiveReward(
        uint256 tokenId_,
        address receiver_,
        uint256 nonce_,
        bytes calldata signature_
    ) public {
        if (isNonceUsed[nonce_]) revert NonceUsed();
        bytes32 messageHash = keccak256(
            abi.encode(receiver_, tokenId_, nonce_)
        );
        bytes32 hash = messageHash.toEthSignedMessageHash();
        if (signer != hash.recover(signature_)) revert InvalidSignature();
        isNonceUsed[nonce_] = true;
        nftCollection.mint(receiver_, tokenId_, 1, "");
        emit Rewarded(receiver_, tokenId_);
    }
}
