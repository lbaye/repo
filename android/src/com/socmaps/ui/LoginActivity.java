package com.socmaps.ui;

import java.util.HashMap;

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

import com.socmaps.util.Constant;
import com.socmaps.util.Data;
import com.socmaps.util.PreferenceConnector;
import com.socmaps.util.RestClient;
import com.socmaps.entity.Response;
import com.socmaps.util.Utility;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
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
	private ProgressDialog m_ProgressDialog;
	private Runnable requestRunnable, forgotpassRunnable;
	private Handler mHandler;

	String[] permissions = { "offline_access", "publish_stream", "user_photos",
			"publish_checkins", "photo_upload","email" };
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

		try {

			etEmail.setText(PreferenceConnector.readString(
					getApplicationContext(), "email", ""));
			etPassword.setText(PreferenceConnector.readString(
					getApplicationContext(), "password", ""));

		} catch (Exception e) {
			// TODO: handle exception
		}

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
				FBUtility.mFacebook, permissions);

		if (FBUtility.mFacebook.isSessionValid()) {
			Log.e("LoginActivity", "isSessionValid=true");
			requestUserData();
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
		Log.d("ForgotPass", status+":"+response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			//Log.d("ForgotPass", status + ":" + response);
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
		Log.d("Login", status+":"+response);
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

	public void loginSuccess(String response) {

		try {
			JSONObject jsonObject = new JSONObject(response);

			String id = jsonObject.getString("id");
			String email = jsonObject.getString("email");
			String firstName = jsonObject.getString("firstName");
			String lastName = jsonObject.getString("lastName");
			String avatar = jsonObject.getString("avatar");
			String deactivated = jsonObject.getString("deactivated");
			String authToken = jsonObject.getString("authToken");
			String source = jsonObject.getString("source");
			String dateOfBirth = jsonObject.getString("dateOfBirth");
			String bio = jsonObject.getString("bio");
			String interests = jsonObject.getString("interests");
			String workStatus = jsonObject.getString("workStatus");
			String relationshipStatus = jsonObject
					.getString("relationshipStatus");
			String address = jsonObject.getString("address");
			boolean enabled = jsonObject.getBoolean("enabled");
			String lastLogin = jsonObject.getString("lastLogin");
			String updateDate = jsonObject.getString("updateDate");
			String settings = jsonObject.getString("settings");
			String circles = jsonObject.getString("circles");
			String createDate = jsonObject.getString("createDate");

			Log.d("AuthToken", authToken);

			// save the authToken, id to the storage
			Utility.storeSession(id, authToken, LoginActivity.this);

			if (chkRememberPassword.isChecked()) {
				Utility.storePreferences(etEmail.getText().toString().trim(),
						etPassword.getText().toString(), true,
						getApplicationContext());
			}

			finish();
			Intent myIntent = new Intent(LoginActivity.this, HomeActivity.class);
			startActivity(myIntent);

		} catch (JSONException e) {
			// TODO: handle exception
			Log.e("Parse Error", e.getMessage());
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
				
				//if( Utility.isValidEmailID(etForgotpassEmail.getText().toString()))
				if(!etForgotpassEmail.getText().toString().trim().equalsIgnoreCase(""))
				{
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
		btnForgotPassword = (TextView) findViewById(R.id.btnForgotPassword);
	}

	/*
	 * Callback for fetching current user's name, picture, uid.
	 */
	public class UserRequestListener extends BaseRequestListener {

		// @Override
		public void onComplete(final String response, final Object state) {
			JSONObject jsonObject;
			Log.e("FB Data", response);
			
			try {
				jsonObject = new JSONObject(response);

				final String picURL = jsonObject.getString("picture");
				final String name = jsonObject.getString("name");
				FBUtility.userUID = jsonObject.getString("id");

				mHandler.post(new Runnable() {
					// @Override
					public void run() {
						
						String accessToken = FBUtility.mFacebook.getAccessToken();
						
						Log.e("LoginActivity", "Welcome " + name + "!");
						Log.e("FB Access token", accessToken);
						// mUserPic.setImageBitmap(Utility.getBitmap(picURL));
					}
				});

			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
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
		params.putString("fields", "name, picture");
		FBUtility.mAsyncRunner.request("me", params, new UserRequestListener());
	}

}
