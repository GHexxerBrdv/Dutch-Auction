// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {deployFactory, AuctionFactory} from "../script/Factory.s.sol";

contract deployTest is Test {
    deployFactory deployer;
    AuctionFactory factory;

    function setUp() public {
        deployer = new deployFactory();
        factory = deployer.run();
    }

    function test_deployer() public view {
        assertFalse(address(factory) == address(0));
    }
}
