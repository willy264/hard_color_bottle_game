// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ColorBottleGame {
    uint256[5] private correctArrangement;
    uint256 public attempts;
    bool public gameActive;
    address public player;

    event GameStarted(address indexed player, uint256[5] arrangement);
    event AttemptMade(address indexed player, uint256[5] attempt, uint256 correctCount);
    event GameWon(address indexed player);
    event GameReset();

    modifier onlyPlayer() {
        require(msg.sender == player, "Not your game session");
        _;
    }

    constructor() {
        _shuffleBottles();
    }

    function startGame() external {
        require(!gameActive, "Game already active");
        player = msg.sender;
        attempts = 0;
        gameActive = true;
        _shuffleBottles();
        emit GameStarted(msg.sender, correctArrangement);
    }

    function makeAttempt(uint256[5] memory attempt) external onlyPlayer returns (uint256 correctCount) {
        require(gameActive, "Start a new game first");
        require(attempts < 5, "Maximum attempts reached");

        correctCount = _checkCorrectBottles(attempt);
        attempts++;

        emit AttemptMade(msg.sender, attempt, correctCount);

        if (correctCount == 5) {
            gameActive = false;
            emit GameWon(msg.sender);
        } else if (attempts == 5) {
            gameActive = false;
            emit GameReset();
        }
    }

    function _shuffleBottles() private {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, address(this))));
        for (uint256 i = 0; i < 5; i++) {
            correctArrangement[i] = (seed % 5) + 1;
            seed >>= 1;
        }
    }

    function _checkCorrectBottles(uint256[5] memory attempt) private view returns (uint256 count) {
        for (uint256 i = 0; i < 5; i++) {
            if (attempt[i] == correctArrangement[i]) {
                count++;
            }
        }
    }
}
