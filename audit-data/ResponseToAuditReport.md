# Responses

# N.B. I know that in private audit proof of concept is not mandatory but as there are only a few issues in this smart contract, proof of concept would be highly appreciated for the next audit report!!!

## High

### **Issue 1 : Missing `burn()` and `burnFrom()` Functions**

**Description:** Those two functions were implemented in the ERC20 smart contract which was inherited by the TreasuryLari smart contract. The ERC20 smart contract which was used in the TreasuryLari.s.sol file is a modified ERC20 smart contract of the openzeppelin ERC20 as we needed some additional logic.

```solidity

515    function burn(uint256 value) public virtual {
516        _burn(_msgSender(), value);
517    }

```

```solidity
530        function burnFrom(address account, uint256 value) public virtual {
531        _spendAllowance(account, _msgSender(), value);
532        _burn(account, value);
533    }
```

Proof of concept:

```solidity
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

```

```solidity
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
```

## Medium severity

## Issue 2: Unsafe ERC20 Token Transfers Using `.call()`

**Description:** It's being used only on the withdrawStuckedAsset function which is only callable by the owner and just trying to withdraw the stucked asset. So, the owner should be kind aware of the token contract and the recipant. Also, was trying to avoid the SafeTransfer library as it wasn't being used on anywhere else. Anyway, if it is still is a big issue we can use the regular token transfer call instead as the owner will be aware of the these. Auditor's input on this will be appreciated.

## Issue 3: Missing `transfer()` and `transferFrom()` Functions

**Description:** Those two functions were implemented in the ERC20 smart contract which was inherited by the TreasuryLari smart contract. The ERC20 smart contract which was used in the TreasuryLari.s.sol file is a modified ERC20 smart contract of the openzeppelin ERC20 as we needed some additional logic.

```solidity
448  function transfer(address to, uint256 value) public virtual returns (bool) {
449        address owner = _msgSender();
450        _transfer(owner, to, value);
451        return true;
452    }
```

```solidity
499    function transferFrom(
500        address from,
501        address to,
502        uint256 value
503    ) public virtual returns (bool) {
504        address spender = _msgSender();
505        _spendAllowance(from, spender, value);
506        _transfer(from, to, value);
507        return true;
508    }
```

**Proof of concept:**

```solidity
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
```

```solidity
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
```

## Low Severity

## Issue 4: Lack of Validation in `updateTLWallet()` and `updateTaxWallet()` Functions (Already in known issues)\*\*

**Description:** Input vailidation for address zero check will be added.

## Issue 5: Missing permit() Function for Off-Chain Approvals (EIP-2612 Support)

**Description:** There is a permit function in the ERC20Permit function which is being inherited by the TreasuryLari smart contract. Also, I quite not get your explanation as well as the proposed fix, there is no function named \_permit in the ERC20Permit which you are proposing to call. Also, could you specify where are you proposing to put your proposed code? In the TreasuryLari or in the ERC20Permit?

Here is the permit function which already exists in the ERC20Permit

```solidity
1664  function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }
```

Here is a test suite code where I tested the Permit function

```solidity
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
```

## Gas Severity

## Issue 1: Cache array length outside of loop

**Description:** the array (users) is a memory array which is being taken as the function parameter, so, I'm not sure which array are you talking about.
