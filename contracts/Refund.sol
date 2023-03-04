// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Refund is Initializable, OwnableUpgradeable {
    address public token;
    uint256 public totalRefundAmount;

    uint256 injectCount;
    uint256 percentageDivider;
    mapping(uint256 => uint256) public injects;
    mapping(uint256 => bool) public isInjectExit;

    function initialize(address _token, uint256 _totalRefundAmount)
        public
        initializer
    {
        token = _token;
        totalRefundAmount = _totalRefundAmount;
        percentageDivider = 10_000;
    }

    function changeToltalRefund(uint256 _refundAmount) public onlyOwner {
        totalRefundAmount = _refundAmount;
    }

    function changeInjectionStatus(uint256 _Id, bool _status) public onlyOwner {
        isInjectExit[_Id] = _status;
    }

    function changeToken(address _token) public onlyOwner {
        token = _token;
    }

    function depositToken(uint256 _amount) public onlyOwner {
        IERC20MetadataUpgradeable(token).transferFrom(
            owner(),
            address(this),
            _amount
        );
        injects[injectCount] = _amount;
        isInjectExit[injectCount] = true;
        injectCount++;
    }

    struct UserData {
        uint256 share;
        uint256 claimedAmount;
        bool isclaimed;
        mapping(uint256 => bool) calimedInjection;
    }
    mapping(address => UserData) users;

    function insertUserAmount(address[] memory _user, uint256[] memory _amount)
        public
        onlyOwner
    {
        for (uint256 i = 0; i <= _user.length; i++) {
            users[_user[i]].share = _amount[i];
        }
    }

    function editUserAmount(address _user, uint256 _amount) public onlyOwner {
        users[_user].share = _amount;
    }

    function claimInjection(uint256 _injection) public {
        UserData storage user = users[msg.sender];
        require(isInjectExit[_injection], "Injection doesn't exist");
        require(user.share > 0, "Don't have any amount to calim");
        require(
            !user.calimedInjection[_injection],
            "you already claimed that injection"
        );
        require(!user.isclaimed, "User claimed the share");
        uint256 userShare = (user.share * percentageDivider) /
            totalRefundAmount;
        uint256 claim = (userShare * percentageDivider) / injects[_injection];
        if (user.claimedAmount + claim > user.share) {
            claim = user.share - user.claimedAmount;
            user.isclaimed = true;
        }
        IERC20MetadataUpgradeable(token).transfer(msg.sender, claim);
        user.calimedInjection[_injection] == true;
        user.claimedAmount += claim;
    }

    function withdrawTokens(uint256 _amount) public onlyOwner {
        IERC20MetadataUpgradeable(token).transfer(owner(), _amount);
    }
}
