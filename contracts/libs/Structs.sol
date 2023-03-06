// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Structs {
    struct TargetAddressFunction {
        address targetAddress;
        bytes4 targetFunctionSelector;
        bytes arguments;
    }

    struct Condition {
        address creator;
        uint256 created;
        TargetAddressFunction[] targetAddressFunctions;
        address conditionAddress;
        bytes4 conditionSelector;
        bytes data;
        bool resolved;
    }

    struct Delta {
        address creator;
        uint256 created;
        address targetAddress;
        bytes4 targetStateSelector;
        address deltaAddress;
        bytes4 deltaSelector;
        bytes arguments;
        bool resolved;
    }

    struct ConditionDelta {
        uint256 id;
        Condition condition;
        Delta delta;
    }
}
