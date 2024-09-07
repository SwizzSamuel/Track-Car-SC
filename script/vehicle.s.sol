// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Vehicle} from "../src/vehicle.sol";

contract DeployVehicle is Script {
    function run() external returns(Vehicle) {
        vm.startBroadcast();
        Vehicle vehicle = new Vehicle();
        vm.stopBroadcast();
        return vehicle;
    }
}

