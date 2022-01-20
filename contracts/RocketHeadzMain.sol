// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RocketHeadzMain is FxBaseRootTunnel, ERC721Enumerable, Ownable {
  string public provenanceHash;
  string public baseURI;
  bytes32 public merkleRoot;
  bool public whitelistSaleIsActive;
  bool public publicSaleIsActive;

  uint256 public constant MINT_PRICE = 0.08 ether;
  uint256 public constant MAX_MINTS_PER_TXN = 10;
  uint256 public constant MAX_ROCKETHEADZ = 8888;

  mapping(address => bool) public whitelistMinters;

  constructor(
    string memory _provenanceHash,
    bytes32 _merkleRoot,
    address _checkpointManager,
    address _fxRoot
  )
    FxBaseRootTunnel(_checkpointManager, _fxRoot)
    ERC721("RocketHeadz", "RKTHDZ")
  {
    provenanceHash = _provenanceHash;
    merkleRoot = _merkleRoot;
  }

  function whitelistMintRocketHead(bytes32[] calldata proof) public payable {
    uint256 supply = totalSupply();
    require(whitelistSaleIsActive, "WHITELIST_SALE_NOT_ACTIVE");
    require(msg.value >= MINT_PRICE, "INSUFFICIENT_ETH_FOR_MINT");
    require(whitelistMinters[msg.sender] == false, "ALREADY_MINTED");

    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    bool verified = MerkleProof.verify(proof, merkleRoot, leaf);
    require(verified, "NOT_PART_OF_WHITELIST");

    _safeMint(msg.sender, supply + 1);
    whitelistMinters[msg.sender] = true;
  }

  function mintRocketHead(uint256 amount) public payable {
    uint256 supply = totalSupply();
    require(publicSaleIsActive, "SALE_NOT_ACTIVE");
    require(amount <= MAX_MINTS_PER_TXN, "MAX_MINT_PER_TX_EXCEEDED");
    require(supply + amount <= MAX_ROCKETHEADZ, "MAX_SUPPLY_EXCEEDED");
    require(msg.value >= MINT_PRICE * amount, "INSUFFICIENT_ETH_FOR_MINT");

    for (uint256 i = 0; i < amount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  /** FX PORTAL FUNCTIONS */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    super._beforeTokenTransfer(from, to, tokenId);

    bytes memory message = abi.encode(from, to, tokenId);
    _sendMessageToChild(message);
  }

  function _processMessageFromChild(bytes memory data) internal override {
    // Do nothing
  }

  /** HELPER FUNCTIONS */
  function setProvenanceHash(string memory _provenance) public onlyOwner {
    provenanceHash = _provenance;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function flipWhitelistSaleState() public onlyOwner {
    whitelistSaleIsActive = !whitelistSaleIsActive;
  }

  function flipPublicSaleState() public onlyOwner {
    publicSaleIsActive = !publicSaleIsActive;
  }

  function setBaseURI(string memory _uri) public onlyOwner {
    baseURI = _uri;
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }
}
