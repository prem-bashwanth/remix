// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimeLockedVault {
    struct PrivateMessage {
        string encryptedMessage;
        uint256 unlockTime;
    }

    struct PublicMessage {
        address sender;
        string encryptedMessage;
        uint256 unlockTime;
    }

    mapping(address => PrivateMessage[]) public privateMessages;
    PublicMessage[] public publicMessages;

    event PrivateMessageStored(address indexed sender, uint256 index, uint256 unlockTime);
    event PublicMessageStored(address indexed sender, uint256 index, uint256 unlockTime);

    /// @notice Store a private encrypted message with unlock duration (in seconds)
    function storePrivateMessage(string calldata _encryptedMessage, uint256 _durationInSeconds) external {
        require(_durationInSeconds > 0, "Duration must be greater than 0");

        uint256 unlockTime = block.timestamp + _durationInSeconds;

        privateMessages[msg.sender].push(PrivateMessage({
            encryptedMessage: _encryptedMessage,
            unlockTime: unlockTime
        }));

        emit PrivateMessageStored(msg.sender, privateMessages[msg.sender].length - 1, unlockTime);
    }

    /// @notice View a private message (only by sender) after unlock time
    function viewPrivateMessage(uint256 index) external view returns (string memory) {
        require(index < privateMessages[msg.sender].length, "Invalid index");

        PrivateMessage memory message = privateMessages[msg.sender][index];
        require(block.timestamp >= message.unlockTime, "Message still locked");

        return message.encryptedMessage;
    }

    /// @notice Store a public encrypted message with unlock duration (in seconds)
    function storePublicMessage(string calldata _encryptedMessage, uint256 _durationInSeconds) external {
        require(_durationInSeconds > 0, "Duration must be greater than 0");

        uint256 unlockTime = block.timestamp + _durationInSeconds;

        publicMessages.push(PublicMessage({
            sender: msg.sender,
            encryptedMessage: _encryptedMessage,
            unlockTime: unlockTime
        }));

        emit PublicMessageStored(msg.sender, publicMessages.length - 1, unlockTime);
    }

    /// @notice View a public message after unlock time
    function viewPublicMessage(uint256 index) external view returns (string memory) {
        require(index < publicMessages.length, "Invalid index");

        PublicMessage memory message = publicMessages[index];
        require(block.timestamp >= message.unlockTime, "Message still locked");

        return message.encryptedMessage;
    }

    /// @notice Get count of public messages
    function getPublicMessageCount() external view returns (uint256) {
        return publicMessages.length;
    }

    /// @notice Get count of private messages sent by the caller
    function getPrivateMessageCount() external view returns (uint256) {
        return privateMessages[msg.sender].length;
    }
}
