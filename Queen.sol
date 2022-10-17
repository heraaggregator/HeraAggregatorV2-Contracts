// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Queen is Ownable, ReentrancyGuard {
    bool public STATUS = true;
    bool private USE_NATIVE = true;
    event ChangedStatus(bool indexed status);
    event ChangedUseNative(bool indexed status);

    modifier checkStatus() {
        require(STATUS == true, "Contract Stopped!");
        _;
    }

    constructor() payable {}

    function changeStatus(bool _status) external onlyOwner {
        STATUS = _status;
        emit ChangedStatus(_status);
    }

    function changeNative(bool _status) external onlyOwner {
        USE_NATIVE = _status;
        emit ChangedUseNative(_status);
    }

    function getNative() internal view returns (bool) {
        return USE_NATIVE;
    }

    receive() external payable {}
}
