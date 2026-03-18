// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

error NotMember();
error AdminCannotEarnPoints();
error CountdownNotFinished(uint256 secondsLeft);

contract RewardSystem {
    address immutable admin;

    struct Member {
        bool isMember;
        uint248 points;
    }

    enum RewardChoice { TShirt, Jeans, Shoes }

    mapping(address => Member) private members;
    mapping(RewardChoice => uint248) private rewardCost;
    mapping(address => uint256) private lastTimeEarnedPoints;
    mapping(address => bool) private frozen;



    event MemberJoined(address indexed member);
    event EarnedPoints(address indexed member, uint248 pointsAdded);
    event RedeemedReward(address indexed member, uint248 cost);
    event TransferredPoints(address indexed from, address indexed to, uint248 points);
    event MemberPointsFrozen(address indexed member);
    event MemberPointsUnfrozen(address indexed member);


//------------Kostnader----------------------//
    constructor() {
        admin = msg.sender;
        rewardCost[RewardChoice.TShirt] = 200;
        rewardCost[RewardChoice.Jeans]  = 600;
        rewardCost[RewardChoice.Shoes]  = 1000;
    }

//--------------------Modifiers/säkerhet-------------------//
    modifier onlyAdmin() {
        require(msg.sender == admin, "You cannot call this function because you are not an admin");
        _;
    }

    modifier notFrozen() {
        require(!frozen[msg.sender], "Account has been frozen from using points");
        _;
    }

//------------------Frys medlem------------------//
    function freezeMemberPoints(address _member) external onlyAdmin {
        frozen[_member] = true;
        emit MemberPointsFrozen(_member);
    }

    function unfreezeMemberPoints(address _member) external onlyAdmin {
        frozen[_member] = false;
        emit MemberPointsUnfrozen(_member);
    }

//----------------Bli medlem-------------//
    function signMembership() public {
        require(msg.sender != admin, "Admin cannot become a member");
        require(!members[msg.sender].isMember, "You are already a member, please sign in to your existing account");
        members[msg.sender].isMember = true;
        members[msg.sender].points = 0;
        emit MemberJoined(msg.sender);
    }

//-----------------Poängsystem----------------//
    function SeeMembersPoints(address _member) public view onlyAdmin returns (uint248){
        require(members[_member].isMember, "The address you provided is not a member");
        return members[_member].points;
    }

    function SeeMyPoints() public view returns (uint248 _points) {
        require(members[msg.sender].isMember, "Only members can see their points");
        return members[msg.sender].points;
    }

    function sendPoints(address _to, uint248 _points) public notFrozen {
        require(members[msg.sender].isMember, "You are not a member and cannot send points");
        require(members[_to].isMember, "The address you provided is not a member and cannot receive points");
        require(members[msg.sender].points >= _points, "You dont have enough points to proceed this transaction");
        require(_to != admin, "You cannot send points to the admin");
        uint248 totalBefore = members[msg.sender].points + members[_to].points;
        members[msg.sender].points -= _points;
        members[_to].points += _points;
        uint248 totalAfter = members[msg.sender].points + members[_to].points;
        assert(totalAfter == totalBefore);
        emit TransferredPoints(msg.sender, _to, _points);
    }

    function givePoints(address _member, uint248 _points) public onlyAdmin{
        require(members[_member].isMember, "This user is not a member");
        members[_member].points += _points;
        emit EarnedPoints(_member, _points);
    }

    function earnPoints() public notFrozen {
        if (msg.sender == admin) revert AdminCannotEarnPoints();
        if (!members[msg.sender].isMember) revert NotMember();
        uint256 elapsed = block.timestamp - lastTimeEarnedPoints[msg.sender];
        if (elapsed < 24 hours) revert CountdownNotFinished(24 hours - elapsed);
        members[msg.sender].points += 10;
        lastTimeEarnedPoints[msg.sender] = block.timestamp;
        emit EarnedPoints(msg.sender, 10);
    }

    function timeUntilNextEarn() public view returns (uint256) {
        require(members[msg.sender].isMember, "Only members can call this function");
        if (block.timestamp >= lastTimeEarnedPoints[msg.sender] + 24 hours) {
            return 0;
        } else {
            return (lastTimeEarnedPoints[msg.sender] + 24 hours) - block.timestamp;
        }
    }

//----------------Lös ut reward----------------//
    function redeemReward(RewardChoice _reward) public notFrozen{
        require(members[msg.sender].isMember, "Only members can redeem rewards");
        uint248 cost = rewardCost[_reward];
        require(members[msg.sender].points >= cost, "You don't have enough points to redeem this reward");
        uint248 oldPoints = members[msg.sender].points;
        members[msg.sender].points -= cost;
        assert(members[msg.sender].points <= oldPoints);
        emit RedeemedReward(msg.sender, cost);
    }

//-----------------Fallback och receive----------------//

    fallback() external payable {
        revert("This contract does not accept ETH");
    }

    receive() external payable {
        revert("This contract does not accept ETH");
    }
}
