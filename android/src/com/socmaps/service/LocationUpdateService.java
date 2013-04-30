package com.socmaps.service;

import java.util.Timer;
import java.util.TimerTask;

import com.socmaps.gps.GpsService;
import com.socmaps.gps.ILocationUpdateIndicator;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;

import com.socmaps.util.Utility;

import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Handler.Callback;
import android.util.Log;
import android.widget.Toast;

public class LocationUpdateService extends Service implements ILocationUpdateIndicator {

	private static final String TAG = "MyService";
	// MediaPlayer player;

	private Timer mytimer;

	long firstInterval = 300000; // 5 Minute
	long periodicInterval = 300000; // 5 Minute

	private GpsService gpsService;
	private static Handler handler;
	private Runnable runnable;

	private double myLat = 0, myLng = 0;
	String responseStringUpdateLocation;
	int responseStatusUpdateLocation = 0;

	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public void onCreate() {

		// Toast.makeText(this, "My Service Created", Toast.LENGTH_LONG).show();
		Utility.log(TAG, "My Service Created");

		gpsService = new GpsService(getApplicationContext(), this);

		startGpsService();

	}

	@Override
	public void onStart(Intent intent, int startid) {

		// Toast.makeText(this, "My Service Started", Toast.LENGTH_LONG).show();

		Utility.log(TAG, "My Service Started");

		timerTask();

	}

	protected void timerTask() {

		// player = MediaPlayer.create(this, R.raw.frog);
		// player.setLooping(false);

		mytimer = new Timer();

		mytimer.schedule(new TimerTask() {
			@Override
			public void run() {

				// player.start();
				
				if(myLat != 0 && myLng!=0)
				{
					sendSelfLocationToServer();
				}

				

				Utility.log(TAG, "timerTask()>>>>>>>>>>>>>>> " + " Lat: " + myLat
						+ " Lng: " + myLng + " current time in millise:"
						+ System.currentTimeMillis());

			}

		}, firstInterval, periodicInterval);
	}

	private void startGpsService() {

		gpsService.StartListener();

		handler = new Handler(new Callback() {
			@Override
			public boolean handleMessage(Message msg) {
				handler.removeCallbacks(runnable);
				return false;
			}
		});
		runnable = new Runnable() {
			Message msg;
			Location location = null;

			@Override
			public void run() {
				location = gpsService.getLastLocation();
				if (location != null) {
					catchLocationUpdate(location);
					msg = new Message();
					msg.what = 1;
					handler.sendMessage(msg);
					return;
				}
				handler.postDelayed(this, 2000);
			}
		};
		handler.post(runnable);
	}

	@Override
	public void onDestroy() {
		// Toast.makeText(this, "My Service Stopped", Toast.LENGTH_LONG).show();
		Utility.log(TAG, "My Service Stopped");

		// player.stop();

		if (mytimer != null) {

			mytimer.cancel();
		}

		gpsService.stopListener();
	}

	@Override
	public void catchLocationUpdate(Location location) {
		// TODO Auto-generated method stub

		myLat = location.getLatitude();
		myLng = location.getLongitude();

		Utility.log(TAG + " catchLocationUpdate " + " location.getLatitude():"
				+ location.getLatitude(),
				"location.getLongitude():" + location.getLongitude());

		// sendSelfLocationToServer();
	}

	private void sendSelfLocationToServer() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, updateLocationThread,
					"Start update location");
			thread.start();

			// show progress dialog if needed

		} else {

			Utility.log("Location update", "No internet connection available.");
		}
	}

	private Runnable updateLocationThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smUpdateLocationUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(getApplicationContext()));

			restClient.AddParam("lat", "" + myLat);
			restClient.AddParam("lng", "" + myLng);

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseStringUpdateLocation = restClient.getResponse();

			responseStatusUpdateLocation = restClient.getResponseCode();

			Utility.log(TAG + " Update Location response >>",
					responseStatusUpdateLocation + " : "
							+ responseStringUpdateLocation
							+ " current time in millise:"
							+ System.currentTimeMillis());

			responseStringUpdateLocation = null;

			// runOnUiThread(returnResponseUpdateLocation);
		}
	};

	private Runnable returnResponseUpdateLocation = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseUpdateLocation(responseStatusUpdateLocation,
					responseStringUpdateLocation);

			responseStringUpdateLocation = null;

			// dismiss progress dialog if needed
		}

	};

	private void handleResponseUpdateLocation(int responseStatusUpdateLocation,
			String responseStringUpdateLocation) {
		// TODO Auto-generated method stub
		Utility.log("Update Location", responseStatusUpdateLocation + " "
				+ responseStringUpdateLocation);
	}
}
