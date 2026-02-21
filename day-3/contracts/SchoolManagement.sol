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


    struct Student {
        uint256 id;
        string name;
        address wallet;
        uint256 level;
        bool paid;
        uint256 paidAt;
    }

    struct Staff {
        uint256 id;
        string name;
        address wallet;
        uint256 salary;
        uint256 paidAt;
        bool suspended;
    }

    mapping(uint256 => Student) public students;
    mapping(uint256 => Staff) public staffs;
    mapping(uint256 => uint256) public levelFees;

    uint256 public studentCount;
    uint256 public staffCount;

    Staff[] public allStaffs;
    Student[] public allStudents;
    
    event StudentRegistered(uint256 indexed _studentId, address indexed _walletAddress, string _studentName, uint256 _level);
    event StaffRegistered(uint256 indexed _staffId, address indexed _walletAddress, string _staffName, uint256 _salary);
    event FeePaid(uint256 _studentId, uint256 _amount, uint256 timestamp);
    event SalaryPaid(uint256 _staffId, uint256 _amount, uint256 timestamp);
    event LevelFeeUpdated(uint256 level, uint256 newFee);

    constructor(address _token){
        owner = msg.sender;
        require(_token != address(0), "Zero token address");
        token = _token;

        levelFees[100] = 10 * 10**18;  
        levelFees[200] = 15 * 10**18;  
        levelFees[300] = 20 * 10**18;
        levelFees[400] = 25 * 10**18;

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
        Staff memory staff = Staff(id, _name, _wallet, _salary, 0, false);
        staffs[id] = staff;
        allStaffs.push(staff);
        emit StaffRegistered(id, _wallet,_name, _salary);
    }

    function getAllStaff() external view returns(Staff[] memory) {
      return allStaffs;
    }

    function suspendStaff(uint256 _staffId, bool _suspend) external onlyOwner returns(bool) {
        require(staffs[_staffId].wallet != address(0), "Student not found");

        staffs[_staffId].suspended = _suspend;
        
        for(uint i; i < allStaffs.length; i++){
            if(allStaffs[i].id == _staffId){
                allStaffs[i].suspended = _suspend;
            }
        }
        return true;
    }


  function paySalary(uint256 _staffId) external onlyOwner {
        require(staffs[_staffId].wallet != address(0), "Staff not found");
        require(staffs[_staffId].suspended == false, "Staff has been suspended");
        
        uint256 salary = staffs[_staffId].salary;

        require(IERC20(token).transfer(staffs[_staffId].wallet, staffs[_staffId].salary), "Payment failed");

        staffs[_staffId].paidAt = block.timestamp;
        
        for(uint i = 0; i < allStaffs.length; i++) {
            if(allStaffs[i].id == _staffId) {
                allStaffs[i].paidAt = block.timestamp;
                break;
            }
        }
        
        emit SalaryPaid(_staffId, salary, block.timestamp);
    }

    function registerSudent( string calldata _name, uint256 _level) external returns(uint256 id) {
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
        allStudents.push(student);
        emit FeePaid(id, amount, block.timestamp);
        emit StudentRegistered(id, msg.sender,_name, _level);
    }

    function removeStudent(uint256 _id) external {
        require(students[_id].wallet != address(0), "Student not found");
        
        // address studentWallet = students[_id].wallet;
        
        for(uint i; i < allStudents.length; i++) {
            if(allStudents[i].id == _id) {
                allStudents[i] = allStudents[allStudents.length - 1];
                allStudents.pop();
            }
        }
        delete students[_id];
    }

    function getStudent(uint256 _id) external view returns(Student memory){
        return students[_id];
    }

    function contractTokenBalance() external view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }



    
}