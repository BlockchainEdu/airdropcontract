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
  Region:
  MultiTX:

Variables:
  bool isAlive: 
  address creator:
  Region[] regions:
  MultiTx[] transactions: 

Modifiers: 
  isRep(uint _regIDX):
  amtAllowed(uint _regIDX, uint _amt):

Functions:
  Contract Functions:
    MultiSig():
    fallback(): 
    killContract():

  BEN Global Functions:
    addRegion():
    removeRegion():
    addRep():
    removeRep():
    confirm():
    reject():
    clearTx():

  Public Functions: 
    stageTx(): 
    getRegionTag():
    getRegionSpent():
    getRegionAllowance():


<h2> Future Refactoring </h2>
<ol>
  <li> Allow reps from a given region to add more reps in that region
  <li> Allow reps from a given region to remove staged TX from that region
</ol>