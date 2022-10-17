// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Queen.sol";
import "./interfaces/IHeraExecutor.sol";
import "./libraries/HeraERC20.sol";
import "./libraries/RevertReasonParser.sol";

contract HeraAggregatorV2 is Queen {
    using HeraERC20 for IERC20;
    using SafeMath for uint256;

    event Swapped(
        address sender,
        IERC20 inputToken,
        IERC20 outputToken,
        address dstAccount,
        address executor,
        uint256 spentAmount,
        uint256 returnAmount
    );

    struct Detail {
        IERC20 inputToken;
        IERC20 outputToken;
        address srcAccount;
        address dstAccount;
        uint256 amountIn;
        uint256 amountMinOut;
    }

    function Swap(
        IHeraExecutor executor,
        Detail calldata detail,
        bytes memory data
    ) public payable nonReentrant checkStatus returns (uint256 returnAmount) {
        return _swap(executor, detail, data);
    }

    function StableSwap(
        IHeraExecutor executor,
        Detail calldata detail,
        bytes memory data
    ) public payable nonReentrant checkStatus returns (uint256 returnAmount) {
        return _swap(executor, detail, data);
    }

    /// @notice Checking Slippage
    function _swap(
        IHeraExecutor executor,
        Detail calldata detail,
        bytes memory data
    ) internal returns (uint256 returnAmount) {
        require(detail.amountIn > 0, "AmountIn cannot be zero");
        require(detail.amountMinOut > 0, "AmountMinOut cannot be zero");
        require(data.length > 0, "Data cannot be zero");

        require(
            detail.srcAccount == msg.sender,
            "msg.sender and account must be the same"
        );

        (detail.inputToken).HeraTransferFrom(
            msg.sender,
            address(executor),
            detail.amountIn,
            msg.value,
            getNative()
        );

        uint256 initialBalance = (detail.outputToken).HeraBalanceOf(
            address(this)
        );

        if (
            detail.inputToken == detail.outputToken &&
            detail.inputToken.isNative()
        ) {
            initialBalance = initialBalance.sub(detail.amountIn);
        }

        {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory result) = executeCall(
                address(executor),
                msg.value,
                abi.encodeWithSelector(
                    IHeraExecutor.execute.selector,
                    abi.encode(
                        detail.srcAccount,
                        detail.inputToken,
                        detail.outputToken,
                        detail.amountIn
                    ),
                    data
                )
            );
            if (!success) {
                revert(RevertReasonParser.parse(result, "Executor Error: "));
            }
        }

        returnAmount = (detail.outputToken).HeraBalanceOf(address(this)).sub(
            initialBalance
        );

        require(
            returnAmount >= detail.amountMinOut,
            "ReturnAmount must be greater than AmountMinOut"
        );
        (detail.outputToken).HeraTransfer(
            payable(detail.dstAccount),
            returnAmount
        );

        emit Swapped(
            msg.sender,
            detail.inputToken,
            detail.outputToken,
            detail.dstAccount,
            address(executor),
            detail.amountIn,
            returnAmount
        );
    }

    function executeCall(
        address _target,
        uint256 _value,
        bytes memory _calldata
    ) internal returns (bool, bytes memory) {
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData;
        assembly {
            _success := call(
                gas(),
                _target,
                _value,
                add(_calldata, 0x20),
                mload(_calldata),
                0,
                0
            )

            _toCopy := returndatasize()
            mstore(_returnData, _toCopy)
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }

    function rescueFunds(IERC20 token, uint256 amount) external onlyOwner {
        token.HeraTransfer(payable(msg.sender), amount);
    }
}
