pragma solidity ^0.8.0;

library DeltaLibrary {
    // Condition template
    struct Condition {
        uint256 id;
        address contractAddress;
        bytes4 functionSignature;
    }

    // Delta template
    struct Delta {
        uint256 id;
        address contractAddress;
        bytes4 functionSignature;
    }

    // ConditionDelta template
    struct ConditionDelta {
        uint256 id;
        Condition condition;
        Delta delta;
    }

    function CreateDelta() internal returns(Delta delta){

    }

    function createCondition() internal returns(Condition condition){

    }

    function createConditionDelta() internal returns(ConditionDelta conditionDelta){

    }
}
