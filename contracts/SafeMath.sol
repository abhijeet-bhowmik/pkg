// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;


library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

    function isMultipleOf(uint256 dividend, uint256 divisor) internal pure returns (bool) {
        assert(dividend >= divisor);
        return dividend % divisor == 0;
    }
}