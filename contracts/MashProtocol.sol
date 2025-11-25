// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title MashProtocol Smart Contract
/// @notice This contract includes ERC-20, ERC-721, and Governance functionalities.
contract MashProtocol is ERC20, ERC721, ERC721URIStorage, Ownable, Governor, GovernorVotes, GovernorTimelockControl {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    /// @notice Constructor for the MashProtocol contract
    /// @param initialSupply The initial supply of the ERC-20 MASH token
    /// @param timelock The address of the TimelockController
    constructor(uint256 initialSupply, TimelockController timelock)
        ERC20("MashToken", "MASH")
        Governor("MashGovernor")
        GovernorTimelockControl(timelock)
    {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /// @notice Mint a new ERC-721 NFT representing a physical asset
    /// @param to The address of the recipient
    /// @param uri The metadata URI of the NFT
    function mintNFT(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /// @notice Override required by Solidity for ERC-721 and ERC721URIStorage
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /// @notice Override required by Solidity for ERC-721 and ERC721URIStorage
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /// @notice Voting power is based on the balance of MASH tokens
    function _getVotes(address account, uint256 blockNumber, bytes memory params)
        internal
        view
        override(Governor, GovernorVotes)
        returns (uint256)
    {
        return super._getVotes(account, blockNumber, params);
    }

    /// @notice Required override for Governor and TimelockControl
    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(proposalId);
    }

    /// @notice Required override for Governor and TimelockControl
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(Governor, IGovernor) returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    /// @notice Required override for Governor and TimelockControl
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable override(Governor, GovernorTimelockControl) returns (uint256) {
        return super.execute(targets, values, calldatas, descriptionHash);
    }

    /// @notice Required override for Governor and TimelockControl
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage, GovernorTimelockControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
