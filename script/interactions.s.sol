// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {AuctionFactory} from "../src/DutchFactory.sol";
import {DutchAuction} from "../src/DutchAuction.sol";

contract Interactions is Script {
    function run() external {
        address factoryAddress = DevOpsTools.get_most_recent_deployment("AuctionFactory", block.chainid);

        vm.startBroadcast();
        DutchAuction auction =
            AuctionFactory(factoryAddress).startAuction{value: 0.15 ether}("hoodie", 15 ether, 25, 10, 11 ether);
        console2.log("the address of deployed dutch auction is:", address(auction));

        uint256 price = auction.getPrice();
        console2.log("The price of the auction :", price);

        console2.log("the duration for the auction is: ", auction.getDuration());
        console2.log("the seller of the auction is :", auction.getSeller());

        assert(auction.getSeller() == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        vm.stopBroadcast();
    }
}
