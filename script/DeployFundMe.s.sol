// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before startBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();

        // Since activeNetworkConfig is a public state variable in your HelperConfig contract,
        // Solidity automatically creates a getter function for it.
        // When interacting with a public state variable from outside the contract in which it's declared,
        // you must use the automatically generated getter function.
        (address ethUsdPriceFeed, ) = helperConfig.activeNetworkConfig(); // Destructuring assignment

        vm.startBroadcast();
        // After startBroadcast -> Real tx!
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
