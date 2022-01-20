// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RocketHeadzPolygon is FxBaseChildTunnel, ERC721Enumerable, Ownable {
  string public baseURI;

  constructor(address _fxChild)
    FxBaseChildTunnel(_fxChild)
    ERC721("RocketHeadz Polygon", "RKHTHDZ-POLY")
  {}

  /** FX PORTAL FUNCTIONS */
  function _processMessageFromRoot(
    uint256, /* stateId */
    address sender,
    bytes memory message
  ) internal override validateSender(sender) {
    (address from, address to, uint256 tokenId) = abi.decode(
      message,
      (address, address, uint256)
    );

    _mintOrTransfer(from, to, tokenId);
  }

  /** HELPER FUNCTIONS */
  function _mintOrTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal {
    if (from == address(0)) {
      _mint(to, tokenId);
    } else {
      _safeTransfer(from, to, tokenId, "");
    }
  }

  function setBaseURI(string memory _uri) public onlyOwner {
    baseURI = _uri;
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  /** DISABLE USER TRANSFER FUNCTIONS */
  function transferFrom(
    address,
    address,
    uint256
  ) public pure override {
    revert("DISABLED");
  }

  function safeTransferFrom(
    address,
    address,
    uint256
  ) public pure override {
    revert("DISABLED");
  }

  function safeTransferFrom(
    address,
    address,
    uint256,
    bytes memory
  ) public pure override {
    revert("DISABLED");
  }
}
