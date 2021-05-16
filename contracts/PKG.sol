// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import './SafeMath.sol';

contract PKG {
    using SafeMath for uint256;
    enum PackageState { PROPOSED, ACCEPTED, DELIVERED, CANCELLED }
    struct Package {
        uint pkgId;
        address payable from;
        address to;
        address payable channel;
        uint256 maxVal;
        uint256 bid;
        string annotations;
        PackageState state;  
    }
    uint packageId = 0;
    mapping (address => uint[]) public proposals;
    mapping (uint => Package) public packages;

    event Propose(uint pkgId, address by);
    event Bid(uint pkgId, address by, uint amount);
    event Accept(uint pkgId, address by, address bidder, uint amount);
    event Deliver(uint pkgId, address receivedBy, address deliveredBy);
    event Cancel(uint pkgId, address canceledBy, string reason);
    event Revert(uint pksId, address to, uint amount);

    modifier balanceCheck() {
        require(msg.sender.balance >= msg.value);
        _;
    }

    modifier packageExists(uint pkgId) {
        require(packages[pkgId].from != address(0), "package not found");
        _;
    }

    modifier checkState(uint pkgId, PackageState state) {
        require(packages[pkgId].state == state, 'invalid state of package');
        _;
    }

    modifier checkBid(uint pkgId, uint256 amount) {
        require(packages[pkgId].maxVal >= amount, 'max package value exceeded');
        require(amount > 0, 'zero bid value invalid');
        require(amount < packages[pkgId].bid, 'Value more than current lowest bid');
        _; 
    }

    modifier onlyProposer(uint pkgId) {
        require(packages[pkgId].from == msg.sender, 'only proposer can accept');
        _;
    }

    modifier onlyReceiver(uint pkgId) {
        require(packages[pkgId].to == msg.sender, 'only receiver can accept');
        _;
    }

    // function random() internal returns(uint) 
    // {
    // // increase nonce

    // return uint(keccak256(abi.encodePacked(now, 
    //     msg.sender, 99))) % 10000;
    // }


    function propose(address payable to, string memory annotations)
    balanceCheck
    public payable 
    returns(Package memory) {
        packageId += 1;
        packages[packageId] = Package(packageId, payable(msg.sender), to, payable(address(0)), msg.value, msg.value, annotations, PackageState.PROPOSED);
        proposals[msg.sender].push(packageId);
        emit Propose(packageId, msg.sender);
        return packages[packageId];
    }

    function bid(uint pkgId, uint amount)
    // packageExists(pkgId)
    checkState(pkgId, PackageState.PROPOSED)
    checkBid(pkgId, amount)
    public
    returns(Package memory) {
        packages[pkgId].bid = amount;
        packages[pkgId].channel = payable(msg.sender);
        emit Bid(pkgId, msg.sender, amount);
        return packages[pkgId];
    }


    function accept(uint pkgId)
    public
    packageExists(pkgId)
    onlyProposer(pkgId)
    checkState(pkgId, PackageState.PROPOSED)
    returns(Package memory) {
        require(packages[pkgId].channel != address(0), 'no bids placed yet');
        
        packages[pkgId].state = PackageState.ACCEPTED;

        emit Accept(pkgId, msg.sender, packages[pkgId].channel, packages[pkgId].bid); 
        
        return packages[pkgId];
    }

    function cancel(uint pkgId, string memory reason)
    public
    packageExists(pkgId)
    onlyProposer(pkgId)
    checkState(pkgId, PackageState.PROPOSED)
    returns(Package memory) {
        packages[pkgId].state = PackageState.CANCELLED;
        packages[pkgId].annotations = (reason);
        // refund the money
        packages[pkgId].from.transfer(packages[pkgId].maxVal);
        
        emit Cancel(pkgId, msg.sender, reason);
        emit Revert(pkgId, packages[pkgId].from, packages[pkgId].maxVal);
        
        return packages[pkgId];
    }

    function deliver(uint pkgId)
    public payable
    packageExists(pkgId)
    onlyProposer(pkgId)
    checkState(pkgId, PackageState.ACCEPTED)
    returns(Package memory) {
        packages[pkgId].state = PackageState.DELIVERED;
        // pay the money to deliverer
        packages[pkgId].channel.transfer(packages[pkgId].bid);
        // refund residue
        packages[pkgId].from.transfer(packages[pkgId].maxVal.sub(packages[pkgId].bid));

        emit Deliver(pkgId, msg.sender, packages[pkgId].channel);
        emit Revert(pkgId, packages[pkgId].from, packages[pkgId].maxVal.sub(packages[pkgId].bid));
        
        return packages[pkgId];
    }

    function getPackage(uint pkgId)
    public view
    packageExists(pkgId)
    returns(Package memory) {
        return packages[pkgId];
    }

    function getProposals()
    public view
    returns(uint[] memory) {
        return proposals[msg.sender];
    }
}