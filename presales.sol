pragma solidity ^0.4.16;

interface token{
    function transfer (address receiver,uint amount) public;
    function getBalance(address _funderAddress) public returns (uint);
}

contract NavroPresale {
    address public beneficiary;
    uint public amountRaised;
    uint public fundingGoalInEthersPresale;
    uint public preSaleDeadlineInDays;
    uint public preSalePrice;

    token public tokenReward;
    mapping (address=>uint) balanceOf;
    bool fundingGoalPresaleReached = false;
    bool preSaleClosed = false;
    

    event GoalReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    event Withdrawal(address _beneficiary, uint _amountRaised, uint _time);
    
    
   
    
    
    /* Constructor */
    function NavroPresale(address _ifSuccessfulSendTo,uint _fundingGoalInWeiPresale,
    uint _preSaleDeadlineInDays,uint _preSaleWeiCostOfEachToken,
    address _addressOfTokenUsedAsReward) public
    {
        beneficiary = _ifSuccessfulSendTo;
        fundingGoalInEthersPresale = _fundingGoalInWeiPresale;
        preSaleDeadlineInDays = now + _preSaleDeadlineInDays * 1 days;
        preSalePrice = _preSaleWeiCostOfEachToken;
        tokenReward = token(_addressOfTokenUsedAsReward);
    }

    function () payable{
        require(!preSaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender,(amount/preSalePrice)*1000000000000000000);
        FundTransfer(msg.sender,amount,true);
    }

     
    modifier afterPreSalesdeadline(){
        if(now >= preSaleDeadlineInDays){
            _;
        }
    }

    
    function checkPreSalesGoalReached()  public afterPreSalesdeadline{
        if(amountRaised >= fundingGoalInEthersPresale){
            fundingGoalPresaleReached = true;
            preSaleClosed = true;
            GoalReached(beneficiary,amountRaised);
        }
        preSaleClosed = true;
    }
    

    
    function withdrawal() public{

        if(beneficiary == msg.sender){
            if(beneficiary.send(amountRaised)){
                    Withdrawal(beneficiary,amountRaised,now);
                    FundTransfer(beneficiary,amountRaised,false);
                }

        }

    }
    
     function getBalance(address _funderAddress) view public returns (uint){
       return tokenReward.getBalance(_funderAddress);
    }

}