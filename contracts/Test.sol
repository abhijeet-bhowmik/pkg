// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import './SafeMath.sol';

contract Test {
    uint256 public state;
    uint256 public factor;

    using SafeMath for uint256;

    event StateChange(address setter, uint256 prev, uint256 curr);

    constructor(uint256 initState, uint256 initFactor) {
        require(initState.isMultipleOf(initFactor));
        state = initState;
        factor = initFactor;

        emit StateChange(msg.sender, 0, initFactor);
    }

    function set(uint256 stateValue) public returns(uint256) {
        require(stateValue.isMultipleOf(factor));

        uint256 prevValue = state;
        state = stateValue;

        emit StateChange(msg.sender, prevValue, state);

        return state;

    }
}


