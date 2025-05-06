// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Dead Man's Switch with Multi-Beneficiary Support and Events
/// @author You
/// @notice Releases funds to multiple beneficiaries if owner is inactive past a timeout
contract DeadManSwitchMulti {
    address public immutable owner;
    address[] public beneficiaries;
    uint256 public lastPing;
    uint256 public timeoutPeriod;

    /// @notice Emitted when the owner pings to stay alive
    event Pinged(address indexed sender, uint256 timestamp);

    /// @notice Emitted when funds are claimed and contract is destructed
    event Claimed(address indexed triggeredBy, uint256 totalAmount, uint256 timestamp);

    /// @param _beneficiaries List of addresses to receive funds if owner is inactive
    /// @param _timeoutPeriod Time (in seconds) after which funds can be claimed
    constructor(address[] memory _beneficiaries, uint256 _timeoutPeriod) payable {
        require(_beneficiaries.length > 0, "No beneficiaries provided");
        owner = msg.sender;
        beneficiaries = _beneficiaries;
        timeoutPeriod = _timeoutPeriod;
        lastPing = block.timestamp;
    }

    /// @notice Called by the owner to reset the inactivity timer
    function ping() external {
        require(msg.sender == owner, "Only owner can ping");
        lastPing = block.timestamp;
        emit Pinged(msg.sender, block.timestamp);
    }

    /// @notice Transfers ETH equally to all beneficiaries if owner has not pinged in time
    function claimFunds() external {
        require(block.timestamp > lastPing + timeoutPeriod, "Owner still active");
        uint256 share = address(this).balance / beneficiaries.length;

        for (uint256 i = 0; i < beneficiaries.length; ++i) {
            payable(beneficiaries[i]).transfer(share);
        }

        emit Claimed(msg.sender, address(this).balance, block.timestamp);
        selfdestruct(payable(msg.sender)); // Remaining dust to caller
    }

    /// @notice Allows the contract to receive ETH directly
    receive() external payable {}
}
