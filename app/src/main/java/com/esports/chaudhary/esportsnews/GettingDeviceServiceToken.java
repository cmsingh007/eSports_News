package com.esports.chaudhary.esportsnews;

import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;

public class GettingDeviceServiceToken extends FirebaseInstanceIdService {

    @Override
    public void onTokenRefresh() {
        String DeviceToken = FirebaseInstanceId.getInstance().getToken();
        Log.d("DEVICE TOKEN", DeviceToken);
    }
}
