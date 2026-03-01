-include .env

deploy-lisk:
	forge script script/CrackedDev.s.sol \
		--rpc-url $(LISK_SEPOLIA_URL) \
		--account privatekey \
		--sender $(YOUR_ADDRESS) \
		--broadcast \
		-vvvv
