pragma solidity ^0.4.4;

contract Multisig {


  struct stagedTx {
    uint8 regionID;
    address localrep;
    address receiver; 
    address approvedBy; 
  }
 
  bool isAlive = true;
  address creator; // = 0xfd5e7D9B422b12022d1488710AA7a1d2F40bA0C4; //benglobal metamask 

  
  mapping(address => bool) benGlobalReps; // address exists or not. 0 if doesn't exist, 1 if it does
  mapping(uint8 => mapping(address => bool)) regionReps; //regionID => (address => approved/not for that region)
  mapping(uint256 => stagedTx) transactions;

////Events
  event Deposit(address indexed from, uint value);
////Modifiers
  modifier onlyBENGlobal {
    require(benGlobalReps[msg.sender] = true);
    _;
  }
  modifier onlyRegionRep (uint8 _regionID, address _rep) {
    require(regionReps[_regionID][_rep] = true);
    _;
  }

////Functions
  //constructor sets the creator and initalizes benGlobalReps
  function Multisig(){
    creator = msg.sender; //set owner to whoever created the contract. used to widraw funds
    benGlobalReps[msg.sender] = true; //whoever created the contract has inital rights to ben global 
  }

  // Fallback function serves as a deposit function, logs deposit address and amount
  function () payable {
    if(!isAlive) revert(); //allows to 'kill' the contract
    Deposit(msg.sender, msg.value);
  }

  function killContract(){
    if(msg.sender != creator) revert(); //only owner can disable
    if(this.balance > 0) revert();  //can't disable if money still in contract
    
    isAlive = false;
  }
  // BEN Global Reps
  /////////////////////////////////////////////////////////////// 
  function addLocalRep(uint _regionID, address _localRep) onlyBENGlobal returns(bool success){
    
  }
  
  function addBenGlobal(address _beng) onlyBENGlobal returns(bool success){
    //TODO
  }
  
  function approveTx(uint8 _txID) onlyBENGlobal returns (bool success){
    //TODO
  }

  function rejectTx(uint8 _txID)  onlyBENGlobal returns (bool success){
    //TODO
  }
  ////////////////////////////////////////////////////////////////////
  //Region Reps
  function stageTx(address _reciever) returns(bool success){
    //TODO
  }

}