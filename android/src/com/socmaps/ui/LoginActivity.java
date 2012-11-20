package com.socmaps.ui;

import java.io.ByteArrayOutputStream;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.android.*;
import com.facebook.android.Facebook.*;

import com.socmaps.entity.FacebookErrorResponse;
import com.socmaps.entity.MyInfo;
import com.socmaps.fb.BaseRequestListener;
import com.socmaps.fb.FBUtility;
import com.socmaps.fb.SessionEvents;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;
/*import com.socmaps.fb.BaseRequestListener;
 import com.socmaps.fb.FBUtility;
 import com.socmaps.fb.LoginButton;
 import com.socmaps.fb.SessionStore;*/
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class LoginActivity extends Activity {
	EditText etEmail, etPassword;
	CheckBox chkRememberPassword;
	Button btnLogin, btnCreateAccount;
	TextView btnForgotPassword;
	// LoginButton btnFBLogin;
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

	Context context;

	String facebookFetchedDataString;

	ImageView ivFacebookProfile;
	Activity activity;
	String facebookResponse;

	FbAPIsAuthListener fbAPIsAuthListener;
	FbAPIsLogoutListener fbAPIsLogoutListener;
	SessionEvents sessionEvents;

	// Facebook mFacebook;
	// AsyncFacebookRunner mAsyncRunner;
	String facebookId;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login_layout);

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

		/*
		 * // Create the Facebook Object using the app id. FBUtility.mFacebook =
		 * new Facebook(Constant.FB_APP_ID); // Instantiate the asynrunner
		 * object for asynchronous api calls. FBUtility.mAsyncRunner = new
		 * AsyncFacebookRunner(FBUtility.mFacebook);
		 * 
		 * // restore session if one exists
		 * SessionStore.restore(FBUtility.mFacebook, context);
		 * SessionEvents.addAuthListener(fbAPIsAuthListener);
		 * SessionEvents.addLogoutListener(fbAPIsLogoutListener);
		 */

		// btnFBLogin.init(this, Constant.AUTHORIZE_ACTIVITY_RESULT_CODE,
		// FBUtility.mFacebook, Constant.facebookPermissions,
		// getString(R.string.connectWithFbLabel),
		// getString(R.string.connectWithFbLabel));

		// btnFBLogin.init(this,
		// Constant.AUTHORIZE_ACTIVITY_RESULT_CODE,FBUtility.mFacebook,
		// Constant.facebookPermissions);

		FBUtility.mFacebook = new Facebook(Constant.FB_APP_ID);
		FBUtility.mAsyncRunner = new AsyncFacebookRunner(FBUtility.mFacebook);

		SessionEvents.addAuthListener(fbAPIsAuthListener);
		SessionEvents.addLogoutListener(fbAPIsLogoutListener);

		btnFBLogin2.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Utility.hideKeyboardContext(context);
				// requestUserData();

				authenticateFacebook();

			}
		});

		/*
		 * if (FBUtility.mFacebook.isSessionValid()) { Log.e("LoginActivity",
		 * "isSessionValid=true"); btnFBLogin.setVisibility(View.GONE);
		 * btnFBLogin2.setVisibility(View.VISIBLE); } else {
		 * Log.e("LoginActivity", "isSessionValid=false"); }
		 */

		btnCreateAccount.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Utility.hideKeyboardContext(context);

				finish();
				Intent myIntent = new Intent(LoginActivity.this,
						RegistrationActivity.class);
				startActivity(myIntent);
			}
		});

		btnForgotPassword.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				/*
				 * Intent myIntent = new Intent(LoginActivity.this,
				 * ForgotPasswordActivity.class); startActivity(myIntent);
				 */
				Utility.hideKeyboardContext(context);
				performForgotPass();
			}
		});

		btnLogin.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				Utility.hideKeyboardContext(context);

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
							@Override
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

	public void authenticateFacebook() {
		FBUtility.mFacebook.authorize(LoginActivity.this,
				Constant.facebookPermissions, new LoginDialogListener());

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		FBUtility.mFacebook.authorizeCallback(requestCode, resultCode, data);
	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {

			// have to do something here
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();

			handleResponse(responseStatus, responseString);

			closeProgressDialog();
		}
	};

	private Runnable returnResFb = new Runnable() {

		@Override
		public void run() {

			// have to do something here
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();
			closeProgressDialog();

			handleResponseFb(responseStatus, responseString);

		}
	};

	private Runnable fbErrorHandleThread = new Runnable() {

		@Override
		public void run() {

			handleFacebookError(facebookResponse);
			// Toast.makeText(context, "Failed to login in Facebook",
			// Toast.LENGTH_SHORT).show();
		}
	};

	private Runnable returnForgotPass = new Runnable() {

		@Override
		public void run() {

			// have to do something here
			// Toast.makeText(getApplicationContext(),pInfo.getUserName(),
			// Toast.LENGTH_SHORT).show();

			handleForgotPassResponse(forgotpassResponseStatus,
					forgotpassResponseString);

			closeProgressDialog();
		}
	};

	@Override
	protected void onDestroy() {

		super.onDestroy();

		SessionEvents.removeAuthListener(fbAPIsAuthListener);
		SessionEvents.removeLogoutListener(fbAPIsLogoutListener);
	}

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

		// String facebookId = FBUtility.userUID;
		String facebookAuthToken = FBUtility.mFacebook.getAccessToken();

		Log.i("facebookAuthToken", facebookAuthToken);

		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response,
				facebookId, facebookAuthToken, false);

		if (myInfo != null) {
			StaticValues.myInfo = myInfo;

			// save the authToken, id to the storage
			Utility.storeSession(StaticValues.myInfo.getId(),
					StaticValues.myInfo.getAuthToken(), LoginActivity.this);

			// save the image here

			if (StaticValues.myInfo.getAvatar() != null) {
				try {
					ByteArrayOutputStream full_stream = new ByteArrayOutputStream();
					Bitmap fbAvatar = Utility
							.loadBitmapFromURL(StaticValues.myInfo.getAvatar());
					fbAvatar.compress(Bitmap.CompressFormat.PNG, 100,
							full_stream);
					byte[] full_bytes = full_stream.toByteArray();
					String eventPhotoString = Base64.encodeToString(full_bytes,
							Base64.DEFAULT);

					Utility.setFacebookImage(context, eventPhotoString);

					finish();
					Intent myIntent = new Intent(LoginActivity.this,
							HomeActivity.class);
					startActivity(myIntent);

				} catch (Exception e) {
					// TODO: handle exception
				}

			} else {

				finish();
				Intent myIntent = new Intent(LoginActivity.this,
						HomeActivity.class);
				startActivity(myIntent);

			}

			// end of save image

		} else {
			Log.e("Facebook Login Error", "Error during parsing response");
		}

	}

	public void loginSuccess(String response) {
		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response,
				false);

		if (myInfo != null) {
			StaticValues.myInfo = myInfo;

			if (chkRememberPassword.isChecked()) {
				Utility.storePreferences(etEmail.getText().toString().trim(),
						etPassword.getText().toString(), true,
						getApplicationContext());
			} else {
				Utility.storePreferences(null, null, false,
						getApplicationContext());
			}

			// save the authToken, id to the storage
			Utility.storeSession(StaticValues.myInfo.getId(),
					StaticValues.myInfo.getAuthToken(), LoginActivity.this);

			finish();
			Intent myIntent = new Intent(LoginActivity.this, HomeActivity.class);
			startActivity(myIntent);
		} else {
			Log.e("Facebook Login Error", "Error during parsing response");
		}

	}

	/*
	 * public void handleFbResponse(String fbResponse) {
	 * 
	 * final String responseText = fbResponse;
	 * 
	 * if (Utility.isConnectionAvailble(getApplicationContext())) {
	 * 
	 * requestRunnable = new Runnable() { public void run() {
	 * 
	 * sendFbRegistrationRequest(responseText);
	 * 
	 * } }; Thread thread = new Thread(null, requestRunnable,
	 * "MagentoBackground"); thread.start(); m_ProgressDialog =
	 * ProgressDialog.show(LoginActivity.this, "Login",
	 * "Sending request. Please wait...", false);
	 * 
	 * } else { Toast.makeText(LoginActivity.this,
	 * "Internet Connection Unavailable", Toast.LENGTH_SHORT) .show(); }
	 * 
	 * }
	 */

	public void sendFbRegistrationRequest(String fbResponse) {
		try {
			JSONObject jsonObject = new JSONObject(fbResponse);
			if (!jsonObject.isNull("id")) {
				facebookId = jsonObject.getString("id");
				// String accessToken = FBUtility.mFacebook.getAccessToken();

				String facebookId = jsonObject.getString("id");
				// String facebookAuthToken =
				// FBUtility.mFacebook.getAccessToken();
				String facebookAuthToken = FBUtility.mFacebook.getAccessToken();

				// String avatarString = jsonObject.getString("picture");

				String avatarString = "https://graph.facebook.com/"
						+ facebookId + "/picture?type=normal";

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
			} else {
				closeProgressDialog();
				runOnUiThread(fbErrorHandleThread);
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			Log.e("FB parse error", e.getMessage());
			e.printStackTrace();
			closeProgressDialog();

			// runOnUiThread(fbErrorHandleThread);

			// handleFacebookError(fbResponse);
			// Toast.makeText(context, "Failed to login in Facebook",
			// Toast.LENGTH_SHORT).show();
		}
	}

	public void closeProgressDialog() {
		if (m_ProgressDialog != null) {
			if (m_ProgressDialog.isShowing()) {
				m_ProgressDialog.dismiss();
			}
		}
	}

	public void performForgotPass() {
		// custom dialog
		forgotpassDialog = new Dialog(LoginActivity.this,
				R.style.CustomDialogTheme);
		forgotpassDialog.setContentView(R.layout.forgotpass_dialog_layout);

		forgotpassDialog.setOnDismissListener(new OnDismissListener() {

			@Override
			public void onDismiss(DialogInterface arg0) {
				// TODO Auto-generated method stub
				Utility.hideKeyboard(LoginActivity.this);
			}
		});

		etForgotpassEmail = (EditText) forgotpassDialog
				.findViewById(R.id.etForgotpassEmail);

		Button btnCancel = (Button) forgotpassDialog
				.findViewById(R.id.btnCancel);
		// if button is clicked, close the custom dialog
		btnCancel.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				forgotpassDialog.dismiss();

			}
		});

		Button btnSend = (Button) forgotpassDialog.findViewById(R.id.btnSend);
		// if button is clicked, close the custom dialog
		btnSend.setOnClickListener(new OnClickListener() {
			@Override
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
				@Override
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

		context = LoginActivity.this;
		activity = LoginActivity.this;

		etEmail = (EditText) findViewById(R.id.etEmail);
		etPassword = (EditText) findViewById(R.id.etPassword);
		chkRememberPassword = (CheckBox) findViewById(R.id.chkRememberPassword);
		btnLogin = (Button) findViewById(R.id.btnLogin);
		btnCreateAccount = (Button) findViewById(R.id.btnCreateAccount);
		// btnFBLogin = (LoginButton) findViewById(R.id.login);
		btnFBLogin2 = (Button) findViewById(R.id.btnFBLogin2);
		btnForgotPassword = (TextView) findViewById(R.id.btnForgotPassword);

		ivFacebookProfile = (ImageView) findViewById(R.id.ivFacebookProfile);

		fbAPIsAuthListener = new FbAPIsAuthListener();
		fbAPIsLogoutListener = new FbAPIsLogoutListener();
		sessionEvents = new SessionEvents();

		setProfilePicture();
	}

	/**
	 * 
	 */
	private void setProfilePicture() {
		// TODO Auto-generated method stub
		String avatarString = Utility.getFacebookImage(context);
		if (avatarString != null) {
			try {
				byte[] imageAsBytes = Base64.decode(avatarString.getBytes(),
						Base64.DEFAULT);
				ivFacebookProfile.setImageBitmap(BitmapFactory.decodeByteArray(
						imageAsBytes, 0, imageAsBytes.length));
			} catch (Exception e) {
				// TODO: handle exception
			}

		}
	}

	/*
	 * Callback for fetching current user's name, picture, uid.
	 */
	public class UserRequestListener extends BaseRequestListener {

		// @Override
		@Override
		public void onComplete(final String response, final Object state) {

			Log.e("FB Data", response);

			facebookResponse = response;

			if (m_ProgressDialog != null) {
				// m_ProgressDialog.setMessage(getString(R.string.please_wait_text));
			}
			// handleFbResponse(response)
			sendFbRegistrationRequest(response);

		}

	}

	public class FbAPIsAuthListener implements AuthListener {

		// @Override
		@Override
		public void onAuthSucceed() {
			Log.i("FB Login", "success");
			requestUserData();
		}

		// @Override
		@Override
		public void onAuthFail(String error) {
			Log.e("FB Login", "Login Failed: " + error);
		}
	}

	public class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		@Override
		public void onLogoutBegin() {
			Log.e("LoginActivity", "Logging out...");
		}

		// @Override
		@Override
		public void onLogoutFinish() {
			Log.e("LoginActivity", "You have logged out! ");

			// mahadi:start login again
			// btnFBLogin.setVisibility(View.GONE);
			// btnFBLogin2.setVisibility(View.VISIBLE);
			Utility.setFacebookImage(context, null);
			ivFacebookProfile.setImageDrawable(getResources().getDrawable(
					R.drawable.icon_facebook));

			// FBUtility.mFacebook.authorize(activity,
			// Constant.facebookPermissions, Facebook.FORCE_DIALOG_AUTH, new
			// LoginDialogListener());
			FBUtility.mFacebook.authorize(activity,
					Constant.facebookPermissions,
					Constant.AUTHORIZE_ACTIVITY_RESULT_CODE,
					new LoginDialogListener());
		}
	}

	/*
	 * Request user name, and picture to show on the main screen.
	 */
	public void initiateRequestUserData() {

		Log.e("LoginActivity", "Fetching user name, profile pic...");
		Bundle params = new Bundle();
		params.putString(
				"fields",
				"id,email,name,picture,first_name,last_name,username,bio,birthday,location,relationship_status,gender");
		FBUtility.mAsyncRunner.request("me", params, new UserRequestListener());
		// FBUtility.mAsyncRunner.request("me", new UserRequestListener());
	}

	public void requestUserData() {
		Log.i("LoginActivity", "inside requestUserData");

		Thread thread = new Thread(null, sendRequestThread,
				"Start send request");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.facebook_data_request_message), true);
	}

	private Runnable sendRequestThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			initiateRequestUserData();
			// runOnUiThread(sendRequestResponse);
		}
	};

	public void handleFacebookError(String fbResponse) {
		FacebookErrorResponse fbError = ServerResponseParser
				.parseFacebookError(fbResponse);

		// error_subcode list:
		// http://developers.facebook.com/docs/authentication/access-token-expiration/
		if (fbError.getErrorSubCode() > 0) {

			Toast.makeText(context, fbError.getMessage(), Toast.LENGTH_LONG)
					.show();

			/*
			 * SessionEvents.onLogoutBegin(); AsyncFacebookRunner asyncRunner =
			 * new AsyncFacebookRunner( FBUtility.mFacebook);
			 * asyncRunner.logout(context, new LogoutRequestListener());
			 */

			/*
			 * FBUtility.mFacebook.authorize(activity,
			 * Constant.facebookPermissions, Facebook.FORCE_DIALOG_AUTH, new
			 * LoginDialogListener());
			 */

		} else {
			Toast.makeText(context,
					"An unknown error occured during login into Facebook.",
					Toast.LENGTH_SHORT).show();
		}
	}

	private class LogoutRequestListener extends BaseRequestListener {
		// @Override
		@Override
		public void onComplete(String response, final Object state) {
			/*
			 * callback should be run in the original thread, not the background
			 * thread
			 */
			mHandler.post(new Runnable() {
				// @Override
				@Override
				public void run() {
					// sessionEvents.onLogoutFinish();
				}
			});
		}
	}

	private final class LoginDialogListener implements DialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			Log.e("LoginDialogListener", "onComplete");
			SessionEvents.onLoginSuccess();
			// requestUserData();
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

}
