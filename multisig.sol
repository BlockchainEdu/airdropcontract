pragma solidity ^0.4.15;

contract Multisig {


  struct MultiTx {
    uint    idx;        //set idx = 0 if rejected
    uint    regionIDX;  //index region in the regions[] array
    uint    amount;     //amount in wei to send //can't do eth cause decimal places require floats
    address localrep;   //address of the person that instantiated that transaction
    address receiver;   //address of the person reciving the eth
    address approvedBy; //0x0 if not approved yet, otherwise address of the benG rep that approved the tx 
  }

  struct Region {
    uint idx;                      //index of this region in the regions[] array
    bytes32 tag;                   //string tag for the region. 'chicago', 'uni south florida', etc
    mapping(address => bool) reps;  //using mapping instead of array for o1 lookup. true if <addr> is a rep, false otherwise 
    uint256 allowance;              //total allowance this region is allowed to spend in wei
    uint256 spent;                  //total amount this region has spent
  }
 
  bool isAlive = true;  // determines if the contract is alive/accepting funds or not
  address creator;      // 0xfd5e7D9B422b12022d1488710AA7a1d2F40bA0C4; //benglobal metamask 

  Region[] regions;       //list of regions. keys (int idx) useful to find all regions/do analytics on data
  MultiTx[] transactions; //no good way to garbage collect list removals, so both approved and staged tx exist in one array
                          //for quicker analytics use the EVENTS stream to find txs created and approved

////Events
  event Deposit     (address indexed from,  uint value);
  event RegionAdded (address indexed addedBy, uint indexed _regIDX, bytes32 _tag);
  event RepAdded    (address indexed addedBy, uint indexed _regIDX, address _repAddr);
  event TxAdded     (uint indexed _txID, uint indexed _regIDX, address indexed _repAddr);
  event TxApproved  (uint indexed _txID, uint amount, address indexed receiver, address indexed approvedBy);
  event TxReject    (uint indexed _txID, address indexed rejectedBy);
  event TxCleared   (address _benG, uint _txClearedCount);
////Modifiers
  modifier isRep(uint _regIDX){
    require(regions[_regIDX].reps[msg.sender] == true);
    _;
  }
  modifier isInAllowance(uint _regIDX, uint _amt){
    require(regions[_regIDX].allowance > (regions[_regIDX].spent + _amt));
    _;
  }

  
////Functions
  //Set Creator, Push BENG Chapter to regions, add msg.sender to beng reps
  function Multisig() public {
    creator = msg.sender; //set owner to whoever created the contract. used to widraw funds
    regions.push(Region({
      idx : 0,                 //should use regions.length but this is more clear and regions should be [] during initalization
      tag : "BENGlobal",       //tag is useful to figure out which regions are what if idx list is lost. 
      allowance : 0,           //auto initalized to 0 already, but better to state it and be clear about it. 0 == infinite allowance
      spent     : 0            //ben G spent. benG can initate tx as well as local reps
    }));
    regions[0].reps[msg.sender] = true;      
    
    //initalize the tx array with a tx in [0] so all future ids will be 1+
    //set id to 0 for any tx you want to reject
    transactions.push(MultiTx({
      idx: 0,
      regionIDX: 0,
      amount: 0,
      localrep: 0x0,
      receiver: 0x0,
      approvedBy: 0x0
    }));
  }

  // Fallback function serves as a deposit function, logs deposit address and amount
  function () external payable {
    if(!isAlive) revert(); //allows to 'kill' the contract
    Deposit(msg.sender, msg.value);
  }

  function killContract() public{
    if(msg.sender != creator) revert(); //only owner can disable
    if(this.balance > 0) revert();      //can't disable if money still in contract
    isAlive = false;
  }

  // BEN Global Reps Functions, modifier makes sure msg.sender is in benG approved reps
  /////////////////////////////////////////////////////////////// 
  function addRegion(bytes32 _tag, uint256 _weiAllowance) public isRep(0)  returns (uint _regIDX){
    _regIDX = regions.length;
    regions.push(Region({
      //reps(addr>bool) mapping and spent=0 init'd to defaults automatically
      idx : _regIDX, //current length should be max index + 1 so this works
      tag : _tag,
      allowance : _weiAllowance,
      spent: 0
    }));
    RegionAdded(msg.sender, regions.length, _tag);
    return _regIDX;
  }
  //function removeRegion()
  function addRep(uint _regionID, address _localRep) public isRep(0)  returns (bool){
    //only allow adding a local rep if msg.sender is a BENG rep
    regions[_regionID].reps[_localRep] = true;
    RepAdded(msg.sender, _regionID, _localRep);
    return true;
  }
  //function removeRep()
  function approve(uint _txID) public isRep(0)  returns (bool){
      if(transactions[_txID].idx == 0 && transactions[_txID].approvedBy != 0x0) {revert();}
      transactions[_txID].receiver.transfer(transactions[_txID].amount); //if this fails than the tx should remain pending, so the following code should not execute
      transactions[_txID].approvedBy = msg.sender;
      TxApproved(_txID, transactions[_txID].amount, transactions[_txID].receiver, msg.sender);
      return true;
  }
  function reject(uint _txID) public isRep(0) returns (bool) {
    if(transactions[_txID].approvedBy != 0x0) {revert();} //can't reject an already approved transaction
    transactions[_txID].idx = 0; //0 idx is for rejected transactions. 
    TxReject(_txID, msg.sender);
    return true; //was successful
  }
  //function rejectTx(uint _txID) isRep(0)  returns (bool success){}

  ////////////////////////////////////////////////////////////////////
  // open functions
  function stageTx(uint _regIDX, address _rec, uint256 _amtInWei) isRep(_regIDX) public returns(uint _txID){
    //modifiers: make sure that the rep is authorized, make sure amount is within thier alloance, and we still have that $ in our contract
    if(_amtInWei <= 0) { revert(); } //uint shouldn't be able to be negative but also 0 wei tx are excluded
    _txID = transactions.length;
    transactions.push(MultiTx({
      idx: _txID,
      regionIDX : _regIDX,
      localrep : msg.sender,
      receiver: _rec,
      amount: _amtInWei,
      approvedBy: 0x0     //serves as a 'staged' vs 'completed' check
    }));
    TxAdded(transactions[_txID].idx, _regIDX, msg.sender);
    return _txID;
  }
  function getRegionTag   (uint idx) public constant returns (bytes32)  { return regions[idx].tag;    }
  function getRegionSpent (uint idx)  public constant returns (uint256)  { return regions[idx].spent;  }
  function getRegionAllowance (uint idx) public constant returns (uint256) { return regions[idx].allowance; }
  function clearTx () public isRep(0) returns (uint) {
    uint totalTx = transactions.length;
    delete transactions;  //sets tx = []
    TxCleared(msg.sender, totalTx);
    return transactions.length;
  }
}  