package com.example.qrreader;

import android.app.Activity;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.FormatException;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.NotFoundException;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Reader;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import android.content.Context;


public class SiriShortcuts extends CordovaPlugin {

 private CallbackContext callbackContext;
 private static final String TAG = "QR_READER";
 //private static final String RESULT_OK = "RESULT_OK"
 private static final String PRESENT = "present";
 private static final String QRGENERATE = "qrGenerate";
	String contents = null;
	
	@Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
       
    }
	
	@Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
		final CordovaPlugin that = this;       
	    this.callbackContext = callbackContext;
       // this.requestArgs = args;
		

            Log.d(TAG, "ACTION: " + action);

            if (PRESENT.equalsIgnoreCase(action)) {
				 
				 PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
                 r.setKeepCallback(true);
                 this.callbackContext.sendPluginResult(r);
				try{
				 Intent i = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.INTERNAL_CONTENT_URI);
                final int ACTIVITY_SELECT_IMAGE = 1234;
                this.cordova.startActivityForResult((CordovaPlugin) this, i, ACTIVITY_SELECT_IMAGE);
				}
				catch(Exception e){
					e.printStackTrace();
					}
				return true;
			}else if(QRGENERATE.equalsIgnoreCase(action)){
				 PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
                 r.setKeepCallback(true);
                 this.callbackContext.sendPluginResult(r);
				 
				Class QRGenerateActivity;
					Context context = cordova.getActivity().getApplicationContext();
					String  packageName = context.getPackageName();
					Intent  launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
					String  className = launchIntent.getComponent().getClassName();

					try {
						//loading the Main Activity to not import it in the plugin
						QRGenerateActivity = Class.forName(className);
						} catch (Exception e) {
							e.printStackTrace();
						}
					Intent i = new Intent(cordova.getActivity(), QRGenerateActivity.class);
					this.cordova.getActivity().startActivity(i);
				return true;
			}
			return false; 

	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);

        switch(requestCode) {
            case 1234:
                if(resultCode == Activity.RESULT_OK){
                    Uri selectedImage = data.getData();
                    String[] filePathColumn = {MediaStore.Images.Media.DATA};

                    Cursor cursor = cordova.getActivity().getContentResolver().query(selectedImage, filePathColumn, null, null, null);
                    cursor.moveToFirst();

                    int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                    String filePath = cursor.getString(columnIndex);
                    cursor.close();

                    Bitmap yourSelectedImage = BitmapFactory.decodeFile(filePath);

                    /* Now you have choosen image in Bitmap format in object "yourSelectedImage". You can use it in way you want! */

                    int[] intArray = new int[yourSelectedImage.getWidth() * yourSelectedImage.getHeight()];
                    //copy pixel data from the Bitmap into the 'intArray' array
                    yourSelectedImage.getPixels(intArray, 0, yourSelectedImage.getWidth(), 0, 0, yourSelectedImage.getWidth(), yourSelectedImage.getHeight());

                    LuminanceSource source = new RGBLuminanceSource(yourSelectedImage.getWidth(), yourSelectedImage.getHeight(), intArray);
                    BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));

                    Reader reader = new MultiFormatReader();
                    Result result = null;
                  
                    try {
                        result = reader.decode(bitmap);
                        contents = result.getText();
						this.callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, contents.toString()));
                        //Toast.makeText(cordova.getActivity(), contents, Toast.LENGTH_LONG).show();
						//this.callbackContext.success(contents);
						//PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, contents);
						//callbackContext.sendPluginResult(pluginResult);
                    } catch (NotFoundException e) {
                       // Toast.makeText(cordova.getActivity(), "Selected image is not valid QR Code", Toast.LENGTH_LONG).show();
					  // this.callbackContext.error(": Selected image is not valid QR Code");
					 // PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, contents); //TAG + ": Selected image is not valid QR Code"
					  //    callbackContext.sendPluginResult(pluginResult);
                    } catch (ChecksumException e) {
                        e.printStackTrace();
                    } catch (FormatException e) {
                        e.printStackTrace();
                    }
                }
        }

    };
	
}
	
