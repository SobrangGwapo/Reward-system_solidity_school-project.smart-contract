// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {RewardSystem} from "../src/RewardSystem.sol";
import {CountdownNotFinished, AdminCannotEarnPoints, NotMember} from "../src/RewardSystem.sol";


contract RewardSystemTest is Test {
    RewardSystem reward;

    address admin = vm.addr(0x1);
    address member1 = vm.addr(0x2);
    address member2 = vm.addr(0x3);
    address nonMember = vm.addr(0x4);

    function setUp() public {
        vm.prank(admin);
        reward = new RewardSystem();
    }
//-----------Deployment----------------//
    function test_Deployment() public {
        reward = new RewardSystem();
    }

//------------Frys member----------------//
    function test_FrozenMemberCannotEarnPoints() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.freezeMemberPoints(member1);

        vm.prank(member1);
        vm.expectRevert(bytes("Account has been frozen from using points"));
        reward.earnPoints();
    }

    function test_FrozenMemberCannotSendPoints() public {
        vm.prank(member1);
        reward.signMembership();
        vm.prank(member2);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 50);

        vm.prank(admin);
        reward.freezeMemberPoints(member1);

        vm.prank(member1);
        vm.expectRevert(bytes("Account has been frozen from using points"));
        reward.sendPoints(member2, 10);
    }

    function test_FrozenMemberCannotRedeemReward() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 200);

        vm.prank(admin);
        reward.freezeMemberPoints(member1);

         vm.prank(member1);
        vm.expectRevert(bytes("Account has been frozen from using points"));
        reward.redeemReward(RewardSystem.RewardChoice.TShirt);
    }

    function test_UnfrozenMemberCanEarnPoints() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.unfreezeMemberPoints(member1);

        vm.prank(admin);
        reward.unfreezeMemberPoints(member1);

        vm.warp(block.timestamp + 24 hours);
        vm.prank(member1);
        reward.earnPoints();

        vm.prank(member1);
        assertEq(reward.SeeMyPoints(), 10);
    }

//-----------------Bli medlem----------------//
    function test_AdminCannotBecomeMember() public {
        vm.prank(admin);
        vm.expectRevert(bytes("Admin cannot become a member"));
        reward.signMembership();
    }

    function test_NonMemberCanSignMembership() public {
        vm.prank(member1);
        reward.signMembership();
    }

    function test_MemberCannotSignMembership() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(member1);
        vm.expectRevert(
            bytes("You are already a member, please sign in to your existing account"));
        reward.signMembership();
    }

//--------------------Tjäna poäng------------------//
    function test_MemberCanEarnPoints() public {
        vm.prank(member1);
        reward.signMembership();

        vm.warp(block.timestamp + 24 hours);

        vm.prank(member1);
        reward.earnPoints();

        vm.prank(member1);
        uint248 points = reward.SeeMyPoints();

        assertEq(points, 10);
    }

    function test_NonMemberCannotEarnPoints() public {
        vm.prank(member2);
        vm.expectRevert(NotMember.selector);
        reward.earnPoints();
    }


    function test_AdminCannotEarnPoints() public {
        vm.prank(admin);
        vm.expectRevert(AdminCannotEarnPoints.selector);
        reward.earnPoints();
    }

//------------------Skicka poäng------------------//
    function test_MemberCanSendPointsToMember() public {
        vm.prank(member1);
        reward.signMembership();
        vm.prank(member2);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 20);

        vm.prank(member1);
        uint248 startPointsMember1 = reward.SeeMyPoints();
        vm.prank(member2);
        uint248 startPointsMember2 = reward.SeeMyPoints();

        assertEq(startPointsMember1, 20);
        assertEq(startPointsMember2, 0);

        vm.prank(member1);
        reward.sendPoints(member2, 10);

        vm.prank(member1);
        uint248 afterPointsMember1 = reward.SeeMyPoints();
        vm.prank(member2);
        uint248 afterPointsMember2 = reward.SeeMyPoints();

        assertEq(afterPointsMember1, 10);
        assertEq(afterPointsMember2, 10);
    }

    function test_MemberCannotSendPointsToNonMember() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 20);

        vm.prank(member1);
        vm.expectRevert(
            bytes("The address you provided is not a member and cannot receive points"));
        reward.sendPoints(nonMember, 10);
    }

    function test_MemberCannotSendPointsToAdmin() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 20);

        vm.prank(member1);
        vm.expectRevert(
            bytes("The address you provided is not a member and cannot receive points"));
        reward.sendPoints(admin, 10);
    }

    function test_NonMemberCannotSendPoints() public {
        vm.prank(nonMember);
        vm.expectRevert(
            bytes("You are not a member and cannot send points"));
        reward.sendPoints(member1, 10);
    }

    function test_MemberCannotSendMorePointsThanTheyHave() public {
        vm.prank(member1);
        reward.signMembership();
        vm.prank(member2);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 5);

        vm.prank(member1);
        vm.expectRevert(
            bytes("You dont have enough points to proceed this transaction")
        );
        reward.sendPoints(member2, 10);
    }

