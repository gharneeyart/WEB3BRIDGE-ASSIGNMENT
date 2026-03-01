// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Ecommerce {
    event CreateProduct(uint256 indexed _productId, address indexed _seller, uint256 _quantity);
    event BuyProduct(uint256 indexed _productId, address indexed _buyer, uint256 indexed _amount, uint256 _quantity);
    event DeactivateProduct(uint256 indexed _productId, string _message);
    event PaySeller(uint256 indexed _orderId, uint256 indexed _amount, address indexed _seller, bytes data);
    event OrderCreated(uint256 indexed _orderId, address indexed _buyer, uint256 _createdAt, OrderStatus _status);
    event ShippedOrder(uint256 indexed _orderId, uint256 indexed _productId, address indexed _seller, OrderStatus _status);
    event CancelOrder(uint256 indexed _orderId, address indexed _deactivator);
    event Refund(uint256 indexed _orderId, address indexed _buyer,uint256 indexed _amount);

    enum OrderStatus{Pending, Shipped, Delivered, Cancelled, Refunded}

    // OrderStatus public status;

    address public owner;

    struct Product {
        uint256 productId;
        string name;
        string desc;
        uint256 price;
        uint256 quantity;
        address seller;
        bool isActive;
    }

    struct Order{
        uint256 id;
        uint256 productId; 
        uint256 quantity;
        address buyer;
        uint256 totalAmount;
        OrderStatus status;
        uint256 createdAt;
    }

    mapping(uint => Product) public products;
    mapping(uint => Order) public orders;

    uint256 public product_id;

    Product[] public allProducts;
    Order[] public allOrders;

    uint256 public productCount;
    uint256 public orderCount;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not the owner");
        _;
    }
    modifier productExists(uint256 _id){
        require(products[_id].seller != address(0), "Product does not exist");
        _;
    }
    modifier inStock(uint256 _id){
        require(products[_id].quantity > 0, "Out of stock");
        _;
    }
    modifier orderExists(uint256 _id){
        require(orders[_id].buyer != address(0), "Product does not exist");
        _;
    }
    modifier onlyBuyer(uint256 _orderId){
        require(orders[_orderId].buyer == msg.sender, "Only buyer can confirm delivery");
        _;
    }


    // modifier onlySeller(uint256 _productId){
    //     require(products[_productId].seller == msg.sender, "Only seller can ship order");
    //     _;
    // }


    function addProduct(string memory _name, string memory _desc, uint256 _price, uint256 _quantity) external {
        productCount++;
        product_id = productCount;
        require(_price > 0, "No zero price");
        require(_quantity > 0, "Invalid quantity");

        Product memory product = Product({productId: product_id, name: _name, desc: _desc, price: _price, quantity: _quantity, seller: msg.sender, isActive: true});
        allProducts.push(product);
        products[product_id] = product;
        // productCount++;
        
        
        emit CreateProduct(product_id, msg.sender, _quantity);
    }

    function buyProduct(uint256 _productId, uint256 _quantity) external payable productExists(_productId) inStock(_productId) {
        require(products[_productId].quantity >= _quantity, "Not enough stock");
        require(products[_productId].isActive, "Inactive product");

        uint256 _amount = products[_productId].price * _quantity;


        require(_amount == msg.value, "Payment not yet complete");

        products[_productId].quantity = products[_productId].quantity - _quantity;
        orderCount++;   
        uint256 orderId = orderCount;

        Order memory order = Order({id:orderId, productId: _productId, quantity: _quantity, buyer: msg.sender, totalAmount: _amount, status: OrderStatus.Pending, createdAt: block.timestamp});

        allOrders.push(order);
        orders[orderId] = order;
        
        
        emit BuyProduct(_productId, msg.sender, _amount, _quantity);
        emit OrderCreated(orderId, msg.sender, block.timestamp, OrderStatus.Pending);
    }

    function shipOrder(uint256 _orderId) external orderExists(_orderId) {
    Order storage order = orders[_orderId];
    Product storage product = products[order.productId];

    require(product.seller == msg.sender, "Not seller");
    require(order.status == OrderStatus.Pending, "Invalid state");

    order.status = OrderStatus.Shipped;

    emit ShippedOrder(_orderId, product.productId, msg.sender, order.status);
    }

    function confirmDelivery(uint256 _orderId) external onlyBuyer(_orderId){
        require(orders[_orderId].status == OrderStatus.Shipped, "Not shipped");
        // require(orders[_orderId].status == OrderStatus.Shipped, "Invalid state");
        orders[_orderId].status = OrderStatus.Delivered;

        uint256 _productId = orders[_orderId].productId;

        uint256 _amount = orders[_orderId].totalAmount;

        address seller = products[_productId].seller;

        (bool result, bytes memory data) = payable(seller).call{value: _amount}("");

        require(result, "payment failed");

        emit PaySeller(_orderId, _amount, seller, data);
    }

    function cancelOrder(uint256 _orderId) external orderExists(_orderId) {
    Order storage order = orders[_orderId];

    Product storage product = products[order.productId];

    require(
        msg.sender == order.buyer || msg.sender == product.seller,
        "Not authorized"
    );

    require(order.status == OrderStatus.Pending, "Already processed");

    order.status = OrderStatus.Refunded;

    (bool success, ) = payable(order.buyer).call{value: order.totalAmount}("");
    require(success, "Refund failed");

    emit CancelOrder(_orderId, msg.sender);
    emit Refund(_orderId, order.buyer, order.totalAmount);
    }


    function getProduct(uint256 _productId) external view returns(Product memory){
        return products[_productId];
    }

    function getAllProduct() external view returns(Product[] memory){
        return allProducts;
    }

    function deactivateProduct(uint256 _productId) external onlyOwner productExists(_productId){
        products[_productId].isActive = false;
        emit DeactivateProduct(_productId, "Product has been deactivated");
    } 

    function getOrder(uint256 _orderId) external view returns(Order memory){
        return orders[_orderId];
    }  
}

