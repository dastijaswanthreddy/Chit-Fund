// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

struct Subscriber
{
    string name;
    string email;
    address account_id;
    string password;
    uint256 phone_number;
    string dob;
    string Address;
    string aadhar;
}

contract ChitFundCompany
{
    mapping(address => Subscriber) public subscribers;
    mapping(string => address) public chitfunds;
    function register(string memory _name, string memory _email, address _account_id, string memory _password, uint256 _phone, string memory _dob, string memory _address, string memory _aadhar) public {
        require(subscribers[_account_id].account_id != _account_id, "Already Registered");
        subscribers[_account_id] = Subscriber(_name, _email, _account_id, _password, _phone, _dob, _address, _aadhar);  
    }
    function createChitFund(string memory name, address foremanId, string memory password, uint256 amount, uint256 installments, uint256 participants) public {
        require(subscribers[foremanId].account_id == foremanId, "Register to company inorder to create");
        require(chitfunds[name] == 0x0000000000000000000000000000000000000000, "ChitFund ID is already taken! Try Again");
        chitfunds[name] = address(new chitFund(name, foremanId, password, amount, installments, participants));
    }
    // function getChitFundAddress(string memory name) public view returns(address){
    //     require(chitfunds[name] != 0x0000000000000000000000000000000000000000, "Invalid ChitFund Name");
    //     return chitfunds[name];
    // }
    // function getSubscriberDetails(address _address) public view returns (Subscriber memory){
    //     return subscribers[_address];
    // }
}

contract chitFund
{
    //to store chitfund details
    string public chitFundName;
    address public foremanId;
    string public password;
    uint256 public installmentAmount;
    uint256 public noOfInstallments;
    uint256 public noOfParticipants;
    
    address[] public participantsArray;
    mapping(address => bool) public participants;
    mapping(address => uint256) public contributedParticipants;
    mapping(address => bool) public winnersList;
    address public winner;
    uint256 public currentNumberOfContributors = 0;
    uint256 public currentInstallment = 1;
    uint256 public minBidAmount = 0;
    uint256 public chitFundBalance = 0;
    uint256 public foremanCommision = 0;
    uint256 public equalShare = 0;
    bool public status = true;

    constructor(string memory _name, address _foremanId, string memory _password, uint256 _amount, uint256 _installments, uint256 _participants) {
        chitFundName = _name;
        foremanId = _foremanId;
        password = _password;
        installmentAmount = _amount;
        noOfInstallments = _installments;
        noOfParticipants = _participants;
        minBidAmount = _amount * _installments;
    }
    
    modifier isForeman() {
        require(msg.sender == foremanId, "Access Denied");
        _;
    }

    modifier isParticipant() {
        require(participants[msg.sender] == true, "Access Denied");
        _;
    }

    modifier isEnoughParticipants() {
        require(participantsArray.length == noOfParticipants, "");
        _;
    }

    modifier chitFundStatus() {
        require(status == true, "This ChitFund has been completed");
        _;
    }

    function joinChitFund() public chitFundStatus {
        require(participants[msg.sender] != true, "Already a Participant");
        require(participantsArray.length < noOfParticipants, "Participants Limit Reached");
        require(status, "This ChitFund has been completed");
        participants[msg.sender] = true;
        participantsArray.push(msg.sender);
    }

    function contribute() public isParticipant chitFundStatus payable {
        require(participantsArray.length == noOfParticipants, "Waiting for Participants to join the Chit :(");
        require(msg.value == installmentAmount, "Invalid Amount");
        require(contributedParticipants[msg.sender] != currentInstallment, "Already Paid");
        require(status, "This ChitFund has been completed");
        contributedParticipants[msg.sender] = currentInstallment;
        chitFundBalance += msg.value;
        currentNumberOfContributors++;
    }

    function bid(uint256 amt) public isParticipant chitFundStatus {
        require(participantsArray.length == noOfParticipants, "Waiting for Participants to join the Chit :(");
        require(currentNumberOfContributors == noOfParticipants, "Waiting for all participants contribution");
        require(amt>0, "Invalid Amount");
        require(amt<minBidAmount, "Amount is greater than current Bid");
        require(winnersList[msg.sender] == false, "You are not eligible to participate in Bid");
        require(status, "This ChitFund has been completed"); 
        minBidAmount = amt;
        winner = msg.sender;
    }

    function releaseFund() public isForeman chitFundStatus payable {
        require(currentNumberOfContributors == noOfParticipants, "Waiting for all participants contribution");
        payable(winner).transfer(minBidAmount);
        winnersList[winner] = true;
        chitFundBalance -= minBidAmount;
        foremanCommision = chitFundBalance / 20;  //usually foreman will take 5% of remaining balance so 5/100 => 1/20
        payable(foremanId).transfer(foremanCommision);
        chitFundBalance -= foremanCommision;
        equalShare = chitFundBalance / (noOfParticipants - 1);
        for(uint256 i = 0; i < noOfParticipants; i++)
        {
            if(equalShare > 0 && participantsArray[i] != winner)
            {
                payable(participantsArray[i]).transfer(equalShare);
            }
        }
        minBidAmount = installmentAmount * noOfInstallments;
        chitFundBalance = 0;
        currentNumberOfContributors = 0;
        currentInstallment++;
        if(currentInstallment > noOfInstallments)status = false;
    }
}