import React from 'react'
import ReactDOM from 'react-dom'
import Web3 from 'web3'
import TruffleContract from 'truffle-contract'
import Content from './Content'
import "./App.css";
import 'bootstrap/dist/css/bootstrap.css'

var Web3 = require('web3');
var Eth = require('web3-eth');

// hierfür muss das RPC interface freigeschaltet sein
// geth --rpc --rpcaddr localhost --rpcport 8545 --rpccorsdomain '*'
// geth --mine --testnet --rpc --rpcaddr "localhost" --rpcport "8545" --rpcapi "web3,eth" --rpccorsdomain "http://localhost:8545"

if (window.ethereum){
  //Only used for MetaMask
  const web3 = new Web3(window.ethereum);
  await window.ethereum.enable();
} else if (typeof web3 !== ‘undefined’) {
  //Used for ethereum-compaitble browsers
  const web3 = new Web3(web3.currentProvider);
} else {
   const web3 = new Web3(new Web3.providers.HttpProvider('http://85.214.70.226:8545'));

/*
  Server 1 - 85.214.70.226
    ff55adc8cc588435bfc23bb8b60ea52b72141e39bed98cd09e1c2b9df84c9b17ba0957d975a7efb35644dbe02be43969b9631ee4ca9f2d87c9c06e83d22d08f8
  Server 2 - 85.214.50.129
    80195015e90c555e3b18edd27fc90d1421b7d23906b6904d1efcf3aa769be38ac0cbe5e676fad8d232c6ccd309436b7d31646a4c632a620fa297bfd1e369ff92
  Server 3 - 85.214.74.229
    e9d30dcb4c26371a0f99cae89df5ab020eeceb80113d2c7394e70a874135046a1a4dc54741c2e809c4a3d9fc1297fabd3db90159c4c264816121dfd90d17a012
*/

 }

 web3.eth.getProtocolVersion()
 .then(console.log);

//this.web3 = new Web3('http://localhost:8545')
//var Praxisprojekt = web3.eth.contract(ABI);
//var NodeAddress = sampleContract.at(ff55adc8cc588435bfc23bb8b60ea52b72141e39bed98cd09e1c2b9df84c9b17ba0957d975a7efb35644dbe02be43969b9631ee4ca9f2d87c9c06e83d22d08f8);

