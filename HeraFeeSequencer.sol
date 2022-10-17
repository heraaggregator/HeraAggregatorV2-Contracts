// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./interfaces/IHeraPowerCompiler.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract HeraFeeSequencer is AccessControl {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    bytes32 public constant MANAGER = keccak256("MANAGER");

    IHeraPowerCompiler public POWER_CONTRACT;

    bool public FEE_STATUS = true;
    bool public BLESSEDDAY_STATUS = false;
    bool public DYNAMIC_REDUCER = false;
    bool public DYNAMIC_STABLE_REDUCER = false;

    uint256 private constant PROTOCOL_MIN_FEE_RATE = 0;
    uint256 private constant PROTOCOL_MAX_FEE_RATE = 1000;

    uint256 public MIN_FEE_RATE = 100;
    uint256 public MAX_FEE_RATE = 300;
    uint256 public AMM_FEE_RATE = 300;

    uint256 public STABLE_MIN_FEE_RATE = 100;
    uint256 public STABLE_MAX_FEE_RATE = 300;
    uint256 public STABLE_FEE_RATE = 100;

    uint256 private DIVIDER = 100000;

    EnumerableSet.AddressSet private WHITELIST_ACCOUNTS;
    EnumerableSet.UintSet private RATE_LEVELS;
    EnumerableSet.AddressSet private STABLE_TOKENS;
    EnumerableSet.Bytes32Set private BLESSED_PAIRS;

    event RemovedWhitelistAccount(address indexed account);
    event AddedWhitelistAccount(address indexed account);
    event RemovedStableToken(address indexed token);
    event AddedStableToken(address indexed token);
    event ChangedBlessedDayStatus(bool indexed status);
    event ChangedDynamicStableReducer(bool indexed status);
    event ChangedDynamicReducer(bool indexed status);
    event ChangedFeeStatus(bool indexed status);
    event ChangedPowerContract(address indexed newContract, address exContract);
    event ChangedStableFeeRate(uint indexed feeRate);
    event ChangedStableMaxFeeRate(uint indexed maxFeeRate);
    event ChangedStableMinFeeRate(uint indexed minFeeRate);
    event ChangedAmmFeeRate(uint indexed feeRate);
    event ChangedMaxFeeRate(uint indexed maxFeeRate);
    event ChangedMinFeeRate(uint indexed minFeeRate);

    event RemovedBlessedPair(
        bytes32 indexed index,
        address tokenIn,
        address tokenOut
    );
    event AddedBlessedPair(
        bytes32 indexed index,
        address tokenIn,
        address tokenOut
    );

    event AddedLevelRate(uint indexed levelValue);
    event ChangedLevelRate(uint indexed newLevel, uint exLevel);
    event RemovedLevelRate(uint indexed levelValue);

    constructor(
        address admin,
        address manager,
        IHeraPowerCompiler _powerContract
    ) {
        POWER_CONTRACT = _powerContract;
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MANAGER, manager);
        RATE_LEVELS.add(0);
        RATE_LEVELS.add(200);
        RATE_LEVELS.add(400);
        RATE_LEVELS.add(600);
        RATE_LEVELS.add(800);
        RATE_LEVELS.add(10000);
    }

    function getAmountWithFee(
        address account,
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amountInWithFee, uint256 protocolFee) {
        uint256 rate;
        if (WHITELIST_ACCOUNTS.contains(account)) {
            amountInWithFee = amountIn;
        } else {
            if (FEE_STATUS) {
                if (BLESSEDDAY_STATUS) {
                    if (checkBlessed(tokenIn, tokenOut)) {
                        amountInWithFee = amountIn;
                    }
                }
                if (amountInWithFee == 0) {
                    rate = 0;
                    if (checkStableToken(tokenIn, tokenOut)) {
                        rate = checkStable(account);
                    } else {
                        rate = checkStandard(account);
                    }
                    protocolFee = amountIn.mul(rate).div(DIVIDER);
                    amountInWithFee = amountIn.sub(protocolFee);
                }
            } else {
                amountInWithFee = amountIn;
            }
        }
    }

    function checkStandard(address account) internal view returns (uint256) {
        if (DYNAMIC_REDUCER) {
            uint256 level = getLevel(account);
            uint levelCount = RATE_LEVELS.length().sub(2);
            return
                MIN_FEE_RATE.add(
                    MAX_FEE_RATE
                        .sub(MIN_FEE_RATE)
                        .mul(levelCount.sub(level))
                        .div(levelCount)
                );
        } else {
            return AMM_FEE_RATE;
        }
    }

    function checkStable(address account) internal view returns (uint256) {
        if (DYNAMIC_STABLE_REDUCER) {
            uint256 level = getLevel(account);
            uint levelCount = RATE_LEVELS.length().sub(2);
            return
                STABLE_MIN_FEE_RATE.add(
                    STABLE_MAX_FEE_RATE
                        .sub(STABLE_MIN_FEE_RATE)
                        .mul(levelCount.sub(level))
                        .div(levelCount)
                );
        } else {
            return STABLE_FEE_RATE;
        }
    }

    function checkBlessed(address tokenIn, address tokenOut)
        internal
        view
        returns (bool)
    {
        return
            BLESSED_PAIRS.contains(
                keccak256(abi.encodePacked(tokenIn, tokenOut))
            );
    }

    function getLevel(address account) public view returns (uint256 level) {
        uint256 power = POWER_CONTRACT.getUserPower(account);

        uint levelLength = RATE_LEVELS.length() - 1;
        for (uint i = 1; i < levelLength; i++) {
            if (power >= RATE_LEVELS.at(i) && power < RATE_LEVELS.at(i + 1)) {
                level = i;
                break;
            }
        }
        if (power >= RATE_LEVELS.at(levelLength)) {
            level = levelLength.sub(1);
        }
    }

    function checkStableToken(address tokenIn, address tokenOut)
        internal
        view
        returns (bool)
    {
        return
            STABLE_TOKENS.contains(tokenIn) && STABLE_TOKENS.contains(tokenOut);
    }

    function getBlessedTokens() external view returns (bytes32[] memory) {
        return BLESSED_PAIRS.values();
    }

    function addBlessedPair(address tokenIn, address tokenOut)
        external
        onlyRole(MANAGER)
    {
        bytes32 data = keccak256(abi.encodePacked(tokenIn, tokenOut));
        BLESSED_PAIRS.add(data);
        emit AddedBlessedPair(data, tokenIn, tokenOut);
    }

    function removeBlessedPair(address tokenIn, address tokenOut)
        external
        onlyRole(MANAGER)
    {
        bytes32 data = keccak256(abi.encodePacked(tokenIn, tokenOut));
        BLESSED_PAIRS.remove(data);
        emit RemovedBlessedPair(data, tokenIn, tokenOut);
    }

    function getLevelRates() external view returns (uint[] memory) {
        return RATE_LEVELS.values();
    }

    function addLevelRate(uint newLevel) external onlyRole(MANAGER) {
        RATE_LEVELS.add(newLevel);
        sortLevels();
        emit AddedLevelRate(newLevel);
    }

    function changeLevelRate(uint256 exdata, uint newdata)
        external
        onlyRole(MANAGER)
    {
        RATE_LEVELS.remove(exdata);
        RATE_LEVELS.add(newdata);
        sortLevels();
        emit ChangedLevelRate(exdata, newdata);
    }

    function removeLevelRate(uint value) external onlyRole(MANAGER) {
        RATE_LEVELS.remove(value);
        sortLevels();
        emit RemovedLevelRate(value);
    }

    function sortLevels() internal {
        uint[] memory tempValues = RATE_LEVELS.values();
        uint length = RATE_LEVELS.length();

        for (uint i = 0; i < length; i++) {
            RATE_LEVELS.remove(tempValues[i]);
        }

        for (uint i = 1; i < length; i++) {
            uint key = tempValues[i];
            uint j = i - 1;
            while ((int(j) >= 0) && (tempValues[j] > key)) {
                tempValues[j + 1] = tempValues[j];
                j--;
            }
            tempValues[j + 1] = key;
        }

        for (uint i = 0; i < length; i++) {
            RATE_LEVELS.add(tempValues[i]);
        }
    }

    function changeMinFeeRate(uint256 rate) external onlyRole(MANAGER) {
        if (rate >= PROTOCOL_MIN_FEE_RATE && rate <= PROTOCOL_MAX_FEE_RATE) {
            if (rate < MAX_FEE_RATE) {
                MIN_FEE_RATE = rate;
                emit ChangedMinFeeRate(rate);
            } else {
                revert("Out of Max Fee Rate");
            }
        } else {
            revert("Out of Fee Rate");
        }
    }

    function changeMaxFeeRate(uint256 rate) external onlyRole(MANAGER) {
        if (rate >= PROTOCOL_MIN_FEE_RATE && rate <= PROTOCOL_MAX_FEE_RATE) {
            if (rate > MIN_FEE_RATE) {
                MAX_FEE_RATE = rate;
                emit ChangedMaxFeeRate(rate);
            } else {
                revert("Out of Max Fee Rate");
            }
        } else {
            revert("Out of Fee Rate");
        }
    }

    function changeAmmFeeRate(uint256 rate) external onlyRole(MANAGER) {
        if (rate >= PROTOCOL_MIN_FEE_RATE && rate <= PROTOCOL_MAX_FEE_RATE) {
            AMM_FEE_RATE = rate;
            emit ChangedAmmFeeRate(rate);
        } else {
            revert("Out of Fee Rate");
        }
    }

    function changeStableMinFeeRate(uint256 rate) external onlyRole(MANAGER) {
        if (rate >= PROTOCOL_MIN_FEE_RATE && rate <= PROTOCOL_MAX_FEE_RATE) {
            if (rate < STABLE_MAX_FEE_RATE) {
                STABLE_MIN_FEE_RATE = rate;
                emit ChangedStableMinFeeRate(rate);
            } else {
                revert("Out of Max Fee Rate");
            }
        } else {
            revert("Out of Fee Rate");
        }
    }

    function changeStableMaxFeeRate(uint256 rate) external onlyRole(MANAGER) {
        if (rate >= PROTOCOL_MIN_FEE_RATE && rate <= PROTOCOL_MAX_FEE_RATE) {
            if (rate > STABLE_MIN_FEE_RATE) {
                STABLE_MAX_FEE_RATE = rate;
                emit ChangedStableMaxFeeRate(rate);
            } else {
                revert("Out of Max Fee Rate");
            }
        } else {
            revert("Out of Fee Rate");
        }
    }

    function changeStableFeeRate(uint256 rate) external onlyRole(MANAGER) {
        if (rate >= PROTOCOL_MIN_FEE_RATE && rate <= PROTOCOL_MAX_FEE_RATE) {
            STABLE_FEE_RATE = rate;
            emit ChangedStableFeeRate(rate);
        } else {
            revert("Out of Fee Rate");
        }
    }

    function changePowerContract(IHeraPowerCompiler powerAddr)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        address beforeAddr = address(POWER_CONTRACT);
        POWER_CONTRACT = powerAddr;
        emit ChangedPowerContract(address(powerAddr), beforeAddr);
    }

    function changeFeeStatus(bool status) external onlyRole(MANAGER) {
        FEE_STATUS = status;
        emit ChangedFeeStatus(status);
    }

    function changeDynamicReducer(bool status) external onlyRole(MANAGER) {
        DYNAMIC_REDUCER = status;
        emit ChangedDynamicReducer(status);
    }

    function changeDynamicStableReducer(bool status)
        external
        onlyRole(MANAGER)
    {
        DYNAMIC_STABLE_REDUCER = status;
        emit ChangedDynamicStableReducer(status);
    }

    function changeBlessedDayStatus(bool status) external onlyRole(MANAGER) {
        BLESSEDDAY_STATUS = status;
        emit ChangedBlessedDayStatus(status);
    }

    function getStableTokens() external view returns (address[] memory) {
        return STABLE_TOKENS.values();
    }

    function addStableToken(address token) public onlyRole(MANAGER) {
        STABLE_TOKENS.add(token);
        emit AddedStableToken(token);
    }

    function addStableTokens(address[] memory tokens) public onlyRole(MANAGER) {
        for (uint i = 0; i < tokens.length; i++) {
            addStableToken(tokens[i]);
        }
    }

    function removeStableToken(address token) external onlyRole(MANAGER) {
        STABLE_TOKENS.remove(token);
        emit RemovedStableToken(token);
    }

    function getWhitelistAccounts() public view returns (address[] memory) {
        return WHITELIST_ACCOUNTS.values();
    }

    function addWhitelistAccount(address acc) external onlyRole(MANAGER) {
        WHITELIST_ACCOUNTS.add(acc);
        emit AddedWhitelistAccount(acc);
    }

    function removeWhitelistAccount(address acc) external onlyRole(MANAGER) {
        WHITELIST_ACCOUNTS.remove(acc);
        emit RemovedWhitelistAccount(acc);
    }
}
