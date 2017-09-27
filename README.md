<h1> Airdrop Multisig </h1>

<h4> Index </h4>

<ol> 
<li> <a href="#deploy">Deploy</a>
<li> <a href="#regions">Regions</a>
<li> <a href="#reps"> Representatives</a>
<li> <a href="#stage">Stage a Tx</a>
<li> <a href="#confirm">Confirm a Tx</a>
<li> <a href="#events">Events API</a>
</ol>

<h2> Deploy </h2>
                                              
Use <a href='http://remix.ethereum.org/?#gist=23f01c3cfaae4612b8833454b15daabd'> this </a> to load the current multisig code into remix. Compile & Run using remix tools. 

To deploy on main net, make sure to switch remix to 'injected web3' and have your metamask set to main net ethereum. 


<h2 id="regions"> Regions </h2>
When deploying the contract, region 0 is automatically created as the approving authority.
Region 0 reps can add regions, add reps from any region, and confirm/deny transactions. 
They can also 0 out the pending tx list if it gets spammed.

<h2 id='reps'> Representatives </h2>