// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IHeraFeeSequencer {
    function getAmountWithFee(
        address account,
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amountInWithFee, uint256 protocolFee);
}