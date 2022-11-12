contract Contracts {
    // Nested mapping (mapping from address to another mapping)
    mapping(string => mapping(string => bool)) public contracts;

    function get(string memory email_source, string memory email_target) public view returns (bool) {
        // You can get values from a nested mapping
        // even when it is not initialized
        return contracts[email_source][email_target];
    }

    function set(
        string memory email_source,
        string memory email_target,
        bool status
    ) public {
        contracts[email_source][email_target] = status;
    }

    function remove(string memory email_source, string memory email_target) public {
        delete contracts[email_source][email_target];
    }

    function getall(string memory source_email) public view returns (string){
        string memory s = "";
      for (uint i = 0; i < length; i++) {
        s = string(abi.encodePacked(s, contractStructs[email_source].targetEmailIndex[i]));
        s = string(abi.encodePacked(s, ", "));
      }
      return s;
      
    }
}



