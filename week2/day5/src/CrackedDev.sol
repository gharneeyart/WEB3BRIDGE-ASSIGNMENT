// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol"; //used for encoding svg to base64
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrackedDev is ERC721, Ownable {
    using Strings for uint256;
    uint256 private _tokenIdCounter;
    error TokenNotFound();

    // Modifiers
    // modifier onlyOwner() {
    // require(owner() == msg.sender, 'Caller is not the owner');
    // _;
    // }
    constructor() ERC721("CrackedDevNFT", "CDFT") Ownable(msg.sender) {}

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) revert TokenNotFound();
        string memory name = string(abi.encodePacked("CrackedDevNFT #", tokenId.toString()));
        string memory description =
            "A high-skill Web3 developer and security expert, mastering decentralized protocols in a high-tech, neon-lit workspace.";
        string memory image = generateBase64Image();
        string memory json = string(
            abi.encodePacked('{"name":"', name, '",', '"description":"', description, '",', '"image":"', image, '"}')
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function generateBase64Image() internal pure returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg viewBox="0 0 200 200" width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
                "<defs>",
                '<radialGradient id="skinGrad" cx="50%" cy="45%" r="55%">',
                '<stop offset="0%" stop-color="#fde8d8"/>',
                '<stop offset="100%" stop-color="#f5b8a0"/>',
                "</radialGradient>",
                "</defs>",
                '<ellipse cx="100" cy="105" rx="76" ry="82" fill="url(#skinGrad)" stroke="#e8967a" stroke-width="2"/>',
                '<ellipse cx="100" cy="55" rx="77" ry="48" fill="#3b1f0e"/>',
                '<ellipse cx="100" cy="48" rx="60" ry="35" fill="#5c2d0e"/>',
                "</svg>"
            )
        );

        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svg))));
    }

    function mint() public {
        _tokenIdCounter += 1;
        _safeMint(msg.sender, _tokenIdCounter);
    }
}

