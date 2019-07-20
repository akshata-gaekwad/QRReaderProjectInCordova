package com.example.qrreader;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import static android.graphics.Color.WHITE;
import android.util.Base64;
import android.graphics.drawable.Drawable;
import org.apache.cordova.PluginResult;


public class QRGenerateActivity extends Activity{
	
	
	private String TAG = "QRGenerateActivity";
	 private ImageView qrImage;
    private EditText editBox;
    private Button buttonGenerate;
    String download = "RXcW/8Nco6/kWo3L0rdA9j8YJcEMsh4blCFJL3L8nmu0+cMlnmCE7ds55TwDvH40paOUHkueJIh2uEupq4tEIO4aB4+KumUTnwInp8XyIpyoF2ig/x3P8TpQvPfts6Tpw2q2zKTepoXkjcxtMhbv16mKTArQWOCKNXQ+Z6u6f2A=\n" +
            "~008159500001~23100007~Somphasith Mom~10~~Test ~SELF\n";

    String a = "\"d/Efe+xgbLdiq/lCqkmDrThacxoFRCSbGOpfZ2Oh+/JRCujmY4POBoPsiXINR5I0\\n\" +\n" +
            "                \"cNU6GmOeUKOcEen85U9inouS7eU3NOImZFaTgqheFc177ADfwAlbENhKE7LB4YHv\\n\" +\n" +
            "                \"tpdREcu3br6Obfoj6eV+VeoAT4rgEtyU/MN3PUwG8R0=\\n\" +\n" +
            "                \"~003372200001~55450277~AOTH SISANON~10~~test~SELF\"";

    String john = "IDusdEg5DgjleJtXVBtSMTZi/xX+cRu/mJKRZhFiiDNWC5yb16MS2uIAfJlpdNuIM8G8XrLvO5ApOUkjiqKpHIyWczGZ+uBkqu3r1gYbpXGpkq+ENA2rov3TwB8LZrgVdRk4yq6Z2nGyYQofXnKC4CjAj7lLv4DA5dFOlylZ+W4=\n" +
            "~null~55061631~Jacob JOHN~0~~test~SELF";

    String nitesh = "TM9WfBLTlHb5u1esKoEQjovdtyGXXNPIa+uPPKdXgnmFzp29Pf50js2DgjgXBU3PDR7PNNcnAnl7O1UJtYe5I1sDe4I0kuwCOWeFQG1Iv7GY9SzDRYb9uMeZbdhGpVIQZleXIL/yHtrOu6BhfMNEk0L67qpADJk4CpDB+ZmfSwk= ~007041500010~75888898~Nitesh Porwal~13~LAK~~BEN";


@Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
		
		setContentView(getResources().getIdentifier("activity_qr_generate", "layout", getPackageName()));
		final Button buttonGenerate = (Button) findViewById(getResources().getIdentifier("buttonGenerate", "id", getPackageName()));
		final ImageView qrImage = (ImageView) findViewById(getResources().getIdentifier("qrImage", "id", getPackageName()));	
		final EditText editBox = (EditText) findViewById(getResources().getIdentifier("editBox", "id", getPackageName())); 
		
		 buttonGenerate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try{
                    int width = 300;
                    int height = 300;
                    int smallestDimension = width < height ? width : height;

                    String qrCodeData = editBox.getText().toString();
					editBox.setText(john);
                    String charSet = "UTF-8";
                    Map<EncodeHintType, ErrorCorrectionLevel> hintMap = new HashMap<EncodeHintType, ErrorCorrectionLevel>();
                    hintMap.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
                    createQRCode(qrCodeData, charSet, hintMap, smallestDimension, smallestDimension);

                }catch(Exception e){
                    e.printStackTrace();
                    Log.e("QRGenerate", e.getMessage());
                }
            }
        });
    }
	
	
	  public  void createQRCode(String qrCodeData, String charset, Map hintMap, int qrCodeheight, int qrCodewidth){

        try {
            //generating qr code in bitmatrix type
            BitMatrix matrix = new MultiFormatWriter().encode(new String(qrCodeData.getBytes(charset), charset),
                    BarcodeFormat.QR_CODE, qrCodewidth, qrCodeheight, hintMap);
            //converting bitmatrix to bitmap

            int width = matrix.getWidth();
            int height = matrix.getHeight();
            int[] pixels = new int[width * height];
            // All are 0, or black, by default
            for (int y = 0; y < height; y++) {
                int offset = y * width;
                for (int x = 0; x < width; x++) {
                    //pixels[offset + x] = matrix.get(x, y) ? BLACK : WHITE;
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        pixels[offset + x] = matrix.get(x, y) ?
						getResources().getIdentifier("black", "colors", getPackageName()) :WHITE;
                               // ResourcesCompat.getColor(getResources(),R.color.black,null) :WHITE;
                        //getResources().getColor(R.color.black, null) :WHITE;
                    }
                }
            }

            Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
            //setting bitmap to image view

			int draw1 = getResources().getIdentifier("maruhan_icon_32x32", "drawable", getPackageName());
			//Drawable drawable1 = getDrawable(draw1);
            Bitmap overlay = BitmapFactory.decodeResource(getResources(), draw1);

            qrImage.setImageBitmap(mergeBitmaps(overlay,bitmap));
            saveToInternalStorage(mergeBitmaps(overlay, bitmap));
			
			 String base64 = bitmapToBase64(mergeBitmaps(overlay, bitmap));
			// sendPluginResult(new PluginResult(PluginResult.Status.OK, base64));
           // Toast.makeText(Main4Activity.this, base64, Toast.LENGTH_LONG).show();

        }catch (Exception er){
            Log.e("QrGenerate",er.getMessage());
        }
    }
	
	 public Bitmap mergeBitmaps(Bitmap overlay, Bitmap bitmap) {

        int height = bitmap.getHeight();
        int width = bitmap.getWidth();

        Bitmap combined = Bitmap.createBitmap(width, height, bitmap.getConfig());
        Canvas canvas = new Canvas(combined);
        int canvasWidth = canvas.getWidth();
        int canvasHeight = canvas.getHeight();

        canvas.drawBitmap(bitmap, new Matrix(), null);

        int centreX = (canvasWidth  - overlay.getWidth()) /2;
        int centreY = (canvasHeight - overlay.getHeight()) /2 ;
        canvas.drawBitmap(overlay, centreX, centreY, null);

        return combined;
    }

    // to store image to internal storage
    private String saveToInternalStorage(Bitmap bitmapImage){
        String fileName = "QRGenerated.jpg";

        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        bitmapImage.compress(Bitmap.CompressFormat.JPEG, 40, bytes);

        File ExternalStorageDirectory = Environment.getExternalStorageDirectory();
        File file = new File(ExternalStorageDirectory + "/Download" + File.separator + fileName);

        FileOutputStream fileOutputStream = null;
        try {
            file.createNewFile();
            fileOutputStream = new FileOutputStream(file);
            fileOutputStream.write(bytes.toByteArray());

          //  Toast.makeText(Main4Activity.this,file.getAbsolutePath(), Toast.LENGTH_LONG).show();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            if(fileOutputStream != null){
                try {
                    fileOutputStream.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        }

        return file.getAbsolutePath();
    }
	
	 private String bitmapToBase64(Bitmap bitmap) {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
        byte[] byteArray = byteArrayOutputStream .toByteArray();
        return Base64.encodeToString(byteArray, Base64.DEFAULT);
    }
}