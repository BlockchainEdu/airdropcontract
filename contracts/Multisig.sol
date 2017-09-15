pragma solidity ^0.4.4;

contract Multisig {


  struct multiTx {
    uint8 regionIDX;    //index region in the regions[] array
    address localrep;   //address of the person that instantiated that transaction
    address receiver;   //address of the person reciving the eth
    uint256 amount;     //amount in wei to send //can't do eth cause decimal places require floats
    address approvedBy; //0x0 if not approved yet, otherwise address of the benG rep that approved the tx 
  }

  struct region {
    uint8 idx;                      //index of this region in the regions[] array
    bytes32 tag;                    //string tag for the region. 'chicago', 'uni south florida', etc
    mapping(address => bool) reps;  //using mapping instead of array for o1 lookup. true if <addr> is a rep, false otherwise 
    uint256 allowance;              //total allowance this region is allowed to spend in wei
    uint256 spent;                  //total amount this region has spent
  }
 
  bool isAlive = true;  // determines if the contract is alive/accepting funds or not
  address creator;      // 0xfd5e7D9B422b12022d1488710AA7a1d2F40bA0C4; //benglobal metamask 

  region[] regions;     //list of regions. keys (int idx) useful to find all regions/do analytics on data
  multiTx[] staged;     //no good way to garbage collect list removals, so both approved and staged tx exist in one array
                        //for quicker analytics use the EVENTS stream to find txs created and approved




////Events
  event Deposit(address indexed from, uint value);

////Modifiers
  modifier isRep(uint8 _regIDX){
    require(regions[_regIDX].reps[msg.sender] == true);
    _;
  }

////Functions
  //constructor sets the creator and initalizes benGlobalReps
  function Multisig(){
    creator = msg.sender; //set owner to whoever created the contract. used to widraw funds
    regions.push({
      idx = 0,                 //should use regions.length but this is more clear and regions should be [] during initalization
      tag = "BENGlobal",       //tag is useful to figure out which regions are what if idx list is lost. 
      reps[msg.senger] = true, //add msg.sender to the approved ben global list
      allowance = 0;           //auto initalized to 0 already, but better to state it and be clear about it. 0 == infinite allowance
      spent     = 0;           //ben G spent. benG can initate tx as well as local reps
    })      
  }

  // Fallback function serves as a deposit function, logs deposit address and amount
  function () payable {
    if(!isAlive) revert(); //allows to 'kill' the contract
    Deposit(msg.sender, msg.value);
  }

  function killContract(){
    if(msg.sender != creator) revert(); //only owner can disable
    if(this.balance > 0) revert();      //can't disable if money still in contract
    isAlive = false;
  }

  // BEN Global Reps Functions, modifier makes sure msg.sender is in benG approved reps
  /////////////////////////////////////////////////////////////// 
  function addRegion()
  function addLocalRep(uint8 _regionID, address _localRep)  isRep(0) returns(bool success){}
  function addBenGlobal(address _beng)                      isRep(0) returns(bool success){}
  function approveTx(uint8 _txID)                           isRep(0) returns (bool success){}
  function rejectTx(uint8 _txID)                            isRep(0) returns (bool success){}

  ////////////////////////////////////////////////////////////////////
  //Anyone rep can call this function
  function stageTx(address _reciever) returns(bool success){

  }

}