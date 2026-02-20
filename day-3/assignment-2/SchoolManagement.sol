// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import {IERC20} from "./IERC20.sol";
// Create a School management system where people can:
// Register students & Staffs.
// Pay School fees on registration using ERC20.
// Pay staffs also with ERC20.
// Get the students and their details.
// Get all Staffs.
// Pricing is based on grade / levels from 100 - 400 level.
// Payment status can be updated once the payment is made which should include the timestamp.

contract SchoolManagement {
    address public owner;
    address public token;

    enum Level{L100, L200, L300, L400}

    struct Student {
        uint256 id;
        string name;
        address wallet;
        Level level;
        bool paid;
        uint256 paidAt;
    }

    struct Staff {
        uint256 id;
        string name;
        address wallet;
        uint256 salary;
        uint256 paidAt;
    }

    mapping(uint256 => Student) public students;
    mapping(uint256 => Staff) public staffs;
    mapping(Level => uint256) public levelFees;

    uint256 public studentCount;
    uint256 public staffCount;

    Staff[] public allStaffs;
    
    event StudentRegistered(uint256 indexed _studentId, address indexed _walletAddress, string _studentName, Level _level);
    event StaffRegistered(uint256 indexed _staffId, address indexed _walletAddress, string _staffName, uint256 _salary);
    event FeePaid(uint256 _studentId, uint256 _amount, uint256 timestamp);
    event SalaryPaid(uint256 _staffId, uint256 _amount, uint256 timestamp);
    event LevelFeeUpdated(Level level, uint256 newFee);

    constructor(address _token, uint256[4] memory fees){
        owner = msg.sender;
        require(_token != address(0), "Zero token address");
        token = _token;

        levelFees[Level.L100] = fees[0];
        levelFees[Level.L200] = fees[1];
        levelFees[Level.L300] = fees[2];
        levelFees[Level.L400] = fees[3];

        studentCount = 1;
        staffCount = 1;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

  
    function registerStaff( string calldata _name, address _wallet, uint256 _salary) external onlyOwner returns(uint256 id) {
        require(_wallet != address(0), "Zero wallet address");
        require(bytes(_name).length > 0, "Empty name");
        require(_salary > 0, "Salary > 0");

        id = staffCount++;
        Staff memory staff = Staff(id, _name, _wallet, _salary, 0);
        allStaffs.push(staff);
        emit StaffRegistered(id, _wallet,_name, _salary);
    }

    function getAllStaff() external view returns(Staff[] memory) {
      return allStaffs;
    }

    function paySalary(uint256 _staffId) external onlyOwner {
        require(_staffId < allStaffs.length, "Staff not found");

        require(staffs[_staffId].wallet != address(0), "Staff not found");
        require(IERC20(token).transferFrom(msg.sender, staffs[_staffId].wallet, staffs[_staffId].salary), "Payment failed");

        staffs[_staffId].paidAt = block.timestamp;
        emit SalaryPaid(_staffId, staffs[_staffId].salary, block.timestamp);
    }


    function registerSudent( string calldata _name, Level _level) external returns(uint256 id) {
        require(bytes(_name).length > 0, "Empty name");

        id = studentCount++;
        students[id] = Student(id, _name, msg.sender, _level,false, 0);

        Student storage student = students[id];
        require(student.wallet != address(0), "Student not found");
        require(!student.paid, "Already paid");
        require(msg.sender == student.wallet, "Not student");

        uint256 amount = levelFees[student.level];
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Payment failed");

        student.paid = true;
        student.paidAt = block.timestamp;
        emit FeePaid(id, amount, block.timestamp);
        emit StudentRegistered(id, msg.sender,_name, _level);
    }

    function getStudent(uint256 _id) external view returns(Student memory){
        return students[_id];
    }

    function contractTokenBalance() external view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }



    
}