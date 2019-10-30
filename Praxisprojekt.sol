pragma solidity ^0.5.8;

contract Praxisprojekt {
  uint institutionCount = 0;
  uint objectCount = 0;
  uint userCount = 0;

  struct Institution {
    uint id;
    string name;
    string email;
    bytes32 password;
    string caCertificate;
  }

  struct Object {
    uint id;
    string description;
    bytes32 signature;
    uint256 timestamp;
    string link; //Where the object is actually stored. either full url or just path on the file system, probably depending on the used protocol
  }

  struct User {
    uint id;
    string firstName;
    string lastName;
    string email;
    bytes32 password;
    string caCertificate;
  }

  mapping(address => Institution) institutions;
  mapping(address => Object[]) objects;
  mapping(address => User) users;

  function createInstitution(string memory name, string memory email, string memory password) public returns(bool){
    if(!(institutions[msg.sender].id > 0)) {
        institutions[msg.sender] = Institution(institutionCount++, name, email, sha256(abi.encode(password)), "");
        return true;
    }
    return false;
  }

// *************************************** USER *******************************************************************
  function createUser(string memory firstName, string memory lastName, string memory email, string memory password, string memory caCertificate) public returns(bool){
    if(!(users[msg.sender].id > 0)) {
        users[msg.sender] = User(userCount++, firstName, lastName, email, sha256(abi.encode(password)), caCertificate);
        return true;
    }
    return false;
  }
  
  function authenticate(string memory user, string memory password) public view returns(bool) {
  	return streql(user, users[msg.sender].email) && sha256(abi.encode(password)) == users[msg.sender].password;
  }
  
  function getUserFirstName() public view returns (string memory) {
    return users[msg.sender].firstName;
  }
  function getUserLastName() public view returns (string memory) {
    return users[msg.sender].lastName;
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

// **********************************************************************************************************
  
// *************************************** Object *******************************************************************
  function getObjectLink(string memory description) public view returns(string memory) {
    return getObject(description).link;
  }

  function createObject(string memory description, string memory link) public returns(bool) {
    if(streql(getObjectLink(description), "")) {
      objects[msg.sender].push(Object(objectCount++, description, keccak256(abi.encode(link)), now, link));
      return true;
    }
    return false;
  }

  //Returns the n'th (user_document_id'th) object of the sender
  function getObjectById(uint user_document_id) public view returns(string memory, string memory) {
  	Object memory o = objects[msg.sender][user_document_id];
    return (o.description, o.link);
  }

  function getObjectCount() public view returns(uint) {
  	return objects[msg.sender].length;
  }

  //Deletes the object from the list but seems to keep the array length the same as before
  function invalidateObject(string memory description) public returns(bool) {
    int index = findObject(description);
    if(index < 0) return false;
    
    for(uint j = uint(index); j < objects[msg.sender].length - 1; j++) {
        objects[msg.sender][j] = objects[msg.sender][j + 1];
    }
    delete objects[msg.sender][objects[msg.sender].length - 1];
    objects[msg.sender].length--;
  }
// **********************************************************************************************************

  //Returns the object to a description. Not public because I don't know how structs are published to an outside referrer
  function getObject(string memory description) private view returns(Object memory) {
    uint objects_length = objects[msg.sender].length;
    for(uint i = 0; i < objects_length; i++) {
    	if(streql(objects[msg.sender][i].description, description)) return objects[msg.sender][i];
    }
  }
  
  //Returns the index of the object with this description, -1 if none exists
  function findObject(string memory description) private view returns(int) {
      uint objects_length = objects[msg.sender].length;
      for(uint i = 0; i < objects_length; i++) {
          if(streql(objects[msg.sender][i].description, description)) return int(i);
      }
      return -1;
  }

  function streql(string memory arg1, string memory arg2) private pure returns(bool) {
    return keccak256(abi.encode(arg1)) == keccak256(abi.encode(arg2));
  }
}
