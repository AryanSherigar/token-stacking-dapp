// SPDX-License-Identifier: MIT
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
