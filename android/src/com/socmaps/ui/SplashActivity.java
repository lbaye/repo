package com.socmaps.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

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
		Log.i("UserData", "" + Utility.getUserData(getApplicationContext()));

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
					if (!Utility.getAuthToken(getApplicationContext()).equals(
							"")) {

						requestRunnable = new Runnable() {
							@Override
							public void run() {

								getUserInfo();

							}

						};
						Thread thread = new Thread(null, requestRunnable,
								"MagentoBackground");
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
							splashHandler1.sendMessage(splashHandler
									.obtainMessage());

							if (i == loopCount) {
								isTimeOver = true;

								if (!Utility
										.isLoggedIn(getApplicationContext())) {
									splashHandler.sendEmptyMessage(0);
								}

								else if (isRequestingToServer) {
									parseUserData(Utility
											.getUserData(getApplicationContext()));
								}

								/*
								 * if (isRequestingToServer == false) {
								 * splashHandler.sendEmptyMessage(0); }
								 */

								// splashHandler.sendEmptyMessage(0);
								//
								// .sendEmptyMessageDelayed(0,
								// 0);
							}
						}
					} catch (Throwable t) {

					}
					// splashHandler.sendEmptyMessageDelayed(0, 0);
				}
			}.start();

		} else {
			showDialogForUnavailableInterenet();
		}
	}

	public void getUserInfo() {
		// TODO Auto-generated method stub

		Log.i("Splash: getUserInfo", "Requesting to server.");

		isRequestingToServer = true;

		RestClient client = new RestClient(Constant.smServerUrl + "/me");
		client.AddHeader("Auth-Token",
				Utility.getAuthToken(getApplicationContext()));
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
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();

			handleResponse(responseStatus, responseString);
		}
	};

	public void handleResponse(int status, String response) {
		Log.d("Login", status + ":" + response);

		isRequestingToServer = false;
		if (isTimeOver) {
			finish();
		} else {
			switch (status) {
			case Constant.STATUS_SUCCESS:
				// Log.d("Login", status+":"+response);
				parseUserData(response);
				break;

			default:
				parseUserData(null);
				// finish();
				// Toast.makeText(getApplicationContext(),"An unknown error occured. Please try again.",
				// Toast.LENGTH_SHORT).show();
				break;

			}
		}

	}

	public void parseUserData(String response) {
		boolean isError = true;
		if (response != null) {
			if (!response.equals("")) {
				isError = false;

				StaticValues.myInfo = ServerResponseParser
						.parseUserProfileInfo(response, false);

				if (StaticValues.myInfo != null) {
					Utility.storeSession(StaticValues.myInfo.getId(),
							StaticValues.myInfo.getAuthToken(), response,
							getApplicationContext());
				}

				splashHandler.sendEmptyMessage(1);
			} else {
				StaticValues.myInfo = ServerResponseParser
						.parseUserProfileInfo(
								Utility.getUserData(getApplicationContext()),
								false);
				splashHandler.sendEmptyMessage(1);
			}

		}
		if (isError) {
			// Toast.makeText(getApplicationContext(),"An unknown error occured. Please try again.",
			// Toast.LENGTH_SHORT).show();
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

				if (Utility.isBetaAuthenticated(getApplicationContext())) {
					startActivity(new Intent(SplashActivity.this,
							LoginActivity.class));
				} else {
					startActivity(new Intent(SplashActivity.this,
							BetaLoginActivity.class));
				}

				break;

			case 1:

				finish();
				if (StaticValues.myInfo != null) {

					startActivity(new Intent(SplashActivity.this,
							HomeActivity.class));
				} else {
					startActivity(new Intent(SplashActivity.this,
							LoginActivity.class));
				}

				break;
			}
			super.handleMessage(msg);
		}
	};
}
