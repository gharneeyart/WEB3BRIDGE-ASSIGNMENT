import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("SchoolManagement", function() {
     async function deploySchoolManagement(){
        const [owner, addr1, addr2] = await hre.ethers.getSigners();

        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("MyToken", "MTK", 18, 1000000);
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const SchoolManagement = await hre.ethers.getContractFactory("SchoolManagement");
        const schoolManagement = await SchoolManagement.deploy(erc20.target);

        return {schoolManagement, owner, erc20, addr1, addr2};
    }

    describe("School Mangement", function(){
        it("Should register staff", async function(){
            const {schoolManagement, owner} = await loadFixture(deploySchoolManagement);
            const name: string = "Gani";
            const wallet: string = "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB";
            const salary: number = 1000;

            await schoolManagement.registerStaff(name, wallet, salary);
        })

        it("Should get all staff", async function(){
            const {schoolManagement} = await loadFixture(deploySchoolManagement);
            const name: string = "Gani";
            const wallet: string = "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB";
            const salary = hre.ethers.parseEther("1");

            await schoolManagement.registerStaff(name, wallet, salary);

            let staff_length: any = await schoolManagement.getAllStaff();

            expect(staff_length.length).to.equal(1);
        })

        it("Should suspend staff", async function(){
            const {schoolManagement, owner, addr2} = await loadFixture(deploySchoolManagement);
            const name: string = "Gani";
            const wallet = addr2;
            const salary = hre.ethers.parseEther("1");

            await schoolManagement.registerStaff(name, wallet, salary);

            await schoolManagement.suspendStaff(1, true);

            let staff_length: any = await schoolManagement.getAllStaff();

            
            expect(staff_length[0].suspended).to.equal(true);
        })

        it("Should only allow owner to register staff", async function () {
            const {schoolManagement, addr1, addr2} = await loadFixture(deploySchoolManagement);
            const name = "Unauthorized Staff";
            const salary = hre.ethers.parseEther("1");

        // Try to register from non-owner account
        await expect(
            schoolManagement.connect(addr1).registerStaff(name, addr2.address, salary)
        ).to.be.revertedWith("Only Owner");
        });

        // it("Should pay staff", async function() {
        //     const {schoolManagement, owner,addr2, erc20} = await loadFixture(deploySchoolManagement);
        //     const name: string = "Gani";
        //     // const wallet: string = "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB";
        //     const salary = hre.ethers.parseUnits("1");

        //     await schoolManagement.registerStaff(name, addr2, salary);

        //     await erc20.approve(schoolManagement.target, 5000000000000000000000n);
        //     await schoolManagement.connect(owner).paySalary(1);

        //     let staff_length: any = await schoolManagement.getAllStaff();

        //    expect(staff_length[0].salary).to.equal("1")

        // })

        it("Should pay staff", async function () {
            const { schoolManagement, owner, addr2, erc20 } = await loadFixture(deploySchoolManagement);

            const name = "Gani";
            const salary = hre.ethers.parseUnits("1", 18); 

            await schoolManagement.registerStaff(name, addr2.address, salary);

            await erc20.transfer(schoolManagement.target, salary);

            await schoolManagement.connect(owner).paySalary(1); 

            const balance = await erc20.balanceOf(addr2.address);
            expect(balance).to.equal(salary);

            const staffs = await schoolManagement.getAllStaff();
            expect(staffs[0].paidAt).not.equal(0);
        });

        it("Should register student", async function(){
            const { schoolManagement, owner, addr1, erc20 } = await loadFixture(deploySchoolManagement);

            const name = "Gani";
            const level: number = 100;

            // await schoolManagement.registerSudent(name, level);

            
            // const amount = await schoolManagement.levelFees(level);
            const amountLevel0 = ethers.parseEther("10");
            // expect(amount).to.equal(ethers.parseEther("10"));

            await erc20.transfer(await addr1.getAddress(), amountLevel0);

            const addres1Balance = await erc20.balanceOf(addr1);
            expect(addres1Balance).to.equal(ethers.parseEther("10"));

            await erc20.connect(addr1).approve(await schoolManagement.getAddress(), amountLevel0);

            const getAllowance = await erc20.allowance(await addr1.getAddress(), await schoolManagement.getAddress());

            expect(getAllowance).to.equal(amountLevel0);

            

            // await erc20.connect(addr1).approve(await schoolManagement.getAddress(), amountLevel0);

            // const allowance = await erc20.allowance(await addr1.getAddress(), await schoolManagement.getAddress());
            // expect(allowance).to.equal(ethers.parseEther("10"));

            await schoolManagement.connect(addr1).registerSudent(name, level);
            const student = await schoolManagement.getStudent(1);
            expect(student.paid).equal(true);
            expect(student.paidAt).not.equal(0);

            await schoolManagement.removeStudent(1);
            //  expect(student).to.equal(0);

        })

        // it("Should remove student", async function(){
        //     // const { schoolManagement, owner, addr1, erc20 } = await loadFixture(deploySchoolManagement);

        

      

     
        // })

    })
});