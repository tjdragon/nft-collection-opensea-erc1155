# Ultimate guide to create a ERC1155-compliant NFT Collection for OpenSea

## Intro

The documentation on [OpenSea](https://opensea.io/) is sparse when it comes to create collections. The site is out of date, with references
to codebases that are years-old.  
After [raising USD $300 millions](https://techcrunch.com/2022/01/04/nft-kingpin-opensea-lands-13-3b-valuation-in-300m-raise-from-paradigm-and-coatue/) you would think that
they would spend a bit of that fixing their web site, documentation, bugs, etc.

If you like what you see, please donate some BTC to bc1qf3gsvfk0yp9fvw0k8xvq7a8dk80rqw0apcy8kx or some ETH to 0xcDE1EcaFCa4B4c7A6902c648CD01db52d8c943F3

This documentation is a step-by-step guide, after quite intensive research, to create a NFT Collection, compliant with 
[ERC-1155](https://eips.ethereum.org/EIPS/eip-1155) and [OpenSea](https://opensea.io/).

By "compliance", I mean the ability to sell and collect [creator fees](https://support.opensea.io/hc/en-us/articles/1500011590241-What-are-service-and-creator-fees-) via OpenSea.

## It all starts with ERC1155

[ERC-1155](https://eips.ethereum.org/EIPS/eip-1155) is a "new" multi-token standard that allows us to mint a large
number of NFTs on creation (that is just one aspect of this standard).

## NFTs
You can refer to my other projects to get to know NFTs: [NFT Step-By-Step](https://github.com/tjdragon/nft-step-by-step), 
[NFT With On-Chain Data](https://github.com/tjdragon/nft-on-chain-data) and finally [Your NFT Tree](https://yournftree.com/).

### Implementation #1

This is the most basic implementation for an NFT Collection:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MultiNFTContractSimple is ERC1155 {
    uint[] token_ids;
    uint[] amounts;
    address _opensea_proxy;

    constructor() ERC1155("https://raw.githubusercontent.com/tjdragon/nft-images/main/nft{id}.json") {
        for(uint256 index = 1; index <= 2; index++) {
            token_ids.push(index);
            amounts.push(1);
        }

        _mintBatch(msg.sender, token_ids, amounts, "");
    }
}
```
- Images and meta-data are stored [there](https://github.com/tjdragon/nft-images)
- All images (in our case 2) are pre-minted when the constructor is called via _mintBatch

If you go to OpenSea, you will not see a collection, nor the images, because we need to add two methods to the previous code to make it work.

### Implementation #2

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MultiNFTContractSimple is ERC1155 {
    uint[] token_ids;
    uint[] amounts;
    address _opensea_proxy;

    constructor() ERC1155("https://raw.githubusercontent.com/tjdragon/nft-images/main/nft{id}.json") {
        for(uint256 index = 1; index <= 2; index++) {
            token_ids.push(index);
            amounts.push(1);
        }

        _mintBatch(msg.sender, token_ids, amounts, "");
    }

    function name() pure public returns(string memory) {
        return "TJ Collection II";
    }

    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string(
            abi.encodePacked("https://raw.githubusercontent.com/tjdragon/nft-images/main/nft",
            Strings.toString(tokenId),
            ".json"
        ));
    }
}
```
- We added the ops "name" and "uri"
- This is what is needed to have the NFTs available on OpenSea: check [https://testnets.opensea.io/collection/tj-s-fancy-collection](https://testnets.opensea.io/collection/tj-s-fancy-collection)

What you will notice is that there is no creator fee because with this method, OpenSea does not have control over your collection.
In order for OpenSea's smart contract to handle this, we need to do a bit of work.

### Implementation #3

The next bit to make it fully OpenSea compliant is to add [DefaultOperatorFilterer](https://github.com/ProjectOpenSea/operator-filter-registry) to the contract.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract MultiNFTContract is ERC1155, DefaultOperatorFilterer, Ownable  {
    uint[] token_ids;
    uint[] amounts;

    constructor() ERC1155("https://raw.githubusercontent.com/tjdragon/nft-images/main/nft{id}.json") {
        for(uint256 index = 1; index <= 2; index++) {
            token_ids.push(index);
            amounts.push(1);
        }

        _mintBatch(msg.sender, token_ids, amounts, "");
    }

    function name() pure public returns(string memory) {
        return "TJ Collection II";
    }

    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string(
            abi.encodePacked("https://raw.githubusercontent.com/tjdragon/nft-images/main/nft",
            Strings.toString(tokenId),
            ".json"
        ));
    }

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory _amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, _amounts, data);
    }
}
```

This collection can be seen there: [https://testnets.opensea.io/collection/tj-collection-ii](https://testnets.opensea.io/collection/tj-collection-ii).  
You can now, in OpenSea, update the Creator's fee, set up a floor price for all items, etc.

### Other ideas
It would be fairly easy to:

- Check for OFAC sanctioned addresses as part of the transfers
- Work-out a risk profile based on all NFT holders
