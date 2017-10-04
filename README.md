<h1> Airdrop Multisig </h1>

<h4> Index </h4>

<ol> 
<li> <a href="#deploy">Deploy</a>
<li> <a href="#regions">Regions</a>
<li> <a href="#reps"> Representatives</a>
<li> <a href="#stage">Stage a Tx</a>
<li> <a href="#confirm">Confirm a Tx</a>
<li> <a href="#api">Contract API</a>
<li> <a href="#events">Events API</a>
</ol>

<h2> Deploy </h2>
                                              
Use <a href='http://remix.ethereum.org/?#gist=23f01c3cfaae4612b8833454b15daabd'> this </a> to load the current multisig code into remix. Compile & Run using remix tools. 

To deploy on main net, make sure to switch remix to 'injected web3' and have your metamask set to main net ethereum. 

<h2 id="regions"> Regions </h2>
Regions are local chapters that request crypto for airdrops. Regions maintain data about what representatives they have (only these people are allowed to create new transactions),how much they are allowed to spend and how much they have spent already. 

New regions can be added using the addRegion() method by a BEN Global admin. When deploying the contract, region 0 is automatically created as the approving authority and designated with the BEN Global tag.

Region 0 reps can add regions, add reps from any region, and confirm/deny transactions. They can also clear out the pending tx list if it gets spammed.

<h2 id='reps'> Representatives </h2>
Every region has a mapping of representatives. Only BEN G reps can add reps to other regions. Reps can can stage transactions. 

<h2 id="stage"> Stage a TX </h2>
Represenatives from a chapter can stage transactions by calling the stageTX() function with the address of the person they want to send eth to, as well as the amount (in WEI! -- use a web app to auto convert before doing the function call). 

1.000 ETH = 1000000000000000000 Wei,
0.017 ETH =   17000000000000000 Wei (~$5 at $300/Eth)

A staged TX must have an AMT that doesn't exceed the allowance of the region. The spent eth is also kept around.  

<h2 id="confirm"> Confirming a TX </h2>
A BEN rep can stay up to date on which transactions are occuring by watching the TxStaged events feed. They can then approve the TX from their end as well. When a BENG rep confirms a tx (using the confirm() method) the eth is sent from the contract to the receiver.  

BENG reps can also reject a TX or clear them all out if theres any leftover ones / wrong ones. 
</h2>

<h3 id="api">Contract API</h2>

Structs: 
  <ul>
    <li> Region:
      <ul>
        <li> uint idx: index of this region in the regions[] array ***not used for anything currently, but useful if reverse mapping
        <li> bytes32 tag: a string tag for the region. 'BEN Global' for instance. 
        <li> mapping(address => bool) reps: mapping of addresses to true/false. true if that address is a rep, false otherwise. 
        <li> uint allowance: the total amount, in WEI, that the region is allowed to spend
        <li> uint spent: the confirmed total amount the region has spent
        <li> uint pending: the pending amount in uncofirmed tx's that the region has outstanding. 
      </ul>
    <li> MultiTx
      <ul>
        <li> uint idx: idx of the tx in transactions[] list. 0 if its a rejected transaction
        <li> uint regionIDX: the idx of the region in the regions[] array that issued the tx
        <li> uint amount: the amount in WEI that the tx wants to send out
        <li> address localrep: the address of the representative that issued the tx
        <li> address receiver: the address of the receipient of the eth 
        <li> address approvedBy: the address of the admin representative that confirmed the tx. 0x0 if unconfirmed
      </ul>
  </ul>

Variables:
  <ul>
    <li> bool isAlive: determines if the contract is accepting funds or not. Cannot kill the contract if theres money still in the contract. So no new funds also means no more transactions that can be done. 
    <li> address creator: the address of the person who published the contract
    <li> Region[] regions: the list of regions the contract keeps track off. Regions can be 'removed' by setting their allowance to 0. 
    <li> MultiTx[] transactions: list of all transactions. Pending, Rejected, and Accepted transactions all live in this list. There's no good way to garbage collect, but if size grows too large, we can use clearTx() function  to clear the list. The logs of all tx still stored, but actual storage space will be freed up.
  </ul>

  bool isAlive: 
  address creator:
  Region[] regions:
  MultiTx[] transactions: 

