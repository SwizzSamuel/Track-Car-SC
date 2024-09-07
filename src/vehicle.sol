pragma solidity ^0.8.13;

error NotOwner();

contract Vehicle {

    address public immutable i_owner;

    modifier onlyOwner() {
        if(msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    event VehicleAdded(string VIN, string carModel);
    event MileageUpdated(uint256 oldOdometerReading, uint256 newOdometerReading);
    event StolenStatusUpdated(bool status);
    event OwnershipTransferred(string oldOwner, string newOwner);

    struct Owner {
        string name;
        string ownerAddress;
        uint256 purchaseDate;
    }

    struct Vehicles {
        string VIN;
        uint256 odometerReading;
        uint16  yearOfProduction;
        string carModel;
        bool stolen;
        bool alreadyExisting;
        string colour;
        string accidentHistory;
        Owner[] ownerHistory;
    }
    

    mapping (string => Vehicles) public vehicleInfo;

    function addVehicle(
        string memory _VIN, 
        uint256 _odoReading, 
        uint16 _yearOfProd, 
        string memory _carModel, 
        string memory _colour, 
        string memory _accidentHistory, 
        string memory _ownerName, 
        string memory _ownerAddress, 
        uint256 _purchaseDate
    ) public onlyOwner(){
        require(vehicleInfo[_VIN].alreadyExisting == false, "Vehicle Already Exists");
        require(_purchaseDate < block.timestamp, "Vehicle cannot be purchased in the future");
        vehicleInfo[_VIN].VIN = _VIN;
        vehicleInfo[_VIN].odometerReading = _odoReading;
        vehicleInfo[_VIN].yearOfProduction = _yearOfProd;
        vehicleInfo[_VIN].carModel = _carModel;
        vehicleInfo[_VIN].stolen = false;
        vehicleInfo[_VIN].alreadyExisting = true;
        vehicleInfo[_VIN].colour = _colour;
        vehicleInfo[_VIN].accidentHistory = _accidentHistory;
        vehicleInfo[_VIN].ownerHistory.push(Owner({name: _ownerName, ownerAddress: _ownerAddress, purchaseDate: _purchaseDate}));

        emit VehicleAdded(_VIN, _carModel);
    }

    function updateMileage(string memory _VIN, uint256 newOdoReading) public onlyOwner() {
        require(vehicleInfo[_VIN].alreadyExisting == true, "Vehicle doesn't exist");
        require(vehicleInfo[_VIN].stolen == false, "Warning: Vehicle is reported as stolen");
        require(newOdoReading > vehicleInfo[_VIN].odometerReading, "New Mileage lower than last recorded");
        uint256 oldOdoReading = vehicleInfo[_VIN].odometerReading;
        vehicleInfo[_VIN].odometerReading = newOdoReading;
        emit MileageUpdated(oldOdoReading, newOdoReading);
    }

    function transferOwnership(string memory _VIN, string memory _ownerName, string memory _ownerAddress, uint256 _purchaseDate) public onlyOwner() {
        require(vehicleInfo[_VIN].alreadyExisting == true, "Vehicle doesn't exist");
        string memory oldOwner = vehicleInfo[_VIN].ownerHistory[vehicleInfo[_VIN].ownerHistory.length - 1].name;
        vehicleInfo[_VIN].ownerHistory.push(Owner({name: _ownerName, ownerAddress: _ownerAddress, purchaseDate: _purchaseDate}));
        emit OwnershipTransferred(oldOwner, _ownerName);
    }

    function updateStolenStatus(string memory _VIN) public onlyOwner() {
        require(vehicleInfo[_VIN].alreadyExisting == true, "Vehicle doesn't exist");
        if(vehicleInfo[_VIN].stolen == true) {
            vehicleInfo[_VIN].stolen = false;
            emit StolenStatusUpdated(false);
        } else {
            vehicleInfo[_VIN].stolen = true;
            emit StolenStatusUpdated(true);
        }
    }

    function checkStolenStatus(string memory _VIN) public view returns(bool) {
        return vehicleInfo[_VIN].stolen;
    }

    function checkMileage(string memory _VIN) public view returns(uint256) {
        return vehicleInfo[_VIN].odometerReading;
    }

    function displayVehicleInformation(string memory _VIN) public view returns(string memory, uint256, uint16, string memory, bool, string memory, string memory) {
        require(vehicleInfo[_VIN].alreadyExisting == true, "Vehicle doesn't exist");
        return(
            vehicleInfo[_VIN].VIN,
            vehicleInfo[_VIN].odometerReading,
            vehicleInfo[_VIN].yearOfProduction,
            vehicleInfo[_VIN].carModel,
            vehicleInfo[_VIN].stolen,
            vehicleInfo[_VIN].accidentHistory,
            vehicleInfo[_VIN].colour
        );
    }

    function displayVehicleOwnershipHistory(string memory _VIN) public view returns(Owner[] memory) {
        require(vehicleInfo[_VIN].alreadyExisting == true, "Vehicle doesn't exist");
        return vehicleInfo[_VIN].ownerHistory;
    }

    function getCurrentOwner(string memory _VIN) public view returns(string memory) {
        require(vehicleInfo[_VIN].alreadyExisting == true, "Vehicle doesn't exist");
        return vehicleInfo[_VIN].ownerHistory[vehicleInfo[_VIN].ownerHistory.length - 1].name;
    }
}