// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {AuctionFactory, DutchAuction} from "../src/DutchFactory.sol";

contract FactoryTest is Test {
    AuctionFactory factory;
    // DutchAuction auction;
    address owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        factory = new AuctionFactory();
        vm.stopPrank();
    }

    function test_Construction() public view {
        console2.log("the address of factory", address(factory));
        assertEq(factory.owner(), owner);
        assertEq(factory.count(), 0);
        assertEq(factory.FEES(), 0.15 ether);
    }

    function test_startAuction() public {
        address seller = makeAddr("seller");
        vm.deal(seller, 1 ether);

        vm.startPrank(seller);
        DutchAuction auction = factory.startAuction{value: factory.FEES()}("dell laptop", 2 ether, 20, 10, 1 ether);
        vm.stopPrank();

        assertEq(address(factory.auctions(factory.count() - 1)), address(auction));
        assertEq(factory.sellerToAuction(seller, 0), 0);
        assertEq(factory.count(), 1);

        console2.log("auction address: ", address(auction));
        assertEq(auction.getSeller(), seller);
        assertEq(auction.getDescription(), "dell laptop");
        console2.log("the starting price of auction is:", auction.getStartingPrice());
        // assertEq(auction.discountRate(), 20);
        assertEq(auction.getDuration(), auction.timestamp() + 10 days);
        (bool isActive, bool isSold) = auction.getStatus();
        assertTrue(isActive);
        assertFalse(isSold);
        assertEq(auction.sellerBalance(), 0);

        assertEq(address(factory).balance, 0.15 ether);
    }

    function test_CannotStartAuctionWithoutFeesOrLessFees() public {
        address seller = makeAddr("seller");
        vm.deal(seller, 0.5 ether);

        vm.startPrank(seller);
        vm.expectRevert();
        factory.startAuction{value: 1}("dell laptop", 2 ether, 20, 10, 1 ether);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        address seller = makeAddr("seller");
        vm.deal(seller, 1 ether);

        vm.startPrank(seller);
        factory.startAuction{value: factory.FEES()}("dell laptop", 2 ether, 20, 10, 1 ether);
        vm.stopPrank();

        assertEq(address(factory).balance, 0.15 ether);

        vm.prank(owner);
        factory.withdraw();

        assertEq(address(factory).balance, 0 ether);
        assertEq(address(owner).balance, 0.15 ether);
    }

    function test_NonOwnerCanNotWithdraw() public {
        address seller = makeAddr("seller");
        vm.deal(seller, 1 ether);

        vm.startPrank(seller);
        factory.startAuction{value: factory.FEES()}("dell laptop", 2 ether, 20, 10, 1 ether);
        vm.stopPrank();

        assertEq(address(factory).balance, 0.15 ether);

        address user = makeAddr("user");

        vm.prank(user);
        vm.expectRevert();
        factory.withdraw();
    }

    function test_CleanUp() public {
        address seller = makeAddr("seller");
        vm.deal(seller, 1 ether);

        vm.startPrank(seller);
        DutchAuction auction = factory.startAuction{value: factory.FEES()}("dell laptop", 2 ether, 20, 10, 1 ether);
        vm.stopPrank();

        address buyer = makeAddr("buyer");
        vm.deal(buyer, 3 ether);

        vm.warp(auction.timestamp() + 6 days);
        vm.prank(buyer);
        auction.buyGood{value: 2 ether}();
        (bool isActive, bool isSold) = auction.getStatus();
        assertEq(isSold, true);

        vm.prank(seller);
        auction.withdraw();

        (isActive,) = auction.getStatus();
        assertGt(seller.balance, 1 ether);
        assertEq(isActive, false);

        vm.prank(owner);
        factory.cleanUp(0);

        assertEq(address(factory.auctions(factory.count() - 1)), address(0));
        assertEq(factory.sellerToAuction(seller, 0), 0);
    }

    function test_NonOwnerCleanUp() public {
        address seller = makeAddr("seller");
        vm.deal(seller, 1 ether);

        vm.startPrank(seller);
        DutchAuction auction = factory.startAuction{value: factory.FEES()}("dell laptop", 2 ether, 20, 10, 1 ether);
        vm.stopPrank();

        address buyer = makeAddr("buyer");
        vm.deal(buyer, 3 ether);

        vm.warp(auction.timestamp() + 6 days);
        vm.prank(buyer);
        auction.buyGood{value: 2 ether}();

        (bool isActive, bool isSold) = auction.getStatus();

        assertEq(isSold, true);

        vm.prank(seller);
        auction.withdraw();

        (isActive,) = auction.getStatus();

        assertGt(seller.balance, 1 ether);
        assertEq(isActive, false);

        vm.prank(seller);
        vm.expectRevert();
        factory.cleanUp(0);
    }
}
