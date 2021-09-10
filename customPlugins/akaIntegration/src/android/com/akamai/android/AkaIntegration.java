package com.akamai.android;

import android.util.Log;

import com.akamai.android.sdk.AkaCommon;
import com.akamai.android.sdk.AkaMap;
import com.akamai.android.sdk.Logger;
import com.akamai.android.sdk.MapSdkInfo;
import com.akamai.mpulse.android.MPulse;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;


/**
 * This class echoes a string called from JavaScript.
 */
public class AkaIntegration extends CordovaPlugin {

    public static final String TAG = "AkaIntegration";

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        switch (action) {
            case "handleNotification":
                this.handleNotification(args);
                return true;
            case "echo":
                echo();
                return true;
            case "printConfig":
                this.printConfig();
                return true;
            case "printCache":
                this.printCache();
                return true;
            case "registerSegment":
                final String segments = args.getString(0);
                this.registerSegments(segments);
                return true;
            case "startAction":
                this.startAction(args.getString(0));
                return true;
            case "stopAction":
                this.stopAction();
                return true;
        }
        return false;
    }

    private void echo() {
        Log.i(TAG, "echo!");
    }

    private void startAction(String actionName) {
        cordova.getThreadPool().submit(() -> MPulse.sharedInstance().startAction(actionName));
    }

    private void stopAction() {
        cordova.getThreadPool().submit(() -> MPulse.sharedInstance().stopAction());
    }

    private void printConfig() {
        try {
            Logger.setLevel(Logger.LEVEL.DEBUG);
            MapSdkInfo.logCurrentConfiguration(this.cordova.getActivity().getApplicationContext());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void printCache() {
        try {
            Logger.setLevel(Logger.LEVEL.DEBUG);
            MapSdkInfo.logExistingContent(this.cordova.getActivity().getApplicationContext());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void registerSegments(String segments) {
        AkaMap.getInstance().subscribeSegments(new HashSet<>(Arrays.asList(segments)));
    }

    private void handleNotification(JSONArray array) {
        final HashMap<String, String> pairs = new HashMap<>();
        for (int i = 0; i < array.length(); i++) {
            final JSONObject j = array.optJSONObject(i);
            final Iterator iterator = j.keys();
            while (iterator.hasNext()) {
                final String key = (String) iterator.next();
                if ("mapsdk".equals(key)) {
                    try {
                        final String mapConfig = j.getString(key);
                        pairs.put(key, mapConfig);
                        AkaCommon.getInstance().handlePushNotification(pairs);
                        return;
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
