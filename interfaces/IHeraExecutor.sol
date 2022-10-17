// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IHeraExecutor {
    function execute(address sender,bytes memory datas) external payable;
}