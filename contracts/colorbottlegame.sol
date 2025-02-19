// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ColorBottleGame {
    uint256[5] private correctArrangement;
    uint256 public attempts;
    bool public gameActive;
    address public player;

    modifier onlyPlayer() {
        require(msg.sender == player, "Not your game session");
        _;
    }

    constructor() {
        shuffleBottles();
    }

    event GameStarted(address indexed player, uint256[5] arrangement);
    event AttemptMade(address indexed player, uint256[5] attempt, uint256 correctCount);
    event GameWon(address indexed player);
    event GameReset();

    function startGame() external {
        require(!gameActive, "Game already active");
        player = msg.sender;
        attempts = 0;
        gameActive = true;
        shuffleBottles();
        emit GameStarted(msg.sender, correctArrangement);
    }

    function makeAttempt(uint256[5] memory attempt) external onlyPlayer returns (uint256 correctCount) {
        require(gameActive, "Start a new game first");
        require(attempts < 5, "Maximum attempts reached");

        correctCount = checkCorrectBottles(attempt);
        attempts += 1;

        emit AttemptMade(msg.sender, attempt, correctCount);

        if (correctCount == 5) {
            gameActive = false;
            emit GameWon(msg.sender);
        } else if (attempts == 5) {
            gameActive = false;
            emit GameReset();
        }
    }

    function shuffleBottles() private {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, address(this))));
        for (uint256 i = 0; i < 5; i++) {
            correctArrangement[i] = (seed % 5) + 1;
            seed >>= 1;
        }
    }

    function checkCorrectBottles(uint256[5] memory attempt) private view returns (uint256 count) {
        for (uint256 i = 0; i < 5; i++) {
            if (attempt[i] == correctArrangement[i]) {
                count += 1;
            }
        }
    }
}
