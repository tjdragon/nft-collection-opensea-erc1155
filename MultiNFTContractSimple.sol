// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MultiNFTContractSimple is ERC1155 {
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
}