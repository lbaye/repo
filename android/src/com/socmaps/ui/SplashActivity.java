package com.socmaps.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.widget.ProgressBar;

import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * SplashActivity class is used to show Splash in a certain amount of period.
 * Each time when the application is run Splash image will be shown with a
 * progress bar.
 * 
 */

public class SplashActivity extends Activity {
	ProgressBar pbSplash;
	int total = 0;
	boolean isRunning = false;
	int splashDuration = 7000; // millisecond

	int loopCount = 700;

	String responseString;
	int responseStatus;

	Runnable requestRunnable;

	boolean isRequestingToServer = false;
	boolean isTimeOver = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.splash_layout);

		initialize();

	}

	private void initialize() {
		pbSplash = (ProgressBar) findViewById(R.id.pbSplash);
	}

	@Override
	public void onStart() {
		super.onStart();
		pbSplash.setProgress(0);
		isRunning = true;

		if (Utility.isConnectionAvailble(getApplicationContext())) {

			if (Utility.isLoggedIn(getApplicationContext())) {

				if (Utility.getAuthToken(getApplicationContext()) != null) {
					if (!Utility.getAuthToken(getApplicationContext()).equals("")) {

						requestRunnable = new Runnable() {
							@Override
							public void run() {

								getUserInfo();

							}

						};
						Thread thread = new Thread(null, requestRunnable, "MagentoBackground");
						thread.start();
					}
				}

			}

			new Thread() {
				@Override
				public void run() {
					try {
						for (int i = 1; i <= loopCount && isRunning; i++) {
							Thread.sleep(splashDuration / loopCount);
							splashHandler1.sendMessage(splashHandler.obtainMessage());

							if (i == loopCount) {
								isTimeOver = true;

								if (!Utility.isLoggedIn(getApplicationContext())) {
									splashHandler.sendEmptyMessage(0);
								}

								else if (isRequestingToServer) {
									parseUserData(Utility.getUserData(getApplicationContext()));
								}
							}
						}
					} catch (Throwable t) {

					}
				}
			}.start();

		} else {
			showDialogForUnavailableInterenet();
		}
	}

	private void getUserInfo() {
		// TODO Auto-generated method stub

		Utility.log("Splash: getUserInfo", "Requesting to server.");

		isRequestingToServer = true;

		RestClient client = new RestClient(Constant.smServerUrl + "/me");
		client.AddHeader("Auth-Token", Utility.getAuthToken(getApplicationContext()));
		client.setConnectionTimeout(5);

		try {
			client.Execute(RestClient.RequestMethod.GET);
			responseString = client.getResponse();
			responseStatus = client.getResponseCode();
			runOnUiThread(returnRes);
		} catch (Exception e) {
			e.printStackTrace();
			responseString = "";
			responseStatus = 0;
			runOnUiThread(returnRes);
		}

	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {

			// have to do something here
			handleResponse(responseStatus, responseString);
		}
	};

	private void handleResponse(int status, String response) {
		Utility.log("Login", status + ":" + response);

		isRequestingToServer = false;
		if (isTimeOver) {
			finish();
		} else {
			switch (status) {
			case Constant.STATUS_SUCCESS:
				parseUserData(response);
				break;

			default:
				parseUserData(null);
				break;

			}
		}

	}

	private void parseUserData(String response) {
		boolean isError = true;
		if (response != null) {
			if (!response.equals("")) {
				isError = false;

				StaticValues.myInfo = ServerResponseParser.parseUserProfileInfo(response, false);

				if (StaticValues.myInfo != null) {
					Utility.storeSession(StaticValues.myInfo.getId(), StaticValues.myInfo.getAuthToken(), response, getApplicationContext());
				}

				splashHandler.sendEmptyMessage(1);
			} else {
				StaticValues.myInfo = ServerResponseParser.parseUserProfileInfo(Utility.getUserData(getApplicationContext()), false);
				splashHandler.sendEmptyMessage(1);
			}

		}
		if (isError) {
			splashHandler.sendEmptyMessage(0);
		}
	}

	private void showDialogForUnavailableInterenet() {
		// TODO Auto-generated method stub
		AlertDialog.Builder adb = new AlertDialog.Builder(this);
		adb.setTitle("Exit");
		adb.setIcon(R.drawable.icon_alert);
		adb.setMessage("No internet connection available.");
		adb.setPositiveButton("OK", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int id) {
				finish();
			}
		});

		adb.show();
	}

	private Handler splashHandler1 = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			total = total + 1;
			pbSplash.incrementProgressBy(1);
		};
	};

	private Handler splashHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				finish();

				startActivity(new Intent(SplashActivity.this, LoginActivity.class));

				break;

			case 1:

				boolean isValid = false;
				finish();
				if (StaticValues.myInfo != null) {

					isValid = true;

					if (StaticValues.myInfo.getRegMedia().equals(Constant.sourceFacebook) && !Utility.isFacebookSessionValid(SplashActivity.this)) {

						isValid = false;

					}

				}

				if (isValid) {
					finish();
					startActivity(new Intent(SplashActivity.this, HomeActivity.class));
				} else {
					finish();
					startActivity(new Intent(SplashActivity.this, LoginActivity.class));
				}

				break;
			}
			super.handleMessage(msg);
		}
	};
}
