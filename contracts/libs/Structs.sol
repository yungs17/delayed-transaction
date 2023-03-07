// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Structs {
    struct Data {
        address targetAddress;
        bytes4 targetSelector;
        bytes arguments;
    }

    struct Condition {
        address creator;
        uint256 created;
        bool resolved;
        bytes conditionDataEncoded;
        bytes[] readFunctionDataEncoded;
    }

    struct Delta {
        address creator;
        uint256 created;
        bool resolved;
        bytes stateData;
        bytes deltaData;
    }

    struct ConditionDelta {
        uint256 id;
        Condition condition;
        Delta delta;
    }

    function encodeData(
        Data calldata data
    ) external pure returns (bytes memory) {
        return
            abi.encode(data.targetAddress, data.targetSelector, data.arguments);
    }

    function decodeData(
        bytes calldata encodedData
    ) external pure returns (Data memory) {
        (
            address _targetAddress,
            bytes4 _targetSelector,
            bytes memory _arguments
        ) = abi.decode(encodedData, (address, bytes4, bytes));

        return Data(_targetAddress, _targetSelector, _arguments);
    }
}
