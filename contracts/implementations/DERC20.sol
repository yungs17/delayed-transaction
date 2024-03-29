// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../libs/Structs.sol";
import "../interfaces/IDeltaImpl.sol";
import "./IDERC20.sol";
import "../core/DeltaFactory.sol";

contract DERC20 is Context, IERC20Metadata, IDeltaImpl, IDERC20 {
    // static storage variables
    string private _name;
    string private _symbol;

    // original storage variables
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    // delta storage variables
    mapping(address => Structs.ConditionDelta[]) private _balancesWithDelta;
    mapping(address => mapping(address => Structs.ConditionDelta[]))
        private _allowancesWithDelta;
    Structs.ConditionDelta[] private _totalSupplyWithDelta;

    // mapping of read function selectors to storage variable selectors
    bytes4[] private _availableReads;
    mapping(bytes4 => bytes4[]) private _statesSelectors;

    // conditiondelta id count
    uint256 private count;

    // initialize mappings
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        // 0x18160ddd
        _availableReads.push(bytes4(keccak256("_totalSupply")));
        // 0x27e235e3
        _availableReads.push(bytes4(keccak256("_balances")));
        // 0xdd62ed3e
        _availableReads.push(bytes4(keccak256("_allowances")));

        _statesSelectors[IERC20.totalSupply.selector].push(_availableReads[0]);
        _statesSelectors[IERC20.balanceOf.selector].push(_availableReads[1]);
        _statesSelectors[IERC20.allowance.selector].push(_availableReads[2]);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        // TODO: implement condition checking

        return 1;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        Structs.Condition memory emptyCondition;
        return transfer(to, amount, emptyCondition);
    }

    function transfer(
        address to,
        uint256 amount,
        Structs.Condition memory condition
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount, condition);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        Structs.Condition memory emptyCondition;
        return approve(spender, amount, emptyCondition);
    }

    function approve(
        address spender,
        uint256 amount,
        Structs.Condition memory condition
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount, condition);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        Structs.Condition memory emptyCondition;
        return transferFrom(from, to, amount, emptyCondition);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount,
        Structs.Condition memory condition
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount, condition);
        _transfer(from, to, amount, condition);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        Structs.Condition memory emptyCondition;
        return increaseAllowance(spender, addedValue, emptyCondition);
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue,
        Structs.Condition memory condition
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(
            owner,
            spender,
            allowance(owner, spender) + addedValue,
            condition
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        Structs.Condition memory emptyCondition;
        return decreaseAllowance(spender, subtractedValue, emptyCondition);
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue,
        Structs.Condition memory condition
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(
                owner,
                spender,
                currentAllowance - subtractedValue,
                condition
            );
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount,
        Structs.Condition memory newCondition
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        // lazywrite _balances
        uint256 _balanceFrom = abi.decode(
            _lazyEvaluate(
                0x27e235e3,
                abi.encode(_balancesWithDelta[from]),
                _balancesWithDelta[from]
            ),
            (uint256)
        );

        uint256 _balanceTo = abi.decode(
            _lazyEvaluate(
                0x27e235e3,
                abi.encode(_balancesWithDelta[to]),
                _balancesWithDelta[to]
            ),
            (uint256)
        );

        _balances[from] = _balanceFrom;
        _balances[to] = _balanceTo;

        // it's okay to directly access storage variable since lazy eval has already been applied at lines above
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        //create delta and conditiondelta
        Structs.Delta memory newDeltaFrom = this.createDelta(
            address(this),
            0x27e235e3,
            address(DeltaFactory),
            bytes4(keccak256("subUint(uint256,uint256)")),
            abi.encode(amount)
        );

        Structs.Delta memory newDeltaTo = this.createDelta(
            address(this),
            0x27e235e3,
            address(DeltaFactory),
            bytes4(keccak256("addUint(uint256,uint256)")),
            abi.encode(amount)
        );

        Structs.ConditionDelta memory fromConditionDelta = this
            .createConditionDelta(newCondition, newDeltaFrom);
        Structs.ConditionDelta memory toConditionDelta = this
            .createConditionDelta(newCondition, newDeltaTo);

        // check condition and broadcast to read-needed states
        this.broadcastConditionDelta(fromConditionDelta);

        // register conditiondelta
        _registerConditionDelta(_balancesWithDelta[from], fromConditionDelta);
        _registerConditionDelta(_balancesWithDelta[to], toConditionDelta);

        //

        // TODO: emit ConditionDeltaRegistered();
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount,
        Structs.Condition memory condition
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount,
        Structs.Condition memory condition
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount, condition);
            }
        }
    }

    function supportsRead(
        bytes4 selector
    ) public view virtual override returns (bool) {
        for (uint i; i < _availableReads.length; i++) {
            if (_availableReads[i] == selector) {
                return true;
            }
        }
        return false;
    }

    function getAvailableReads()
        public
        view
        virtual
        override
        returns (bytes4[] memory)
    {
        return _availableReads;
    }

    function createDelta(
        address targetAddress,
        bytes4 targetStateSelector,
        bytes memory targetArguments,
        address deltaAddress,
        bytes4 deltaSelector,
        bytes memory deltaArguments
    ) external view virtual returns (Structs.Delta memory newDelta) {
        Structs.TargetAddressFunction memory t1 = Structs.TargetAddressFunction(
            targetAddress,
            targetStateSelector,
            targetArguments
        );

        Structs.TargetAddressFunction memory t2 = Structs.TargetAddressFunction(
            deltaAddress,
            deltaSelector,
            deltaArguments
        );

        newDelta = Structs.Delta({
            creator: _msgSender(),
            created: block.timestamp,
            target: t1,
            delta: t2,
            resolved: false
        });
    }

    function createConditionDelta(
        Structs.Condition memory condition,
        Structs.Delta memory delta
    ) external returns (Structs.ConditionDelta memory conditionDelta) {
        // TODO: implement base id counter
        conditionDelta = Structs.ConditionDelta(count, condition, delta);
        count += 1;
    }

    function registerConditionDeltaExternally(
        bytes4 conditionSelector,
        bytes memory arguments,
        Structs.ConditionDelta memory newConditionDelta
    ) external virtual override {
        // TODO: case문 사용해서 _registerConditionDelta 호출하기

        if (conditionSelector == IERC20.totalSupply.selector) {
            _registerConditionDelta(_totalSupplyWithDelta, newConditionDelta);
        }
        //
        else if (conditionSelector == IERC20.balanceOf.selector) {
            address account = abi.decode(arguments, (address));
            _registerConditionDelta(
                _balancesWithDelta[account],
                newConditionDelta
            );
        }
        //
        else if (conditionSelector == IERC20.allowance.selector) {
            (address owner, address spender) = abi.decode(
                arguments,
                (address, address)
            );
            _registerConditionDelta(
                _allowancesWithDelta[owner][spender],
                newConditionDelta
            );
        }
    }

    function _registerConditionDelta(
        Structs.ConditionDelta[] storage stateWithDelta,
        Structs.ConditionDelta memory newConditionDelta
    ) private {
        // TODO: handle priority and other pre-processing
        stateWithDelta.push(newConditionDelta);
    }

    function broadcastConditionDelta(
        Structs.ConditionDelta memory newConditionDelta
    ) external view virtual override {
        // 붙어야 할 곳 찾아서, 해당 stateWithDelta에 register 시켜주기
    }

    function _lazyEvaluate(
        bytes4 stateSelector,
        bytes memory stateEncoded,
        Structs.ConditionDelta[] storage stateWithDelta
    ) private view returns (bytes memory lazyState) {
        // TODO: 상태 iterate해서 staticcall로 direct 실행, 시간, 또는 view function에 따라 값을 읽어오든 말든 하고
        // 실행할 delta들 순서 priority 맞춰서 delta 반영해서 써주기
        // delta가 다른 곳일 수도 있음!

        if (stateSelector == 0x18160ddd) {
            // _totalSupply
            uint256 tempStateWithDelta = _totalSupply;

            for (uint i = 0; i < stateWithDelta.length; i++) {
                Structs.Condition storage condition = stateWithDelta[i]
                    .condition;
                Structs.Delta storage delta = stateWithDelta[i].delta;
                // check and apply

                (bool success, bytes memory canExecVal) = condition
                    .conditionAddress
                    .staticcall(
                        abi.encodeWithSelector(
                            condition.conditionSelector,
                            condition.data
                        )
                    );
                bool canExec = abi.decode(canExecVal, (bool));

                if (success && canExec) {
                    bytes memory concatArguments = abi.encode(
                        stateWithDelta,
                        delta.delta.arguments
                    );
                    (bool success2, bytes memory retVal) = delta
                        .deltaAddress
                        .staticcall(
                            abi.encodeWithSelector(
                                delta.delta.targetFunctionSelector,
                                concatArguments
                            )
                        );
                    if (success2) {
                        (tempStateWithDelta) = abi.decode(retVal, (uint256));
                    }
                }
            }
            lazyState = abi.encode(tempStateWithDelta);
        }
        //
        else if (stateSelector == 0x27e235e3) {
            // _balances
            uint256 tempBalance = abi.decode(stateEncoded, (uint256));
            uint256 tempStateWithDelta = tempBalance;
        }
        //
        else if (stateSelector == 0xdd62ed3e) {
            // _allowances
            uint256 tempAllowance = abi.decode(stateEncoded, (uint256));
            uint256 tempStateWithDelta = tempAllowance;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
