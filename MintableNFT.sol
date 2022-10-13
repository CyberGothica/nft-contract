// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./BaseNFT.sol";

contract MintableNFT is BaseNFT {
  using Strings for uint256;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    TokenRank _initTokenRank,
    uint256 _initTokenRankInt,
    uint256 _initMaxSupply,
    uint256 _maxMintAmount
  ) BaseNFT(_name, _symbol, _initBaseURI, _initTokenRank, _initTokenRankInt, _initMaxSupply, _maxMintAmount) {
  }

  function mint(address _to, uint256 _mintAmount) public virtual payable {
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(tokensMinted + _mintAmount <= maxSupply);

    if(msg.sender != owner() && tokensMinted >= freeTokensAmount) {
      require(msg.value >= cost * _mintAmount);
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, tokensMinted);
      tokensMinted++;
    }
  }
}
