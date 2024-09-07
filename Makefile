-include .env

deploy-sepolia:
		forge script script/vehicle.s.sol:DeployVehicle --rpc-url ${ALCHEMY_URL} --private-key ${SEPOLIA_PRIVATE_KEY} --broadcast  -vvvv --legacy
