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
    mapping(address seller => uint256[] id) public sellerToAuction;

    // mapping(uint256 id => address seller) public idToSeller;
    constructor() {
        owner = msg.sender;
    }

    function startAuction(
        string memory _description,
        uint256 _price,
        uint256 _discountRate,
        uint256 _duration,
        uint256 _threshold
    ) external payable returns (DutchAuction) {
        if (msg.value != FEES) {
            revert AuctionFactory__SendProperFees();
        }
        DutchAuction auction = new DutchAuction(msg.sender, _description, _price, _discountRate, _duration, _threshold);

        auctions[count] = auction;
        sellerToAuction[msg.sender].push(count);
        // idToSeller[count] = msg.sender;
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

    function cleanUp(uint256 id) external {
        if (msg.sender != owner) {
            revert AuctionFactory__NotOwner();
        }

        DutchAuction auction = auctions[id];
        address seller = auction.getSeller();
        (bool isActive,) = auction.getStatus();
        if (!isActive) {
            delete auctions[id];
        }
    }
}
