import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("PropertyManagement", function() {
     async function deployPropertyManagement(){
        const [owner, addr1, addr2] = await hre.ethers.getSigners();

        // Deploy ERC20 token (assumes constructor mints to deployer)
        const Token = await ethers.getContractFactory("MyToken");
        const token = await Token.deploy(1_000_000); // initial supply
        await token.waitForDeployment();
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const PropertyManagement = await hre.ethers.getContractFactory("PropertyManagement");
        const propertyManagement = await PropertyManagement.deploy(token.target);

        return {propertyManagement, owner, token, addr1, addr2};
    }

    describe("Property Management", function(){
        it("Should create property", async function() {
            const {propertyManagement} = await loadFixture(deployPropertyManagement);
            const name: string = "Duplex";
            const desc: string = "4 Bedroom and ensuite";
            const location: string = "Mushin" 
            const price = ethers.parseEther("1");
            await propertyManagement.createProperty(name, desc, location, price);
            let properties = await propertyManagement.getAllProperties();
            expect(properties.length).to.equal(1);
        })

        it("Should remove property", async function () {
            const { propertyManagement, addr1, addr2 } = await loadFixture(deployPropertyManagement);

            const price = ethers.parseEther("1");

            await propertyManagement
                .connect(addr1)
                .createProperty("Duplex", "4 Bedroom and ensuite", "Mushin", price);

            let properties = await propertyManagement.getAllProperties();
            expect(properties.length).to.equal(1);

            await propertyManagement.connect(addr1).removeProperty(0);

            properties = await propertyManagement.getAllProperties();
            expect(properties.length).to.equal(0);

            await expect(
                propertyManagement.connect(addr2).removeProperty(0)
            ).to.be.revertedWithCustomError(propertyManagement, "NOT_THE_OWNER");
        });

        it("Should buy property", async function(){
            
        })

    })
})