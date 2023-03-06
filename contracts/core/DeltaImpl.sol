// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IDeltaImpl.sol";

contract DeltaBase is IDeltaBase {
    function lazyEvaluate() internal virtual returns (bool) {
        //TODO: iterate through past condition-delta and lazy evaluate i.e. "write"

        return true;
    }

    function createDelta(
        address targetAddress,
        bytes4 targetStateSelector,
        address deltaAddress,
        bytes4 deltaSelector,
        bytes dataWithoutState
    ) internal view virtual override returns (Structs.Delta memory newDelta) {
        newDelta = Structs.Delta({
            creator: msg.sender,
            created: block.timestamp,
            targetAddress: targetAddress,
            targetStateSelector: targetStateSelector,
            deltaAddress: deltaAddress,
            deltaSelector: deltaSelector,
            dataWithoutState: dataWithoutState,
            resolved: false
        });
    }

    function registerConditionDelta(
        Structs.ConditionDelta[] stateWithDelta
    ) external virtual override {}
}
