# Airdrop Smart contract

- [About project](#about-project)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Deploy](#deploy)
    - [Interacting with contracts](#interacting-with-contracts)
    - [Deploy Auction](#deploy-token-and-airdrop-contract)
    - [Interact with deployed contract](#interact-with-deployed-contract)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)
- [Thank you!](#thank-you)

# About project

What if you can conduct an auction for your goods and sell them using Rootstock blockchain?

Yes, it is possible.

The dutch auction will enable users to start auction for their good from desired maximum price.As time passes the price will drop at defined rate. Anyone can buy good at their familier price.

# Getting Started

## Requirements

- [VsCode](https://code.visualstudio.com/download)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [foundry](https://getfoundry.sh/)
- [NodeJS](https://nodejs.org/en/download)
- [MetaMask](https://metamask.io/en-GB/download)
- [RSK Test faucets](https://faucet.rootstock.io/)

## Quickstart

```bash
git clone https://github.com/GHexxerBrdv/Dutch-Auction.git
cd Dutch-Auction
forge install # or forge build to install all libraries.
```

# Usage

## Deploy 

### Interacting with contracts

we are going to deploy contracts on Rootstock test network.

make sure you have test faucet to deploy and interact.

make an .env file and store there your metamask private key. Also you have to add rpc url of rootstock test network. 

The .env file will look like this

```js
PRIVATE_KEY=0x(metamask private key)
RPC_URL="public-node.testnet.rsk.co"
```

run the following command to use .env veriables in your terminal.

```bash
source .env
```

### Deploy Auction

Run this command in terminal.

```bash
forge script script/Factory.s.sol --rpc-url $RPC_URL --broadcast --legacy
```

### Interact with deployed contract

Run this command to interact with deployed factory contract.

```bash
forge script script/interactions.s.sol --rpc-url $RPC_URL --broadcast --legacy
```

## Testing

```bash
foundryup
forge test
```

### Test Coverage

```bash
forge coverage
```

## Estimate gas

You can estimate how much gas things cost by running:

```bash
forge snapshot
```

# Formatting

To run code formatting:
```bash
forge fmt
```

# Thank you!