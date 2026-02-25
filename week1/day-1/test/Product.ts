import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Product", function(){
    async function deployProduct() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const Product = await hre.ethers.getContractFactory("Product");
    const product = await Product.deploy() as any;

    const name: string = "Laundry";
    const desc: string = "nice";
    const price: number = 1000;
    const quantity: number = 10;


    await product.createProduct(name, desc, price, quantity);

    return { product, name, desc, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should create a product", async function () {
      const { product, name, desc } = await loadFixture(deployProduct);
      let product_length: any = await product.getAllProduct();

      expect(product_length[0].name).to.equal(name);

      expect(product_length[0].desc).to.equal(desc);

      expect(product_length.length).to.equal(1);
    });

    it("Should get the length of a todo", async function () {
      const { product } = await loadFixture(deployProduct);

      let product_length: any = await product.getAllProduct();

      expect(product_length.length).to.equal(1);
    });

     it("Should get a product by Id", async function () {
      const { product } = await loadFixture(deployProduct);

      let product_length: any = await product.getAllProduct();

      expect(product_length.length).to.equal(1);
      expect(product_length[0].name).to.equal("Laundry");
    });

     it("Should update product", async function () {
      const { product } = await loadFixture(deployProduct);

      await product.updateProduct(1,"Theo", "black", 2000, 1);

      let product_length: any = await product.getAllProduct();

      expect(product_length.length).to.equal(1);
      expect(product_length[0].name).to.equal("Theo");
      expect(product_length[0].desc).to.equal("black");
      expect(product_length[0].price).to.equal(2000);
      expect(product_length[0].quantity).to.equal(1);
    });

    it("Should delete a task", async function () {
      const { product } = await loadFixture(deployProduct);

      await product.deleteProduct(1);

      let product_length: any = await product.getAllProduct();

      expect(product_length.length).to.equal(0);
    });
});
})