package praxisprojekt;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.WritableRaster;
import java.io.File;
import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.SignatureException;
import java.security.spec.EncodedKeySpec;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;

import javax.imageio.ImageIO;

public class Signatur {

	static final String pub = "53756e20445341205075626c6963204b65790a20202020506172616d65746572733a0a20202020703a0a2020202038663739333564392062396161653962662061626564383837612063663439353162362066333265633539652033626166333731382065386561633439362031663365666433360a2020202030366537343335312061396334313833332033396238303965372063326165316335332039626137343735622038356430313161642062386234373938372037353439383436390a2020202035636163306538662031346233333630382032386132326666612032373131306133642036326139393334352033343039613066652036393663343635382066383462646432300a2020202038313963333730392061303130353762312039356164636430302032333364626135342038346236323931662039643634386566382038333434383637372039373963656330340a2020202062343334613661632032653735653939382035646532336462302032393266633131312038633966666139642038313831653733332038646237393262372033306437623965330a2020202034393539326636382030393938373231352033393135656133642036623862343635332063363333343538662038303362333261342063326530663237322039303235366534650a2020202033663861336230382033386131633435302065346531386331612032396133376464662035656131343364652034623636666630342039303365643563662031363233653135380a2020202064343837633630382065393766323131632064383164636132332063623665333830372036356638323265332034326265343834632030353736333933392036303163643636370a20202020713a0a2020202062616636393661362038353738663764662064656537666136372063393737633738352065663332623233332062616535383063302062636435363935640a20202020673a0a2020202031366136356335382032303438353037302034653735303261332039373537303430642033346461336133342037386331353464342065346135633032642032343265653034660a2020202039366536316534622064303930346162642061633866333765652062316530396633312038326432336339302034336362363432662038383030343136302065646639636130390a2020202062333230373661372039633332613632372066323437336539312038373962613263342065373434626432302038313534346362352035623830326333362038643166613833650a2020202064343839653934652030666130363838652033323432386135632037386334373863362038643035323762372031633961336162622030623062653132632034343638393633390a2020202065376433636537342064623130316136352061613262383766362034633638323664622033656337326634622035353939383334622062346564623032662037633930653961340a2020202039366433613535642035333562656266632034356434663631392066363366336465642062623837333932352063326632323465302037373331323936642061383837656331650a2020202034373438663837652066623566646562372035343834333136622032323332646565352035336464616630322031313262306431662030326461333039372033323234666532370a2020202061656461386239642034623239323264392062613862653339652064396531303361362033633532383130622063363838623765322065643433313665312065663137646264650a0a2020793a0a2020202033613736363262642062346230343939312036306265646334652065656232626333642066626361663532622035333630636633312066663264393338382032376461646131660a2020202035323239346437322037343835343939352035343162623939312062313530353665662066353932326661322061383532373935382066643064363565352038303336653662370a2020202038373839643865652065346365333861352063643166613965382031376632613139612034313264393830372036613035353533662036316436636338652031633165343536620a2020202034396638303761362031633463346430372030643632653062372065626137616635612062626362383938612061366462333466642033356536613634612035616635623564320a2020202037643766656331302037383831333637312063633362323166642035623661393433332063323762356263382037346462303233662062396536653732332063333665363336360a2020202033656130343530652031623731316632382035626533353962652066653738613266332033623037623761632061366437393938312035633865353936652039626231306437370a2020202030393130633261312030303530383937652039343735616430302035656131633739362033323733343962632033363262313535642061663636336138342032643838323161660a2020202038383863666534662032363337623630322034383865383434392062313733333661622037666237616265312038356537346338312030383266373061312066376536323265340a";
	static final String pri = "73756e2e73656375726974792e70726f76696465722e445341507269766174654b6579406666663132613833";
	
	public static void main(String[] args) throws IOException, NoSuchAlgorithmException, InvalidKeySpecException {
		KeyPairGenerator keyPairGen = null;
		Signature sign = null;
		byte[] signature = null;
		byte[] bytes = null;
		try {
			keyPairGen = KeyPairGenerator.getInstance("DSA");
			sign = Signature.getInstance("SHA256withDSA");
		} catch (NoSuchAlgorithmException e) {}
		keyPairGen.initialize(2048);
		KeyPair kp = keyPairGen.generateKeyPair();
		PrivateKey privateKey = kp.getPrivate();//getPrivateKey(htb(pri));
		PublicKey publicKey = kp.getPublic();//getPublicKey(htb(pub));
		try {
			sign.initSign(privateKey);
			//Beliebigen Pfad zu einer Bilddatei einsetzen
			bytes = extractBytes("/Users/nicolaskepper/Downloads/pen-15.png");
			sign.update(bytes);
			signature = sign.sign();
		} catch (SignatureException | InvalidKeyException e) {
			e.printStackTrace();
		}
		
		printBytesWMessage("Private Key: ", privateKey.toString().getBytes());
		printBytesWMessage("Public Key: ", publicKey.toString().getBytes());
		printBytesWMessage("Signature: ", signature);
		
		try {
			sign.initVerify(publicKey);
			sign.update(bytes);
			System.out.println("Verified: " + sign.verify(signature));
		} catch (SignatureException | InvalidKeyException e) {
			e.printStackTrace();
		}
		
	}
	
	private static void printBytesWMessage(String msg, byte[] array) {
		System.out.print(msg);
		for(byte b : array) System.out.printf("%02x", b);
		System.out.println();
	}

	/**
	 * Get Bytes from Image
	 * @param ImageName Fully qualified path of the image
	 * @return byte array holding the image data
	 * @throws IOException 
	 */
	public static byte[] extractBytes (String ImageName) throws IOException {
		 File imgPath = new File(ImageName);
		 BufferedImage bufferedImage = ImageIO.read(imgPath);

		 WritableRaster raster = bufferedImage .getRaster();
		 DataBufferByte data   = (DataBufferByte) raster.getDataBuffer();

		 return data.getData();
	}
	
	/**
	 * Convert byte array to public key
	 * @param pk array with the key's bytes
	 * @return Public key object created from the bytes
	 * @throws NoSuchAlgorithmException
	 * @throws InvalidKeySpecException
	 * @deprecated doesn't work yet
	 */
	@Deprecated
	public static PublicKey getPublicKey(byte[] pk) throws NoSuchAlgorithmException, InvalidKeySpecException {
        EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(pk);
        KeyFactory kf = KeyFactory.getInstance("DSA");
        PublicKey pub = kf.generatePublic(publicKeySpec);
        return pub;
    }

	/**
	 * Convert byte array to PrivateKey
	 * @param privk array with the key's bytes 
	 * @return private key object created from the bytes
	 * @throws NoSuchAlgorithmException
	 * @throws InvalidKeySpecException
	 * @deprecated doesn't work yet
	 */
	@Deprecated
    public static PrivateKey getPrivateKey(byte[] privk) throws NoSuchAlgorithmException, InvalidKeySpecException {
        EncodedKeySpec privateKeySpec = new PKCS8EncodedKeySpec(privk);
        KeyFactory kf = KeyFactory.getInstance("DSA");
        PrivateKey privateKey = kf.generatePrivate(privateKeySpec);
        return privateKey;
    }
	
	/**
	 * Hex To Byte - Converts hex string to bytes
	 * @param s
	 * @return
	 */
	public static byte[] htb(String s) {
	    int len = s.length();
	    byte[] data = new byte[len / 2];
	    for (int i = 0; i < len; i += 2) {
	        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
	                             + Character.digit(s.charAt(i+1), 16));
	    }
	    
	    return data;
	}
}
