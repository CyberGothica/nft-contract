// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  enum TokenRank {
    Warrior,
    Gladiator
  }

  TokenRank public tokenRank;
  uint256 public tokenRankInt;

  address public higherRankTokenAddress;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public freeTokensAmount = 10;
  uint256 public cost = 200 ether;
  uint256 public maxSupply;
  uint256 public maxMintAmount;
  bool public paused = false;

  uint256 public tokensMinted;
  
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    TokenRank _initTokenRank,
    uint256 _initTokenRankInt,
    uint256 _initMaxSupply,
    uint256 _maxMintAmount
  ) ERC721(_name, _symbol) {

    setBaseURI(_initBaseURI);

    tokenRank = _initTokenRank;
    tokenRankInt = _initTokenRankInt;
    maxSupply = _initMaxSupply;
    maxMintAmount = _maxMintAmount;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function _tokenRank() internal view virtual returns (TokenRank) {
    return tokenRank;
  }

  function _tokenRankInt() internal view virtual returns (uint256) {
    return tokenRankInt;
  }

  function _maxSupply() internal view virtual returns (uint256) {
    return maxSupply;
  }

  function burnToken(uint256 tokenId) public {
    require(msg.sender == ownerOf(tokenId), "Sender is not token owner");
    _burn(tokenId);
  }

  function burnByHigherToken(uint256 tokenId) public {
    require(msg.sender == higherRankTokenAddress, "Sender is not token owner");
    _burn(tokenId);
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setRank(uint256 _newRank) public onlyOwner {
    tokenRankInt = _newRank;
  }

  function setFreeTokens(uint256 _freeTokensAmount) public onlyOwner {
    freeTokensAmount = _freeTokensAmount;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function setHigherRankTokenAddress(address _tokenAddress) public onlyOwner {
    higherRankTokenAddress = _tokenAddress;
  }

  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }
}
