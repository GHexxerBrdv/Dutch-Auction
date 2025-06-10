// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DutchAuction} from "./DutchAuction.sol";

contract AuctionFactory {
    error AuctionFactory__NonOwnerCanNotWithdraw();
    error AuctionFactory__SendProperFees();
    error AuctionFactory__TransactionFailed();
    error AuctionFactory__NotOwner();

    address public owner;
    uint256 public constant FEES = 0.15 ether;
    uint256 public count = 0;
    mapping(uint256 id => DutchAuction auction) public auctions;
    mapping(address seller => uint256 id) public sellerToAuction;

    constructor() {
        owner = msg.sender;
    }

    function startAuction(string memory _description, uint256 _price, uint256 _discountRate, uint256 _duration)
        external
        payable
        returns (DutchAuction)
    {
        if (msg.value != FEES) {
            revert AuctionFactory__SendProperFees();
        }
        DutchAuction auction = new DutchAuction(msg.sender, _description, _price, _discountRate, _duration);

        auctions[count] = auction;
        sellerToAuction[msg.sender] = count;
        count += 1;
        return auction;
    }

    function withdraw() external {
        if (msg.sender != owner) {
            revert AuctionFactory__NonOwnerCanNotWithdraw();
        }
        (bool ok,) = payable(owner).call{value: address(this).balance}("");

        if (!ok) {
            revert AuctionFactory__TransactionFailed();
        }
    }

    function cleanUp() external {
        if (msg.sender != owner) {
            revert AuctionFactory__NotOwner();
        }
        uint256 length = count;

        for (uint256 i = 0; i < length; i++) {
            DutchAuction auction = auctions[i];
            address seller = auction.seller();
            if (!auction.isActive()) {
                delete auctions[i];
                delete sellerToAuction[seller];
            }
        }
    }
}
