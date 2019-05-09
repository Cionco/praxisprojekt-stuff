pragma solidity >=0.4.22 <0.6.0;

contract Identity {
    //struct in der alle User bezogenen Daten gespeichert werden
    //ein struct ist so was, wie eine Java-Klasse ohne methoden.
    //Es gibt nur Attribute, alle Attribute sind sozusagen public
    struct User {
        uint age;
        bytes32[] fingerprints;
        bytes32 id_code;
        //Vergleichbar mit java.util.HashMap
        //Für alle, die noch nie mit Maps gearbeitet haben:
        //mapping(K => V)
        //eine Art Key-Value Store, in dem Values des Typs V
        //eindeutig einem Key des Typs K zugewiesen werden.
        //Im Gegensatz zu Java, wo Maps externe Klassen (bzw interfaces)
        //sind und dementsprechend jegliche Operationen mit Methoden der Klasse erledigt werden müssen
        //ist das Mapping ein Built-in in Solidity und kann daher ähnlich wie ein Array benutzt werden:
        //mapname[key] = value oder irgendeinefunktion(mapname[key]) und so weiter
        //Dieses mapping ordnet "Dokumente" einem eindeutigen Key zu.
        //Mein Beispiel in der Präsentation war den Wert 709611 dem Key "Fuehrerschein" zuzuordnen
        mapping(string => string) documents;
    } 
    
    //Enums beschreiben Datentypen, die aus einer Menge benannter Werte bestehen.
    //Diese Werte verhalten sich gewöhnlicherweise wie Konstanten und können zum Beispiel zum
    //entscheiden zwischen eine begrenzeten Anzahl von Möglichkeiten genutzt werden. 
    //für diesen Fall könnten auch ganz klassisch Konstanten benutzt werden, ich fand es so 
    //aber v.a. für eventuelle weiterentwicklungen angenehmer
    //Die Werte werden standardmäßig einfach durchgezählt, wennn man also die Fingerprint Methode
    //im remix frontend auswählen will muss man in das Feld eine 0, für ID eine 1 schreiben
    enum AuthenticationMethod {
        FINGERPRINT, ID
    }
    
    //Function Pointer preparation
    bytes4[] private methods;
    
    //Der Konstruktor (erstellt den Contract bzw wird bei erstellen aufgerufen) des Contracts. 
    //Für die aktuelle Funktionalität reicht der Default-constructor aus, aber als vorbereitung für Function-
    //Pointer steht er schon im Code
    //Function Pointer preparation
    constructor() public {
        methods.push(bytes4(keccak256("idAuthentication(bytes32)")));
        methods.push(bytes4(keccak256("fingerprintAuthentication(bytes32)")));
    }
    
    //In diesem Mapping werden die User gespeichert. Ein User wird anhand seiner Adresse (Account-Adresse) -
    //z.B. 0xca35b7d915458ef540ade6068dfe2f44e8fa733c - eindeutig idendifiziert.
    mapping(address => User) users;
    
    //Registriert einen User mit seinem Alter und legt die Ausweisnummer als "zugangscode" fest
    function registerUser(uint age, string id_code) public {
        address sender = msg.sender; //Variable vom Typ address mit der Adresse des jenigen, der sich registrieren will
        //In mappings in solidity existiert jeder Wert mit default 0, das heißt es kann nicht, wie in Java,
        //users[sender] == null überprüft werden. Da der default Value 0 ist und sich keiner mit Alter 0 registrieren wird
        //kann das als ausreichende Bedingung genutzt werden um festzustellen ob der User schon existiert.
        if(users[sender].age > 0) return; //Sollte das der Fall sein wird die Funktion abgebrochen
        users[sender].age = age;
        users[sender].id_code = keccak256(id_code); //Hasht den übergebenen code und speichert ihn im User struct ab
    }
    
    //Bevor ich die Kommentare zu den nächsten beiden Methoden schreibe, muss ich anmerken, dass der Code hier wirklich nicht
    //ideal geschrieben ist (folgende Ausrede: ich habe ihn in der BigData Vorlesung geschrieben ^^)
    //Momentan ist es so, dass bei jeder Authentifizierung sowohl bytes32 für eine Fingerabdruckauthentifizierung
    //als auch ein String (der zugegebenermaßen leer sein kann) übergeben werden müssen. Wenn ich mich nicht täusche
    //würde erst ein sinnvolleres Frontend als das von remix besseren Code zulassen. 
    //TODO: Vielleicht könnte ich den bytes32 Parameter als String übergeben und dann casten..
    
    //Tl;dr: Es werden immer bytes32 und string übergeben und nur der Wert verwendet, der für die Methode wichtig ist
    //bzw der string wird verwendet, wenn er nicht leer ist.

    //Side note: der bytes 32 parameter muss immer angegeben werden, da er nicht optional ist. Es kann zwar ein leerer
    //string übergeben werden, das Äquivalent (naja nicht wirklich, aber es dient als solches für unsere Zwecke)
    //dazu für bytes32 ist 0x00


    //Fügt einen Fingerabdruck zur Liste von Fingerabdrücken für den User hinzu
    //@param fingerprintToAdd die bytes32 codierung die den neuen Fingerabdruck repräsentiert
    //@param method die Methode, die zum Authentifizieren verwendet werden soll (siehe Enum doc)
    //@param authenticationBytes 0x00 wenn id verwendet wird, die fingerprint bytes bei der fingerprint methode
    //@param authenticationString "" wenn fingerprint verwendet wird, der code mit dem sich ein User registriert hat
    function addFingerprint(bytes32 fingerprintToAdd, AuthenticationMethod method, bytes32 authenticationBytes, string authenticationString) public {
        address sender = msg.sender; //Bereits erläutert (l. 54), werden wir noch öfters sehen
        //Wenn ein string übergeben wurde, der nicht leer ist wird er gehasht und in den anderen Parameter geschrieben,
        //damit in die tatsächliche authentication methode nur noch einer der Parameter übergeben werden muss.
        //Das ist auch teilweise mit dem hintergedanken entstanden später das ganze auf Function Pointer umzuschreiben
        if(bytes(authenticationString).length != 0) authenticationBytes = keccak256(authenticationString);
        //Checkt ob der User sich mit den übergebenen Bytes authentifizieren kann, wenn nicht wird die Methode abgebrochen
        if(!authenticate(authenticationBytes, method)) return;
        //War die Authentifizierung erfolgreich wird der neue Fingerabdruck in das Fingerprint-Array des Users gespeichert
        users[sender].fingerprints.push(fingerprintToAdd);
    }
    
    //Fügt ein "Dokument" zur Dokumentenmap des Users hinzu
    //@param documentKey der Key unter dem das Dokument zu finden sein soll
    //@param documentToAdd das Dokument, das hinzugefügt werden soll
    //@param method die Methode, die zum Authentifizieren verwendet werden soll (siehe Enum doc)
    //@param authenticationBytes 0x00 wenn id verwendet wird, die fingerprint bytes bei der fingerprint methode
    //@param authenticationString "" wenn fingerprint verwendet wird, der code mit dem sich ein User registriert hat
    function addDocument(string documentKey, string documentToAdd, AuthenticationMethod method, bytes32 authenticationBytes, string authenticationString) public {
        //l. 103 - 105 siehe l. 84 - 90
        address sender = msg.sender;
        if(bytes(authenticationString).length != 0) authenticationBytes = keccak256(authenticationString);
        if(!authenticate(authenticationBytes, method)) return;
        //Check ob schon ein Dokument mit dem übergebenen Key für diesen User gespeichert ist
        //wenn ja, brich die methode ab.
        //da Solidity scheinbar keine Methode zu Strings vergleichen wie Java (java.lang.String.equals(Object o)) hat
        //müssen beide Strings gehasht und die hashes verglichen werden. 
        if(keccak256(users[sender].documents[documentKey]) != keccak256("")) return;
        //Wurde nirgends vorher abgebrochen wird hier das Dokument unter dem übergebenen Key in die Map gespeichert
        users[sender].documents[documentKey] = documentToAdd;
    }
    
    //Genau wie in Java gibt es auch in Solidity noch andere Modifier als nur public, protected, private, package-private.
    //die Zugriffsmodifier (gerade genannt) sind in Solidity public, internal, private und external (was genau external tut
    //müsste ich nochmal nachlesen). Zusätzlich gibt es zum Beispiel den Modifier view, der anzeigt, dass die Funktion keine
    //Werte ändert sondern nur liest (Gero hatte das schon kurz angesprochen).
    //Einigen ist es vielleicht schon in l. 37 aufgefallen: Im Gegensatz zu Java, wo modifier vorne stehen
    // z.B. public static void main()....
    //      ^mod    ^mod  ^return ^name
    //... stehen sowohl modifier (als auch return type bei Funktionen) hinten
    //Variable: z.B. address private someprivateaddress
    //Function: z.B: function someprivateviewmethod(uint8 someintargument) private view returns (int256) {}
    //                          ^name                                       ^mod    ^mod       ^returntype

    //Leitet die Überprüfung an authenticate() weiter
    //Gibt true zurück wenn die Authentifizierung erfolgreich war
    function loginWithFingerprint(bytes32 fingerprint) public view returns (bool loginSuccessfull) {
        return authenticate(fingerprint, AuthenticationMethod.FINGERPRINT);
    }
    
    //Hasht den übergebenen string und leitet die Überprüfung and authenticate() weiter
    //Gibt true zurück wenn die Authentifizierung erfolgreich war
    function loginWithId(string id_code) public view returns (bool loginSuccessfull) {
        return authenticate(keccak256(id_code), AuthenticationMethod.ID);
    }
    
    //Leitet die Bytes für die Authentifizierung an die Funktion, die für die gewählte Methode zuständig ist weiter
    //Gibt true zurück wenn die Authentifizierung erfolgreich war
    function authenticate(bytes32 byteAuthentication, AuthenticationMethod method) internal view returns (bool) {
        if(method == AuthenticationMethod.FINGERPRINT) return fingerprintAuthentication(byteAuthentication);
        else if(method == AuthenticationMethod.ID) return idAuthentication(byteAuthentication);
        
        //So soll die Funktion mal ausgeführt werden, wenn ich Function Pointer in Solidity endlich
        //richtig verstanden habe
        //return this.call(methods[uint(method)], byteAuthentication);
    }
    
    //Führt die Authentifizierung über den id code durch und gibt true zurück wenn erfolgreich
    function idAuthentication(bytes32 id_code) private view returns (bool) {
        //Ähnlich wie l. 54 nur dass diesmal direkt das User Object als Variable genommen wird
        //Memory ist ein modifier, der sich darauf bezieht welcher Speicherbereich der EVM genutzt wird.
        //Dabei ist es unter anderem unterschiedlich, wie viel Gas benötigt wird.
        //Die Speicherbereiche sind Storage, Memory und Stack und lassen sich teilweise gut mit den
        //JVM Speicherbereichen Heap und Stack vergleichen. Im Storage werden standardmäßig vor allem 
        //state Variablen und lokale Variablen, die structs, arrays oder mapping referenzieren gespeichert, 
        //während lokale Variablen und Funktionsargumente im Memory stehen. Im Stack befinden sich lokale
        //Variablen von "Value Typen" (int, uint etc)
        User memory u = users[msg.sender];
        if(u.age == 0) return false; //Überprüfung ob der User registriert ist (siehe l. 58)
        return id_code == u.id_code; //Überprüfung ob der Hash des eingegebenen Codes dem entspricht mit dem
        //der User sich registriert hat
    }
    
    //Führt die Authentifizierung über einen Fingerabdruck durch und gibt true zurück wenn erfolgreich
    function fingerprintAuthentication(bytes32 fingerprint) private view returns (bool) {
        User memory u = users[msg.sender]; //siehe l. 152 - 160
        if(u.age == 0) return false; //siehe l. 161
        //Iteriere über das Array registrierter Fingerabdrücke des Users und... 
        for(uint i = 0; i < u.fingerprints.length; i++)
            if(fingerprint == u.fingerprints[i]) return true; //gibt true zurück, wenn einer der Fingerabdrücke mit
            //dem eingegebenen übereinstimmt
        return false; //gib false zurück falls keiner überein stimmt
    }
    
    //Sucht ein Dokument aus den gespeicherten heraus
    //@param document der Key unter dem das Dokument zu finden sein soll
    //@param authenticationBytes 0x00 wenn id verwendet wird, die fingerprint bytes bei der fingerprint methode
    //@param authenticationString "" wenn fingerprint verwendet wird, der code mit dem sich ein User registriert hat
    //@param method die Methode, die zum Authentifizieren verwendet werden soll (siehe Enum doc)
    //@return "Access Rejected", wenn fehlerhafte Authentifizierung, sonst das zum key gehörende Dokument
    function getDoc(string document, bytes32 authenticationBytes, string authenticationString, AuthenticationMethod method) public view returns (string) {
        if(bytes(authenticationString).length != 0) authenticationBytes = keccak256(authenticationString); //siehe l. 85 - 88
        if(!authenticate(authenticationBytes, method)) return "Access Rejected"; //Authentifizierung, falls fehlgeschlagen gibt Fehlermeldung zurück
        User storage u = users[msg.sender]; // siehe l. 168, aus irgendeinem Grund beschwert sich hier der Compiler, wenn 
        //ich versuche u als memory Variable zu deklarieren, obwohl es in den anderen Methoden ohne Probleme geklappt hat
        return u.documents[document]; //Gib das Dokument zurück, das unter dem übergebenen Key gespeichert ist
    }
}