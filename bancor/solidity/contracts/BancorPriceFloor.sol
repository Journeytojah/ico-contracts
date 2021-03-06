pragma solidity ^0.4.11;
import './TokenHolder.sol';
import './SafeMath.sol';
import './ISmartToken.sol';
import './Owned.sol';

/*
    BancorPriceFloor v0.1

    The bancor price floor contract is a simple contract that allows selling smart tokens for a constant ETH price

    'Owned' is specified here for readability reasons
*/
contract BancorPriceFloor is Owned, TokenHolder, SafeMath {
    uint256 public constant TOKEN_PRICE_N = 1;      // crowdsale price in wei (numerator)
    uint256 public constant TOKEN_PRICE_D = 100;    // crowdsale price in wei (denominator)

    string public version = '0.1';
    ISmartToken public token; // smart token the contract allows selling

    /**
        @dev constructor

        @param _token   smart token the contract allows selling
    */
    function BancorPriceFloor(ISmartToken _token)
        validAddress(_token)
    {
        token = _token;
    }

    /**
        @dev sells the smart token for ETH
        note that the function will sell the full allowance amount

        @return ETH sent in return
    */
    function sell() public returns (uint256 amount) {
        uint256 allowance = token.allowance(msg.sender, this); // get the full allowance amount
        assert(token.transferFrom(msg.sender, this, allowance)); // transfer all tokens from the sender to the contract
        uint256 etherValue = safeMul(allowance, TOKEN_PRICE_N) / TOKEN_PRICE_D; // calculate ETH value of the tokens
        msg.sender.transfer(etherValue); // send the ETH amount to the seller
        return etherValue;
    }

    /**
        @dev withdraws ETH from the contract

        @param _amount  amount of ETH to withdraw
    */
    function withdraw(uint256 _amount) public ownerOnly {
        assert(msg.sender.send(_amount)); // send the amount
    }

    /**
        @dev deposits ETH in the contract
    */
    function() public payable {
    }
}
