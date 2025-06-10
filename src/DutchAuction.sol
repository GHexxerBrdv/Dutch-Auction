// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
 This dutch auction allows user to sell their goods with desired price, the price will gose down by the time pass by defined discountRate set by seller.
*/
contract DutchAuction {
    error AuctionIsNotActive();

    address owner;
    uint256 count = 0;
    uint256 public constant duration = 7 days;

    struct Auction {
        address payable seller;
        address buyer;
        string description;
        uint256 price;
        uint256 discountRate;
        uint256 timestamp;
        uint256 duration;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(address seller => uint256 balance) private userBalance;

    constructor() {
        owner = msg.sender;
    }

    function addBid(string memory _description, uint256 _price, uint256 _rate) external returns (Auction memory) {
        require(_rate <= 5, "discount rate is too high");
        require(_price >= _rate * duration, "starting price < min");
        Auction memory auction = Auction({
            seller: payable(msg.sender),
            buyer: address(0),
            description: _description,
            price: _price * 1 ether,
            discountRate: _rate,
            timestamp: block.timestamp,
            duration: block.timestamp + duration
        });
        auctions[count] = auction;
        count = count + 1;
        return auction;
    }

    function getPrice(uint256 id) public view returns (uint256) {
        Auction memory auction = auctions[id];
        if (block.timestamp > auction.duration) {
            revert AuctionIsNotActive();
        }
        uint256 timepassed = block.timestamp - auction.timestamp;
        uint256 goodPrice = auction.price;

        uint256 discount = (auction.price * auction.discountRate * timepassed) / 10000;
        return goodPrice - discount;
    }

    function buyGood(uint256 id) external payable {
        Auction storage auction = auctions[id];
        require(auction.buyer == address(0), "Item already sold");
        require(block.timestamp <= auction.duration, "Auction is not active");
        require(msg.sender != auction.seller, "Seller can not but their own good");
        uint256 currentPrice = getPrice(id);
        require(msg.value >= currentPrice, "You don't have enough money");
        userBalance[auction.seller] += currentPrice;
        auction.buyer = msg.sender;
        auction.price = 0;
        delete auctions[id];
        (bool ok,) = payable(msg.sender).call{value: msg.value - currentPrice}("");
        require(ok, "transfer failed");
    }

    function withdraw() external {
        uint256 amount = userBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");
        userBalance[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transaction failed");
    }

    function getUserBalance(address user) external view returns (uint256) {
        return userBalance[user];
    }
}
