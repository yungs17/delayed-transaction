// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libs/Structs.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDERC20 is IERC20 {
    function transfer(
        address to,
        uint256 amount,
        Structs.Condition calldata condition
    ) external returns (bool);

    function approve(
        address spender,
        uint256 amount,
        Structs.Condition calldata condition
    ) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount,
        Structs.Condition calldata condition
    ) external returns (bool);
}
