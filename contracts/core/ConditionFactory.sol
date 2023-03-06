// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libs/Structs.sol";

library ConditionFactory {
    enum Compare {
        EQUAL,
        NOT_EQUAL,
        GREATER,
        GREATER_EQUAL
    }

    function createBalanceChecker(
        address targetDERC20Contract,
        address targetBalanceAddress,
        uint256 criterion,
        Compare compare
    ) public view returns (Structs.Condition memory) {
        //
        //TODO: check ideltabase,compare,target 컨트랙이 해당 함수(balanceOf) 지원하는지

        bytes memory arguments = abi.encodePacked(targetBalanceAddress);

        Structs.TargetAddressFunction
            memory firstTargetAddressFunction = Structs.TargetAddressFunction({
                targetAddress: targetDERC20Contract,
                targetFunctionSelector: bytes4(keccak256("balanceOf(address)")),
                arguments: arguments
            });

        Structs.TargetAddressFunction[]
            memory _tempArr = new Structs.TargetAddressFunction[](1);
        _tempArr[0] = firstTargetAddressFunction;

        Structs.Condition memory newCondition = Structs.Condition({
            creator: msg.sender,
            created: block.timestamp,
            targetAddressFunctions: _tempArr,
            conditionAddress: address(this),
            conditionSelector: bytes4(
                keccak256("balanceChecker(address,address,uint256,uint8)")
            ),
            data: abi.encodeWithSignature(
                "balanceChecker(address,address,uint256,uint8)",
                targetDERC20Contract,
                targetBalanceAddress,
                criterion,
                compare
            ),
            resolved: false
        });

        return newCondition;
    }

    function balanceChecker(
        address targetDERC20Contract,
        address targetBalanceAddress,
        uint256 criterion,
        Compare compare
    ) external view returns (bool) {
        //TODO: check targetDERC20Contract.supportsInterface(IDERC20);

        (bool success, bytes memory data) = targetDERC20Contract.staticcall(
            abi.encodeWithSignature("balanceOf(address)", targetBalanceAddress)
        );

        if (success) {
            uint256 _balance = abi.decode(data, (uint256));
            if (_compareUint(_balance, criterion, compare)) {
                return true;
            } else return false;
        } else revert("failed");
    }

    function _compareUint(
        uint a,
        uint b,
        Compare compare
    ) internal pure returns (bool) {
        if (compare == Compare.EQUAL) {
            return a == b;
        } else if (compare == Compare.NOT_EQUAL) {
            return a != b;
        } else if (compare == Compare.GREATER) {
            return a > b;
        } else {
            return a >= b;
        }
    }
}
