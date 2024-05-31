// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract 3DAssetMarketplace is ERC721 {
    uint256 private _tokenIds;

    uint256 public listingPrice = 0.025 ether;
    address payable public owner;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool sold;
        string tokenSymbol;
    }

    mapping(uint256 => MarketItem) public idToMarketItem;
    mapping(uint256 => string) private _tokenSymbols;

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        bool sold,
        string tokenSymbol
    );

    constructor() ERC721("3DAssets", "3DA") {
        owner = payable(msg.sender);
        _tokenIds = 0;
    }

    function createToken(string memory tokenSymbol, uint256 price) public payable {
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _tokenIds += 1;
        uint256 newTokenId = _tokenIds;

        _mint(msg.sender, newTokenId);
        _tokenSymbols[newTokenId] = tokenSymbol;

        idToMarketItem[newTokenId] = MarketItem(
            newTokenId,
            payable(msg.sender),
            price,
            false,
            tokenSymbol
        );

        emit MarketItemCreated(
            newTokenId,
            msg.sender,
            price,
            false,
            tokenSymbol
        );
    }

    function purchaseToken(uint256 tokenId) public payable {
        MarketItem storage item = idToMarketItem[tokenId];
        require(msg.value == item.price, "Please submit the asking price in order to complete the purchase");
        require(!item.sold, "This item has already been sold");

        item.seller.transfer(msg.value);
        _transfer(item.seller, msg.sender, tokenId);
        item.sold = true;
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds;
        uint256 unsoldItemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemCount; i++) {
            if (!idToMarketItem[i].sold) {
                unsoldItemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            if (!idToMarketItem[i].sold) {
                MarketItem storage currentItem = idToMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getTokenSymbol(uint256 tokenId) public view returns (string memory) {
        return _tokenSymbols[tokenId];
    }
}
