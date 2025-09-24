// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract PrizePoolBattle {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Voter {
        uint256 id;
        string name;
        uint256 weight;
        bool voted;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(uint256 => Voter) public voters;
    mapping(address => bool) public votersExist;
    mapping(address => uint256) public votersID;
    uint256 public candidatesCount;
    uint256 public votersCount;
    uint256 public winner;
    bool public winnerDeclared = false;

    event Voted(address indexed voter, uint256 indexed candidateId);
    event Winner(uint256 indexed candidateId, string name);

    modifier checkWinner(uint256 _candidateId) {
        _;
        if (candidates[_candidateId].voteCount >= 10 ether) {
            winnerDeclared = true;
            winner = _candidateId;
            emit Winner(_candidateId, candidates[_candidateId].name);
        }
    }

    constructor() {
        addCandidate("ENUMA");
        addCandidate("ALPHA");
    }

    function addCandidate(string memory _name) internal {
        require(
            keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("ENUMA"))
                || keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("ALPHA")),
            "Only ENUMA or ALPHA can be added as candidates"
        );
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function addVoter(string memory _name) public payable {
        require(!votersExist[msg.sender], "Voter has already been added.");
        votersCount++;
        uint256 weight = msg.value;
        voters[votersCount] = Voter(votersCount, _name, weight, false);
        votersID[msg.sender] = votersCount;
        votersExist[msg.sender] = true;
    }

    function vote(uint256 _candidateId) public checkWinner(_candidateId) {
        require(votersExist[msg.sender], "You are not an eligible voter.");
        require(!winnerDeclared, "The winner has already been declared.");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");
        uint256 id = votersID[msg.sender];
        require(voters[id].voted == false, "You already vote!");
        voters[id].voted = false;
        candidates[_candidateId].voteCount += voters[id].weight * 1;
        emit Voted(msg.sender, _candidateId);
    }

    function getCandidateVoteCount(uint256 _candidateId) public view returns (string memory name, uint256 voteCount) {
        Candidate storage candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    function getWinner() public view returns (string memory name, uint256 id) {
        Candidate storage candidate = candidates[winner];
        return (candidate.name, candidate.id);
    }
}
