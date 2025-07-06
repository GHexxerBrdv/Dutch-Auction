// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
 This dutch auction allows user to sell their goods with desired price, the price will gose down by the time pass by defined discountRate set by seller.
*/

contract DutchAuction {
    error DutchAuction__AuctionIsNotActive();
    error DutchAuction__SendEnoughMoney();
    error DutchAuction__TransactionFailed();
    error DutchAuction__CallerIsNotSeller();
    error DutchAuction__GoodIsSold();

    address private immutable seller;
    string private description;
    uint256 private immutable startingPrice;
    uint256 private immutable discountRate;
    uint256 public immutable timestamp;
    uint256 private immutable duration;
    uint256 public sellerBalance;
    uint256 public threshold;
    bool private isActive;
    bool private isSold;
    bool private lock;

    modifier auctionStatus() {
        if (isSold) {
            revert DutchAuction__GoodIsSold();
        }

        if (block.timestamp > duration) {
            revert DutchAuction__AuctionIsNotActive();
        }

        if (!isActive) {
            revert DutchAuction__AuctionIsNotActive();
        }
        _;
    }

    modifier locked() {
        require(!lock, "Reentrancy detected");
        lock = true;
        _;
        lock = false;
    }

    constructor(
        address _seller,
        string memory _description,
        uint256 _price,
        uint256 _discountRateInBP,
        uint256 _duration,
        uint256 _threshold
    ) {
        seller = _seller;
        description = _description;
        startingPrice = _price;
        discountRate = (_discountRateInBP * 1e18) / 10000;
        timestamp = block.timestamp;
        duration = timestamp + (_duration * 1 days);
        isActive = true;
        threshold = _threshold;
    }

    function getPrice() public view auctionStatus returns (uint256) {
        uint256 timeElapsed = block.timestamp - timestamp;
        uint256 dayPassed = timeElapsed / 1 days;
        uint256 discount = discountRate * dayPassed;
        if (discount >= startingPrice) {
            return threshold;
        }

        if (startingPrice - discount < threshold) {
            return threshold;
        }
        return startingPrice - discount;
    }

    function buyGood() external payable auctionStatus locked {
        uint256 goodPrice = getPrice();
        if (msg.value < goodPrice) {
            revert DutchAuction__SendEnoughMoney();
        }
        isSold = true;
        sellerBalance = goodPrice;
    }

    function withdraw() external {
        if (msg.sender != seller) {
            revert DutchAuction__CallerIsNotSeller();
        }
        uint256 balance = sellerBalance;
        sellerBalance = 0;
        isActive = false;
        (bool ok,) = payable(seller).call{value: balance}("");

        if (!ok) {
            revert DutchAuction__TransactionFailed();
        }
    }

    function getSeller() external view returns (address) {
        return seller;
    }

    function getDuration() external view returns (uint256) {
        return duration;
    }

    function getDescription() external view returns (string memory) {
        return description;
    }

    function getStartingPrice() external view returns (uint256) {
        return startingPrice;
    }

    function getDiscountRate() external view returns (uint256) {
        return discountRate;
    }

    function getStatus() external view returns (bool, bool) {
        return (isActive, isSold);
    }
}
