// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Script} from "forge-std/Script.sol";
import {RewardSystem} from "../src/RewardSystem.sol";

contract RewardSystemScript is Script {
    RewardSystem public rewardSystem;

    function run() external {
        vm.startBroadcast();
        rewardSystem = new RewardSystem();
        vm.stopBroadcast();
    }
}