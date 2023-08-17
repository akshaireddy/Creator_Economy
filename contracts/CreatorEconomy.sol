// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract CreatorEconomy is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public nextTokenId;
    
    struct Creator {
        address creatorAddress;
        string name;
        uint256 balance;
    }
    
    mapping(address => Creator) public creators;
    mapping(address => mapping(uint256 => uint256)) public tokenPrices;

    event NewCreator(address indexed creatorAddress, string name);
    event NewToken(address indexed creatorAddress, uint256 tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed creatorAddress, uint256 tokenId);

    function initialize() initializer public {
        __Ownable_init();
        nextTokenId = 1;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function createCreator(string memory name) external {
        creators[msg.sender] = Creator(msg.sender, name, 0);
        emit NewCreator(msg.sender, name);
    }

    function createToken(uint256 tokenId, uint256 price) external {
        require(creators[msg.sender].creatorAddress != address(0), "You are not a registered creator");
        tokenPrices[msg.sender][tokenId] = price;
        emit NewToken(msg.sender, tokenId, price);
    }

    function purchaseToken(address creatorAddress, uint256 tokenId) external payable {
        Creator storage creator = creators[creatorAddress];
        require(creator.creatorAddress != address(0), "Creator not found");
        require(tokenId < nextTokenId, "Token does not exist");
        require(msg.value >= tokenPrices[creatorAddress][tokenId], "Insufficient payment");

        uint256 amountToTransfer = tokenPrices[creatorAddress][tokenId];
        creator.balance += amountToTransfer;
        delete tokenPrices[creatorAddress][tokenId];
        emit Purchase(msg.sender, creatorAddress, tokenId);
    }

    function withdrawBalance() external {
        Creator storage creator = creators[msg.sender];
        require(creator.creatorAddress != address(0), "You are not a registered creator");

        uint256 balance = creator.balance;
        creator.balance = 0;
        payable(msg.sender).transfer(balance);
    }

    function getCreatorBalance(address creatorAddress) external view returns (uint256) {
        return creators[creatorAddress].balance;
    }
}
