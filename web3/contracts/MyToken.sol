// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    string public standard ="MyToken v0.1";
    uint256 public totalSupply;
    address public ownerOfContract;
    uint256 public _userId;

    uint256 constant intialSupply = 1000000 * (10**18);

    address[] public holderToken;

    event Transfer(address indexed _from, address indexed_to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping (address => TokenHolderInfo) public tokenHolderInfos;

    struct TokenHolderInfo {
        uint256 _tokenId;
        address _from;
        address _to;
        uint256 _totalToken;
        bool _tokenHolder;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    constructor(){
        ownerOfContract = msg.sender();
        balanceOf[msg.sender] = intialSupply;
        totalSupply = intialSupply;
    }

    function inc() internal {
        _userId++;
    }

    function transfer(address _to, uint256 _value) public returns(bool success){

        require(balanceOf[msg.sender] >=_value);
        inc();

        balanceOf[msg.sender] -=value;
        balanceOf[_to] +=value;

        TokenHolderInfo storage tokenHolderInfo = tokenHolderInfos[_to];

        tokenHolderInfo._to = _to;
        tokenHolderInfo._from = msg.sender;
        tokenHolderInfo._totalToken = _value;
        tokenHolderInfo._tokenHolder = true;
        tokenHolderInfo._tokenId = _userId;

        holderToken.push(_to);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;

    }

    function approve(address _spender, uint256 _value) public returns (bool success){

        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom {
        address _from, address_to, uint256 _value
    } public returns (bool success){

        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= value;
        balanceOf[_to] += value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function getTokenHolderData(address _address) public view returns( 
        uint256,
        address,
        address,
        uint256,
        bool
    ){
        return(
            tokenHolderInfos[_address].tokenId,
            tokenHolderInfos[_address]._to;
            tokenHolderInfos[_address]._from;
            tokenHolderInfos[_address]._totalToken;
            tokenHolderInfos[_address]._tokenHolder
        );
    }

    function getTokenHolder() public view returns (address[] memory){
        return holderToken;
    }


}