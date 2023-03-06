// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Utils {

    function getStorageSelector(address targetContract, string storageVariableName) pure returns (bytes4 storageHash){
        storageHash = bytes4(keccak256(string(targetContract) + storageVariableName));
    }
}
