// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

// 1. Deploy a mock when we are on a local anvil chain
// 2. Keep track of contract address across diffrent chains
// Sepolia ETH/USD vs Mainnet ETH/USD

// If on a local anvil, deploy mocks
// Otherwise, grab the existing address from the live network
contract HelperConfig is Script {
    struct NetworkConfig {
        // ETH/USD price feed address
        address priceFeed;
        uint256 chainid;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            chainid: 11155111
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            chainid: 1
        });
        return mainnetConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
    }
}
