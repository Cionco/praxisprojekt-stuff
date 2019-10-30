pragma solidity ^0.5.8;

///@title Praxisprojekt 2019 Smart contract
///@author Jan Ludwig & Nicolas Kepper
///@notice Takes care of all read and write operations on the blockchain
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

  ///@notice Maps a new Institution Object on the sender's address
  ///@param name Institution's name
  ///@param email Institution's login email
  ///@param password Institution's login password
  ///@return true, if successfully created; false if there's already an institution mapped on the sender's address
  ///@dev not really in use yet, will be important for later steps
  function createInstitution(string memory name, string memory email, string memory password) public returns(bool){
    if(!(institutions[msg.sender].id > 0)) {
        institutions[msg.sender] = Institution(institutionCount++, name, email, sha256(abi.encode(password)), "");
        return true;
    }
    return false;
  }

// *************************************** USER *******************************************************************

  ///@notice Maps a new User Object on the sender's address
  ///@param firstName User's first name
  ///@param lastName User's last name
  ///@param email User's login email
  ///@param password User's login password
  ///@param caCertificate User's certificate that proves that he is who he claims to be
  ///@return true, if successfully created; false if there's already a User mapped on the sender's address
  function createUser(string memory firstName, string memory lastName, string memory email, string memory password, string memory caCertificate) public returns(bool){
    if(!(users[msg.sender].id > 0)) {
        users[msg.sender] = User(userCount++, firstName, lastName, email, sha256(abi.encode(password)), caCertificate);
        return true;
    }
    return false;
  }

  ///@notice Checks if credentials match the one's given at registration
  ///@param user Login Username/Email
  ///@param password Login password
  ///@return true, if md5 hashes of usernames/emails and sha256 hashes of passwords match
  function authenticate(string memory user, string memory password) public view returns(bool) {
  	return streql(user, users[msg.sender].email) && sha256(abi.encode(password)) == users[msg.sender].password;
  }

  ///@return the first name of the User mapped to this address
  function getUserFirstName() public view returns (string memory) {
    return users[msg.sender].firstName;
  }

  ///@return the last name of the User mapped to this address
  function getUserLastName() public view returns (string memory) {
    return users[msg.sender].lastName;
  }

  ///@return the email of the User mapped to this address
  function getUserEmail() public view returns (string memory) {
    return users[msg.sender].email;
  }

  ///@return the hashed password of the User mapped to this address
  function getUserPassword() public view returns (bytes32) {
    return users[msg.sender].password;
  }

  ///@return the Certificate string of the User mapped to this address
  function getUserCaCertificate() public view returns (string memory) {
    return users[msg.sender].caCertificate;
  }

// **********************************************************************************************************

// *************************************** Object *******************************************************************
  ///@notice Adds a new Object to the array of objects mapped to the sender's address
  ///@param description The desired name of the Object/Document
  ///@param link The link to where the file is actually stored
  ///@param signature The Object's/Document's signature
  ///@return true, if successfully created; false if there's already an Object with the same description in this user's array
  function createObject(string memory description, string memory link, string signature) public returns(bool) {
    if(streql(getObjectLink(description), "")) {
      objects[msg.sender].push(Object(objectCount++, description, signature, now, link));
      return true;
    }
    return false;
  }

  ///@notice searches for an Object and returns the corresponding link
  ///@param description the description of the object that's supposed to be found
  ///@return the link stored for the object or "" if there's no object with this description
  function getObjectLink(string memory description) public view returns(string memory) {
    return getObject(description).link;
  }

  ///@notice Finds and returns the n'th (user_document_id'th) object of the sender
  ///@param user_document_id index of the object starting at 0 for each user
  ///@return description and link of the object or ("", "") if the index does not exist
  ///@dev combine with getObjectCount() to get a list of all descriptions and links for a user as returning arrays of more than one value seems too tricky in solidity
  function getObjectById(uint user_document_id) public view returns(string memory, string memory) {
    if(user_document_id >= objects[msg.sender].length) return ("", "");
  	Object memory o = objects[msg.sender][user_document_id];
    return (o.description, o.link);
  }

  ///@notice How many objects are stored for the user mapped to the sender's address?
  ///@return Amount of Objects stored for this user
  ///@dev combine with getObjectById(uint) to get a list of all descriptions and links for a user as returning arrays of more than one value seems too tricky in solidity
  function getObjectCount() public view returns(uint) {
  	return objects[msg.sender].length;
  }

  ///@notice Delete an Object from the User's list of objects
  ///@param description Description of the object that should be deleted
  ///@return true if successfully deleted, false if the description could not be found
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

  ///@notice Returns the object to a description.
  ///@param description description of the object
  ///@return Object with the specified description, probably "{}" but i actually don't know because I didn't really test it
  ///@dev Not public because structs can't be returned to the outside just like that
  function getObject(string memory description) private view returns(Object memory) {
    uint objects_length = objects[msg.sender].length;
    for(uint i = 0; i < objects_length; i++) {
    	if(streql(objects[msg.sender][i].description, description)) return objects[msg.sender][i];
    }
  }

  //Returns the index of the object with this description, -1 if none exists
  ///@notice Finds and returns the index of the object in the list of objects of the right user with the specified description
  ///@param desciprion description of the object
  ///@return index of the object or -1 if description can't be found
  function findObject(string memory description) private view returns(int) {
      uint objects_length = objects[msg.sender].length;
      for(uint i = 0; i < objects_length; i++) {
          if(streql(objects[msg.sender][i].description, description)) return int(i);
      }
      return -1;
  }

  ///@notice Compares two strings and checks if they're equal
  ///@param arg1 first string
  ///@param arg2 second string
  ///@return true if the md5 hashes of both strings match, false if not
  function streql(string memory arg1, string memory arg2) private pure returns(bool) {
    return keccak256(abi.encode(arg1)) == keccak256(abi.encode(arg2));
  }
}
