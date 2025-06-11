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

    address public immutable seller;
    string public description;
    uint256 public immutable startingPrice;
    uint256 public immutable discountRate;
    uint256 public immutable timestamp;
    uint256 public immutable duration;
    uint256 public sellerBalance;
    bool public isActive = false;
    bool public isSold = false;

    constructor(
        address _seller,
        string memory _description,
        uint256 _price,
        uint256 _discountRateInBP,
        uint256 _duration
    ) {
        seller = _seller;
        description = _description;
        startingPrice = _price;
        discountRate = (_discountRateInBP * 1e18) / 10000;
        timestamp = block.timestamp;
        duration = timestamp + (_duration * 1 days);
        isActive = true;
    }

    function getPrice() public view returns (uint256) {
        if (isSold) {
            revert DutchAuction__GoodIsSold();
        }
        if (!isActive) {
            revert DutchAuction__AuctionIsNotActive();
        }
        if (block.timestamp > duration) {
            revert DutchAuction__AuctionIsNotActive();
        }
        uint256 timeElapsed = block.timestamp - timestamp;
        uint256 dayPassed = timeElapsed / 1 days;
        uint256 discount = discountRate * dayPassed;
        if (discount >= startingPrice) {
            return 0;
        }
        return startingPrice - discount;
    }

    function buyGood() external payable {
        if (!isActive) {
            revert DutchAuction__AuctionIsNotActive();
        }
        if (block.timestamp > duration) {
            revert DutchAuction__AuctionIsNotActive();
        }

        if (isSold) {
            revert DutchAuction__GoodIsSold();
        }

        uint256 goodPrice = getPrice();
        if (msg.value < goodPrice) {
            revert DutchAuction__SendEnoughMoney();
        }
        isSold = true;
        uint256 refund = msg.value - goodPrice;
        if (refund > 0) {
            (bool ok,) = payable(msg.sender).call{value: refund}("");
            if (!ok) {
                revert DutchAuction__TransactionFailed();
            }
        }

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
}
