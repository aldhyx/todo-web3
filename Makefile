-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil deploy-sepolia verify

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install modules
install :; forge install cyfrin/foundry-devops@0.3.2 --no-commit && forge install foundry-rs/forge-std@v1.9.6 --no-commit

# Update dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing -a 5

deploy:
	@forge script contract/script/Deploy.s.sol:DeployToken --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PRIVATE_KEY) --broadcast

#deploy-sepolia:
#	@forge script script/Deploy.s.sol:DeployToken --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT)  --constructor-args "$(OWNER_ADDRESS)" --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast --verify
	