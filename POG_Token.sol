pragma solidity 0.4.24;
import "./Ownable.sol";

contract POG_Token is Ownable{
    string public name = "POG_Token";
    uint public POGTPrice = 1000000; // 1 klay = 1000000POTG
    mapping (address => uint) public balanceOf;
    
    constructor(){}

    function buyPOGT () payable  public{
        uint amountPOGT = msg.value / POGTPrice;
        balanceOf[msg.sender] += amountPOGT;
    }
    function withdraw(uint _amount) onlyOwner public {
        msg.sender.transfer(_amount);
    }
    function refunds() public {
        uint klayValue = balanceOf[msg.sender] * POGTPrice;
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(klayValue);
    }
}