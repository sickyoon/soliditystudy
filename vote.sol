// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

/// @title voting with delegation
contract Ballot {

  // complex type used as variable later
  // represents a single voter
  // associated with each address
  struct Voter {
    uint weight;      // weight is accumulated by delegation
    bool voted;       // if true, the person already voted
    address delegate; // person delegated to -> initialized to address(0)
    uint vote;        // index of the voted proposal
  }

  // single proposal type
  struct Proposal {
    bytes32 name;   // short name (up to 32 bytes)
    uint voteCount; // number of accumulated votes
  }

  address public chairperson;

  // declares a state variable that stores voter struct for each possible address
  mapping(address => Voter) public voters;

  // dynamically sized array of Proposal structs
  Proposal[] public proposals;

  // create a new ballot to chose one of proposalNames
  constructor(bytes32[] memory proposalNames) {
    chairperson = msg.sender;
    voters[chairperson].weight = 1;

    // for each proposal names, create a new proposal struct and append to array
    for (uint i = 0; i < proposalNames.length; i++) {
      proposals.push(Proposal{
        name: proposalNames[i],
        voteCount: 0
      });
    }
  }

  event VoteGained(address voter);

  // give voter the right to vote on this ballot
  // may only be called by chairperson
  // downside: many transactions are required to assign rights to vote to all participants
  function giveRightToVote(address voter) public {
    require(msg.sender == chairperson, "Only chairperson can give right to vote");
    require(!voters[voter].voted, "The voter already voted");
    require(voters[voter].weight == 0);
    voters[voter].weight = 1;
    emit VoteGained(voter);
  }

  // STEVE: give right to vote to multiple parties
  // does this count as single transaction even though its calling another public method?
  function giveRightToVoteMultiple(address[] voters) public {
    require(msg.sender == chairperson, "only chairperson can give right to vote");
    for (uint i = 0; i < voters.length; i++) {
      giveRightToVote(voters[i]);
    }
  }

  // delegate your vote to the voter 'to'
  function delegate(address to) public {
    
    // ??? WTF IS THIS?
    // assign reference
    Voter storage sender = voters[msg.sender];

    require(!sender.voted, "You already voted.");
    require(to != msg.sender, "Self-delegation is disallowed.");

    // forward delegation recursively until final destination is not delegated
    // get final to address destination
    while (voters[to].delegate != address(0)) {
      to = voters[to].delegate;
      require(to != msg.sender, "found loop in delegation.");
    }

    // sender is a reference, this modifies voters[msg.sender].voted
    sender.voted = true;
    sender.delegate = to;
    Voter storage delegate_ = voters[to];

    if (delegate_.voted) {
      // if delegate already voted, directly add number of votes
      proposals[delegate_.vote].voteCount += sender.weight;
    } else {
      // if delegate did not vote, add to the weight
      delegate_.weight += sender.weight;
    }
  }

  // vote on proposal with given index
  function vote(uint proposal) public {
    Voter storage sender = voters[msg.sender];
    require(sender.weight != 0, "Has no right to vote");
    require(!sender.voted, "already voted");
    require(proposals[proposal].exists, "proposal index out of range");
    sender.voted = true;
    sender.vote = proposal;
    // if proposal is out of index, this will throw automatically and revert all changes
    proposals[proposal].voteCount += sender.weight;
  }

  /// @dev computes the winning proposal taking all votes into account
  function winningProposal() public view returns (uint winningProposal_) {
    uint winningVoteCount = 0;
    for (uint p = 0; p < proposals.length; p++) {
      if (proposals[p].voteCount > winningVoteCount) {
        winningVoteCount = proposals[p].voteCount;
        winningProposal_ = p;
      }
    }
  }

  // calls winningProposal() to get the index
  function winnerName() public view returns (bytes32 winnerName_) {
    winnerName_ = proposals[winningProposal()].name;
  }

}

