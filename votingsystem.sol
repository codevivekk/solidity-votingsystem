// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    uint256 public candidateCount;
    uint256 public startTime;
    uint256 public endTime;
    address immutable Owner;

    constructor(uint256 _durationInDays) {
        startTime = block.timestamp;
        endTime = block.timestamp + (_durationInDays * 1 days);
        Owner = msg.sender;
    }

    mapping(address => bool) public hasVoted;
    mapping(uint256 => Candidate) public candidates;

    modifier preventMultipleVote() {
        require(!hasVoted[msg.sender], "You can only vote once.");
        require(block.timestamp >= startTime, "Voting has not started yet");
        require(block.timestamp <= endTime, "Voting has ended");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "Not the owner");
        _;
    }

    modifier stopModification() {
        require(
            block.timestamp >= startTime,
            "You cannot modifiy once voting is started"
        );
        _;
    }

    function addCandidate(string memory _name) public {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, 0, true);
    }

    function castVote(uint256 _candidateId) public preventMultipleVote {
        candidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getVotes(uint256 _candidateId) public view returns (uint256) {
        return candidates[_candidateId].voteCount;
    }

    function deleteCandidates(uint256 _candidateId)
        public
        onlyOwner
        stopModification
    {
        require(candidates[_candidateId].exists, "Candidate does not exist");
        delete candidates[_candidateId];
    }

    function getCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory candidateArray = new Candidate[](candidateCount);

        for (uint256 i = 1; i <= candidateCount; i++) {
            candidateArray[i - 1] = candidates[i]; 
        }

        return candidateArray;
    }
}
