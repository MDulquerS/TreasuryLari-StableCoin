// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TreasuryLari, TreasuryLariErrors, Ownable, Pausable, IERC20} from "../src/TreasuryLari.sol";

contract CounterTest is Test {
    TreasuryLari public treasuryLari;
    address public TLWallet = address(1);
    address public taxWallet = address(2);
    address public prankWallet = address(99);
    address public helperAddress10 = address(10);
    address[] public users;
    function setUp() public {
        treasuryLari = new TreasuryLari(TLWallet, taxWallet);
    }

    function testIfRevertIfTLWalletIsZeroWhileInitiating() public {
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ZeroAddress.selector)
        );
        treasuryLari = new TreasuryLari(address(0), taxWallet);
    }
    function testIfRevertIfTaxWalletIsZeroWhileInitiating() public {
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ZeroAddress.selector)
        );
        treasuryLari = new TreasuryLari(TLWallet, address(0));
    }

    function testIfTreasuryLariContractInitiatedSuccessfully() public {
        string memory expectedName = "Treasury Lari";
        string memory expectedSymbol = "GELT";
        address expectedOwner = address(this);
        treasuryLari = new TreasuryLari(TLWallet, taxWallet);
        string memory actualName = treasuryLari.name();

        string memory actualSymbol = treasuryLari.symbol();
        address actualTLWallet = treasuryLari.getTLWallet();
        address actualTaxWallet = treasuryLari.getTaxWallet();
        address actualOwner = treasuryLari.owner();
        assertEq(actualName, expectedName);
        assertEq(actualSymbol, expectedSymbol);
        assertEq(actualTLWallet, TLWallet);
        assertEq(actualTaxWallet, taxWallet);
        assertEq(actualOwner, expectedOwner);
    }

    function testIfgetTLWalletFunctionWorksProperly() public view {
        address actualTLWallet = treasuryLari.getTLWallet();
        assertEq(actualTLWallet, TLWallet);
    }

    function testIfgetTaxWalletFunctionWorksProperly() public view {
        address actualTaxWallet = treasuryLari.getTaxWallet();
        assertEq(actualTaxWallet, taxWallet);
    }

    function testIfIsPoolFunctionWorksProperly() public {
        address poolAddress = address(5);
        bool isPool = true;
        treasuryLari.addPoolAddress(poolAddress, isPool);
        bool actualIsPool = treasuryLari.isPool(poolAddress);
        assertEq(actualIsPool, isPool);
    }

    function testIfgetRTFeeFunctionWorksProperly() public {
        uint256 actualRTFee = treasuryLari.getRTFee();
        assertEq(actualRTFee, 0);
        uint256 rtFeeAfter = 100000;
        treasuryLari.enableRTFee(rtFeeAfter, true);
        uint256 actualRTFeeAfter = treasuryLari.getRTFee();
        assertEq(actualRTFeeAfter, rtFeeAfter);
    }

    function testIfgetSFeeFunctionWorksProperly() public {
        uint256 actualSFee = treasuryLari.getSFee();
        assertEq(actualSFee, 0);
        uint256 sFeeAfter = 100000;
        treasuryLari.enableSFee(sFeeAfter, true);
        uint256 actualSFeeAfter = treasuryLari.getSFee();
        assertEq(actualSFeeAfter, sFeeAfter);
    }

    function testIfgetFDividerFunctionWorksProperly() public view {
        uint256 expectedFDivider = 1000000;
        uint256 actualFDivider = treasuryLari.getFDivider();
        assertEq(actualFDivider, expectedFDivider);
    }

    function testIfgetIsRTFeeEnabledFunctionWorksProperly() public {
        bool actualIsRTFeeEnabled = treasuryLari.getIsRTFeeEnabled();
        assertEq(actualIsRTFeeEnabled, false);
        uint256 rtFeeAfter = 100000;
        treasuryLari.enableRTFee(rtFeeAfter, true);
        bool actualIsRTFeeEnabledAfter = treasuryLari.getIsRTFeeEnabled();
        assertEq(actualIsRTFeeEnabledAfter, true);
    }
    function testIfgetIsSFeeEnabledFunctionWorksProperly() public {
        bool actualIsSFeeEnabled = treasuryLari.getIsSFeeEnabled();
        assertEq(actualIsSFeeEnabled, false);
        uint256 sFeeAfter = 100000;
        treasuryLari.enableSFee(sFeeAfter, true);
        bool actualIsSFeeEnabledAfter = treasuryLari.getIsSFeeEnabled();
        assertEq(actualIsSFeeEnabledAfter, true);
    }

    function testIfRevertIfNonOwnerCallPauseFunction() public {
        vm.startPrank(prankWallet);
        bool isPaused = treasuryLari.paused();
        assertFalse(isPaused);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.pause();
        bool isPausedAfter = treasuryLari.paused();
        assertFalse(isPausedAfter);
        vm.stopPrank();
    }

    function testIfRevertIfAlreadyPausedWhileCallingPauseFunction() public {
        bool isPaused = treasuryLari.paused();
        assertFalse(isPaused);
        pause();
        vm.expectRevert(
            abi.encodeWithSelector(Pausable.EnforcedPause.selector)
        );
        treasuryLari.pause();
    }

    function testIfOwnerCanPauseSuccesfully() public {
        bool isPaused = treasuryLari.paused();
        assertFalse(isPaused);
        vm.expectEmit(address(treasuryLari));
        emit Pausable.Paused(address(this));
        treasuryLari.pause();
        bool isPausedAfter = treasuryLari.paused();
        assertTrue(isPausedAfter);
    }

    function pause() public {
        bool isPaused = treasuryLari.paused();
        assertFalse(isPaused);
        vm.expectEmit(address(treasuryLari));
        emit Pausable.Paused(address(this));
        treasuryLari.pause();
        bool isPausedAfter = treasuryLari.paused();
        assertTrue(isPausedAfter);
    }

    function testIfRevertIfNonOwnerIsCallingUnpauseFunction() public {
        pause();
        vm.startPrank(prankWallet);
        bool isPaused = treasuryLari.paused();
        assertTrue(isPaused);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.unpause();
        bool isPausedAfter = treasuryLari.paused();
        assertTrue(isPausedAfter);
        vm.stopPrank();
    }

    function testIfRevertIfNotPausedWhileUnpasuing() public {
        bool isPaused = treasuryLari.paused();
        assertFalse(isPaused);
        vm.expectRevert(
            abi.encodeWithSelector(Pausable.ExpectedPause.selector)
        );
        treasuryLari.unpause();
    }

    function testIfOwnerCanSuccessfullyUnpause() public {
        pause();
        bool isPaused = treasuryLari.paused();
        assertTrue(isPaused);
        vm.expectEmit(address(treasuryLari));
        emit Pausable.Unpaused(address(this));
        treasuryLari.unpause();
        bool isPausedAfter = treasuryLari.paused();
        assertFalse(isPausedAfter);
    }

    function testIfRevertIfNonOwnerIsTryingToMintNewToken() public {
        vm.startPrank(prankWallet);
        uint256 amount = 100e18;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.mint(amount);

        vm.stopPrank();
    }

    function testIfRevertIfAmountIsZeroWhileCallingMintFunction() public {
        uint256 amount = 0;
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.AmountZero.selector)
        );
        treasuryLari.mint(amount);
    }

    function testIfRevertIfTLWalletIsZeroWhileCallingMintFunction() public {
        uint256 amount = 100e18;
        treasuryLari.updateTLWallet(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ZeroAddress.selector)
        );
        treasuryLari.mint(amount);
    }

    function testIfOwnerCanSuccessfullyMintNewToken() public {
        uint256 currentSupply = treasuryLari.totalSupply();
        assertEq(currentSupply, 0);
        uint256 balanceOfTLWallet = treasuryLari.balanceOf(TLWallet);
        assertEq(balanceOfTLWallet, 0);
        uint256 amount = 100e18;
        vm.expectEmit(address(treasuryLari));
        emit IERC20.Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        uint256 currentSupplyAfter = treasuryLari.totalSupply();
        assertEq(currentSupplyAfter, amount);
        uint256 balanceOfTLWalletAfter = treasuryLari.balanceOf(TLWallet);
        assertEq(balanceOfTLWalletAfter, amount);

        assertEq(currentSupplyAfter, currentSupply + amount);

        assertEq(balanceOfTLWalletAfter, currentSupply + amount);
    }

    function testIfRevertIfNonOwnerIsCallingBlockUsersFunction() public {
        vm.startPrank(prankWallet);
        users.push(helperAddress10);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.blockUsers(users);

        vm.stopPrank();
    }

    function testIfOwnerCanSuccessfullyBlockUser() public {
        users.push(helperAddress10);
        bool isBlocked = treasuryLari.blocked(users[0]);
        assertFalse(isBlocked);
        vm.expectEmit(address(treasuryLari));
        emit IERC20.UserBlocked(users[0]);
        treasuryLari.blockUsers(users);
        bool isBlockedAfter = treasuryLari.blocked(users[0]);
        assertTrue(isBlockedAfter);
    }

    function testIfRevertIfNonOwnerIsCallingunblockUsersFunction() public {
        vm.startPrank(prankWallet);
        users.push(helperAddress10);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.unblockUsers(users);

        vm.stopPrank();
    }

    function testIfOwnerCanSuccessfullyUnblockUser() public {
        users.push(helperAddress10);
        bool isBlocked = treasuryLari.blocked(users[0]);
        assertFalse(isBlocked);
        vm.expectEmit(address(treasuryLari));
        emit IERC20.UserBlocked(users[0]);
        treasuryLari.blockUsers(users);
        bool isBlockedAfter = treasuryLari.blocked(users[0]);
        assertTrue(isBlockedAfter);
        vm.expectEmit(address(treasuryLari));
        emit IERC20.UserUnblocked(users[0]);
        treasuryLari.unblockUsers(users);
        bool isBlockedAfterUnblock = treasuryLari.blocked(users[0]);
        assertFalse(isBlockedAfterUnblock);
    }

    function testIfRevertIfNonOwnerIsCallingaddPoolAddressFunction() public {
        vm.startPrank(prankWallet);
        address poolAddress = address(5);
        bool isPool = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.addPoolAddress(poolAddress, isPool);

        vm.stopPrank();
    }

    function testIfRevertIfPoolDetailsIsAddedAndAlreadyExists() public {
        address poolAddress = address(5);
        bool isPool = true;
        treasuryLari.addPoolAddress(poolAddress, isPool);
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ExactDetails.selector)
        );
        treasuryLari.addPoolAddress(poolAddress, isPool);
    }

    function testIfOwnerCanSuccessfullyAddPoolAddress() public {
        address poolAddress = helperAddress10;
        bool isPool = true;
        bool actualIsPool = treasuryLari.isPool(poolAddress);
        assertFalse(actualIsPool);
        vm.expectEmit(address(treasuryLari));
        emit TreasuryLari.PoolAddressAdded(poolAddress, isPool);
        treasuryLari.addPoolAddress(poolAddress, isPool);
        bool actualIsPoolAfter = treasuryLari.isPool(poolAddress);
        assertTrue(actualIsPoolAfter);
    }

    function testIfRevertIfNonOwnerIsCallingUpdateTLWallet() public {
        vm.startPrank(prankWallet);
        address newTLWallet = helperAddress10;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.updateTLWallet(newTLWallet);

        vm.stopPrank();
    }

    function testRevertIfNewWalletIsTheSameAsOldWalletWhileCallingUpdateTLWallet()
        public
    {
        address newTLWallet = TLWallet;
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ExactDetails.selector)
        );
        treasuryLari.updateTLWallet(newTLWallet);
    }

    function testIfOwnerCanSuccessfullyUpdateTLWallet() public {
        address newTLWallet = helperAddress10;
        address actualTLWallet = treasuryLari.getTLWallet();
        assertEq(actualTLWallet, TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit TreasuryLari.UpdatedTLWallet(newTLWallet);
        treasuryLari.updateTLWallet(newTLWallet);
        address actualTLWalletAfter = treasuryLari.getTLWallet();
        assertEq(actualTLWalletAfter, newTLWallet);
    }

    function testIfRevertIfNonOwnerIsCallingUpdateTaxWallet() public {
        vm.startPrank(prankWallet);
        address newTaxWallet = helperAddress10;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.updateTaxWallet(newTaxWallet);

        vm.stopPrank();
    }

    function testIfRevertIfTaxWalletIsSameAsPreviousWhileCallingUpdateTaxWallet()
        public
    {
        address newTaxWallet = taxWallet;
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ExactDetails.selector)
        );
        treasuryLari.updateTaxWallet(newTaxWallet);
    }

    function testIfOwnerCanSuccessfullyUpdateTaxWallet() public {
        address newTaxWallet = helperAddress10;
        address actualTaxWallet = treasuryLari.getTaxWallet();
        assertEq(actualTaxWallet, taxWallet);
        vm.expectEmit(address(treasuryLari));
        emit TreasuryLari.UpdatedTaxWallet(newTaxWallet);
        treasuryLari.updateTaxWallet(newTaxWallet);
        address actualTaxWalletAfter = treasuryLari.getTaxWallet();
        assertEq(actualTaxWalletAfter, newTaxWallet);
    }

    function testIfRevertIfNonOwnerIsCallingwithdrawStuckedTokenFunction()
        public
    {
        vm.startPrank(prankWallet);
        address tokenAddress = address(5);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.withdrawStuckedToken(tokenAddress, msg.sender);

        vm.stopPrank();
    }

    function testIfRevertIfTokenAmountIsZeroWhileCallingwithdrawStuckedTokenFunction()
        public
    {
        TreasuryLari tokenAddress = new TreasuryLari(TLWallet, taxWallet);
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.AmountZero.selector)
        );
        treasuryLari.withdrawStuckedToken(address(tokenAddress), msg.sender);
    }

    function testIfOwnerCanSuccessfullyCallWithdrawStuckedTokenFunction()
        public
    {
        TreasuryLari tokenAddress = new TreasuryLari(address(this), taxWallet);
        uint256 amount = 100e18;
        uint256 balanceOfToken = tokenAddress.balanceOf(address(this));
        assertEq(balanceOfToken, 0);
        vm.expectEmit(address(tokenAddress));
        emit IERC20.Transfer(address(0), address(this), amount);
        tokenAddress.mint(amount);
        uint256 balanceOfTokenAfter = tokenAddress.balanceOf(address(this));
        assertEq(balanceOfTokenAfter, amount);
        vm.expectEmit(address(tokenAddress));
        emit IERC20.Transfer(address(this), address(treasuryLari), amount);
        tokenAddress.transfer(address(treasuryLari), amount);

        uint256 balanceOfLari = tokenAddress.balanceOf(address(treasuryLari));
        assertEq(balanceOfLari, amount);
        vm.expectEmit(address(tokenAddress));
        emit IERC20.Transfer(address(treasuryLari), address(this), amount);
        treasuryLari.withdrawStuckedToken(address(tokenAddress), address(this));
        uint256 balanceOfTokenAfterWithdraw = tokenAddress.balanceOf(
            address(treasuryLari)
        );
        assertEq(balanceOfTokenAfterWithdraw, 0);
        uint256 balanceOfThis = tokenAddress.balanceOf(address(this));
        assertEq(balanceOfThis, amount);
    }

    function testIfRevertIfNonOwnerIsCallingenableRTFeeFunction() public {
        vm.startPrank(prankWallet);
        uint256 rtFee = 100000;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.enableRTFee(rtFee, enable);

        vm.stopPrank();
    }

    function testIfRevertIfRTFeeIsMoreThan20PercentWhileCallingenableRTFeeFunction()
        public
    {
        uint256 rtFee = 200001;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                TreasuryLariErrors.MoreThan20Percent.selector
            )
        );
        treasuryLari.enableRTFee(rtFee, enable);
    }

    function testIfOwnerCanSuccessfullyCallenableRTFeeFunction() public {
        uint256 rtFee = 100000;
        bool enable = true;
        uint256 actualRTFee = treasuryLari.getRTFee();
        bool actualRTFeeStatus = treasuryLari.getIsRTFeeEnabled();
        assertEq(actualRTFee, 0);
        assertFalse(actualRTFeeStatus);
        vm.expectEmit(address(treasuryLari));
        emit TreasuryLari.EnabledRTFee(rtFee, enable);
        treasuryLari.enableRTFee(rtFee, enable);
        uint256 actualRTFeeAfter = treasuryLari.getRTFee();
        bool actualRTFeeAfterStatus = treasuryLari.getIsRTFeeEnabled();
        assertEq(actualRTFeeAfter, rtFee);

        assertTrue(actualRTFeeAfterStatus);
    }

    function testIfRevertIfNonOwnerIsCallingenableSFeeFunction() public {
        vm.startPrank(prankWallet);
        uint256 sFee = 100000;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.enableSFee(sFee, enable);

        vm.stopPrank();
    }

    function testIfRevertIfSFeeIsMoreThan20PercentWhileCallingenableSFeeFunction()
        public
    {
        uint256 sFee = 200001;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                TreasuryLariErrors.MoreThan20Percent.selector
            )
        );
        treasuryLari.enableSFee(sFee, enable);
    }

    function testIfOwnerCanSuccessfullyCallenableSFeeFunction() public {
        uint256 sFee = 100000;
        bool enable = true;
        uint256 actualSFee = treasuryLari.getSFee();
        bool actualSFeeStatus = treasuryLari.getIsSFeeEnabled();
        assertEq(actualSFee, 0);
        assertFalse(actualSFeeStatus);
        vm.expectEmit(address(treasuryLari));
        emit TreasuryLari.EnabledSFee(sFee, enable);
        treasuryLari.enableSFee(sFee, enable);
        uint256 actualSFeeAfter = treasuryLari.getSFee();
        bool actualSFeeAfterStatus = treasuryLari.getIsSFeeEnabled();
        assertEq(actualSFeeAfter, sFee);

        assertTrue(actualSFeeAfterStatus);
    }

    function testIfOwnerFunctionWorksProperly() public view {
        address expectedOwner = address(this);
        address actualOwner = treasuryLari.owner();
        assertEq(actualOwner, expectedOwner);
    }

    function testIfRevertNonOwnerIsCallingrenounceOwnershipFunction() public {
        vm.startPrank(prankWallet);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.renounceOwnership();
        vm.stopPrank();
    }

    function testIfOwnerCanSuccessfullyRenounceOwnership() public {
        address expectedOwner = address(0);
        address actualOwner = treasuryLari.owner();
        assertEq(actualOwner, address(this));
        vm.expectEmit(address(treasuryLari));
        emit Ownable.OwnershipTransferred(address(this), address(0));
        treasuryLari.renounceOwnership();
        address actualOwnerAfter = treasuryLari.owner();
        assertEq(actualOwnerAfter, expectedOwner);
    }

    function testIfRevertIfNonOwnerIsCallingtransferOwnershipFunction() public {
        vm.startPrank(prankWallet);
        address newOwner = helperAddress10;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.transferOwnership(newOwner);
        vm.stopPrank();
    }

    function testIfRevertIfNewOwnerIsZeroWhileCallingtransferOwnershipFunction()
        public
    {
        address newOwner = address(0);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableInvalidOwner.selector,
                newOwner
            )
        );
        treasuryLari.transferOwnership(newOwner);
    }

    function testIfOwnerCanSuccessfullyTransferOwnership() public {
        address newOwner = helperAddress10;
        address actualOwner = treasuryLari.owner();
        assertEq(actualOwner, address(this));
        vm.expectEmit(address(treasuryLari));
        emit Ownable.OwnershipTransferred(address(this), newOwner);
        treasuryLari.transferOwnership(newOwner);
        address actualOwnerAfter = treasuryLari.owner();
        assertEq(actualOwnerAfter, newOwner);
    }

    function testIfpausedFunctionWorksProperly() public {
        bool actualPaused = treasuryLari.paused();
        assertFalse(actualPaused);
        pause();
        bool actualPausedAfter = treasuryLari.paused();
        assertTrue(actualPausedAfter);
    }

    function testIfNameFunctionWorksProperly() public view {
        string memory expectedName = "Treasury Lari";
        string memory actualName = treasuryLari.name();
        assertEq(actualName, expectedName);
    }

    function testIfSymbolFunctionWorksProperly() public view {
        string memory expectedSymbol = "GELT";
        string memory actualSymbol = treasuryLari.symbol();
        assertEq(actualSymbol, expectedSymbol);
    }

    function testIfdecimalsFunctionWorksProperly() public view {
        uint8 expectedDecimals = 6;
        uint8 actualDecimals = treasuryLari.decimals();
        assertEq(actualDecimals, expectedDecimals);
    }

    function testIftotalSupplyFunctionWorksProperly() public {
        uint256 expectedTotalSupply = 0;
        uint256 actualTotalSupply = treasuryLari.totalSupply();
        assertEq(actualTotalSupply, expectedTotalSupply);
        uint256 amount = 100e18;
        vm.expectEmit(address(treasuryLari));
        emit IERC20.Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        uint256 actualTotalSupplyAfter = treasuryLari.totalSupply();
        assertEq(actualTotalSupplyAfter, amount);
    }

    function testIfbalanceOfFunctionWorksProperly() public {
        uint256 expectedBalance = 0;
        uint256 actualBalance = treasuryLari.balanceOf(TLWallet);
        assertEq(actualBalance, expectedBalance);
        uint256 amount = 100e18;
        vm.expectEmit(address(treasuryLari));
        emit IERC20.Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        uint256 actualBalanceAfter = treasuryLari.balanceOf(TLWallet);
        assertEq(actualBalanceAfter, amount);
    }

    function testIfblockedFunctionWorksProperly() public {
        address user = helperAddress10;
        bool actualBlocked = treasuryLari.blocked(user);
        assertFalse(actualBlocked);
        users.push(user);
        vm.expectEmit(address(treasuryLari));
        emit IERC20.UserBlocked(user);
        treasuryLari.blockUsers(users);
        bool actualBlockedAfter = treasuryLari.blocked(user);
        assertTrue(actualBlockedAfter);
    }

    function testIfallowanceFunctionWorksProperly() public {
        address owner = address(this);
        address spender = helperAddress10;
        uint256 expectedAllowance = 0;
        uint256 actualAllowance = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowance, expectedAllowance);
        uint256 amount = 100e18;
        vm.expectEmit(address(treasuryLari));
        emit IERC20.Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.expectEmit(address(treasuryLari));
        emit IERC20.Approval(owner, spender, amount);
        treasuryLari.approve(spender, amount);
        uint256 actualAllowanceAfter = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowanceAfter, amount);
    }
}
