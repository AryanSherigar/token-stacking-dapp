// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Initializable.sol";
import "./IERC20.sol";

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