//------------------Lös ut reward----------------//
    function test_MemberCanRedeemRewardTshirt() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 500);

        vm.prank(member1);
        uint248 startPoints = reward.SeeMyPoints();
        assertEq(startPoints, 500);

        vm.prank(member1);
        reward.redeemReward(RewardSystem.RewardChoice.TShirt);

        vm.prank(member1);
        uint248 afterPoints = reward.SeeMyPoints();
        assertEq(afterPoints, 300);
    }

    function test_NonMemberCannotRedeemReward() public {
        vm.prank(nonMember);
        vm.expectRevert(
            bytes("Only members can redeem rewards")
        );
        reward.redeemReward(RewardSystem.RewardChoice.TShirt);
    }

    function test_MemberCanRedeemRewardJeans() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 1000);

        vm.prank(member1);
        uint248 startPoints = reward.SeeMyPoints();
        assertEq(startPoints, 1000);

        vm.prank(member1);
        reward.redeemReward(RewardSystem.RewardChoice.Jeans);

        vm.prank(member1);
        uint248 afterPoints = reward.SeeMyPoints();
        assertEq(afterPoints, 400);
    }

    function test_MemberCannotRedeemWithoutPoints() public {
        vm.prank(member2);
        reward.signMembership();

        vm.prank(member2);
        vm.expectRevert(bytes("You don't have enough points to redeem this reward"));
        reward.redeemReward(RewardSystem.RewardChoice.TShirt);
    }

//----------Tjäna poäng--------------------//
    function test_MemberCannotEarnPointsBefore24Hours() public {
        vm.prank(member1);
        reward.signMembership();

        vm.warp(block.timestamp + 24 hours);

        vm.prank(member1);
        reward.earnPoints();

        vm.prank(member1);
        vm.expectRevert(
            abi.encodeWithSelector(
                CountdownNotFinished.selector,
                24 hours
            )
        );
        reward.earnPoints();
    }

    function test_TimeUntilNextEarnReturnsZeroAfter24Hours() public {
        vm.prank(member1);
        reward.signMembership();

        vm.warp(block.timestamp + 24 hours);
        vm.prank(member1);
        reward.earnPoints();

        vm.warp(block.timestamp + 24 hours);

        vm.prank(member1);
        uint256 timeLeft = reward.timeUntilNextEarn();

        assertEq(timeLeft, 0);
    }

    function test_TimeUntilNextEarnReturnsRemainingTime() public {
        vm.prank(member1);
        reward.signMembership();

        vm.warp(block.timestamp + 24 hours);
        vm.prank(member1);
        reward.earnPoints();

        vm.warp(block.timestamp + 4 hours);

        vm.prank(member1);
        uint256 timeLeft = reward.timeUntilNextEarn();

        assertEq(timeLeft, 20 hours);
    }

    function test_NonMemberCannotCallTimeUntilNextEarn() public {
        vm.prank(nonMember);
        vm.expectRevert(
            bytes("Only members can call this function"));
        reward.timeUntilNextEarn();
    }

//------------------Se poäng----------------//
    function test_AdminCanSeeMembersPoints() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        uint248 points = reward.SeeMembersPoints(member1);

        assertEq(points, 0);
    }

    function test_MemberCanSeeOwnPoints() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 20);

        vm.prank(member1);
        uint248 points = reward.SeeMyPoints();

        assertEq(points, 20);
    }

    function test_NonMemberCannotSeeOwnPoints() public {
        vm.prank(nonMember);
        vm.expectRevert(
            bytes("Only members can see their points"));
        reward.SeeMyPoints();
    }

    function test_NonAdminCannotSeeMembersPoints() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(member2);
        vm.expectRevert(
            bytes("You cannot call this function because you are not an admin"));
        reward.SeeMembersPoints(member1);
    }

    function test_AdminCannotSeeNonMembersPoints() public {
        vm.prank(admin);
        vm.expectRevert(
            bytes("The address you provided is not a member"));
        reward.SeeMembersPoints(nonMember);
    }

//------------------Ge poäng----------------//
    function test_AdminCannotGivePointsToNonMember() public {
        vm.prank(admin);
        vm.expectRevert(
            bytes("This user is not a member"));
        reward.givePoints(nonMember, 10);
    }

    function test_AdminCanGivePointsToMember() public {
        vm.prank(member1);
        reward.signMembership();

        vm.prank(admin);
        reward.givePoints(member1, 30);

        vm.prank(member1);
        uint248 points = reward.SeeMyPoints();

        assertEq(points, 30);
    }
    
//-----------------Fallback och receive----------------//
    function test_FallbackFunction() public {
        vm.deal(member1, 1 ether);
        vm.prank(member1);

        vm.expectRevert(bytes("This contract does not accept ETH"));
        (bool success, ) = address(reward).call{value: 1 ether}(
            abi.encodeWithSignature("doesNotExist()")
        );
        success;
    }

    function test_ReceiveFunction() public {
        vm.deal(member1, 1 ether);
        vm.prank(member1);

        vm.expectRevert(bytes("This contract does not accept ETH"));
        (bool success, ) = address(reward).call{value: 1 ether}("");
        success;
    }
}