const Praxisprojekt = web3.eth.Contract(
  [{
    "constant": true,
    "inputs": [{"name": "description", "type": "string"}],
    "name": "getObject",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": false,
    "inputs": [{"name": "firstName", "type": "string"}, {
      "name": "lastName",
      "type": "string"
    }, {"name": "passportNumber", "type": "string"}, {
      "name": "email",
      "type": "string"
    }, {"name": "password", "type": "string"}, {"name": "caCertificate", "type": "string"}],
    "name": "createUser",
    "outputs": [{"name": "", "type": "bool"}],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getUserPassword",
    "outputs": [{"name": "", "type": "bytes32"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getUserFirstName",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getObjectCount",
    "outputs": [{"name": "", "type": "uint256"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [{"name": "user", "type": "string"}, {"name": "password", "type": "string"}],
    "name": "authenticate",
    "outputs": [{"name": "", "type": "bool"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": false,
    "inputs": [{"name": "name", "type": "string"}, {
      "name": "email",
      "type": "string"
    }, {"name": "password", "type": "string"}],
    "name": "createInstitution",
    "outputs": [{"name": "", "type": "bool"}],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getUserEmail",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [{"name": "document_id", "type": "uint256"}],
    "name": "getObjectById",
    "outputs": [{"name": "", "type": "string"}, {"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getUserPassportNumber",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getUserCaCertificate",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": true,
    "inputs": [],
    "name": "getUserLastName",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }, {
    "constant": false,
    "inputs": [{"name": "description", "type": "string"}, {
      "name": "documentContent",
      "type": "string"
    }],
    "name": "createObject",
    "outputs": [{"name": "", "type": "bool"}],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }]
  , ff55adc8cc588435bfc23bb8b60ea52b72141e39bed98cd09e1c2b9df84c9b17ba0957d975a7efb35644dbe02be43969b9631ee4ca9f2d87c9c06e83d22d08f8
);

web3.eth.defaultAccount = web3.eth.accounts[0];
//const accounts = await web3.eth.getAccounts();
//console.log('Sending from account: ' + accounts[0]);

/*
  var Accounts = require('web3-eth-accounts');
  var accounts = new Accounts('ws://localhost:8546');

  //Create an account with private and public key
  web3.eth.accounts.create([entropy]);

  //Sign transaction with private key
  web3.eth.accounts.signTransaction(tx, privateKey [, callback]);

  //Hash a message to be passed to another function, e.g. one that recovers the ethereum address that was used to sign a transaction
  web3.eth.accounts.hashMessage(message);

  //encript private key
  web3.eth.accounts.encrypt(privateKey, password);

  //create wallet, create accounts in wallt etc...
  web3.eth.accounts.wallet.create(numberOfAccounts [, entropy]);
  web3.eth.accounts.wallet.add(account);
  web3.eth.accounts.wallet.clear();
  web3.eth.accounts.wallet.encrypt(password);

  //store encrypted wallet as a string in local storage
  web3.eth.accounts.wallet.save(password [, keyName]);

  //Loads wallet from local storage and decryptes it
  web3.eth.accounts.wallet.load(password [, keyName]);

  //Create account from private key
  this.wallet = web3.eth.accounts.privateKeyToAccount(privateKey);
  console.debug("wallet: ",this.wallet);
  web3.eth.accounts.encrypt(privateKey, password)
  .catch(err => console.error(err));
  web3.eth.accounts.wallet.save(password [, keyName]);
  web3.eth.accounts.wallet.load(password [, keyName]);

*/

export default class FetchRandomSomething extends React.Component {

  constructor(props) {
      super(props);
      this.state = {
        loading: true,
        firstName: '',
        lastName: '',
        usertype: null,
        institutionName: '',
        email: '',
        password: '',
        passportNo: '',
        document: null,
        document_id: null,
        document_name: null,
        signature: null,
        certificat: null
      };
  }


  async register(userType, firstName, lastName, email, password) {

    //caKey mit dem das Zertifikat verifiziert werden kann, dann nur PublicKey weitergeben und speichern

    const createAccountResult = web3.eth.accounts.create(web3.utils.randomHex(32));

    if (userType = 'institutional'){
      Praxisprojekt.methods.createInstitution(firstName + " " + lastName, email, password, {from: createAccountResult.address}).send();
    } else {
      //passportNumber not required
      const registerResult = await Praxisprojekt.methods.createUser(firstName, lastName, email, password, caCertificate, {from: createAccountResult.address}).send();
    }

    web3.eth.isSyncing()
    .then(console.log);
  }

//Should probably be a hash that is stored to the blockchain. Actual file to be stored on server
  async uploadDocument(document_name, documentContent) {
    //var documentContent = fetch(this.props.ref);

    const uploadResult = await Praxisprojekt.methods.createObject(document_name, documentContent).send();

    if (uploadResult) {
      //render message "successful upload of document"
    } else {
      //Show error, then return to upload page
    }

    web3.eth.isSyncing()
    .then(console.log);

    //AUSBAUSTUFE 2: HASHES DES DOKUMENTS & SPEICHERS DIESES IN DER BC ANSTELLE DES EIGENTLICHEN DOKUMENTS; FRAGE => WO WIRD ES GEHASHED, BEVOR AUF DEM SERVER GESPEICHERT
    /*
      var ourObject =
      var crypto = require('crypto')
      var sha256 = crypto.createHash('sha256').update('We are so smat').digest('hex')
      console.log(sha256)
    */
  }

  async login(email, password) {

    const userAddress = await Praxisprojekt.getUserAddress(email).call();

    const loginResult = await Praxisprojekt.methods.authenticate(email, password, {from: userAddress}).send();
    await this.setState({
      email: email
    });

    web3.eth.isSyncing()
    .then(console.log);


  }


  async requestDocument(){
    //getSignature from blockchain
    //get Hash from getSignature
    //Pull Document from SERVER
    //Hash document and check whether hashes are equal
    //give document to frontend
  }

  //return firstName on the basis of what? No reference. Need getFirstName by looking up userName from email or so
  getFirstName() {
    return Praxisprojekt.methods.getUserFirstName().call();
  }

  getLastName() {
    return Praxisprojekt.methods.getUserLastName().call();
  }

  getObjectById() {
    return Praxisprojekt.methods.getObjectById(document_id).call();
  }

  getCaCertificate() {
    return Praxisprojekt.methods.getUserCaCertificate().call();
  }

  fetchObject() {
    //Probably should be fetchObjectHash, then create Hash from Object that is pulled from the server, then compare both Hashes for security
    return Praxisprojekt.methods.getObject(document_name).call();
  }

  getObjectCount() {
    return Praxisprojekt.methods.getObjectCount().call();
  }

  getDocumentVerificationStatus() {
    //Check whether document is still being verified or is already verified
  }

  verificationCheck() {
    //Check whether document already verified or not
  }

  deleteDocumentHash() {
    //Delete the document on the server and the Hash from the Blockchain
  }

  getDocumentsData() {
    //Array of users that stores id, name and verifcation status of each
    const userDocuments = []
    const objectName = Praxisprojekt.methods.getObject(document_name).call();
  }
