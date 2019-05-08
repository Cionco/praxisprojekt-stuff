pragma solidity >=0.4.22 <0.6.0;

contract Identity {
    struct User {
        uint age;
        bytes32[] fingerprints;
        bytes32 id_code;
        mapping(string => string) documents;
    } 
    
    enum AuthenticationMethod {
        FINGERPRINT, ID
    }
    
    bytes4[] private methods;
    
    constructor() public {
        methods.push(bytes4(keccak256("idAuthentication(bytes32)")));
        methods.push(bytes4(keccak256("fingerprintAuthentication(bytes32)")));
    }
    
    mapping(address => User) users;
    
    function registerUser(uint age, string id_code) public {
        address sender = msg.sender;
        if(users[sender].age > 0) return;
        users[sender].age = age;
        users[sender].id_code = keccak256(id_code);
    }
    
    function addFingerprint(bytes32 fingerprintToAdd, AuthenticationMethod method, bytes32 authenticationBytes, string authenticationString) public {
        address sender = msg.sender;
        if(bytes(authenticationString).length != 0) authenticationBytes = keccak256(authenticationString);
        if(!authenticate(authenticationBytes, method)) return;
        users[sender].fingerprints.push(fingerprintToAdd);
    }
    
    function addDocument(string documentToAdd, string documentKey, AuthenticationMethod method, bytes32 authenticationBytes, string authenticationString) public {
        address sender = msg.sender;
        if(bytes(authenticationString).length != 0) authenticationBytes = keccak256(authenticationString);
        if(!authenticate(authenticationBytes, method)) return;
        if(keccak256(users[sender].documents[documentKey]) != keccak256("")) return;
        users[sender].documents[documentKey] = documentToAdd;
    }
    
    function loginWithFingerprint(bytes32 fingerprint) public view returns (bool loginSuccessfull) {
        return authenticate(fingerprint, AuthenticationMethod.FINGERPRINT);
    }
    
    function loginWithId(string id_code) public view returns (bool loginSuccessfull) {
        return authenticate(keccak256(id_code), AuthenticationMethod.ID);
    }
    
    function authenticate(bytes32 byteAuthentication, AuthenticationMethod method) internal view returns (bool) {
        if(method == AuthenticationMethod.FINGERPRINT) return fingerprintAuthentication(byteAuthentication);
        else if(method == AuthenticationMethod.ID) return idAuthentication(byteAuthentication);
        
        //return this.call(methods[uint(method)], byteAuthentication);
    }
    
    function idAuthentication(bytes32 id_code) private view returns (bool) {
        User memory u = users[msg.sender];
        if(u.age == 0) return false;
        return id_code == u.id_code;
    }
    
    function fingerprintAuthentication(bytes32 fingerprint) private view returns (bool) {
        User memory u = users[msg.sender];
        if(u.age == 0) return false;
        for(uint i = 0; i < u.fingerprints.length; i++)
            if(fingerprint == u.fingerprints[i]) return true;
        return false;
    }
    
    function getDoc(string document, bytes32 authenticationBytes, string authenticationString, AuthenticationMethod method) public view returns (string) {
        if(bytes(authenticationString).length != 0) authenticationBytes = keccak256(authenticationString);
        if(!authenticate(authenticationBytes, method)) return "Access Rejected";
        User storage u = users[msg.sender];
        return u.documents[document];
    }
}