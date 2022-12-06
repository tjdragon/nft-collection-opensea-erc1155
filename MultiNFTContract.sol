// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {UpdatableOperatorFilterer} from "./UpdatableOperatorFilterer.sol";
import {RevokableDefaultOperatorFilterer} from "./RevokableDefaultOperatorFilterer.sol";

contract MultiNFTContract is ERC1155, RevokableDefaultOperatorFilterer, Ownable  {
    uint[] token_ids;
    uint[] amounts;

    constructor() ERC1155("https://raw.githubusercontent.com/tjdragon/nft-images/main/singa{id}.json") {
        for(uint256 index = 1; index <= 5; index++) {
            token_ids.push(index);
            amounts.push(1);
        }

        _mintBatch(msg.sender, token_ids, amounts, "");
    }

    function name() pure public returns(string memory) {
        return "TJ Singa Collection I";
    }

    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string(
            abi.encodePacked("https://raw.githubusercontent.com/tjdragon/nft-images/main/singa",
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

    function owner() public view virtual override (Ownable, UpdatableOperatorFilterer) returns (address) {
        return Ownable.owner();
    }
}