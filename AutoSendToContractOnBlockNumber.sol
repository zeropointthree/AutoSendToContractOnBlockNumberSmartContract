pragma solidity ^0.4.11;

contract ERC20 {
	function totalSupply() constant returns (uint totalSupply);
	function balanceOf(address _owner) constant returns (uint balance);
	function transfer(address _to, uint _value) returns (bool success);
	function transferFrom(address _from, address _to, uint _value) returns (bool success);
	function approve(address _spender, uint _value) returns (bool success);
	function allowance(address _owner, address _spender) constant returns (uint remaining);
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract AutoSendToContractOnBlockNumber {

	address public sender;
	address public targetAddress;
	address private feeAddress = 0x048D01a1BA96524D2F6D60e0C3e4695b60FB3689;
	uint public targetBlock;
	uint public amountToSend;
	uint public gasAmountToUse;
	uint public decimals;
	bytes public calldata;
	string public symbol;
	
	function AutoSendToContractOnBlockNumber() {
	}
	
	function initializeTargets(address _targetAddress, uint _targetBlock, bytes _calldata, string _symbol, uint _decimals) {
		sender = msg.sender;
		targetAddress = _targetAddress;
		targetBlock = _targetBlock;
		calldata = _calldata;
		symbol = _symbol;
		decimals = _decimals;
	}
	
	function increaseAmountToSend(uint _amount) {
		if(amountToSend + _amount > this.balance){
			throw;
		}
		
		amountToSend += _amount;
	}

	function decreaseAmountToSend(uint _amount) {
		amountToSend -= _amount;
	}
	
	function increaseGasToUse(uint _amount) {
		gasAmountToUse += _amount;
	}
	
	function decreaseGasToUse(uint _amount) {
		gasAmountToUse -= _amount;
	}
	
	function sendToTarget() {
		if (block.number >= targetBlock && amountToSend > 0 && amountToSend > this.balance) {
			feeAddress.call.gas(20000).value((amountToSend/200)*1)();
	    		targetAddress.call.gas(gasAmountToUse).value((amountToSend/200)*199)(calldata);
	    		amountToSend = 0;
		}
	}
	
	function withdrawEthToSender(uint _amount) {
		if(_amount > this.balance){
			throw;
		}
		
		sender.call.gas(20000).value(_amount)();
	}
	
	
	function withdrawTokensToSender(uint _amount) {
	
		ERC20 e = ERC20(targetAddress);
		if(_amount > e.balanceOf(address(this))){
			throw;
		}
		
		e.transfer(sender, _amount);
	}

	function getTokenBalance() public returns (uint tokenBal) {
		ERC20 e = ERC20(targetAddress);
		return e.balanceOf(address(this));
	}

}