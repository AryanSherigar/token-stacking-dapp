// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Address.sol";

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
