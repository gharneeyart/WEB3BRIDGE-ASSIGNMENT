// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ecommerce} from "../src/Ecommerce.sol";

contract EcommerceTest is Test{
    Ecommerce public ecommerce;
    // enum OrderStatus{Pending, Shipped, Delivered, Cancelled, Refunded}
    address internal owner;
    address internal sellers;
    address internal buyers;

    function setUp() public {
        owner = makeAddr("owner");
        sellers = makeAddr("sellers");
        buyers = makeAddr("buyers");

        vm.prank(owner);
        ecommerce = new Ecommerce();

        vm.deal(buyers, 10 ether); 
    }

    function testOwnerIsSetCorrectly() public view {
        assertEq(ecommerce.owner(), owner);
    }

    function test_addProduct() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);
        (uint256 productId, string memory name, string memory desc, uint256 price, uint256 quantity, address seller, bool isActive) = ecommerce.allProducts(0);
        assertEq(productId, 1);
        assertEq(name, _name);
        assertEq(desc, _desc);
        assertEq(price, _price);
        assertEq(quantity, _quantity);
        assertEq(seller, sellers);
        assertEq(isActive, true);
    }

    function test_getProduct() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);
        (uint256 productId, string memory name, string memory desc, uint256 price, uint256 quantity, address seller, bool isActive) = ecommerce.allProducts(0);
        assertEq(productId, 1);
        assertEq(name, _name);
        assertEq(desc, _desc);
        assertEq(price, _price);
        assertEq(quantity, _quantity);
        assertEq(seller, sellers);
        assertEq(isActive, true);

        ecommerce.getProduct(1);
    }
    function test_getAllProduct() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);
        (uint256 productId, string memory name, string memory desc, uint256 price, uint256 quantity, address seller, bool isActive) = ecommerce.allProducts(0);
        assertEq(productId, 1);
        assertEq(name, _name);
        assertEq(desc, _desc);
        assertEq(price, _price);
        assertEq(quantity, _quantity);
        assertEq(seller, sellers);
        assertEq(isActive, true);

        ecommerce.getAllProduct();
    }

    function test_buyProduct() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);

        vm.prank(buyers);
        uint256 tAmount = _price * 10;
        ecommerce.buyProduct{value: tAmount}(1, 10);
        
        (uint256 id, uint256 productId, uint256 quantity, address buyer, uint256 totalAmount, Ecommerce.OrderStatus status, uint256 createdAt) = ecommerce.allOrders(0);
        assertEq(id, 1);
        assertEq(productId, 1);
        assertEq(quantity, 10);
        assertEq(buyer, buyers);
        assertEq(totalAmount, tAmount);
        assertEq(uint(status), uint(Ecommerce.OrderStatus.Pending));
        assertEq(createdAt, block.timestamp);

        (uint256 _productId, string memory name, string memory desc, uint256 price, uint256 quantit, address seller, bool isActive) = ecommerce.products(1);
        assertEq(_productId, 1);
        assertEq(name, "Indomitable");
        assertEq(desc, "Chicken flavor 70g");
        assertEq(price, 0.1 ether);
        assertEq(quantit, 10);
        assertEq(seller, sellers);
        assertEq(isActive, true);
    }

    function test_shipOrder() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);

        vm.prank(buyers);
        uint256 tAmount = _price * 10;
        ecommerce.buyProduct{value: tAmount}(1, 10);

        vm.prank(sellers);
        ecommerce.shipOrder(1);
        (uint256 id, uint256 productId, uint256 quantity, address buyer, uint256 totalAmount, Ecommerce.OrderStatus status, uint256 createdAt) = ecommerce.orders(1);
        assertEq(id, 1);
        assertEq(productId, 1);
        assertEq(quantity, 10);
        assertEq(buyer, buyers);
        assertEq(totalAmount, tAmount);
        assertEq(uint(status), uint(Ecommerce.OrderStatus.Shipped));
        assertEq(createdAt, block.timestamp);
    }
    function test_getOrder() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);

        vm.prank(buyers);
        uint256 tAmount = _price * 10;
        ecommerce.buyProduct{value: tAmount}(1, 10);

        vm.prank(sellers);
        ecommerce.shipOrder(1);
        
        ecommerce.getOrder(1);
    }

    function test_confirmDelivery() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);

        vm.prank(buyers);
        uint256 tAmount = _price * 10;
        ecommerce.buyProduct{value: tAmount}(1, 10);

        vm.prank(sellers);
        ecommerce.shipOrder(1);

        vm.prank(buyers);
        ecommerce.confirmDelivery(1);

        (uint256 id, uint256 productId, uint256 quantity, address buyer, uint256 totalAmount, Ecommerce.OrderStatus status, uint256 createdAt) = ecommerce.orders(1);
        assertEq(id, 1);
        assertEq(productId, 1);
        assertEq(quantity, 10);
        assertEq(buyer, buyers);
        assertEq(totalAmount, tAmount);
        assertEq(uint(status), uint(Ecommerce.OrderStatus.Delivered));
        assertEq(createdAt, block.timestamp);
    }

    function test_cancelOrder() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);

        vm.prank(buyers);
        uint256 tAmount = _price * 10;
        ecommerce.buyProduct{value: tAmount}(1, 10);

        vm.prank(buyers);
        ecommerce.cancelOrder(1);

        (uint256 id, uint256 productId, uint256 quantity, address buyer, uint256 totalAmount, Ecommerce.OrderStatus status, uint256 createdAt) = ecommerce.orders(1);
        assertEq(id, 1);
        assertEq(productId, 1);
        assertEq(quantity, 10);
        assertEq(buyer, buyers);
        assertEq(totalAmount, tAmount);
        assertEq(uint(status), uint(Ecommerce.OrderStatus.Refunded));
        assertEq(createdAt, block.timestamp);
    }

    function test_deactivateProduct() public {
        string memory _name = "Indomitable";
        string memory _desc = "Chicken flavor 70g";
        uint256 _price = 0.1 ether;
        uint256 _quantity = 20;

        vm.prank(sellers);
        ecommerce.addProduct(_name, _desc, _price, _quantity);

        vm.prank(owner);
        ecommerce.deactivateProduct(1);

        (uint256 productId, string memory name, string memory desc, uint256 price, uint256 quantity, address seller, bool isActive) = ecommerce.products(1);
        assertEq(productId, 1);
        assertEq(name, "Indomitable");
        assertEq(desc, "Chicken flavor 70g");
        assertEq(price, 0.1 ether);
        assertEq(quantity, 20);
        assertEq(seller, sellers);
        assertEq(isActive, false);

    }
}