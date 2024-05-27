// SPDX-License-Identifier: MIT
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
