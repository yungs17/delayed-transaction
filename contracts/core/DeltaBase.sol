// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract DeltaBase {

    event ConditionDeltaRegistered(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaCancelled(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaModified(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaApplied(uint256 id, bytes4 writeFunctionSign);
    event ConditionDeltaReverted(uint256 id, bytes4 writeFunctionSign);

    struct Condition {
        uint256 id;
        address contractAddress;
        bytes4 functionSignature;
    }

    struct Delta {
        uint256 id;
        address contractAddress;
        bytes4 functionSignature;
    }

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


    function lazyEvaluate() internal virtual returns (bool) {
        //TODO: iterate through past condition-delta and lazy evaluate i.e. "write"
        // 컨디션델타 어레이 이터레이트해서 각 로직 따라 처리해서 write하는 함수
        // return false if failure

        // 이거 무조건 앞두로 두번해야될수도. 내가 넣은 트랜잭션이 condition 발동시켯냐 안시켯냐 처리.
        // 둘 중 하나. 상태 변경시킬 때 컨디션들에만 체크를 해놓을지, 아님 delta반영까지 해줄지.
        // delta반영은 그 target을 사용할 일이 있을 때만 반영해도 되고.
        // 근데 만약 후자로 한다면, 굳이 read할 때 컨디션 검사를 안해줘도 된다. 그냥 state를 읽어와줘도 될듯.
        // 완전 publisher - listener 형태로 처리하는 셈.
        // 즉, 상태를 변경하는 행동이 publishing하는 셈이고, listener가 조건들.

        return true;
    }


}
