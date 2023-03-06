// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library DeltaFactory {
    function addUint(
        uint256 state,
        uint256 delta
    ) public pure returns (uint256) {
        return state + delta;
    }

    function subUint(
        uint256 state,
        uint256 delta
    ) public pure returns (uint256) {
        require(state >= delta); // Make sure it doesn't return a negative value.
        return state - delta;
    }

    function replaceUint(uint256, uint256 delta) public pure returns (uint256) {
        return delta;
    }
}
