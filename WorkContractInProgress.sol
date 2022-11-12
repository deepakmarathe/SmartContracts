pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;

contract UserCrud {

  struct UserStruct {
    string userEmail;
    string dob;
    uint index;
  }

  struct WorkContractItem {
      bool is_terminated_source;
      bool is_terminated_target;
      uint256 start_date;
      uint256 end_date;
      uint rate_dollar_per_hour;
      uint joining_bonus;
      uint notice_period_days;
      bool is_accepted_source;
      bool is_accepted_target;
      uint index;
  }

  struct WorkContractSource {
      string source_email;
      mapping (string => WorkContractItem) targetContracts;
      string[] targetEmailIndex;
      uint index;
  }

  struct WorkContractTarget {
      string target_email;
      mapping (string => WorkContractItem) sourceContracts;
      string[] sourceEmailIndex;
      uint index;
  }

  mapping(address => UserStruct) private userStructs;
  address[] private userIndex;

  mapping(string => WorkContractSource) private contractStructsSource;
  mapping(string => WorkContractTarget) private contractStructsTarget;
  string[] private emailIndex;

  mapping(string => mapping(string => WorkContractSource)) private terminatedContracts;
  
  event LogNewUser   (address indexed userAddress, uint index, string userEmail, string dob);
  event LogUpdateUser(address indexed userAddress, uint index, string userEmail, string dob);
  

    function fallback() external  payable{
        // custom function code
    }

    function receive() external payable {
        // custom function code
    }

  function isUser(address userAddress)
    public 
    view
    returns(bool isIndeed) 
  {
    if(userIndex.length == 0) return false;
    return (userIndex[userStructs[userAddress].index] == userAddress);
  }

    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

  function isContract(string memory source_email, string memory target_email)
    public 
    view
    returns(bool isIndeed) 
  {
    if(emailIndex.length == 0) return false;
    return compareStrings(emailIndex[contractStructsSource[source_email].index], source_email) && 
    contractStructsSource[source_email].targetContracts[target_email].is_accepted_source == true &&
    contractStructsSource[source_email].targetContracts[target_email].is_accepted_target == true && 
    contractStructsSource[source_email].targetContracts[target_email].is_terminated_source == false &&
    contractStructsSource[source_email].targetContracts[target_email].is_terminated_target == false;
  }

  function insertUser(
    address  userAddress, 
    string memory userEmail, 
    string memory dob) 
    public
    returns(uint index)
  {
    assert(!isUser(userAddress));
    userStructs[userAddress].userEmail = userEmail;
    userStructs[userAddress].dob = dob;
    userStructs[userAddress].index     = userIndex.push(userAddress)-1;
    emit LogNewUser(
        userAddress, 
        userStructs[userAddress].index, 
        userEmail,
        dob);
    return userIndex.length-1;
  }
  
  function insertContract(
    string memory email_source, 
    string memory email_target)
    public
    returns(uint index)
  {
        require(compareStrings(email_source, email_target) == false, "contracts cannot be between the same emails.");
        // require(isContract(email_source, email_target) == false, "a contract exists.");
      
        
        if ( isContract(email_source, email_target) == true ){
            if ( contractStructsSource[email_source].targetContracts[email_target].is_terminated_source == true || contractStructsSource[email_source].targetContracts[email_target].is_terminated_target == true )
            {
                contractStructsSource[email_source].targetContracts[email_target].is_terminated_source = false;
                contractStructsSource[email_source].targetContracts[email_target].is_terminated_target = false;
                contractStructsSource[email_source].targetContracts[email_target].start_date = block.timestamp;

                contractStructsTarget[email_target].sourceContracts[email_source].is_terminated_source = false;
                contractStructsTarget[email_target].sourceContracts[email_source].is_terminated_target = false;
                contractStructsTarget[email_target].sourceContracts[email_source].start_date = block.timestamp;
            } 
        } else {
            contractStructsSource[email_source].source_email = email_source;
            contractStructsSource[email_source].targetContracts[email_target].is_accepted_source = true;
            contractStructsSource[email_source].targetContracts[email_target].is_accepted_target = true;
            contractStructsSource[email_source].targetContracts[email_target].index = contractStructsSource[email_source].targetEmailIndex.push(email_target) - 1;

            contractStructsSource[email_source].index = emailIndex.push(email_source) - 1;
          
            contractStructsTarget[email_target].target_email = email_target;
            contractStructsTarget[email_target].sourceContracts[email_source].is_accepted_source = true;
            contractStructsTarget[email_target].sourceContracts[email_source].is_accepted_target = true;
            contractStructsTarget[email_target].sourceContracts[email_source].index = contractStructsTarget[email_target].sourceEmailIndex.push(email_source) - 1;            
        }     
    return emailIndex.length-1;
  }
  
    function terminateContract(string memory email_source, string memory email_target) public {
        require(isContract(email_source, email_target) == true, "a contract does not exist.");

        uint256 d = block.timestamp;
        
        contractStructsSource[email_source].targetContracts[email_target].is_terminated_source = true;
        contractStructsSource[email_source].targetContracts[email_target].is_terminated_target = true;
        contractStructsSource[email_source].targetContracts[email_target].end_date = d;
        
        contractStructsTarget[email_target].sourceContracts[email_source].is_terminated_source = true;
        contractStructsTarget[email_target].sourceContracts[email_source].is_terminated_target = true;
            
    }

  function getUser(address userAddress) 
    public 
    view
    returns(string memory userEmail, string memory dob, uint index)
    
  {
    assert(isUser(userAddress));
    return(
      userStructs[userAddress].userEmail, 
      userStructs[userAddress].dob, 
      userStructs[userAddress].index
      );
  } 
  
  function getSourceContracts(string memory email_source) public view returns (string memory targets) {
      uint length = contractStructsSource[email_source].targetEmailIndex.length;
      
      string memory s = "";
      for (uint i = 0; i < length; i++) {
        s = string(abi.encodePacked(s, contractStructsSource[email_source].targetEmailIndex[i]));
        s = string(abi.encodePacked(s, ", "));
      }
      return s;
  }

  function getTargetContracts(string memory email_target) public view returns (string memory targets) {
      uint length = contractStructsTarget[email_target].sourceEmailIndex.length;
      
      string memory s = "";
      for (uint i = 0; i < length; i++) {
        s = string(abi.encodePacked(s, contractStructsTarget[email_target].sourceEmailIndex[i]));
        s = string(abi.encodePacked(s, ", "));
      }
      return s;
  }

  function getContract(string memory email_source, string memory email_target) 
    public 
    view
    returns( 
            uint256  start_date, 
            uint256  end_date, 
            bool  is_accepted_source,
            bool  is_accepted_target,
            bool is_terminated_source,
            bool is_terminated_target,
            uint  rate)
            {
    return(
      contractStructsSource[email_source].targetContracts[email_target].start_date,
      contractStructsSource[email_source].targetContracts[email_target].end_date,
      contractStructsSource[email_source].targetContracts[email_target].is_accepted_source,
      contractStructsSource[email_source].targetContracts[email_target].is_accepted_target,
      contractStructsSource[email_source].targetContracts[email_target].is_terminated_source,
      contractStructsSource[email_source].targetContracts[email_target].is_terminated_target,
      contractStructsSource[email_source].targetContracts[email_target].rate_dollar_per_hour
      );
  } 

  function updateUserEmail(address userAddress, string memory userEmail, string memory dob) 
    public
    returns(bool success) 
  {
    assert(isUser(userAddress));
    userStructs[userAddress].userEmail = userEmail;
    userStructs[userAddress].dob = dob;
    
    emit LogUpdateUser(
      userAddress, 
      userStructs[userAddress].index,
      userEmail, 
      dob);
    return true;
  }
  
  function updateUserDOB(address userAddress, string memory dob) 
    public
    returns(bool success) 
  {
    assert(isUser(userAddress));
    userStructs[userAddress].dob = dob;
    emit LogUpdateUser(
      userAddress, 
      userStructs[userAddress].index,
      userStructs[userAddress].userEmail, 
      userStructs[userAddress].dob);
    return true;
  }

  function getUserCount() 
    public
    view
    returns(uint count)
  {
    return userIndex.length;
  }

  function getUserAtIndex(uint index)
    public
    view
    returns(address userAddress)
  {
    return userIndex[index];
  }
}



