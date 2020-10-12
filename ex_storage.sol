// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.8.0;

// storage example
contract SimpleStorage {
  
  // declare state variable 'storedData' of uint 256 bits
  uint storedData;

  function set(uint x) public {
    storedData = x;
  }

  function get() public view returns (uint) {
    return storedData;
  }

}

// subcurrency example
contract Coin {
  
  // keyword 'public' makes variable accessible from other contracts
  // 'address' is 160-bit value that does not allow arithmetic operations
  // used to store addresses of contracts or hash of public half of a keypair belonging to external accounts
  address public minter;

  // mapping type can be seen as hash tables
  // every possible key exists from start and is mapped to a value whose byte-representation is all zeroes
  // it is not possible to obtain list of keys nor values
  mapping (address => uint) public balances;

  // events allow clients to react to specific contract changes you declare
  // this is emitted in the last line of send() method
  // ethereum clients can listen for this events emitted on blockchain without much cost
  // once emitted, listener receives [from, to, amount] to track transactions
  event Sent(address from, address to, uint amount);

  // constructor code is only run when the contract is created
  // permanently stores address of the person creating the contract
  // 'msg' is special global variable that contains properties to allow access to blockchain
  // https://solidity.readthedocs.io/en/v0.7.3/units-and-global-variables.html#special-variables-functions
  // msg.sender is always the address where the current (external) function call came from
  constructor() {
    minter = msg.sender;
  }

  // sends an amount of newly created coins to an address
  // can only be called by the contract creator
  function mint(address receiver, uint amount) public {
    require(msg.sender == minter);
    require(amount < 1e60); // this ensures that there are no overflow errors in the future
    balances[receiver] += amount;
  }

  // sends an amount of existing coin from any caller to an address
  function send(address receiver, uint amount) public {
    require(amount <= balances[msg.sender], "Insufficient balance.");
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    emit Sent(msg.sender, receiver, amount);
  }

  
}

