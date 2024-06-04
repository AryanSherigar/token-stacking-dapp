// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Address {
    /**
    * @dev Determines whether the specified address is a contract.
    *
    * This function checks if the `account` address contains bytecode.
    * An address is considered a contract if the length of its code is greater than 0.
    *
    * @param account The address to be checked.
    * @return bool Returns true if the address is a contract, false otherwise.
    */
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    /**
    * @dev Transfers a specified amount of Ether to a given payable address.
    * Reverts if the contract's balance is insufficient or if the transfer fails.
    *
    * @param recipient The address to which the Ether will be sent.
    * @param amount The amount of Ether (in wei) to send.
    */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient Fund");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "unable to make transaction, transaction reverted");
    }


    // This is a common utility function to call a contract through low level in solidity
    // This function down here does not contain the entire implementation
    // It is just calling a overloaded version of itself
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address : low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory){
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    )internal returns (bytes memory){
        return functionCallWithValue(target, data, value, "Address : Low-level call failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value, 
        string memory errorMessage
    )internal returns (bytes memory){
        require(address(this).balance>=value, "Insufficient Balance");
        require(isContract(target), "Address call to non contract");

        (bool success, bytes memory returndata) = target.call{value:value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }   

    function functionStaticCall(address target, bytes memory data) internal view returns(bytes memory) {
        return functionStaticCall(target, data, "Address : Low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns(bytes memory){
        require(isContract(target), "Address : Static call to non contract");
        
        //.staticcall is used to make low-level, read-only call to another contract
        //It also ensures that the state of the blockchain is not modified
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns(bytes memory){
        return functionDelegateCall(target, data, "Address : Low-level delegate-call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory){
        require(isContract(target), "Address: Delegate call to non contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns(bytes memory){
        if(success){
            return returndata;
        } else {

            if (returndata.length>0) {

                assembly{
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.9;


/**
 * @title Initializable
 * @dev Abstract contract for initializing contract instances.
 */
abstract contract Initializable {
    
    uint8 private _initialized;

    bool private _initializing; 

    event Initialized(uint8 version);

    /**
     * @dev Modifier to ensure initialization logic is only run once.
     */
    modifier initializer() {
        // Check if the contract is being initialized for the first time or if it's being reinitialized.
        bool isTopLevelCall = !_initializing;

        require(
            (isTopLevelCall && _initialized < 1) ||
            (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: Contract is already initialized."
        );

        _initialized = 1;

        if (isTopLevelCall) {
            _initializing = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev Modifier to ensure reinitialization logic is only run once.
     * @param version The version of initialization.
     */
    modifier reinitializer(uint8 version) {
        require(
            _initializing && _initialized < version,
            "Initializable: Contract is already initialized."
        );

        _initialized = version;
        _initializing = true;

        _;

        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to ensure the contract is being initialized.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: Contract is not initializing.");
        _;
    }

    /**
     * @dev Internal function to disable further initialization.
     */
    function _disableInitializer() internal virtual {
        require(!_initializing, "Initializable: Contract is initializing.");

        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

pragma solidity ^0.8.9;

/**
 * @title Context
 * @dev Provides information about the current execution context, including the sender of the transaction and calldata.
 */
abstract contract Context {
    /**
     * @dev Returns the address of the sender of the current transaction.
     * @return The address of the sender.
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Returns the calldata of the current transaction.
     * @return calldata The calldata of the transaction.
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.9;



/**
 * @title Ownable
 * @dev Contract to manage ownership, providing functionality to transfer ownership and enforce access control.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Modifier to restrict functions to the current owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Retrieves the current owner address.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Internal function to verify if the caller is the current owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Allows the current owner to relinquish ownership of the contract.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Allows the current owner to transfer ownership to a new address.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Internal function to transfer ownership to a new address.
     * @param newOwner The address of the new owner.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.9;

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.9;

/**
 * @title ReentrancyGuard
 * @dev Contract to prevent reentrancy attacks by tracking the status of function calls.
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Initializes the contract setting the initial status to not entered.
     */
    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Modifier to prevent reentrancy attacks by ensuring a function is not being executed recursively.
     */
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.9;



pragma solidity ^0.8.9;

contract TokenStaking is Ownable, ReentrancyGuard, Initializable {

    struct User{
        uint256 stakeAmount; 
        uint256 rewardAmount;
        uint256 lastStakeTime;
        uint256 lastRewardCalculationTime;
        uint256 rewardsClaimedSoFar;
    }

    uint256 _minimumStakingAmount;
    
    uint256 _maxStakeTokenLimit;

    uint256 _stakeEndDate;

    uint256 _stakeStartDate;

    uint256 _totalStakedTokens;

    uint256 _totalUsers;

    uint256 _stakeDays;

    uint256 _earlyUnstakeFeePercentage;

    bool _isStakingPaused;

    address private _tokenAddress;

    uint256 _apyRate;

    uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
    uint256 public constant APY_RATE_CHANGE_THRESHOLD = 10;

    mapping (address => User) private _users;

    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);
    event EarlyUnstakeFee(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);

    modifier whenTreasuryHasBalance(uint256 amount) {
        require(
            IERC20(_tokenAddress).balanceOf(address(this))>=amount,
            "TokenStaking: insufficient funds in the treasury"
        );
        _;
    }

    /**
    * @dev Initializes the staking contract with the given parameters.
    * 
    * @param owner_ The owner of the contract.
    * @param tokenAddress_ The address of the token to be staked.
    * @param apyRate_ The annual percentage yield rate.
    * @param minimumStakingAmount_ The minimum amount required to stake.
    * @param maxStakeTokenLimit_ The maximum amount of tokens that can be staked.
    * @param stakeStartDate_ The start date for staking.
    * @param stakeEndDate_ The end date for staking.
    * @param stakeDays_ The number of days tokens must be staked.
    * @param earlyUnstakeFeePercentage_ The fee percentage for early unstaking.
    */
    function initialize(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) public virtual initializer {
        _TokenStakin_init_unchained(
            owner_,
            tokenAddress_,
            apyRate_,
            minimumStakingAmount_,
            maxStakeTokenLimit_,
            stakeStartDate_,
            stakeEndDate_,
            stakeDays_,
            earlyUnstakeFeePercentage_
        );
    }

    function _TokenStakin_init_unchained(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) internal onlyInitializing {
        require(_apyRate <= 10000, "TokenStaking: apy rate should be less than 10000");
        require(stakeDays_ > 0, "TokenStaking: stake days must be non-zero");
        require(tokenAddress_ != address(0), "TokenStaking: token address cannot be 0 address");
        require(stakeStartDate_ < stakeEndDate_, "TokenStaking: start date must be less than the end date");

        _transferOwnership(owner_);
        _tokenAddress = tokenAddress_;
        _apyRate =apyRate_;
        _minimumStakingAmount = minimumStakingAmount_;
        _maxStakeTokenLimit = maxStakeTokenLimit_;
        _stakeStartDate = stakeStartDate_;
        _stakeEndDate = stakeEndDate_;
        _stakeDays = stakeDays_* 1 days;
        _earlyUnstakeFeePercentage = earlyUnstakeFeePercentage_;
    }

    /* View Method Start */

    /**
     * @notice This function is used to get the minimum staking amount for program
     */
    function getMinimumStakingAmount() external view returns (uint256){
        return _minimumStakingAmount;
    }

    /**
     * @notice This function is used to get the maximum staking amount for program
     */
    function getMaxStakingAmount() external view returns (uint256){
        return _maxStakeTokenLimit;
    }

    /**
     * @notice This function is used to get the staking start date for program
     */
    function getStakeStartDate() external view returns (uint256){
        return _stakeStartDate;
    }

    /**
     * @notice This function is used to get the staking end date for program
     */
    function getStakeEndDate() external view returns (uint256){
        return _stakeEndDate;
    }

    /**
     * @notice This function is used to get the total no of tokens that are staked
     */
    function getTotalStakedTokens() external view returns (uint256){
        return _totalStakedTokens;
    }

    /**
     * @notice This function is used to get the total no of users
     */
    function getTotalUsers() external view returns (uint256){
        return _totalUsers;
    }

    /**
     * @notice This function is used to get the stake days
     */
    function getStakeDays() external view returns (uint256){
        return _stakeDays;
    }

    /**
     * @notice This function is used to get early unstake fee percentage
     */
    function getEarlyUnstakeFeePercentage() external view returns (uint256){
        return _earlyUnstakeFeePercentage;
    }

    /**
     * @notice This function is used to get staking status
     */
    function getStakingStatus() external view returns (bool){
        return _isStakingPaused;
    }

    /**
     * @notice This function is used to get the current APY Rate
     * @return Current APY Rate
     */
    function getAPY() external view returns (uint256){
        return _apyRate;
    }

    /**
     * @notice This function is used to get msg.sender's estimated reward amount
     * @return msg.sender's estimated reward amount
     */
    function getUserEstimatedRewards() external view returns (uint256){
        (uint256 amount, ) = _getUserEstimatedRewards(msg.sender);
        return _users[msg.sender].rewardAmount + amount;
    }

    /**
     * @notice This function is used to get withdrawable amount from contract
     */
    function getWithdrawableAmount() external view returns (uint256){
        return IERC20(_tokenAddress).balanceOf(address(this)) - _totalStakedTokens;
    }

    /**
     * @notice This function is used to get User's details
     * @param userAddress User's address to get details of
     * @return User Struct
     */
    function getUser(address userAddress) external view returns (User memory){
        return _users[userAddress];
    }

    /**
     * @notice This function is used to check if a user is a StakeHolder
     * @param _user Address of the user to check
     * @return True if user is a stakeholder, false otherwise
     */
    function isStakeHolder(address _user) external view returns (bool){
        return _users[_user].stakeAmount != 0;
    }

    /* View Methods End*/

    /* Owner Methods Start*/

    /**
     * @notice This function is used to update minimum Staking amount
     */
    function updateMinimumStakingAmount(uint256 newAmount) external onlyOwner {
        _minimumStakingAmount = newAmount;
    }

    /**
     * @notice This function is used to update maximum Staking amount
     */
    function updateMaximumStakingAmount(uint256 newAmount) external onlyOwner {
        _maxStakeTokenLimit = newAmount;
    }

    /**
     * @notice This function is used to update staking End date
     */
    function updateStakingEndDate(uint256 newDate) external onlyOwner {
        _stakeEndDate = newDate;
    }

    /**
     * @notice This function is used to update early unstake fee percentage
     */
    function updateEarlyUnstakeFeePercentage(uint256 newPercentage) external onlyOwner {
        _earlyUnstakeFeePercentage = newPercentage;
    }

    /**
     * @notice stake tokens for specific user
     * @dev this function can be used to stake tokens for specific user
     * 
     * @param amount the amount to stake
     * @param user user's address
     */
    function stakeForUser(uint256 amount, address user) external onlyOwner nonReentrant{
        _stakeTokens(amount, user);
    }

    /**
     * @notice enable/disable staking
     * @dev this function can be used to toggle staking status
     */
    function toggleStakingStatus() external onlyOwner{
        _isStakingPaused = !_isStakingPaused;
    }

    /**
     * @notice Withdraw the specified amount if possible
     * @dev this function can be used to withdraw the available tokens with this contract to the caller
     * 
     * @param amount the amount to withdraw
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant{
        require(this.getWithdrawableAmount() >= amount, "TokenStaking: not enough withdrawable tokens");
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    /* Owner Methods End */

    /* User Methods Start */

    /**
     * @notice This function is used to stake token
     * @param _amount Amount of token to be staked
     */
    function stake(uint256 _amount) external nonReentrant{
        _stakeTokens(_amount, msg.sender);
    }

    function _stakeTokens(uint256 _amount, address user_) private {
        require(!_isStakingPaused, "TokenStaking: staking is paused");

        uint256 currentTime = getCurrentTime();
        require(currentTime > _stakeStartDate, "TokenStaking: Staking is not started yet");
        require(currentTime < _stakeEndDate, "TokenStaking: Staking ended");
        require(_totalStakedTokens + _amount <= _maxStakeTokenLimit, "TokenStaking: max staking token limit reached");
        require(_amount > 0, "TokenStaking: stake amount should be greater than zero");
        require(_amount >= _minimumStakingAmount, "TokenStaking: stake amount must be greater than minimum amount allowed");

        if(_users[user_].stakeAmount != 0) {
            _calculateRewards(user_);
        } else {
            _users[user_].lastRewardCalculationTime = currentTime;
            _totalUsers += 1;
        }

        _users[user_].stakeAmount += _amount;
        _users[user_].lastStakeTime = currentTime;

        _totalStakedTokens += _amount;

        require(
            IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount),
            "TokenStaking: failed to tranfer tokens"
        );
        emit Stake(user_, _amount);
    }

    /**
     * @notice This function is used to unstake tokens
     * @param _amount Amount of tokens to be unstaked
     */
    function unstake(uint256 _amount) external nonReentrant whenTreasuryHasBalance(_amount){
        address user = msg.sender;

        require(_amount !=0, "TokenStaking: amount should be non-zero");
        require(this.isStakeHolder(user), "TokenStaking : not a stakeholder");
        require(_users[user].stakeAmount >= _amount, "TokenStaking: not enough stkae to unstake");

        //Calculate User's rewards untill now
        _calculateRewards(user);

        uint256 feeEarlyUnstake;

        if(getCurrentTime() <=_users[user].lastStakeTime + _stakeDays) {
            feeEarlyUnstake = ((_amount * _earlyUnstakeFeePercentage) / PERCENTAGE_DENOMINATOR);
            emit EarlyUnstakeFee(user, feeEarlyUnstake);
        }

        uint256 amountToUnstake = _amount - feeEarlyUnstake;

        _users[user].stakeAmount -= _amount;

        _totalStakedTokens -= _amount;

        if(_users[user].stakeAmount == 0){
            //delete _users[user];
            _totalUsers -= 1;
        }

        require(IERC20(_tokenAddress).transfer(user, amountToUnstake), "TokenStaking: failed to transfer");
        emit UnStake(user, _amount);
    }

    /**
     * @notice This function is used to claim user's rewards
     */
    function claimReward() external whenTreasuryHasBalance(_users[msg.sender].rewardAmount) {
        _calculateRewards(msg.sender);
        uint256 rewardAmount = _users[msg.sender].rewardAmount;

        require(rewardAmount > 0, "TokenStaking: no reward to claim");

        require(IERC20(_tokenAddress).transfer(msg.sender, rewardAmount), "TokenStaking: failed to transfer");

        _users[msg.sender].rewardAmount = 0;
        _users[msg.sender].rewardsClaimedSoFar += rewardAmount;

        emit ClaimReward(msg.sender, rewardAmount);
    }

    /* User Methods Ends */

    /* Private Helper Methods Start */

    /**
     * @notice This function is used to calculate rewards for a user.
     * @param _user Address of the user.
     */
    function _calculateRewards(address _user) private {
        (uint256 userReward, uint256 currentTime) = _getUserEstimatedRewards(_user);

        _users[_user].rewardAmount += userReward;
        _users[_user].lastRewardCalculationTime = currentTime;
    }

    /**
     * @notice This function is used to get estimated rewards for a user.
     * @param _user Address of the user.
     * @return Estimated rewards for the user.
     */
    function _getUserEstimatedRewards(address _user) private view returns(uint256, uint256){
        uint256 userReward;
        uint256 userTimeStamp = _users[_user].lastRewardCalculationTime;

        uint256 currentTime = getCurrentTime();

        if(currentTime > _users[_user].lastStakeTime + _stakeDays) {
            currentTime = _users[_user].lastStakeTime + _stakeDays;
        }

        uint256 totalStakedTime = currentTime - userTimeStamp;

        userReward += ((totalStakedTime = _users[_user].stakeAmount + _apyRate) / 365 days) / PERCENTAGE_DENOMINATOR;

        return(userReward, currentTime);
    }
    
    /**
     * @notice This function is used to get the current time.
     * @return Returns a the timestamp of the block.
     */
    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }


}

/**
 * @title MyToken
 * @dev A basic ERC20 token contract implementation.
 */
contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    string public standard = "MyToken v0.1";
    uint256 public totalSupply;
    address public ownerOfContract;
    uint256 public _userId;

    uint256 constant initialSupply = 1000000 * (10**18);

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

    /**
     * @dev Constructor to initialize the token contract.
     */
    constructor() {
        ownerOfContract = msg.sender;
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
    }

    /**
     * @dev Internal function to increment user ID.
     */
    function inc() internal {
        _userId++;
    }

    /**
     * @dev Transfer tokens from sender to a specified recipient.
     */
    function transfer(address _to, uint256 _value) public returns(bool success) {
        require(balanceOf[msg.sender] >= _value);
        inc();

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

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

    /**
     * @dev Approve the spender to spend a specified amount of tokens on behalf of the sender.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from a specified sender to a specified recipient on behalf of the sender.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Retrieve token holder data for a specified address.
     */
    function getTokenHolderData(address _address) public view returns(uint256, address, address, uint256, bool) {
        return (
            tokenHolderInfos[_address]._tokenId,
            tokenHolderInfos[_address]._to,
            tokenHolderInfos[_address]._from,
            tokenHolderInfos[_address]._totalToken,
            tokenHolderInfos[_address]._tokenHolder
        );
    }

    /**
     * @dev Retrieve all token holders.
     */
    function getTokenHolder() public view returns (address[] memory) {
        return holderToken;
    }
}


