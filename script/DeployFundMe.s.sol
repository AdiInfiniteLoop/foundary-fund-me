//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/Fund.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "./HelperConfig,s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //Anything before .startBroadcast() is not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed); //tocreate a contract
        vm.stopBroadcast();
        return fundMe;
    }
}
