// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./SafeERC20.sol";

contract LPLock {
    using SafeERC20 for IERC20;

    address public owner;
    uint256 public lockDuration;
    uint256 public unlockTimestamp;
    mapping(address => uint256) public lockedBalances;

    event TokensLocked(address indexed user, address indexed token, uint256 amount, uint256 lockDuration);
    event TokensUnlocked(address indexed user, address indexed token, uint256 amount);
    event DestinationChanged(address indexed oldDestination, address indexed newDestination);


    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender; 
    }

		// Lock LP Tokens for the specified duration
    function lockTokens(address _token, uint256 _amount, uint256 _lockDuration) external onlyOwner {
        require(lockedBalances[msg.sender] == 0, "Tokens already locked");
        require(_amount > 0, "Amount is zero");
        require(_lockDuration > block.timestamp, "Invalid lock duration");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        lockedBalances[msg.sender] = _amount;
        unlockTimestamp = _lockDuration;
        lockDuration = _lockDuration;

        emit TokensLocked(msg.sender, _token, _amount, lockDuration);
    }

		// Unlock LP Tokens after the specified duration
    function unlockTokens(address _token) external onlyOwner {
        require(block.timestamp >= unlockTimestamp, "Tokens cannot be unlocked yet");
        uint256 amount = lockedBalances[msg.sender];
        lockedBalances[msg.sender] = 0;
        IERC20(_token).safeTransfer(owner, amount);

        emit TokensUnlocked(msg.sender, _token, amount);
    }
		
		// Change owner of contract & receiver of LP token(s)
    function changeDestination(address _newDestination) external onlyOwner {
        require(_newDestination != address(0), "Invalid destination address");
        emit DestinationChanged(owner, _newDestination);
        owner = _newDestination;
    }

		// Extend the LP lock duration (unix timestamp)
    function extendDuration(uint256 _newLockDuration) external onlyOwner {
        require(_newLockDuration > unlockTimestamp, "New lock duration must be greater than previous duration");
        unlockTimestamp = _newLockDuration;
        lockDuration = _newLockDuration;

        emit DurationExtended(msg.sender, _newLockDuration);
    }
}