// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {TreasuryLari, TreasuryLariErrors, Ownable, Pausable, IERC20, IERC20Errors, ERC20Permit, ECDSA} from "../src/TreasuryLari.sol";

interface AllEvents {
    event Paused(address account);
    event Unpaused(address account);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event UserBlocked(address indexed user);
    event UserUnblocked(address indexed user);
    event PoolAddressAdded(address indexed pool, bool isPool);

    event UpdatedTLWallet(address indexed newTLWallet);

    event UpdatedTaxWallet(address indexed newTaxWallet);

    event EnabledRTFee(uint256 fee, bool enabled);

    event EnabledSFee(uint256 sfee, uint256 bfee, bool enabled);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}
contract CounterTest is Test, AllEvents {
    TreasuryLari public treasuryLari;
    address public TLWallet = address(1);
    address public taxWallet = address(2);
    address public prankWallet = address(99);
    address public poolAddress = address(100);
    address public helperAddress10 = address(10);
    address public helperAddress11 = address(11);
    address public helperAddress12 = address(12);
    address public helperAddress13 = address(13);
    address public helperAddress14 = address(14);
    address public helperAddress15 = address(15);

    uint256 public privateKey =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address public publicKey = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
            )
        );

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
        address pool = address(5);
        bool isPool = true;
        treasuryLari.addPoolAddress(pool, isPool);
        bool actualIsPool = treasuryLari.isPool(pool);
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

    function testIfgetSSFeeFunctionWorksProperly() public {
        uint256 actualSSFee = treasuryLari.getSSFee();
        assertEq(actualSSFee, 0);
        uint256 sSFeeAfter = 100000;
        uint256 sBFeeAfter = 100000;
        treasuryLari.enableSFee(sSFeeAfter, sBFeeAfter, true);
        uint256 actualSSFeeAfter = treasuryLari.getSSFee();
        assertEq(actualSSFeeAfter, sSFeeAfter);
    }
    function testIfgetSBFeeFunctionWorksProperly() public {
        uint256 actualSBFee = treasuryLari.getSBFee();
        assertEq(actualSBFee, 0);
        uint256 sSFeeAfter = 100000;
        uint256 sBFeeAfter = 100000;
        treasuryLari.enableSFee(sSFeeAfter, sBFeeAfter, true);
        uint256 actualSBFeeAfter = treasuryLari.getSBFee();
        assertEq(actualSBFeeAfter, sBFeeAfter);
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
    function testIfgetIsSSFeeEnabledFunctionWorksProperly() public {
        bool actualIsSSFeeEnabled = treasuryLari.getIsSFeeEnabled();
        assertEq(actualIsSSFeeEnabled, false);
        uint256 sSFeeAfter = 100000;
        uint256 sBFeeAfter = 100000;
        treasuryLari.enableSFee(sSFeeAfter, sBFeeAfter, true);
        bool actualIsSSFeeEnabledAfter = treasuryLari.getIsSFeeEnabled();
        assertEq(actualIsSSFeeEnabledAfter, true);
    }
    function testIfgetIsSBFeeEnabledFunctionWorksProperly() public {
        bool actualIsSBFeeEnabled = treasuryLari.getIsSFeeEnabled();
        assertEq(actualIsSBFeeEnabled, false);
        uint256 sSFeeAfter = 100000;
        uint256 sBFeeAfter = 100000;
        treasuryLari.enableSFee(sSFeeAfter, sBFeeAfter, true);
        bool actualIsSBFeeEnabledAfter = treasuryLari.getIsSFeeEnabled();
        assertEq(actualIsSBFeeEnabledAfter, true);
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
        emit Paused(address(this));
        treasuryLari.pause();
        bool isPausedAfter = treasuryLari.paused();
        assertTrue(isPausedAfter);
    }

    function pause() public {
        bool isPaused = treasuryLari.paused();
        assertFalse(isPaused);
        vm.expectEmit(address(treasuryLari));
        emit Paused(address(this));
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
        emit Unpaused(address(this));
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
        emit Transfer(address(0), TLWallet, amount);
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
        emit UserBlocked(users[0]);
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
        emit UserBlocked(users[0]);
        treasuryLari.blockUsers(users);
        bool isBlockedAfter = treasuryLari.blocked(users[0]);
        assertTrue(isBlockedAfter);
        vm.expectEmit(address(treasuryLari));
        emit UserUnblocked(users[0]);
        treasuryLari.unblockUsers(users);
        bool isBlockedAfterUnblock = treasuryLari.blocked(users[0]);
        assertFalse(isBlockedAfterUnblock);
    }

    function testIfRevertIfNonOwnerIsCallingaddPoolAddressFunction() public {
        vm.startPrank(prankWallet);
        address pool = address(5);
        bool isPool = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.addPoolAddress(pool, isPool);

        vm.stopPrank();
    }

    function testIfRevertIfPoolDetailsIsAddedAndAlreadyExists() public {
        address pool = address(5);
        bool isPool = true;
        treasuryLari.addPoolAddress(pool, isPool);
        vm.expectRevert(
            abi.encodeWithSelector(TreasuryLariErrors.ExactDetails.selector)
        );
        treasuryLari.addPoolAddress(pool, isPool);
    }

    function testIfOwnerCanSuccessfullyAddPoolAddress() public {
        address pool = helperAddress10;
        bool isPool = true;
        bool actualIsPool = treasuryLari.isPool(pool);
        assertFalse(actualIsPool);
        vm.expectEmit(address(treasuryLari));
        emit PoolAddressAdded(pool, isPool);
        treasuryLari.addPoolAddress(pool, isPool);
        bool actualIsPoolAfter = treasuryLari.isPool(pool);
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
        emit UpdatedTLWallet(newTLWallet);
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
        emit UpdatedTaxWallet(newTaxWallet);
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
        emit Transfer(address(0), address(this), amount);
        tokenAddress.mint(amount);
        uint256 balanceOfTokenAfter = tokenAddress.balanceOf(address(this));
        assertEq(balanceOfTokenAfter, amount);
        vm.expectEmit(address(tokenAddress));
        emit Transfer(address(this), address(treasuryLari), amount);
        tokenAddress.transfer(address(treasuryLari), amount);

        uint256 balanceOfLari = tokenAddress.balanceOf(address(treasuryLari));
        assertEq(balanceOfLari, amount);
        vm.expectEmit(address(tokenAddress));
        emit Transfer(address(treasuryLari), address(this), amount);
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
        emit EnabledRTFee(rtFee, enable);
        treasuryLari.enableRTFee(rtFee, enable);
        uint256 actualRTFeeAfter = treasuryLari.getRTFee();
        bool actualRTFeeAfterStatus = treasuryLari.getIsRTFeeEnabled();
        assertEq(actualRTFeeAfter, rtFee);

        assertTrue(actualRTFeeAfterStatus);
    }

    function testIfRevertIfNonOwnerIsCallingenableSSFeeFunction() public {
        vm.startPrank(prankWallet);
        uint256 sSFee = 100000;
        uint256 sBFee = 100000;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.enableSFee(sSFee, sBFee, enable);

        vm.stopPrank();
    }
    function testIfRevertIfNonOwnerIsCallingenableSBFeeFunction() public {
        vm.startPrank(prankWallet);
        uint256 sSFee = 100000;
        uint256 sBFee = 100000;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                prankWallet
            )
        );
        treasuryLari.enableSFee(sSFee, sBFee, enable);

        vm.stopPrank();
    }

    function testIfRevertIfSSFeeIsMoreThan20PercentWhileCallingenableSSFeeFunction()
        public
    {
        uint256 sSFee = 200001;
        uint256 sBFee = 200001;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                TreasuryLariErrors.MoreThan20Percent.selector
            )
        );
        treasuryLari.enableSFee(sSFee, sBFee, enable);
    }
    function testIfRevertIfSBFeeIsMoreThan20PercentWhileCallingenableSBFeeFunction()
        public
    {
        uint256 sSFee = 20000;
        uint256 sBFee = 200001;
        bool enable = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                TreasuryLariErrors.MoreThan20Percent.selector
            )
        );
        treasuryLari.enableSFee(sSFee, sBFee, enable);
    }

    function testIfOwnerCanSuccessfullyCallenableSSFeeFunction() public {
        uint256 sSFee = 100000;
        uint256 sBFee = 100000;
        bool enable = true;
        uint256 actualSSFee = treasuryLari.getSSFee();
        bool actualSSFeeStatus = treasuryLari.getIsSFeeEnabled();
        assertEq(actualSSFee, 0);
        assertFalse(actualSSFeeStatus);
        vm.expectEmit(address(treasuryLari));
        emit EnabledSFee(sSFee, sBFee, enable);
        treasuryLari.enableSFee(sSFee, sBFee, enable);
        uint256 actualSSFeeAfter = treasuryLari.getSSFee();
        bool actualSSFeeAfterStatus = treasuryLari.getIsSFeeEnabled();
        assertEq(actualSSFeeAfter, sSFee);

        assertTrue(actualSSFeeAfterStatus);
    }
    function testIfOwnerCanSuccessfullyCallenableSBFeeFunction() public {
        uint256 sSFee = 100000;
        uint256 sBFee = 100000;
        bool enable = true;
        uint256 actualSBFee = treasuryLari.getSBFee();
        bool actualSBFeeStatus = treasuryLari.getIsSFeeEnabled();
        assertEq(actualSBFee, 0);
        assertFalse(actualSBFeeStatus);
        vm.expectEmit(address(treasuryLari));
        emit EnabledSFee(sSFee, sBFee, enable);
        treasuryLari.enableSFee(sSFee, sBFee, enable);
        uint256 actualSBFeeAfter = treasuryLari.getSBFee();
        bool actualSBFeeAfterStatus = treasuryLari.getIsSFeeEnabled();
        assertEq(actualSBFeeAfter, sBFee);

        assertTrue(actualSBFeeAfterStatus);
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
        emit OwnershipTransferred(address(this), address(0));
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
        emit OwnershipTransferred(address(this), newOwner);
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
        emit Transfer(address(0), TLWallet, amount);
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
        emit Transfer(address(0), TLWallet, amount);
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
        emit UserBlocked(user);
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
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.expectEmit(address(treasuryLari));
        emit Approval(owner, spender, amount);
        treasuryLari.approve(spender, amount);
        uint256 actualAllowanceAfter = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowanceAfter, amount);
    }

    function testIfRevertIfFromAddressIsZeroWhileCallingtransferFunction()
        public
    {
        vm.startPrank(address(0));
        address to = helperAddress10;
        uint256 amount = 100e18;
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InvalidSender.selector,
                address(0)
            )
        );
        treasuryLari.transfer(to, amount);
        vm.stopPrank();
    }

    function testIfRevertIfToAddressIsZeroWhileCallingtransferFunction()
        public
    {
        address to = address(0);
        uint256 amount = 100e18;
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InvalidReceiver.selector,
                to
            )
        );
        treasuryLari.transfer(to, amount);
    }

    function testIfRevertIfFromAddressIsBlockedWhileCallingTransferFunction()
        public
    {
        address from = helperAddress10;
        address to = helperAddress11;
        uint256 amount = 100e18;
        users.push(from);
        vm.expectEmit(address(treasuryLari));
        emit UserBlocked(from);
        treasuryLari.blockUsers(users);
        vm.startPrank(from);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20Blocked.selector, from)
        );
        treasuryLari.transfer(to, amount);
        vm.stopPrank();
    }

    function testIfRevertIfToAddressIsBlockedWhileCallingTransferFunction()
        public
    {
        address from = helperAddress10;
        address to = helperAddress11;
        uint256 amount = 100e18;
        users.push(to);
        vm.expectEmit(address(treasuryLari));
        emit UserBlocked(to);
        treasuryLari.blockUsers(users);
        vm.startPrank(from);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20Blocked.selector, to)
        );
        treasuryLari.transfer(to, amount);
        vm.stopPrank();
    }

    function testIfRevertIfSenderDoesNotHaveEnoughBalanceWhileCallingTransferFunction()
        public
    {
        address from = helperAddress10;
        address to = helperAddress11;
        uint256 amount = 100e18;
        uint256 balanceOfFrom = treasuryLari.balanceOf(from);
        assertEq(balanceOfFrom, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                from,
                balanceOfFrom,
                amount
            )
        );
        vm.startPrank(from);
        treasuryLari.transfer(to, amount);
        vm.stopPrank();
    }

    function testIfSenderCanSuccessfullyTransferTokensWhileCallingTransferFunction()
        public
    {
        address from = helperAddress10;
        address to = helperAddress11;
        uint256 amount = 100e18;
        uint256 balanceOfFrom = treasuryLari.balanceOf(from);
        assertEq(balanceOfFrom, 0);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, from, amount);
        treasuryLari.transfer(from, amount);
        vm.stopPrank();
        uint256 balanceOfFromAfter = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfter, amount);
        uint256 balanceOfTo = treasuryLari.balanceOf(to);
        assertEq(balanceOfTo, 0);
        vm.startPrank(from);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(from, to, amount);
        treasuryLari.transfer(to, amount);
        uint256 balanceOfFromAfterTransfer = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfterTransfer, 0);
        uint256 balanceOfToAfterTransfer = treasuryLari.balanceOf(to);
        assertEq(balanceOfToAfterTransfer, amount);
        vm.stopPrank();
    }

    function testIfRTFeeFeatureWorksProperlyWhileTransferringTokensIfRTFeeIsEnabled()
        public
    {
        uint256 rtFee = 100000;
        bool enable = true;
        uint256 amount = 100e18;
        uint256 totalFee;
        uint256 expectpedTotalFee = (amount * rtFee) /
            treasuryLari.getFDivider();
        totalFee += expectpedTotalFee;
        address from = helperAddress10;
        address to = helperAddress11;
        uint256 balanceOfFrom = treasuryLari.balanceOf(from);
        assertEq(balanceOfFrom, 0);
        vm.expectEmit(address(treasuryLari));
        emit EnabledRTFee(rtFee, enable);
        treasuryLari.enableRTFee(rtFee, enable);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, from, amount - expectpedTotalFee);
        treasuryLari.transfer(from, amount);
        vm.stopPrank();
        amount = amount - expectpedTotalFee;
        expectpedTotalFee = (amount * rtFee) / treasuryLari.getFDivider();
        totalFee += expectpedTotalFee;
        uint256 balanceOfFromAfter = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfter, amount);
        uint256 balanceOfTo = treasuryLari.balanceOf(to);
        assertEq(balanceOfTo, 0);
        vm.startPrank(from);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(from, to, amount - expectpedTotalFee);
        emit Transfer(from, taxWallet, expectpedTotalFee);
        treasuryLari.transfer(to, amount);
        uint256 balanceOfFromAfterTransfer = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfterTransfer, 0);
        uint256 balanceOfToAfterTransfer = treasuryLari.balanceOf(to);
        assertEq(balanceOfToAfterTransfer, amount - expectpedTotalFee);
        uint256 balanceOfTaxWallet = treasuryLari.balanceOf(taxWallet);
        assertEq(balanceOfTaxWallet, totalFee);
        vm.stopPrank();
    }

    function testIfSSFeeFeatureWorksProperlyWhileTransferringTokensIfSFeeIsEnabled()
        public
    {
        uint256 sSFee = 100000;
        uint256 sBFee = 100000;
        bool enable = true;
        uint256 amount = 100e18;
        uint256 totalFee;
        uint256 expectpedTotalFee = (amount * sSFee) /
            treasuryLari.getFDivider();
        totalFee += expectpedTotalFee;
        address from = helperAddress10;
        address to = poolAddress;
        uint256 balanceOfFrom = treasuryLari.balanceOf(from);
        assertEq(balanceOfFrom, 0);
        vm.expectEmit(address(treasuryLari));
        emit EnabledSFee(sSFee, sBFee, enable);
        treasuryLari.enableSFee(sSFee, sBFee, enable);
        vm.expectEmit(address(treasuryLari));
        emit PoolAddressAdded(poolAddress, true);
        treasuryLari.addPoolAddress(poolAddress, true);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, from, amount);
        treasuryLari.transfer(from, amount);
        vm.stopPrank();
        uint256 balanceOfFromAfter = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfter, amount);
        uint256 balanceOfTo = treasuryLari.balanceOf(to);
        assertEq(balanceOfTo, 0);
        vm.startPrank(from);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(from, to, amount - expectpedTotalFee);
        emit Transfer(from, taxWallet, expectpedTotalFee);
        treasuryLari.transfer(to, amount);
        uint256 balanceOfFromAfterTransfer = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfterTransfer, 0);
        uint256 balanceOfToAfterTransfer = treasuryLari.balanceOf(to);
        assertEq(balanceOfToAfterTransfer, amount - expectpedTotalFee);
        uint256 balanceOfTaxWallet = treasuryLari.balanceOf(taxWallet);
        assertEq(balanceOfTaxWallet, totalFee);
        vm.stopPrank();
    }
    function testIfSBFeeFeatureWorksProperlyWhileTransferringTokensIfSFeeIsEnabled()
        public
    {
        uint256 sSFee = 100000;
        uint256 sBFee = 100000;
        bool enable = true;
        uint256 amount = 100e18;
        uint256 totalFee;
        uint256 expectpedTotalFee = (amount * sBFee) /
            treasuryLari.getFDivider();
        totalFee += expectpedTotalFee;
        address from = helperAddress10;
        address to = poolAddress;
        uint256 balanceOfFrom = treasuryLari.balanceOf(from);
        assertEq(balanceOfFrom, 0);
        vm.expectEmit(address(treasuryLari));
        emit EnabledSFee(sSFee, sBFee, enable);
        treasuryLari.enableSFee(sSFee, sBFee, enable);
        vm.expectEmit(address(treasuryLari));
        emit PoolAddressAdded(poolAddress, true);
        treasuryLari.addPoolAddress(poolAddress, true);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, from, amount);
        treasuryLari.transfer(from, amount);
        vm.stopPrank();
        uint256 balanceOfFromAfter = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfter, amount);
        uint256 balanceOfTo = treasuryLari.balanceOf(to);
        assertEq(balanceOfTo, 0);
        vm.startPrank(from);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(from, to, amount - expectpedTotalFee);
        emit Transfer(from, taxWallet, expectpedTotalFee);
        treasuryLari.transfer(to, amount);
        uint256 balanceOfFromAfterTransfer = treasuryLari.balanceOf(from);
        assertEq(balanceOfFromAfterTransfer, 0);
        uint256 balanceOfToAfterTransfer = treasuryLari.balanceOf(to);
        assertEq(balanceOfToAfterTransfer, amount - expectpedTotalFee);
        uint256 balanceOfTaxWallet = treasuryLari.balanceOf(taxWallet);
        assertEq(balanceOfTaxWallet, totalFee);
        vm.stopPrank();
    }

    function testIfRevertIfUserIsBlockedWhileCallingApproveFunction() public {
        address spender = helperAddress10;
        uint256 amount = 100e18;
        address owner = helperAddress11;
        users.push(owner);
        vm.expectEmit(address(treasuryLari));
        emit UserBlocked(owner);
        treasuryLari.blockUsers(users);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20Blocked.selector, owner)
        );
        vm.startPrank(owner);
        treasuryLari.approve(spender, amount);
        vm.stopPrank();
    }

    function testIfRevertIfUserIsAddressZeroWhileCallingApproveFunction()
        public
    {
        address spender = helperAddress10;
        uint256 amount = 100e18;
        address owner = address(0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InvalidApprover.selector,
                owner
            )
        );
        vm.startPrank(owner);
        treasuryLari.approve(spender, amount);
        vm.stopPrank();
    }

    function testIfRevertIfSpenderIsAddressZeroWhileCallingApproveFunction()
        public
    {
        address spender = address(0);
        uint256 amount = 100e18;
        address owner = helperAddress10;
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InvalidSpender.selector,
                spender
            )
        );
        vm.startPrank(owner);
        treasuryLari.approve(spender, amount);
        vm.stopPrank();
    }

    function testIfUserCanSuccessfullyCallApproveFunction() public {
        address spender = helperAddress10;
        uint256 amount = 100e18;
        address owner = helperAddress11;
        uint256 expectedAllowance = 0;
        uint256 actualAllowance = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowance, expectedAllowance);
        vm.startPrank(owner);
        vm.expectEmit(address(treasuryLari));
        emit Approval(owner, spender, amount);
        treasuryLari.approve(spender, amount);
        vm.stopPrank();
        uint256 actualAllowanceAfter = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowanceAfter, amount);
    }

    function testIfRevertIfAllowanceIsLessThanValueWhileCallingTransferFromFunction()
        public
    {
        address owner = helperAddress10;
        address spender = helperAddress11;
        address to = helperAddress12;
        uint256 amount = 100e18;
        uint256 allowance = treasuryLari.allowance(owner, spender);
        uint256 balanceOfOwner = treasuryLari.balanceOf(owner);
        assertEq(balanceOfOwner, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector,
                spender,
                allowance,
                amount
            )
        );
        vm.startPrank(spender);
        treasuryLari.transferFrom(spender, to, amount);
        vm.stopPrank();
    }

    function testIfUserCanSuccessfullyCallTransferFromFunction() public {
        address owner = helperAddress10;
        address spender = helperAddress11;
        address to = helperAddress12;
        uint256 amount = 100e18;
        uint256 balanceOfOwner = treasuryLari.balanceOf(owner);
        assertEq(balanceOfOwner, 0);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, owner, amount);
        treasuryLari.transfer(owner, amount);
        vm.stopPrank();
        vm.startPrank(owner);
        vm.expectEmit(address(treasuryLari));
        emit Approval(owner, spender, amount);
        treasuryLari.approve(spender, amount);
        vm.stopPrank();
        vm.startPrank(spender);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(owner, to, amount);
        treasuryLari.transferFrom(owner, to, amount);
        vm.stopPrank();
        uint256 balanceOfOwnerAfter = treasuryLari.balanceOf(owner);
        assertEq(balanceOfOwnerAfter, 0);
        uint256 balanceOfTo = treasuryLari.balanceOf(to);
        assertEq(balanceOfTo, amount);
    }

    function testIfRevertIfAddressZeroIsTryingToCallBurnFunction() public {
        uint256 amount = 100e18;
        vm.startPrank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InvalidSender.selector,
                address(0)
            )
        );
        treasuryLari.burn(amount);
        vm.stopPrank();
    }

    function testIfUserCanSuccessfullyCallBurnFunction() public {
        uint256 currentTotalSupply = treasuryLari.totalSupply();
        assertEq(currentTotalSupply, 0);
        uint256 amount = 100e18;
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        uint256 currentTotalSupplyAfter = treasuryLari.totalSupply();
        assertEq(currentTotalSupplyAfter, amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, address(0), amount);
        treasuryLari.burn(amount);
        vm.stopPrank();
        uint256 currentTotalSupplyAfterBurn = treasuryLari.totalSupply();
        assertEq(currentTotalSupplyAfterBurn, 0);
    }

    function testIfRevertIfAmountIsNotApprovedWhileCallingBurnFromFunction()
        public
    {
        address owner = helperAddress10;
        address spender = helperAddress11;
        uint256 amount = 100e18;
        uint256 balanceOfOwner = treasuryLari.balanceOf(owner);
        assertEq(balanceOfOwner, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector,
                spender,
                0,
                amount
            )
        );
        vm.startPrank(spender);
        treasuryLari.burnFrom(owner, amount);
        vm.stopPrank();
    }

    // function testIfRevertIfAccountIsAddressZeroWhileCallingBurnFunction()
    //     public
    // {
    //     address account = address(0);
    //     address spender = helperAddress10;
    //     uint256 amount = 100e18;
    //     vm.startPrank(account);
    //     vm.expectEmit(address(treasuryLari));
    //     emit IERC20.Approval(account, spender, amount);
    //     treasuryLari.approve(spender, amount);
    //     vm.stopPrank();
    //     vm.startPrank(spender);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(
    //             IERC20Errors.ERC20InvalidSender.selector,
    //             account
    //         )
    //     );

    //     treasuryLari.burnFrom(account, amount);
    //     vm.stopPrank();
    // }

    function testIfSpenderCanSuccessfullyCallBurnFromFunction() public {
        address owner = helperAddress10;
        address spender = helperAddress11;
        uint256 amount = 100e18;
        uint256 balanceOfOwner = treasuryLari.balanceOf(owner);
        assertEq(balanceOfOwner, 0);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(address(0), TLWallet, amount);
        treasuryLari.mint(amount);
        uint256 balanceOfTLWallet = treasuryLari.balanceOf(TLWallet);
        assertEq(balanceOfTLWallet, amount);
        vm.startPrank(TLWallet);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(TLWallet, owner, amount);
        treasuryLari.transfer(owner, amount);
        vm.stopPrank();
        vm.startPrank(owner);
        vm.expectEmit(address(treasuryLari));
        emit Approval(owner, spender, amount);
        treasuryLari.approve(spender, amount);
        vm.stopPrank();
        vm.startPrank(spender);
        vm.expectEmit(address(treasuryLari));
        emit Transfer(owner, address(0), amount);
        treasuryLari.burnFrom(owner, amount);
        vm.stopPrank();
        uint256 balanceOfOwnerAfterBurn = treasuryLari.balanceOf(owner);
        assertEq(balanceOfOwnerAfterBurn, 0);
    }

    function testIfNoncesFunctionWorksProperly() public view {
        address user = helperAddress10;
        uint256 expectedNonce = 0;
        uint256 actualNonce = treasuryLari.nonces(user);
        assertEq(actualNonce, expectedNonce);
    }

    // function testIfDOMAIN_SEPARATORFunctionWorksProperly() public {
    //     bytes32 expectedDOMAIN_SEPARATOR = keccak256(
    //         abi.encode(
    //             keccak256(
    //                 "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    //             ),
    //             keccak256("Treasury Lari"),
    //             keccak256("1"),
    //             1,
    //             address(this)
    //         )
    //     );
    //     bytes32 actualDOMAIN_SEPARATOR = treasuryLari.DOMAIN_SEPARATOR();
    //     assertEq(actualDOMAIN_SEPARATOR, expectedDOMAIN_SEPARATOR);
    // }

    function testIfeip712DomainFunctionWorksProperly() public view {
        bytes1 expectedFields = hex"0f";
        string memory expectedName = "Treasury Lari";
        string memory expectedVersion = "1";
        uint256 expectedChainId = 31337;
        address expectedVerifyingContract = address(treasuryLari);
        bytes32 expectedSalt = bytes32(0);
        uint256[] memory expectedExtensions = new uint256[](0);
        (
            bytes1 actualFields,
            string memory actualName,
            string memory actualVersion,
            uint256 actualChainId,
            address actualVerifyingContract,
            bytes32 actualSalt,
            uint256[] memory actualExtensions
        ) = treasuryLari.eip712Domain();
        assertEq(actualFields, expectedFields);
        assertEq(actualName, expectedName);
        assertEq(actualVersion, expectedVersion);
        assertEq(actualChainId, expectedChainId);
        assertEq(actualVerifyingContract, expectedVerifyingContract);
        assertEq(actualSalt, expectedSalt);
        assertEq(actualExtensions, expectedExtensions);
    }

    function testIfRevertIfDeadlineIsExpiredWhileCallingPermitFunction()
        public
    {
        address owner = publicKey;
        address spender = helperAddress10;
        uint256 value = 10e18;
        uint256 deadline = 0;
        uint256 nonce = treasuryLari.nonces(owner);

        // Create EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline)
        );

        // bytes32 digest = treasuryLari.hashTypedDataV4(structHash);
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                treasuryLari.DOMAIN_SEPARATOR(),
                structHash
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.startPrank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20Permit.ERC2612ExpiredSignature.selector,
                deadline
            )
        );
        treasuryLari.permit(owner, spender, value, deadline, v, r, s);
        vm.stopPrank();
    }

    function testIfRevertIfSignerIsNotValidWhileCallingPermitFunction() public {
        address owner = helperAddress11;
        address spender = helperAddress10;
        uint256 value = 10e18;
        uint256 deadline = 1000000000000;
        uint256 nonce = treasuryLari.nonces(owner);

        // Create EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline)
        );

        // bytes32 digest = treasuryLari.hashTypedDataV4(structHash);
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                treasuryLari.DOMAIN_SEPARATOR(),
                structHash
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.startPrank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20Permit.ERC2612InvalidSigner.selector,
                publicKey,
                owner
            )
        );
        treasuryLari.permit(owner, spender, value, deadline, v, r, s);
        vm.stopPrank();
    }

    function testIfUserCanSuccessfullyCallPermitFunction() public {
        address owner = publicKey;
        address spender = helperAddress10;
        uint256 value = 10e18;
        uint256 deadline = block.timestamp + 2 days;
        uint256 nonce = treasuryLari.nonces(owner);

        // Create EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline)
        );

        // bytes32 digest = treasuryLari.hashTypedDataV4(structHash);
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                treasuryLari.DOMAIN_SEPARATOR(),
                structHash
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        uint256 expectedAllowance = 0;
        uint256 actualAllowance = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowance, expectedAllowance);
        vm.expectEmit(address(treasuryLari));
        emit Approval(owner, spender, value);
        treasuryLari.permit(owner, spender, value, deadline, v, r, s);
        uint256 actualAllowanceAfter = treasuryLari.allowance(owner, spender);
        assertEq(actualAllowanceAfter, value);
    }

    function testIfRevertIfSSignatureIsInvalidWhileCallingPermitFunction()
        public
    {
        address owner = publicKey;
        address spender = helperAddress10;
        uint256 value = 10e18;
        uint256 deadline = block.timestamp + 2 days;
        uint256 nonce = treasuryLari.nonces(owner);

        // Create EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline)
        );

        // bytes32 digest = treasuryLari.hashTypedDataV4(structHash);
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                treasuryLari.DOMAIN_SEPARATOR(),
                structHash
            )
        );
        (uint8 v, bytes32 r, ) = vm.sign(privateKey, digest);
        bytes32 invalidS = bytes32(
            0x8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        );
        vm.startPrank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(
                ECDSA.ECDSAInvalidSignatureS.selector,
                invalidS
            )
        );
        treasuryLari.permit(owner, spender, value, deadline, v, r, invalidS);
        vm.stopPrank();
    }

    function testIfRevertInValidSignatureIfSignerIsAddressZero() public {
        address spender = helperAddress10;
        uint256 value = 10e18;
        uint256 deadline = block.timestamp + 2 days;
        bytes32 invalidR = bytes32(0);
        bytes32 invalidS = bytes32(0);
        uint8 invalidV = 27;
        address invalidSigner = address(0);
        vm.startPrank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(ECDSA.ECDSAInvalidSignature.selector)
        );
        treasuryLari.permit(
            invalidSigner,
            spender,
            value,
            deadline,
            invalidV,
            invalidR,
            invalidS
        );
        vm.stopPrank();
    }
}
