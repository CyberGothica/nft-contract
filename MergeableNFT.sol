// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./BaseNFT.sol";
import "./MintableNFT.sol";

contract MergeableNFT is BaseNFT {
  using Strings for uint256;

  uint256 public requiredMintAmount;
  address lowerRankTokenAddress;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    TokenRank _initTokenRank,
    uint256 _initTokenRankInt,
    uint256 _initMaxSupply,
    uint256 _maxMintAmount,
    uint256 _requiredMintAmount,
    address _initLowerRankTokenAddress
  ) BaseNFT(_name, _symbol, _initBaseURI, _initTokenRank, _initTokenRankInt, _initMaxSupply, _maxMintAmount) payable {

    requiredMintAmount = _requiredMintAmount;
    lowerRankTokenAddress = _initLowerRankTokenAddress;
  }

  // public
  function merge(address _to, uint256[] calldata values_) public payable {
    require(!paused);
    require(tokensMinted + 1 < maxSupply);

    if(msg.sender != _to) {
      revert("Why do you mint for external address?)");
    }

    if(msg.sender != owner()) {
      require(msg.value >= cost, "Not enough value sent");
      require(values_.length <= requiredMintAmount, "Not enought tokens were sent");

      MintableNFT lowerRankContract = MintableNFT(lowerRankTokenAddress);

      require(lowerRankContract.tokenRankInt() == tokenRankInt - 1, "Improper token rank");
      
      for (uint256 i = 0; i < requiredMintAmount; i++) {
        address tokenOwner = lowerRankContract.ownerOf(values_[i]);

        if(_to != tokenOwner) {
          string memory tokenIdString = values_[i].toString();
          revert(string(abi.encodePacked("Sender is not owner of token ", tokenIdString)));
        }
        
        lowerRankContract.burnByHigherToken(values_[i]);
      }
    }

    _safeMint(_to, tokensMinted);
    tokensMinted++;
  }

  function setLowerRankTokenAddress(address _tokenAddress) public onlyOwner {
    lowerRankTokenAddress = _tokenAddress;
  }
}
