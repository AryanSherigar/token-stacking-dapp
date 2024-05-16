// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Address.sol";

abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing; // default value of bool is false in solidity.

    event Initialized(uint8 version);

    modifier intializer() {
        bool isTopLevelCall = !_intializing;

        require(
            (isTopLevelCall && _initialized < 1) ||
                (!Address.isContract(address(this)) && _intialized == 1),
            "Initilizable: Contract is already intialized."
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

    modifier reintializer(uint8 version) {
        require(
            _initializing && _intialized < version,
            "Initializable : Contract is already intialized"
        );

        _initialized = version;
        _initializing = true;

        _;

        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyIntializing() {
        require(_initializing, "Initializer : contract is not intialized");
        _;
    }

    function _disableIntializer() internal virtual {
        require(!_initializing, "Initializable : contract is initializing");

        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}
