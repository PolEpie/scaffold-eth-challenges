// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

    ExampleExternalContract public exampleExternalContract;

    mapping ( address => uint256 ) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool public openForWithdraw = false;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    modifier notCompleted() {
        require(exampleExternalContract.completed() == false, "threshold is completed");
        _;
    }

    event Stake(address _from, uint256 _amount);

    function stake() public payable {
        //require(balances[msg.sender] + msg.value <= threshold, "You can't stack more than 1ETH");

        balances[msg.sender] += msg.value;

        emit Stake(msg.sender, msg.value);

        //if (address(this).balance >= threshold) {
        //    exampleExternalContract.complete{value: address(this).balance}();
        //}
    }

    function execute() public notCompleted {
        require(timeLeft() == 0, "deadLine hasn't expired");

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function timeLeft() public view returns (uint256) {
        if (deadline <= block.timestamp ) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function withdraw(address payable accountTo) external notCompleted {
        require(openForWithdraw == true, "You can't withdraw");
        require(balances[msg.sender] > 0, "You don't have any coin stacked");

        accountTo.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }


    receive() external payable {
        stake();
    }


    // Add the `receive()` special function that receives eth and calls stake()


}
