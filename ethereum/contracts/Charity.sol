pragma solidity ^0.5.1;

// Additonal contract for creating instances of Charity to enable multiple users
contract CharityFactory {
    Charity[] public deployedCharities;
    // Allows user to create new instance of Charity contract. msg.sender is orginization.
    function createCharity(uint _minimumDonation) public {
         Charity newCharity = new Charity( _minimumDonation, msg.sender);
         deployedCharities.push(newCharity);
    }
    // Returns address of organization for deployed Charity instances.
    function getDeployedCharities() public view returns (Charity[] memory) {
        return deployedCharities;
    }
}

contract Charity {
    // Information regarding how donations will be spent.
    struct DonationAllocation {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvingVotes;
    }

    // Uses DonationAllocation struct definition to create spendingRequests.
    DonationAllocation[] public spendingRequests;
    // Address of organization that needs money.
    address public orginization;
    // Minimum amount of ether that will need to be donated before you can have voting rights.
    uint public minimumContribution;
    // Mapping addresses of every person who has donated money.
    mapping(address => bool) public approversOfSpending;
    // Record for number of people who approve spending request for donated money.
    uint public numberOfSpendingApprovals;

    // Restricts access to general public to prevent unscrupulous behavior.
    modifier restrictedAccess() {
        require(msg.sender == orginization);
        _;
    }

    // Organizations can create donation channels and set minimum amount of ether required for voting rights.
    constructor(uint _minimumDonation, address _charityCreator) public {
        orginization = _charityCreator;
        minimumContribution = _minimumDonation;
    }
    // Donate money to charity and gain voting rights.
    function donate() public payable {
        require(msg.value > minimumContribution);
        // Mappping to search for boolean value corresponding to donation.
        approversOfSpending[msg.sender] = true;
        numberOfSpendingApprovals++;
    }
    // Allows orginization to ask for votes in favor of spending donated money.
    function createSpendingRequest(string memory _description, uint64 _value, address payable _recipient)
        public payable restrictedAccess {
            DonationAllocation memory newDonationAllocation = DonationAllocation({
                description: _description,
                value: _value,
                recipient: _recipient,
                complete: false,
                approvalCount: 0
            });
            spendingRequests.push(newDonationAllocation);
    }
    // Approve orginization's request for how donated money will be spent.
    function approveSpendingRequest(uint _requestIndex) public {
        DonationAllocation storage request = spendingRequests[_requestIndex];

        require(approversOfSpending[msg.sender]);
        require(!spendingRequests[_requestIndex].approvingVotes[msg.sender]);

        request.approvingVotes[msg.sender] = true;
        request.approvalCount++;
    }
    // Finalize and complete the spending request from organization regarding donated money.
    function completeSpendingRequest(uint _requestIndex) public restrictedAccess {
        DonationAllocation storage request = spendingRequests[_requestIndex];

        require(request.approvalCount > (numberOfSpendingApprovals / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
