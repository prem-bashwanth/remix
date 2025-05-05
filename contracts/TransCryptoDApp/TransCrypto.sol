// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Dead Man's Switch
/// @author You
/// @notice This contract allows a user to assign a beneficiary who can claim funds if the owner doesn't check-in in time.
contract DeadManSwitch {
    address public immutable owner;
    address public immutable beneficiary;
    uint256 public lastPing;
    uint256 public timeoutPeriod;

    constructor(address _beneficiary, uint256 _timeoutPeriod) payable {
        owner = msg.sender;
        beneficiary = _beneficiary;
        timeoutPeriod = _timeoutPeriod;
        lastPing = block.timestamp;
    }

    /// @notice Called by the owner to reset the timer
    function ping() external {
        require(msg.sender == owner, "Only owner can ping");
        lastPing = block.timestamp;
    }

    /// @notice Called by anyone, but only allows transfer to beneficiary if time has passed
    function claimFunds() external {
        require(block.timestamp > lastPing + timeoutPeriod, "Owner still active");
        selfdestruct(payable(beneficiary));
    }

    /// @notice Accept Ether donations
    receive() external payable {}
}