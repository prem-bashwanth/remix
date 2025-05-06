// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Dead Man's Switch (Single Beneficiary Version)
/// @author You
/// @notice Transfers ETH to a beneficiary if the owner becomes inactive for a defined timeout period.
contract DeadManSwitch {
    /// @notice The address of the contract's creator (monitored for activity)
    address public immutable owner;

    /// @notice The address designated to receive funds if the owner becomes inactive
    address public immutable beneficiary;

    /// @notice Timestamp of the last time the owner was active
    uint256 public lastPing;

    /// @notice Duration (in seconds) after which funds may be claimed if owner does not ping
    uint256 public timeoutPeriod;

    /// @notice Emitted when the owner checks in to reset the timer
    event Pinged(address indexed owner, uint256 timestamp);

    /// @notice Emitted when the beneficiary claims the funds
    event Claimed(address indexed beneficiary, uint256 amount, uint256 timestamp);

    /// @param _beneficiary The address designated to receive funds on timeout
    /// @param _timeoutPeriod Duration in seconds after lastPing before beneficiary can claim
    constructor(address _beneficiary, uint256 _timeoutPeriod) payable {
        require(_beneficiary != address(0), "Invalid beneficiary");
        require(_timeoutPeriod > 0, "Timeout must be positive");

        owner = msg.sender;
        beneficiary = _beneficiary;
        timeoutPeriod = _timeoutPeriod;
        lastPing = block.timestamp;
    }

    /// @notice Called by the owner to prove activity and reset the timer
    function ping() external {
        require(msg.sender == owner, "Only owner can ping");
        lastPing = block.timestamp;
        emit Pinged(owner, lastPing);
    }

    /// @notice Called by anyone, but only transfers funds if timeout has passed
    function claimFunds() external {
        require(block.timestamp > lastPing + timeoutPeriod, "Owner still active");

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to claim");

        emit Claimed(beneficiary, balance, block.timestamp);
        selfdestruct(payable(beneficiary));
    }

    /// @notice Fallback to receive ETH directly
    receive() external payable {}
}
