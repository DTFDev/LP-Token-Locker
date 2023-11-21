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

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender; 
    }

    function lockTokens(address _token, uint256 _amount, uint256 _lockDuration) external onlyOwner {
        // Lock LP Tokens for the specified duration
        require(lockedBalances[msg.sender] == 0, "Tokens already locked");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        lockedBalances[msg.sender] = _amount;
        unlockTimestamp = _lockDuration;
        lockDuration = _lockDuration;

        emit TokensLocked(msg.sender, _token, _amount, lockDuration);
    }

    function unlockTokens(address _token) external onlyOwner {
         // Unlock LP Tokens after the specified duration
        require(block.timestamp >= unlockTimestamp, "Tokens cannot be unlocked yet");
        uint256 amount = lockedBalances[msg.sender];
        lockedBalances[msg.sender] = 0;
        IERC20(_token).safeTransfer(owner, amount);

        emit TokensUnlocked(msg.sender, _token, amount);
    }
}
