// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libs/Structs.sol";

interface IDeltaImpl {
    event ConditionDeltaRegistered(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaCancelled(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaModified(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaApplied(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaReverted(uint256 id, bytes4 writeFunctionSign);

    function supportsRead(bytes4 selector) external view returns (bool);

    function getAvailableReads() external view returns (bytes4[] memory);

    function createDelta(
        address targetAddress,
        bytes4 targetStateSelector,
        address deltaAddress,
        bytes4 deltaSelector,
        bytes memory dataWithoutState
    ) external view returns (Structs.Delta memory);

    function createConditionDelta(
        Structs.Condition memory,
        Structs.Delta memory
    ) external pure returns (Structs.ConditionDelta memory);

    // use storage keyword
    function broadcastConditionDelta(
        Structs.ConditionDelta memory newConditionDelta
    ) external;

    function registerConditionDeltaExternally(
        bytes4 targetFunctionSelector,
        bytes memory arguments,
        Structs.ConditionDelta memory
    ) external;
}
