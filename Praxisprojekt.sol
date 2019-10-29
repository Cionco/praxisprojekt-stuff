pragma solidity ^0.5.8;

contract Praxisprojekt {
  uint institutionCount = 0;
  uint objectCount = 0;
  uint userCount = 0;

  struct Institution {
    uint institutionId;
    string name;
    string email;
    bytes32 password;
    string caCertificate;
  }

  struct Object {
    uint documentId;
    string description;
    bytes32 signature;
    uint256 timestamp;
    string documentContent;
  }

  struct User {
    uint userId;
    string firstName;
    string lastName;
    string passportNumber;
    string email;
    bytes32 password;
    string caCertificate;
  }

  mapping(address => Institution) institutions;
  mapping(address => Object[]) objects;
  mapping(address => User) users;

  function createInstitution(string memory name, string memory email, string memory password) public returns(bool){
    if(!(institutions[msg.sender].institutionId > 0)) {
        institutions[msg.sender] = Institution(institutionCount++, name, email, sha256(abi.encode(password)), "");
        return true;
    }
    return false;
  }

  function createUser(string memory firstName, string memory lastName, string memory passportNumber, string memory email, string memory password, string memory caCertificate) public returns(bool){
    if(!(users[msg.sender].userId > 0)) {
        users[msg.sender] = User(userCount++, firstName, lastName, passportNumber, email, sha256(abi.encode(password)), caCertificate);
        return true;
    }
    return false;
  }

  function createObject(string memory description, string memory documentContent) public returns(bool) {
    if(streql(getObject(description), "")) {
      objects[msg.sender].push(Object(objectCount++, description, keccak256(abi.encode(documentContent)), now, documentContent));
      return true;
    }
    return false;
  }

  function getUserFirstName() public view returns (string memory) {
    return users[msg.sender].firstName;
  }
  function getUserLastName() public view returns (string memory) {
    return users[msg.sender].lastName;
  }

  function getUserPassportNumber() public view returns (string memory) {
    return users[msg.sender].passportNumber;
  }

  function getUserEmail() public view returns (string memory) {
    return users[msg.sender].email;
  }

  function getUserPassword() public view returns (bytes32) {
    return users[msg.sender].password;
  	}
  function getUserCaCertificate() public view returns (string memory) {
    return users[msg.sender].caCertificate;
  }

  function getObject(string memory description) public view returns(string memory) {
  	uint objects_length = objects[msg.sender].length;
    for(uint i = 0; i < objects_length; i++) {
    	if(streql(objects[msg.sender][i].description, description)) return objects[msg.sender][i].documentContent;
    }
  }

  function getObjectById(uint document_id) public view returns(string memory, string memory) {
  	Object memory o = objects[msg.sender][document_id];
    return (o.description, o.documentContent);
  }

  function getObjectCount() public view returns(uint) {
  	return objects[msg.sender].length;
  }


  function streql(string memory arg1, string memory arg2) private pure returns(bool) {
    return keccak256(abi.encode(arg1)) == keccak256(abi.encode(arg2));
  }

  function authenticate(string memory user, string memory password) public view returns(bool) {
  	return streql(user, users[msg.sender].email) && sha256(abi.encode(password)) == users[msg.sender].password;
  }
}
