package com.socmaps.ui;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.socmaps.entity.PlatformsPreferences;
import com.socmaps.fb.BaseDialogListener;
import com.socmaps.fb.FBUtility;
import com.socmaps.fb.SessionEvents;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * PlatformPreferencesActivity describes the preferences of platform. 
 * User can choose either one based on his preference. 
 */

public class PlatformPreferencesActivity extends Activity implements
		OnClickListener {
	CheckBox chkFB, chk4sq, chkGplus;
	Button btnSave, btnInvite;
	Button btnBack, btnNotification;
	Context context;
	RadioGroup radioGroupFb, radioGroup4sq, radioGroupGooglePlus;

	ProgressDialog m_ProgressDialog;
	int requestCode;
	String responseString;
	int responseStatus = 0;

	FbAPIsAuthListener fbAPIsAuthListener;
	FbAPIsLogoutListener fbAPIsLogoutListener;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.platform_preferences_layout);

		initialize();

		setViewOnClickListener();

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);

		if (StaticValues.platformsPreferences == null) {
			startDialogAndBgThread();
		} else {
			setFieldValues(StaticValues.platformsPreferences);
		}
	}

	@Override
	protected void onDestroy() {
		SessionEvents.removeAuthListener(fbAPIsAuthListener);
		SessionEvents.removeLogoutListener(fbAPIsLogoutListener);

		System.gc();

		super.onDestroy();
	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void setFieldValues(PlatformsPreferences platformsPreferences) {
		// TODO Auto-generated method stub

		setRadioGroupValue(radioGroupFb, platformsPreferences.getFb());
		setRadioGroupValue(radioGroup4sq, platformsPreferences.getFourSqr());
		setRadioGroupValue(radioGroupGooglePlus,
				platformsPreferences.getGooglePlus());

	}

	private void setRadioGroupValue(RadioGroup rG, boolean status) {
		// TODO Auto-generated method stub
		if (status) {
			((RadioButton) rG.findViewById(R.id.on_radio)).setChecked(status);
		} else
			((RadioButton) rG.findViewById(R.id.off_radio)).setChecked(true);
	}

	private void handlePlatformSettingsResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			PlatformsPreferences platformsPreferences = ServerResponseParser
					.parsePlatformsSettings(response);
			setFieldValues(platformsPreferences);
			StaticValues.platformsPreferences = platformsPreferences;
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response),
					Toast.LENGTH_LONG).show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response),
					Toast.LENGTH_LONG).show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private Runnable returnResGetPlatformsSettings = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}

			handlePlatformSettingsResponse(responseStatus, responseString);
		}

	};

	private Runnable getPlatformSettingsInfo = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient getPlatformSettingsClient = new RestClient(
					Constant.platformsSettingsUrl);
			getPlatformSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getPlatformSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getPlatformSettingsClient.getResponse();

			responseStatus = getPlatformSettingsClient.getResponseCode();

			runOnUiThread(returnResGetPlatformsSettings);

		}
	};

	private void startDialogAndBgThread() {

		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, getPlatformSettingsInfo,
					"Start update password");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true, true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	private void initialize() {

		context = PlatformPreferencesActivity.this;
		radioGroup4sq = (RadioGroup) findViewById(R.id.radioFourSQGroup);
		radioGroupFb = (RadioGroup) findViewById(R.id.radioFbGroup);
		radioGroupGooglePlus = (RadioGroup) findViewById(R.id.radioGooglePlusGroup);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);

		btnSave = (Button) findViewById(R.id.btnSavePlatforms);
		btnInvite = (Button) findViewById(R.id.btnInvite);

		fbAPIsAuthListener = new FbAPIsAuthListener();
		fbAPIsLogoutListener = new FbAPIsLogoutListener();
	}

	private void setViewOnClickListener() {
		// TODO Auto-generated method stub

		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		btnSave.setOnClickListener(this);
		btnInvite.setOnClickListener(this);

	}

	private Runnable updatePlatformValuesThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendDataToServer();
		}
	};

	private int getRadioStatus(RadioGroup rG) {
		int checkedRadioButton = rG.getCheckedRadioButtonId();

		if (((RadioButton) rG.findViewById(R.id.off_radio)).isChecked()) {
			return 0;
		} else {
			return 1;
		}
	}

	private void sendDataToServer() {
		RestClient client = new RestClient(Constant.platformsSettingsUrl);

		// client.AddHeader("GData-Version", "2");
		client.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));
		client.AddParam("fb", getRadioStatus(radioGroupFb) + "");
		client.AddParam("4sq", getRadioStatus(radioGroup4sq) + "");
		client.AddParam("googlePlus", getRadioStatus(radioGroupGooglePlus) + "");

		try {
			client.Execute(RestClient.RequestMethod.PUT);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();

		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);
	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponse(responseStatus, responseString);

			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}

		}
	};

	private void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			Toast.makeText(getApplicationContext(),
					"Information saved successfully!!", Toast.LENGTH_SHORT)
					.show();
			StaticValues.platformsPreferences = ServerResponseParser
					.parsePlatformsSettings(response);
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response),
					Toast.LENGTH_LONG).show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response),
					Toast.LENGTH_LONG).show();
			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void updateAllValues() {
		// TODO Auto-generated method stub

		Thread thread = new Thread(null, updatePlatformValuesThread,
				"Start update platforms");
		thread.start();

		m_ProgressDialog = ProgressDialog.show(this,
				getResources().getString(R.string.please_wait_text),
				getResources().getString(R.string.updating_data_text), true,
				true);
		m_ProgressDialog.show();
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnBack) {
			finish();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(getApplicationContext(),
					NotificationActivity.class);
			startActivity(notificationIntent);
		} else if (v == btnSave) {
			updateAllValues();
		} else if (v == btnInvite) {

			if (StaticValues.myInfo.getRegMedia().equalsIgnoreCase("fb")
					&& FBUtility.mFacebook != null) {
				initInviteFriends();
			} else {
				initInvitationDialog();
			}

		}

	}

	private void initInvitationDialog() {
		// TODO Auto-generated method stub
		FBUtility.mFacebook = new Facebook(Constant.FB_APP_ID);
		FBUtility.mAsyncRunner = new AsyncFacebookRunner(FBUtility.mFacebook);

		SessionEvents.addAuthListener(fbAPIsAuthListener);
		SessionEvents.addLogoutListener(fbAPIsLogoutListener);

		FBUtility.mFacebook.authorize((Activity) context,
				Constant.facebookPermissions, new LoginDialogListener());

	}

	private class FbAPIsAuthListener implements AuthListener {

		// @Override
		@Override
		public void onAuthSucceed() {

			initInviteFriends();

		}

		// @Override
		@Override
		public void onAuthFail(String error) {
			Log.e("HomeActivity", "Login Failed: " + error);
		}
	}

	/*
	 * The Callback for notifying the application when log out starts and
	 * finishes.
	 */
	private class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		@Override
		public void onLogoutBegin() {
			Log.e("HomeActivity", "Logging out...");
		}

		// @Override
		@Override
		public void onLogoutFinish() {
			Log.e("HomeActivity", "You have logged out! ");

			Utility.setFacebookImage(context, null);

			FBUtility.mFacebook.authorize((Activity) context,
					Constant.facebookPermissions, Facebook.FORCE_DIALOG_AUTH,
					new LoginDialogListener());
		}
	}

	private final class LoginDialogListener implements DialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			Log.e("LoginDialogListener", "onComplete");
			SessionEvents.onLoginSuccess();
		}

		// @Override
		@Override
		public void onFacebookError(FacebookError error) {
			Log.e("LoginDialogListener", "onFacebookError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onError(DialogError error) {
			Log.e("LoginDialogListener", "onError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onCancel() {
			Log.e("LoginDialogListener", "onCancel");
			SessionEvents.onLoginError("Action Canceled");
		}
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		FBUtility.mFacebook.authorizeCallback(requestCode, resultCode, data);
	}

	private void initInviteFriends() {
		Log.d("Facebook", "Have to invite");

		if (Utility.isConnectionAvailble(context)) {

			showInvitationDialog();

		} else {
			Toast.makeText(getApplicationContext(),
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}
	}

	private void showInvitationDialog() {
		Bundle params = new Bundle();
		params.putString("message", "Checkout the app.");
		FBUtility.mFacebook.dialog(context, "apprequests", params,
				new AppRequestsListener());
	}

	/*
	 * callback for the apprequests dialog which sends an app request to user's
	 * friends.
	 */
	private class AppRequestsListener extends BaseDialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
		}

		@Override
		public void onFacebookError(FacebookError error) {
		}

		@Override
		public void onCancel() {
		}
	}

}
