// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

/**
 * @title JWTContract
 * @dev A contract representing a JWT secret (encrypted) as an NFT 
 */

contract JWTContract is ERC721 {
    uint256 public currentTokenId;

    string private _tokenURI;
    uint256 private mintPrice;
    uint256 private mintCount;
    bool private allowMint;
    address private owner;
    address private factoryContract;
    string private encrypted_jwt_secret;

    constructor(
        string memory _uri,
        uint256 _mintCount,
        uint256 _tokenPrice,
        bool _allowMint,
        address creator,
        address _factoryContract,
        string memory _encrypted_jwt_secret
    ) ERC721("JWTToken", "JWT") {
        mintCount = _mintCount;
        _tokenURI = _uri;
        mintPrice = _tokenPrice;
        owner = creator;
        allowMint = _allowMint;
        factoryContract = _factoryContract;
        encrypted_jwt_secret = _encrypted_jwt_secret;
    }

    // Event triggered when deploying the contract
    event Initialized(
        string _uris,
        uint256 _mintCount,
        uint256 _tokenPrice,
        address owner,
        bool _allowMints
    );

    modifier onlyOwner() {
        require(tx.origin == owner && msg.sender == factoryContract, "Unauthorized");
        _;
    }

    /**
     * @dev Start the minting process.
     */
    function startMint() public onlyOwner {
        require(!allowMint, "Mint already started");
        allowMint = true;
    }

    /**
     * @dev Pause the minting process.
     */
    function pauseMint() public onlyOwner {
        require(allowMint, "Mint already paused");
        allowMint = false;
    }

    /**
     * @dev Set a new URI for a token.
     * @param _newUri The new URI.
     */
    function setURI(string memory _newUri) public onlyOwner {
        _tokenURI = _newUri;
    }

    /**
     * @dev Set a new URI for a token.
     * @param _encrypted_jwt_secret The new URI.
     */
    function setJwtSecret(string memory _encrypted_jwt_secret) public {
        encrypted_jwt_secret = _encrypted_jwt_secret;
    }

    /**
     * @dev Set a custom price for a token.
     * @param _price The new price for the token.
     */
    function setMintPrice(uint256 _price) public onlyOwner {
        // can be free/should be free
        mintPrice = _price;
    }

    /**
     * @dev Set the mint count for a token.
     * @param _mintCount The new mint count for the token.
     */
    function setMintCount(uint256 _mintCount) public onlyOwner {
        require(_mintCount >= currentTokenId, "Invalid count");
        mintCount = _mintCount;
    }

    /**
     * @dev Mint a token to the specified account.
     * @param to The recipient of the minted token.
     * @return tokenId The ID of the minted token.
     */
    function mint(address to, string memory _encrypted_jwt_secret) public payable returns (uint256 tokenId) {
        require(allowMint, "Minting is currently paused");
        require(msg.value >= mintPrice, "Insufficient funds to mint");
        require(balanceOf(to) == 0, "Only one token per account is allowed");
        tokenId = currentTokenId;
        currentTokenId++;
        encrypted_jwt_secret = _encrypted_jwt_secret;
        _safeMint(to, tokenId);
    }

    // Getter Functions

    /**
     * @dev Returns the URI for a given token.
     * @return The URI string.
     */
    function tokenURI() public view returns (string memory) {
        return _tokenURI;
    }

    /**
     * @dev Returns the mint price for a token.
     * @return The mint price.
     */
    function getTokenMintPrice() public view returns (uint256) {
        return mintPrice;
    }

    /**
     * @dev Returns the mint count for a token.
     * @return The mint count.
     */
    function getTokenMintCount() public view returns (uint256) {
        return mintCount;
    }

    /**
     * @dev Returns the current minting availability status.
     * @return The minting status.
     */
    function getAllowMint() public view returns (bool) {
        return allowMint;
    }

    
}