Modifiers: 
  <ul>
    <li>isRep(uint regID): Checks to make sure that the person calling the function is a representative of a given region. Used to provide access control to 'admin' functions such that they are restricted to region 0 (BEN Global). Also used to check that function callers to proposing new tx are allowed to stage that tx (can't make a tx for a different region than the one you belong to)
    <li>amtAllowed(uint regID, uint amount): checks to make sure that the amount is within the regions' allowance. Reg 0 (BEN G) shortcuts this check as it's allowance is unlimited. 
  </ul>

  
Meta Functions:
<ul>
  <li> MultiSig(): Contract constructor. Sets the creator address, push ben global as region 0 (admin region), and push the Reject Tx 0 (id=0 used to reject tx). 
  <li> (): fallback function. payable such that anyone can deposit money into the contract AS LONG AS isAlive is true. 
  <li> killContract(): checks to make sure all money has been cashed out of the contract and disables the contract from accepting any more money deposits. 
</ul>
Admin Functions (only reps from Region 0 (BEN Global) can call these:
<ul>
  <li> addRegion(bytes32 tag, uint256 weiAllowance): Adds a new region with a given allowance and tag. 
  <li> disableRegion(uint regID): disables the given region by setting the allowance to whatever they've already spent. This stops them from being able to stage any new transactions. 
  <li> enableRegion(uint regID, uint newAllowance): region renabled by setting their new allowance at some value greater than thier already spent $ thus allowing them to continue doing transactions. 
  <li> addRep(uint regID, address localrep): sets the address of the local rep to be true in region's reps mapping. 
  <li> removeRep(uint regID, address localrep): sets the address of the local rep to be false in the region's reps mappping
  <li> confirm(uint _txID): confirms a staged tx and transfers value from the contract to the receiver. 
  <li> reject(uint _txID): rejects a staged Tx by setting the decisionBy attribute to !0x0 
  <li> clearTx(): clears the transactions list of all transactions. you can still access logs of them but list is cleared for garbage collecting from storage.
</ul>
Public Functions
<ul>
  <li>stageTx(uint regID, address receiver, uint amountInWei): any region rep can propose a new tx as long as it's within their region's allowance. 
  <li>getRegionTag(uint regID): returns the bytes32 representation of the string representation their region 'name' 
  <li> getRegionSpent(uint regID): returns the amount any region has spent.
  <li> getRegionAllowance(uint regID): return region total allowance
  <li> getRegionPending(uint regIDX): return amount in pending transactions for a region
</ul>

<h2 id="#events">Events API </h2>
event Deposit     (address indexed from,  uint value); <br />
event RegionAdded (address indexed addedBy, uint indexed _regIDX, bytes32 _tag);<br />
event RegDisabled  (address indexed removedBy, uint indexed _regIDX);<br />
event RegEnabled  (address indexed enabledBy, uint indexed _regIDX, uint _newAllowance);<br />
event RepAdded    (address indexed addedBy, uint indexed _regIDX, address _repAddr);<br />
event RepRemoved  (address indexed removedBy, uint indexed _regIDX, address _repAddr);<br />
event TxAdded     (uint indexed _txID, uint indexed _regIDX, address indexed _repAddr);<br />
event TxConfirmed  (uint indexed _txID, uint amount, address indexed receiver, address indexed decisionBy);<br />
event TxReject    (uint indexed _txID, address indexed rejectedBy);<br />
event TxCleared   (address _benG, uint _txClearedCount);<br />

<h2> Future Refactoring </h2>
<ol>
  <li> Allow reps from a given region to add more reps in that region
  <li> Allow reps from a given region to remove staged TX from that region
</ol>