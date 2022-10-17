// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IHeraPowerCompiler {
    function getUserPower(address user) external view returns (uint256 power);
}
