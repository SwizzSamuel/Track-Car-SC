// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vehicle} from "../src/Vehicle.sol"; 

contract VehicleTest is Test {
    Vehicle public vehicle;
    address public owner;
    address public nonOwner;

    address public USER = makeAddr("USER");

    function setUp() public {
        owner = address(this);
        nonOwner = USER;

        vehicle = new Vehicle();
    }

    function testAddVehicle() public {
        vm.startPrank(owner);
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        (string memory VIN, , , string memory carModel, , , ) = vehicle.displayVehicleInformation("VIN123");
        vm.stopPrank();
        assertEq(VIN, "VIN123");
        assertEq(carModel, "Toyota");
    }

    function testCannotAddExistingVehicle() public {
        vm.startPrank(owner);
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vm.expectRevert(bytes("Vehicle Already Exists"));
        vehicle.addVehicle("VIN123", 15000, 2016, "Honda", "Blue", "Minor Scratch", "Bob", "456 Another St", block.timestamp - 1);
        vm.stopPrank();
    }

    function testUpdateMileage() public {
        vm.startPrank(owner);
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vehicle.updateMileage("VIN123", 15000);
        uint256 updatedMileage = vehicle.checkMileage("VIN123");
        vm.stopPrank();
        assertEq(updatedMileage, 15000);
    }

    function testCannotUpdateMileageToLower() public {
        vm.startPrank(owner);
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vm.expectRevert(bytes("New Mileage lower than last recorded"));
        vehicle.updateMileage("VIN123", 5000);
        vm.stopPrank();
    }

    function testTransferOwnership() public {
        vm.startPrank(owner);
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vehicle.transferOwnership("VIN123", "Bob", "456 Another St", block.timestamp);
        string memory newOwner = vehicle.getCurrentOwner("VIN123");
        vm.stopPrank();
        assertEq(newOwner, "Bob");
    }

    function testUpdateStolenStatus() public {
        vm.startPrank(owner);
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vehicle.updateStolenStatus("VIN123");
        bool isStolen = vehicle.checkStolenStatus("VIN123");
        assertTrue(isStolen);

        vehicle.updateStolenStatus("VIN123");
        isStolen = vehicle.checkStolenStatus("VIN123");
        assertFalse(isStolen);

        vm.stopPrank();
    }

    function testOnlyOwnerCanAddVehicle() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vm.stopPrank();
    }

    function testOnlyOwnerCanUpdateMileage() public {
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vm.prank(nonOwner);
        vm.expectRevert();
        vehicle.updateMileage("VIN123", 20000);
        vm.stopPrank();
    }

    function testOnlyOwnerCanTransferOwnership() public {
        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vm.prank(nonOwner);
        vm.expectRevert();
        vehicle.transferOwnership("VIN123", "Bob", "456 Another St", block.timestamp + 1 days);
    }

    function testOnlyOwnerCanUpdateStolenStatus() public {

        vehicle.addVehicle("VIN123", 10000, 2015, "Toyota", "Red", "No Accidents", "Alice", "123 Main St", block.timestamp - 1);
        vm.prank(nonOwner);
        vm.expectRevert();
        vehicle.updateStolenStatus("VIN123");
    }

    function testDisplayVehicleOwnershipHistory() public {
        vehicle.addVehicle(
            "VIN123", 
            10000, 
            2015, 
            "Toyota", 
            "Red", 
            "No Accidents", 
            "Alice", 
            "123 Main St", 
            block.timestamp - 1
        );

        vehicle.transferOwnership(
            "VIN123", 
            "Bob", 
            "456 Another St", 
            block.timestamp
        );

        vehicle.transferOwnership(
            "VIN123", 
            "Charlie", 
            "789 Different St", 
            block.timestamp + 1
        );

        Vehicle.Owner[] memory ownerHistory = vehicle.displayVehicleOwnershipHistory("VIN123");

        assertEq(ownerHistory.length, 3);

        assertEq(ownerHistory[0].name, "Alice");
        assertEq(ownerHistory[0].ownerAddress, "123 Main St");
        assertEq(ownerHistory[0].purchaseDate, block.timestamp - 1);

        assertEq(ownerHistory[1].name, "Bob");
        assertEq(ownerHistory[1].ownerAddress, "456 Another St");
        assertEq(ownerHistory[1].purchaseDate, block.timestamp);

        assertEq(ownerHistory[2].name, "Charlie");
        assertEq(ownerHistory[2].ownerAddress, "789 Different St");
        assertEq(ownerHistory[2].purchaseDate, block.timestamp + 1);
    }

    function testDisplayOwnershipHistoryForNonExistentVehicle() public {
        vm.expectRevert(bytes("Vehicle doesn't exist"));
        vehicle.displayVehicleOwnershipHistory("VIN_NON_EXISTENT");
    }
}
