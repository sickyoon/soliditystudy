
# Solidy Study Notes

## Questions

* 3 slashes comment?
* when to use storage (memory / storage) -> look at vote.sol
* why tail with underscore sometimes. they are public vars
* if a method is calling another public method, is it considered a single transaction?

## Notes

address is a type

require() method to restrict permission

msg is also available variable
msg.sender

address is 160bit value that does not allow any arithmetic operations.
used to store addresses of contracts or hash of the public half of a keypair belonging to external accounts


coin contract addresses, not address of owner

if transaction has no recipient, the transaction creates new contract and create new address derived from sender address.

Each account has data area called "storage"
key-value store of 256-bit key and 256-bit value
not enumerable
costly to read / initialize / modify

'memory' - cleared instance for each message call
byte level addressable
read -> width of 256 bits
write -> 8 bits or 256 bits wide
can be extended but costs gas

Instead of destruct
Have some clever way to disable the contract

