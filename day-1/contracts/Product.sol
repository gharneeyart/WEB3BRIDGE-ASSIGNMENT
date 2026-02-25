// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Product {
    struct Item{
        uint8 id;
        string name;
        string desc;
        uint256 price;
        uint8 quantity;
    }
    uint8 public product_id;
    Item[] public items;

    function createProduct(string memory _name, string memory _desc, uint256 _price, uint8 _quantity) external {
        product_id = product_id + 1;
        Item memory item = Item({id: product_id,name: _name,desc: _desc,price: _price,quantity: _quantity});
        items.push(item);
    }

    function getAllProduct() external view returns(Item[] memory){
        return items;
    }

    function getProductById(uint8 _id) external view returns(Item memory returnedItem){
        // return items[_id];
        for(uint8 i = 0; i < items.length; i++){
            if(items[i].id == _id){
                return items[i];
            }
        }
    }

    function updateProduct(uint8 _id, string memory _name, string memory _desc, uint256 _price, uint8 _quantity) external {
        for(uint8 i = 0; i < items.length; i++){
            if(items[i].id == _id){
                items[i].name = _name;
                items[i].desc = _desc;
                items[i].price = _price;
                items[i].quantity = _quantity;
            }
        }
    }

    function deleteProduct(uint8 _id) external {
        for(uint8 i =0; i < items.length; i++){
            if(items[i].id == _id){
                items[i] = items[items.length - 1];
                items.pop();
            }
        }
    }
      function sumAndAverage(uint _x, uint _y, uint _a, uint _b) external pure returns (uint _sum, uint _average){
        _sum = _x + _y + _a + _b;
        _average = _sum / 4;
    }


}