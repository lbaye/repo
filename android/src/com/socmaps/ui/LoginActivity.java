package com.socmaps.ui;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.util.Base64;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.socmaps.entity.FacebookErrorResponse;
import com.socmaps.entity.MyInfo;
import com.socmaps.fb.BaseRequestListener;
import com.socmaps.fb.FBUtility;
import com.socmaps.fb.SessionEvents;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * LoginActivity class for generating login view by two way (sm and fb) also navigate to register view.
 *
 */
public class LoginActivity extends Activity {
	EditText etEmail, etPassword;
	CheckBox chkRememberPassword;
	Button btnLogin, btnCreateAccount;
	TextView btnForgotPassword;
	Button btnFBLogin2;
	private ProgressDialog m_ProgressDialog;
	private Runnable requestRunnable, forgotpassRunnable;
	private Handler mHandler;

	String tempURLString;

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
	String facebookId;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login_layout);

		initialize();

		mHandler = new Handler();

		if (Utility.isRememberedLoginInfo(getApplicationContext())) {
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
								"Authenticating. Please wait...", true, true);

					} else {
						Toast.makeText(getApplicationContext(),
								"Internet Connection Unavailable",
								Toast.LENGTH_SHORT).show();
					}
				}
			}
		});

	}

	private void authenticateFacebook() {
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

			handleResponse(responseStatus, responseString);
			closeProgressDialog();
		}
	};

	private Runnable returnResFb = new Runnable() {

		@Override
		public void run() {

			// have to do something here

			closeProgressDialog();
			handleResponseFb(responseStatus, responseString);

		}
	};

	private Runnable fbErrorHandleThread = new Runnable() {

		@Override
		public void run() {

			handleFacebookError(facebookResponse);
		}
	};

	private Runnable returnForgotPass = new Runnable() {

		@Override
		public void run() {

			// have to do something here

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

	private void authenticate() {

		String email = etEmail.getText().toString().trim();
		String password = etPassword.getText().toString();

		Utility.log("Login URL", Constant.smLoginUrl);
		RestClient client = new RestClient(Constant.smLoginUrl);
		client.AddParam("email", email);
		client.AddParam("password", password);

		try {
			client.Execute(RestClient.RequestMethod.POST);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();
		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);

	}

	private void handleForgotPassResponse(int status, String response) {
		Utility.log("ForgotPass", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

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

	private void handleResponse(int status, String response) {
		Utility.log("Login", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

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

	private void handleResponseFb(int status, String response) {
		Utility.log("FB Login", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

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

	private void fbLoginSuccess(String response) {

		String facebookAuthToken = FBUtility.mFacebook.getAccessToken();

		Utility.log("facebookAuthToken", facebookAuthToken);

		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response,
				facebookId, facebookAuthToken, false);

		if (myInfo != null) {
			StaticValues.myInfo = myInfo;

			// save the authToken, id to the storage
			Utility.storeSession(StaticValues.myInfo.getId(),
					StaticValues.myInfo.getAuthToken(), response,
					LoginActivity.this);
			
			Utility.setFacebookSessionExpireTime(context, FBUtility.mFacebook.getAccessExpires());

			finish();
			Intent myIntent = new Intent(LoginActivity.this, HomeActivity.class);
			startActivity(myIntent);

		} else {
			Utility.log("Facebook Login Error", "Error during parsing response");
		}

	}

	private void loginSuccess(String response) {
		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response,
				false);

		if (myInfo != null) {
			StaticValues.myInfo = myInfo;

			if (chkRememberPassword.isChecked()) {
				Utility.storeLoginInfo(etEmail.getText().toString().trim(),
						etPassword.getText().toString(),
						getApplicationContext());
			} else {
				Utility.storeLoginInfo(null, null, getApplicationContext());
			}

			// save the authToken, id to the storage
			Utility.storeSession(StaticValues.myInfo.getId(),
					StaticValues.myInfo.getAuthToken(), response,
					LoginActivity.this);

			finish();
			Intent myIntent = new Intent(LoginActivity.this, HomeActivity.class);
			startActivity(myIntent);
		} else {
			Utility.log("Facebook Login Error", "Error during parsing response");
		}

	}

	private void sendFbRegistrationRequest(String fbResponse) {
		try {
			JSONObject jsonObject = new JSONObject(fbResponse);
			if (!jsonObject.isNull("id")) {
				facebookId = jsonObject.getString("id");

				String facebookId = jsonObject.getString("id");

				String facebookAuthToken = FBUtility.mFacebook.getAccessToken();

				String avatarString = "https://graph.facebook.com/"
						+ facebookId + "/picture?type=large";

				String firstName = jsonObject.getString("first_name");
				String lastName = jsonObject.getString("last_name");
				String email = jsonObject.getString("email");
				String gender = jsonObject.getString("gender");
				String username = jsonObject.getString("username");

				String birthday = jsonObject.getString("birthday");
				String dob = Utility.parseFbDob(birthday);

				RestClient client = new RestClient(Constant.smFbLoginUrl);

				client.AddParam("facebookId", facebookId);
				client.AddParam("facebookAuthToken", facebookAuthToken);
				client.AddParam("email", email);
				client.AddParam("firstName", firstName);
				client.AddParam("lastName", lastName);
				client.AddParam("userName", username);
				client.AddParam("avatar", avatarString);
				client.AddParam("gender", gender);
				client.AddParam("dateOfBirth", dob);

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
			Utility.log("FB parse error", e.getMessage());
			e.printStackTrace();
			closeProgressDialog();
		}
	}

	private void closeProgressDialog() {
		if (m_ProgressDialog != null) {
			if (m_ProgressDialog.isShowing()) {
				m_ProgressDialog.dismiss();
			}
		}
	}

	private void performForgotPass() {
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
				if (!etForgotpassEmail.getText().toString().trim()
						.equalsIgnoreCase("")) {
					sendForgotPasswordRequest();
					forgotpassDialog.dismiss();
				}

			}
		});

		forgotpassDialog.show();
	}

	private void sendForgotPasswordRequest() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			forgotpassRunnable = new Runnable() {
				@Override
				public void run() {

					String email = etForgotpassEmail.getText().toString()
							.trim();

					String url = Constant.smForgotPassUrl + "/" + email;

					Utility.log("Forgot URL", url);

					RestClient client = new RestClient(url);

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
			m_ProgressDialog = ProgressDialog.show(LoginActivity.this,
					"Forgot Password", "Sending request. Please wait...", true,
					true);

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
		btnFBLogin2 = (Button) findViewById(R.id.btnFBLogin2);
		btnForgotPassword = (TextView) findViewById(R.id.btnForgotPassword);

		ivFacebookProfile = (ImageView) findViewById(R.id.ivFacebookProfile);

		fbAPIsAuthListener = new FbAPIsAuthListener();
		fbAPIsLogoutListener = new FbAPIsLogoutListener();
		sessionEvents = new SessionEvents();

		setProfilePicture();
	}

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
	private class UserRequestListener extends BaseRequestListener {

		// @Override
		@Override
		public void onComplete(final String response, final Object state) {

			Utility.log("FB Data", response);

			facebookResponse = response;

			if (m_ProgressDialog != null) {
			}
			sendFbRegistrationRequest(response);

		}

	}

	private class FbAPIsAuthListener implements AuthListener {

		// @Override
		@Override
		public void onAuthSucceed() {
			Utility.log("FB Login", "success");
			requestUserData();
		}

		// @Override
		@Override
		public void onAuthFail(String error) {
			Utility.log("FB Login", "Login Failed: " + error);
		}
	}

	private class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		@Override
		public void onLogoutBegin() {
			Utility.log("LoginActivity", "Logging out...");
		}

		// @Override
		@Override
		public void onLogoutFinish() {
			Utility.log("LoginActivity", "You have logged out! ");

			Utility.setFacebookImage(context, null);
			ivFacebookProfile.setImageDrawable(getResources().getDrawable(
					R.drawable.icon_facebook));

			FBUtility.mFacebook.authorize(activity,
					Constant.facebookPermissions,
					Constant.AUTHORIZE_ACTIVITY_RESULT_CODE,
					new LoginDialogListener());
		}
	}

	/*
	 * Request user name, and picture to show on the main screen.
	 */
	private void initiateRequestUserData() {

		Utility.log("LoginActivity", "Fetching user name, profile pic...");
		Bundle params = new Bundle();
		params.putString(
				"fields",
				"id,email,name,picture,first_name,last_name,username,bio,birthday,location,relationship_status,gender");
		FBUtility.mAsyncRunner.request("me", params, new UserRequestListener());
	}

	private void requestUserData() {
		Utility.log("LoginActivity", "inside requestUserData");

		Thread thread = new Thread(null, sendRequestThread,
				"Start send request");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.facebook_data_request_message), true, true);
	}

	private Runnable sendRequestThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			initiateRequestUserData();
		}
	};

	private void handleFacebookError(String fbResponse) {
		FacebookErrorResponse fbError = ServerResponseParser
				.parseFacebookError(fbResponse);

		if (fbError.getErrorSubCode() > 0) {

			Toast.makeText(context, fbError.getMessage(), Toast.LENGTH_LONG)
					.show();

		} else {
			Toast.makeText(context,
					"An unknown error occured during login into Facebook.",
					Toast.LENGTH_SHORT).show();
		}
	}

	private final class LoginDialogListener implements DialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			Utility.log("LoginDialogListener", "onComplete");
			SessionEvents.onLoginSuccess();
		}

		// @Override
		@Override
		public void onFacebookError(FacebookError error) {
			Utility.log("LoginDialogListener", "onFacebookError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onError(DialogError error) {
			Utility.log("LoginDialogListener", "onError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onCancel() {
			Utility.log("LoginDialogListener", "onCancel");
			SessionEvents.onLoginError("Action Canceled");
		}
	}

}
