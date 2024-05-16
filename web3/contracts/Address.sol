// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Address {
    //checks if the length of the bytecode of the address is more than zero
    //.code is used to convert the address datatype to bytecode
    function isContract(address account) internal view returns (bool) {
        return address.code.length > 0;
    }

    function sendValue(address payable recipent, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient Fund");

        (bool success, ) = recipent.call{value: amount}("");
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
        return functionCallWithValue(target, data, 0, errorMessage)
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
        require(isContract(target),"Address call to non contract");

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

    function functionDelegateCall(address target, bytes memory data) internal view returns(bytes memory){
        return functionDelegateCall(target, data, "Address : Low-level delegate-call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal view returns(bytes memory){
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
