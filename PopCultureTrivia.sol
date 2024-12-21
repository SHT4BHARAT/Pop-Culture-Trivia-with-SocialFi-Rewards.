// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PopCultureTrivia {
    // Token balance mapping
    mapping(address => uint256) public balances;

    // Trivia question structure
    struct Question {
        string questionText;
        string[] options;
        uint8 correctOptionIndex; // The index of the correct option
        bool isActive;
    }

    // Questions storage
    Question[] public questions;

    // Staking balances
    mapping(address => uint256) public stakedBalances;

    // Owner address
    address public owner;

    // Events
    event QuestionAdded(uint256 questionId, string questionText);
    event AnswerSubmitted(address indexed player, uint256 questionId, bool isCorrect);
    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to add a new trivia question
    function addQuestion(
        string memory _questionText,
        string[] memory _options,
        uint8 _correctOptionIndex
    ) public onlyOwner {
        require(_options.length > 1, "There must be at least two options");
        require(_correctOptionIndex < _options.length, "Correct option index is out of range");

        questions.push(Question({
            questionText: _questionText,
            options: _options,
            correctOptionIndex: _correctOptionIndex,
            isActive: true
        }));

        emit QuestionAdded(questions.length - 1, _questionText);
    }

    // Function to submit an answer to a question
    function answerQuestion(uint256 _questionId, uint8 _selectedOption) public {
        require(_questionId < questions.length, "Question does not exist");
        Question storage question = questions[_questionId];

        require(question.isActive, "Question is no longer active");
        require(_selectedOption < question.options.length, "Selected option is invalid");

        if (_selectedOption == question.correctOptionIndex) {
            balances[msg.sender] += 10; // Reward 10 tokens for correct answer
            emit AnswerSubmitted(msg.sender, _questionId, true);
        } else {
            emit AnswerSubmitted(msg.sender, _questionId, false);
        }
    }

    // Function to stake tokens
    function stakeTokens(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        stakedBalances[msg.sender] += _amount;

        emit TokensStaked(msg.sender, _amount);
    }

    // Function to unstake tokens
    function unstakeTokens(uint256 _amount) public {
        require(stakedBalances[msg.sender] >= _amount, "Insufficient staked balance");

        stakedBalances[msg.sender] -= _amount;
        balances[msg.sender] += _amount;

        emit TokensUnstaked(msg.sender, _amount);
    }

    // Function to claim staking rewards
    function claimRewards() public {
        uint256 reward = stakedBalances[msg.sender] / 10; // 10% of staked balance as reward
        require(reward > 0, "No rewards available");

        balances[msg.sender] += reward;

        emit TokensClaimed(msg.sender, reward);
    }

    // View function to get question details
    function getQuestion(uint256 _questionId)
        public
        view
        returns (string memory questionText, string[] memory options, bool isActive)
    {
        require(_questionId < questions.length, "Question does not exist");
        Question storage question = questions[_questionId];

        return (question.questionText, question.options, question.isActive);
    }
}
