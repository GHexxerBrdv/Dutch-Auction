// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {AuctionFactory, DutchAuction} from "../src/DutchFactory.sol";

contract deployFactory is Script {
    AuctionFactory factory;

    function run() external returns (AuctionFactory) {
        vm.startBroadcast();
        factory = new AuctionFactory();
        vm.stopBroadcast();
        return factory;
    }
}
