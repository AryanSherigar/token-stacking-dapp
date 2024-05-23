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

    function intialize(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) public virtual intializer {
        _TokenStakin_init_unchained(
            owner_,
            tokenAddress_,
            apyRate_,
            minimumStakingAmount_,
            maxStakeTokenLimit_,
            stakeStartDate,
            stakeEndDate,
            stakeDays,
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
        require(_apyRate <=10000, "TokenStaking: apy rate should be less than 10000");
        require(stakeDays_ >0, "TokenStaking: stake days must be non-zero");
        require(tokenAddress_ != address(0), "TokenStaking: token address cannot be 0 address");
        require(stakeStartDate_ < stakeEndDate_, "TokenStaking: start date must be less than the end date");

        _transferOwnership(owner);
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
        return _maxStakingAmount;
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
    function getStakingStatus() external view returns (uint256){
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
    function getUserEstimatedRwards() external view returns (uint256){
        (uint256 amount, ) = _getUserEstimatedRewards(msg.sender);
        return _users[msg.sender].rewardAmount + amount;
    }

    /**
     * @notice This function is used to get withdrawable amount from contract
     */
    function getWithdrawableAmount() external view returns (uint256){
        return IERC20(_tokenAddress).balanceOf(address(this)) - totalStakedTokens;
    }

    /**
     * @notice This function is used to get User's details
     * @param userAddress User's address to get details of
     * @return User Struct
     */
    function getUser(address userAddress) external view returns (User memory){
        return _users[userAddress]
    }

    /**
     * @notice This function is used to check if a user is a StakeHolder
     * @param _user Address of the user to check
     * @return True if user is a stakeholder, false otherwise
     */
    function isStakeHolder(address _user) external view returns (bool){
        return _user[_user].stakeAmount != 0;
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
        _maxStakingAmount = newAmount;
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

    




}