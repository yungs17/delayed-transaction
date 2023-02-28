// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ConditionResolver {

    // method function selector => target contract view function selectors
    mapping(bytes4 => bytes4[]) private explicitSelectors;

    constructor(){
        //enum => uint8
        explicitSelectors[bytes4(keccak256("checkBalanceOf(address,address,uint256,uint8)"))] = [IERC20.balanceOf.selector];
    }

    enum Compare
    {
        EQUAL,
        NOT_EQUAL,
        GREATER,
        GREATER_EQUAL
    }

    function compareUint(uint a, uint b, Compare compare) returns (bool){
        if (compare == Compare.EQUAL) {
            return a == b;
        }
        else if (compare == Compare.NOT_EQUAL) {
            return a != b;
        }
        else if (compare == Compare.GREATER) {
            return a > b;
        }
        else {
            return a >= b;
        }
    }

    function getExplicitSelectors(bytes4 methodSelector) view returns(bytes4[]){
        return explicitSelectors[methodSelector];
    }

    function checkBalanceOf(address targetDERC20Contract, address targetAddress, uint256 criterion, Compare compare) view returns (bool){
        //TODO: handle exceptions
        //require targetDERC20Contract.supportsInterface(IDERC20);

        (bool success, uint256 balance) = targetDERC20Contract.staticcall(abi.encodeWithSelector(IERC20.balanceOf.selector, targetAddress));

        if (compareUint(balance, criterion, compare)) {
            return true;
        }
        else return false;

    }


}

