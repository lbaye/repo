package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.logging.Logger;

import org.json.JSONException;
import org.json.JSONObject;

import com.facebook.android.Facebook;
import com.facebook.android.AsyncFacebookRunner;
import com.socmaps.fb.BaseRequestListener;

import com.socmaps.fb.FBUtility;
import com.socmaps.fb.LoginButton;
import com.socmaps.fb.SessionEvents;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;
import com.socmaps.fb.SessionStore;

import com.socmaps.util.AppStaticStorages;
import com.socmaps.util.Constant;
import com.socmaps.util.Data;
import com.socmaps.util.PreferenceConnector;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.entity.AccountSettingsEntity;
import com.socmaps.entity.Response;
import com.socmaps.util.Utility;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class LoginActivity extends Activity {
	EditText etEmail, etPassword;
	CheckBox chkRememberPassword;
	Button btnLogin, btnCreateAccount;
	TextView btnForgotPassword;
	LoginButton btnFBLogin;
	Button btnFBLogin2;
	private ProgressDialog m_ProgressDialog;
	private Runnable requestRunnable, forgotpassRunnable;
	private Handler mHandler;

	String tempURLString;
	// Response responseObject;

	String responseString = "";
	int responseStatus = 0;

	String forgotpassResponseString = "";
	int forgotpassResponseStatus = 0;

	Dialog forgotpassDialog;
	EditText etForgotpassEmail;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		initialize();

		mHandler = new Handler();

		if (Utility.isLoggedIn(getApplicationContext())) {
			try {

				String savedEmail = Utility.getEmail(getApplicationContext());
				String savedPassword = Utility
						.getPassword(getApplicationContext());

				if (savedEmail != null) {
					etEmail.setText(Utility.getEmail(getApplicationContext()));
				}

				if (savedPassword != null) {
					etPassword.setText(Utility
							.getPassword(getApplicationContext()));
				}

				chkRememberPassword.setChecked(true);

			} catch (Exception e) {
				// TODO: handle exception
			}
		}

		btnFBLogin2.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				requestUserData();

			}
		});

		// Create the Facebook Object using the app id.
		FBUtility.mFacebook = new Facebook(Constant.FB_APP_ID);
		// Instantiate the asynrunner object for asynchronous api calls.
		FBUtility.mAsyncRunner = new AsyncFacebookRunner(FBUtility.mFacebook);

		// restore session if one exists
		SessionStore.restore(FBUtility.mFacebook, this);
		SessionEvents.addAuthListener(new FbAPIsAuthListener());
		SessionEvents.addLogoutListener(new FbAPIsLogoutListener());

		/*
		 * Source Tag: login_tag
		 */
		btnFBLogin.init(this, Constant.AUTHORIZE_ACTIVITY_RESULT_CODE,
				FBUtility.mFacebook, Constant.facebookPermissions);

		if (FBUtility.mFacebook.isSessionValid()) {
			Log.e("LoginActivity", "isSessionValid=true");
			btnFBLogin.setVisibility(View.GONE);
			btnFBLogin2.setVisibility(View.VISIBLE);
		} else {
			Log.e("LoginActivity", "isSessionValid=false");
		}

		btnCreateAccount.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {

				finish();
				Intent myIntent = new Intent(LoginActivity.this,
						RegistrationSMActivity.class);
				startActivity(myIntent);
			}
		});

		btnForgotPassword.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				/*
				 * Intent myIntent = new Intent(LoginActivity.this,
				 * ForgotPasswordActivity.class); startActivity(myIntent);
				 */

				performForgotPass();
			}
		});

		btnLogin.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				boolean flag = true;

				if (!Utility.isValidEmailID(etEmail.getText().toString())) {
					flag = false;
					etEmail.setError("Invalid Email Id");
				} else if (etPassword.getText().toString().length() == 0) {
					flag = false;
					etPassword.setError("Password cannot be empty");
				}

				if (flag) {
					if (Utility.isConnectionAvailble(getApplicationContext())) {

						requestRunnable = new Runnable() {
							public void run() {

								authenticate();

							}
						};
						Thread thread = new Thread(null, requestRunnable,
								"MagentoBackground");
						thread.start();
						m_ProgressDialog = ProgressDialog.show(
								LoginActivity.this, "Login",
								"Authenticating. Please wait...", false);

					} else {
						Toast.makeText(getApplicationContext(),
								"Internet Connection Unavailable",
								Toast.LENGTH_SHORT).show();
					}
				}
			}
		});

	}

	private Runnable returnRes = new Runnable() {

		public void run() {

			// have to do something here
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();

			handleResponse(responseStatus, responseString);

			m_ProgressDialog.dismiss();
		}
	};

	private Runnable returnResFb = new Runnable() {

		public void run() {

			// have to do something here
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();

			handleResponseFb(responseStatus, responseString);

			if (null != m_ProgressDialog)
				m_ProgressDialog.dismiss();
		}
	};

	private Runnable returnForgotPass = new Runnable() {

		public void run() {

			// have to do something here
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();

			handleForgotPassResponse(forgotpassResponseStatus,
					forgotpassResponseString);

			m_ProgressDialog.dismiss();
		}
	};

	public void authenticate() {

		String email = etEmail.getText().toString().trim();
		String password = etPassword.getText().toString();

		Log.e("Login URL", Constant.smLoginUrl);
		RestClient client = new RestClient(Constant.smLoginUrl);
		client.AddParam("email", email);
		client.AddParam("password", password);
		// client.AddHeader("GData-Version", "2");

		try {
			client.Execute(RestClient.RequestMethod.POST);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();
		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);

	}

	public void handleForgotPassResponse(int status, String response) {
		Log.d("ForgotPass", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("ForgotPass", status + ":" + response);
			Toast.makeText(
					getApplicationContext(),
					"Request sent successfully. An email has been sent to your supplied address with detailed instructions.",
					Toast.LENGTH_SHORT).show();
			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(), "Email not found.",
					Toast.LENGTH_SHORT).show();
			break;

		case Constant.STATUS_UNAUTHORIZEZ:
			Toast.makeText(getApplicationContext(), "Unauthorized request.",
					Toast.LENGTH_SHORT).show();
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(), "Bad request.",
					Toast.LENGTH_SHORT).show();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_SHORT).show();
			break;

		}
	}

	public void handleResponse(int status, String response) {
		Log.d("Login", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			loginSuccess(response);
			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					"Email/Password does not match.", Toast.LENGTH_SHORT)
					.show();
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(), "Bad request.",
					Toast.LENGTH_SHORT).show();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_SHORT).show();
			break;

		}
	}

	public void handleResponseFb(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			fbLoginSuccess(response);
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					"Bad request. User already exist.", Toast.LENGTH_SHORT)
					.show();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_SHORT).show();
			break;

		}
	}

	public void fbLoginSuccess(String response) {

		String facebookId = FBUtility.userUID;
		String facebookAuthToken = FBUtility.mFacebook.getAccessToken();

		AccountSettingsEntity accountSettingsEntity = ServerResponseParser
				.parseUserProfileInfo(response, facebookId, facebookAuthToken,
						false);

		if (accountSettingsEntity != null) {
			AppStaticStorages.accountSettingsEntity = accountSettingsEntity;

			// save the authToken, id to the storage
			Utility.storeSession(
					AppStaticStorages.accountSettingsEntity.getSmID(),
					AppStaticStorages.accountSettingsEntity.getAuthToken(),
					LoginActivity.this);

			finish();
			Intent myIntent = new Intent(LoginActivity.this, HomeActivity.class);
			startActivity(myIntent);
		} else {
			Log.e("Facebook Login Error", "Error during parsing response");
		}

	}

	public void loginSuccess(String response) {
		AccountSettingsEntity accountSettingsEntity = ServerResponseParser
				.parseUserProfileInfo(response, false);

		if (accountSettingsEntity != null) {
			AppStaticStorages.accountSettingsEntity = accountSettingsEntity;

			
			if (chkRememberPassword.isChecked()) {
				Utility.storePreferences(etEmail.getText().toString().trim(),
						etPassword.getText().toString(), true,
						getApplicationContext());
			} else {
				Utility.storePreferences(null,
						null, false,
						getApplicationContext());
			}
			
			// save the authToken, id to the storage
			Utility.storeSession(
					AppStaticStorages.accountSettingsEntity.getSmID(),
					AppStaticStorages.accountSettingsEntity.getAuthToken(),
					LoginActivity.this);

			finish();
			Intent myIntent = new Intent(LoginActivity.this, HomeActivity.class);
			startActivity(myIntent);
		} else {
			Log.e("Facebook Login Error", "Error during parsing response");
		}

	}

	public void handleFbResponse(String fbResponse) {

		final String responseText = fbResponse;

		if (Utility.isConnectionAvailble(getApplicationContext())) {

			requestRunnable = new Runnable() {
				public void run() {

					sendFbRegistrationRequest(responseText);

				}
			};
			Thread thread = new Thread(null, requestRunnable,
					"MagentoBackground");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(LoginActivity.this, "Login",
					"Sending request. Please wait...", false);

		} else {
			Toast.makeText(LoginActivity.this,
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}

	}

	public void sendFbRegistrationRequest(String fbResponse) {
		try {
			JSONObject jsonObject = new JSONObject(fbResponse);

			FBUtility.userUID = jsonObject.getString("id");
			// String accessToken = FBUtility.mFacebook.getAccessToken();

			String facebookId = jsonObject.getString("id");
			String facebookAuthToken = FBUtility.mFacebook.getAccessToken();

			String avatarString = jsonObject.getString("picture");// have to
																	// check

			String firstName = jsonObject.getString("first_name");
			String lastName = jsonObject.getString("last_name");
			String email = jsonObject.getString("email");
			String gender = jsonObject.getString("gender");
			String username = jsonObject.getString("username");

			// String location = jsonObject.getString("location");
			String birthday = jsonObject.getString("birthday");
			String dob = Utility.parseFbDob(birthday);
			// String bio = jsonObject.getString("bio");
			// String relationshipStatus =
			// jsonObject.getString("relationshipStatus");

			RestClient client = new RestClient(Constant.smFbLoginUrl);

			// client.AddHeader("GData-Version", "2");
			client.AddParam("facebookId", facebookId);
			client.AddParam("facebookAuthToken", facebookAuthToken);
			client.AddParam("email", email);
			client.AddParam("firstName", firstName);
			client.AddParam("lastName", lastName);
			client.AddParam("userName", username);
			client.AddParam("avatar", avatarString);
			client.AddParam("gender", gender);
			// client.AddParam("city", location);
			client.AddParam("dateOfBirth", dob);
			// client.AddParam("bio", bio);
			// client.AddParam("relationshipStatus", relationshipStatus);

			try {
				client.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = client.getResponse();
			responseStatus = client.getResponseCode();

			runOnUiThread(returnResFb);

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			Log.e("FB parse error", e.getMessage());
			e.printStackTrace();
		}
	}

	public void performForgotPass() {
		// custom dialog
		forgotpassDialog = new Dialog(LoginActivity.this,
				R.style.CustomDialogTheme);
		forgotpassDialog.setContentView(R.layout.forgotpass_dialog);

		etForgotpassEmail = (EditText) forgotpassDialog
				.findViewById(R.id.etForgotpassEmail);

		Button btnCancel = (Button) forgotpassDialog
				.findViewById(R.id.btnCancel);
		// if button is clicked, close the custom dialog
		btnCancel.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				forgotpassDialog.dismiss();
			}
		});

		Button btnSend = (Button) forgotpassDialog.findViewById(R.id.btnSend);
		// if button is clicked, close the custom dialog
		btnSend.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {

				// if(
				// Utility.isValidEmailID(etForgotpassEmail.getText().toString()))
				if (!etForgotpassEmail.getText().toString().trim()
						.equalsIgnoreCase("")) {
					sendForgotPasswordRequest();
					forgotpassDialog.dismiss();
				}

			}
		});

		forgotpassDialog.show();
	}

	public void sendForgotPasswordRequest() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			forgotpassRunnable = new Runnable() {
				public void run() {

					String email = etForgotpassEmail.getText().toString()
							.trim();

					String url = Constant.smForgotPassUrl + "/" + email;

					Log.e("Forgot URL", url);

					RestClient client = new RestClient(url);
					// client.AddParam("email", email);
					// client.AddHeader("GData-Version", "2");

					try {
						client.Execute(RestClient.RequestMethod.GET);
					} catch (Exception e) {
						e.printStackTrace();
					}

					forgotpassResponseString = client.getResponse();
					forgotpassResponseStatus = client.getResponseCode();

					runOnUiThread(returnForgotPass);

				}
			};
			Thread thread = new Thread(null, forgotpassRunnable,
					"MagentoBackground");
			thread.start();
			m_ProgressDialog = ProgressDialog
					.show(LoginActivity.this, "Forgot Password",
							"Sending request. Please wait...", false);

		} else {
			Toast.makeText(getApplicationContext(),
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}
	}

	private void initialize() {
		etEmail = (EditText) findViewById(R.id.etEmail);
		etPassword = (EditText) findViewById(R.id.etPassword);
		chkRememberPassword = (CheckBox) findViewById(R.id.chkRememberPassword);
		btnLogin = (Button) findViewById(R.id.btnLogin);
		btnCreateAccount = (Button) findViewById(R.id.btnCreateAccount);
		btnFBLogin = (LoginButton) findViewById(R.id.btnFBLogin);
		btnFBLogin2 = (Button) findViewById(R.id.btnFBLogin2);
		btnForgotPassword = (TextView) findViewById(R.id.btnForgotPassword);
	}

	/*
	 * Callback for fetching current user's name, picture, uid.
	 */
	public class UserRequestListener extends BaseRequestListener {

		// @Override
		public void onComplete(final String response, final Object state) {

			Log.e("FB Data", response);

			// handleFbResponse(response)
			sendFbRegistrationRequest(response);

		}

	}

	/*
	 * The Callback for notifying the application when authorization succeeds or
	 * fails.
	 */

	public class FbAPIsAuthListener implements AuthListener {

		// @Override
		public void onAuthSucceed() {
			requestUserData();
		}

		// @Override
		public void onAuthFail(String error) {
			Log.e("LoginActivity", "Login Failed: " + error);
		}
	}

	/*
	 * The Callback for notifying the application when log out starts and
	 * finishes.
	 */
	public class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		public void onLogoutBegin() {
			Log.e("LoginActivity", "Logging out...");
		}

		// @Override
		public void onLogoutFinish() {
			Log.e("LoginActivity", "You have logged out! ");
			// mUserPic.setImageBitmap(null);
		}
	}

	/*
	 * Request user name, and picture to show on the main screen.
	 */
	public void requestUserData() {

		Log.e("LoginActivity", "Fetching user name, profile pic...");
		Bundle params = new Bundle();
		params.putString(
				"fields",
				"id,email,name,picture,first_name,last_name,username,bio,birthday,location,relationship_status,gender");
		FBUtility.mAsyncRunner.request("me", params, new UserRequestListener());
		// FBUtility.mAsyncRunner.request("me", new UserRequestListener());
	}

}
