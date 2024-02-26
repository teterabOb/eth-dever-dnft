// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract MyDNFT is ERC721, ERC721URIStorage, AutomationCompatibleInterface {
    uint256 private _nextTokenId;

    uint public interval;
    uint public lastTimeStamp;

    enum Years{
        Year2022, // First = 0
        Year2023, // Second = 1
        Year2024 // Third = 2
    }

    // Year of each NFT
    mapping (uint256 => Years) nftYears;

    // Metadata hosted in Pinata
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmPR51yq3MyN2wmDsTjPNjPq8VwD4EXwqMDCX32GZiBg2m/2022.json",
        "https://ipfs.io/ipfs/QmPR51yq3MyN2wmDsTjPNjPq8VwD4EXwqMDCX32GZiBg2m/2023.json",
        "https://ipfs.io/ipfs/QmPR51yq3MyN2wmDsTjPNjPq8VwD4EXwqMDCX32GZiBg2m/2024.json"
    ];

    constructor(uint256 _interval) ERC721("ETH Denver Dynamic NFT", "DNFT")
    {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;        
    }

    function performUpkeep(bytes calldata /* performData */) external override  {        
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;

            updateAllNFTs();            
        }        
    }

    function safeMint(address to) public  {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
        nftYears[tokenId] = Years.Year2022;
    }

    function updateYear(uint256 _tokenId) public {
        uint256 currentYear = getYearOfNFT(_tokenId);

        if(currentYear == 0){
             nftYears[_tokenId] = Years.Year2023; 
        }
        else if(currentYear == 1){
             nftYears[_tokenId] = Years.Year2024; 
        }
        else if(currentYear == 2){
            nftYears[_tokenId] = Years.Year2022;
        }
    }

    function updateAllNFTs() public {
        uint counter = _nextTokenId;
        for(uint i = 0; i <= counter; i++){
            updateYear(i);
        }
    }

    // helper functions
    function getYearOfNFT(uint256 _tokenId) public view returns(uint256){
        Years yearIndex = nftYears[_tokenId];
        return uint(yearIndex);
    }

    function getUriByYear(uint256 _tokenId) public view returns(string memory){
        Years yearIndex = nftYears[_tokenId];
        return IpfsUri[uint(yearIndex)];
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return getUriByYear(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
