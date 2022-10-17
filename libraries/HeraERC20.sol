// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library HeraERC20 {
    using SafeMath for uint256;

    IERC20 private constant _NATIVE_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 private constant _ZERO_ADDRESS = IERC20(address(0));

    function isNative(IERC20 token) internal pure returns (bool) {
        return (token == _ZERO_ADDRESS || token == _NATIVE_ADDRESS);
    }
    
    function HeraBalanceOf(IERC20 token, address account)
        internal
        view
        returns (uint256)
    {
        if (isNative(token)) {
            return account.balance;
        } else {
            return token.balanceOf(account);
        }
    }

    function HeraTransfer(
        IERC20 token,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (isNative(token)) {
                to.transfer(amount);
            } else {
                _callOptionalReturn(
                    token,
                    abi.encodeWithSelector(token.transfer.selector, to, amount)
                );
            }
        }
    }

    function HeraProtocolTransfer(
        IERC20 token,
        address account,
        address payable to,
        uint256 protocolFee
    ) internal {
        uint256 amount = HeraBalanceOf(token,account);
        if (amount < protocolFee) {
            revert("Error: Protocol");
        }
        if (amount > 0) {
            if (isNative(token)) {
                to.transfer(amount);
            } else {
                _callOptionalReturn(
                    token,
                    abi.encodeWithSelector(token.transfer.selector, to, amount)
                );
            }
        }
    }

    function HeraTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 msg_amount,
        bool use_native
    ) internal {
        if (use_native && isNative(token)) {
            require(amount == msg_amount, "msg.value and amountIn must be the same");
        }
        else {
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.transferFrom.selector,
                    from,
                    to,
                    amount
                )
            );
        }
    }

    function HeraApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        require(!isNative(token), "Approve called on ETH");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(
            abi.encodeWithSelector(token.approve.selector, to, amount)
        );

        if (
            !success ||
            (returndata.length > 0 && !abi.decode(returndata, (bool)))
        ) {
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, to, 0)
            );
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, to, amount)
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "ERC20 operation did not succeed"
            );
        }
    }
}
