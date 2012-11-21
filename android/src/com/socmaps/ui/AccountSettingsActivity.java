package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Calendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MyInfo;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.ExpandablePanel;

public class AccountSettingsActivity extends Activity implements
		OnClickListener {

	private Context context;
	private String selectedUnit = "";
	private String flag = ""; // UNIT or INFO
	private String newPassword = "";
	EditText etEmail, etFirstName, etLastName, etUserName, etCity, etZipCode,
			etService, etStreetAddress, etBio, etInterest, etOldPass,
			etNewPass, etNewPassRetype;
	ImageView ivProfilePicture;
	Button btnUpdatePersonalInfo, btnSelectDate, btnChangePassword,
			btnClearHistoryYes, btnClearHistoryNo, btnDeleteAccountYes,
			btnDeleteAccountNo, btnLogoutYes, btnLogoutNo;
	Spinner spRelationshipStatus, spGender, spCountry;
	TextView tvDateOfBirth;
	DatePicker dpDateOfBirth;
	// RadioButton metricBtn,imperialBtn;
	RadioGroup unitRadioGroup;
	Uri imageUri;
	String tempURLString;

	int requestCode;
	String responseString;

	ExpandablePanel erasePanel, deleteAcountPanel, changePassPanel,
			personalInfoPanel, logoutPanel;
	String dob = "";
	Bitmap avatar;
	Calendar now = Calendar.getInstance();

	int selectedYear, selectedMonth, selectedDay;

	int responseStatus = 0;

	private ProgressDialog m_ProgressDialog = null;

	Button btnBack, btnNotification;

	Handler mHandler;

	// FbAPIsAuthListener fbAPIsAuthListener;
	// FbAPIsLogoutListener fbAPIsLogoutListener;

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.account_settings);

		initialize();
		setExpandListener();
		setViewOnClickListener();

		/*
		 * // Create the Facebook Object using the app id. FBUtility.mFacebook =
		 * new Facebook(Constant.FB_APP_ID); FBUtility.mAsyncRunner = new
		 * AsyncFacebookRunner(FBUtility.mFacebook); // restore session if one
		 * exists SessionStore.restore(FBUtility.mFacebook, context);
		 * SessionEvents.addAuthListener(fbAPIsAuthListener);
		 * SessionEvents.addLogoutListener(fbAPIsLogoutListener);
		 */

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		if (StaticValues.myInfo == null)
			startDialogAndBgThread();
		else
			setFieldValue(StaticValues.myInfo);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (avatar != null) {
			avatar.recycle();
		}

		// SessionEvents.removeAuthListener(fbAPIsAuthListener);
		// SessionEvents.removeLogoutListener(fbAPIsLogoutListener);
	}

	private void setViewOnClickListener() {
		// TODO Auto-generated method stub
		ivProfilePicture.setOnClickListener(this);
		btnSelectDate.setOnClickListener(this);

		btnBack.setOnClickListener(this);
		btnChangePassword.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		btnClearHistoryYes.setOnClickListener(this);
		btnClearHistoryNo.setOnClickListener(this);
		btnDeleteAccountYes.setOnClickListener(this);
		btnDeleteAccountNo.setOnClickListener(this);
		btnUpdatePersonalInfo.setOnClickListener(this);

		btnLogoutYes.setOnClickListener(this);
		btnLogoutNo.setOnClickListener(this);

		unitRadioGroup.setOnCheckedChangeListener(unitChangeListener);
	}

	RadioGroup.OnCheckedChangeListener unitChangeListener = new RadioGroup.OnCheckedChangeListener() {

		@Override
		public void onCheckedChanged(RadioGroup group, int checkedId) {

			if (checkedId == R.id.metric_btn) {
				if (!("Metrics").equalsIgnoreCase(StaticValues.myInfo
						.getSettings().getUnit())) {
					updateUserSettings(Constant.UNIT_METRIC);
				}
			} else if (checkedId == R.id.imperial_btn) {
				if (!("Imperial").equalsIgnoreCase(StaticValues.myInfo
						.getSettings().getUnit())) {
					updateUserSettings(Constant.UNIT_IMPERIAL);
				}
			}
		}

	};

	private Runnable updateUnitSettings = new Runnable() {

		@Override
		public void run() {
			flag = "UNIT";
			RestClient changeUnitSettingsClient = new RestClient(
					Constant.smAccountSettingsUrl);
			changeUnitSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			changeUnitSettingsClient.AddParam("settings[unit]", selectedUnit);
			try {
				changeUnitSettingsClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = changeUnitSettingsClient.getResponse();

			responseStatus = changeUnitSettingsClient.getResponseCode();

			runOnUiThread(returnRes);

		}
	};

	private void updateUserSettings(String unit) {
		// Toast.makeText(context, string, Toast.LENGTH_SHORT).show();
		if (Utility.isConnectionAvailble(getApplicationContext())) {
			selectedUnit = unit;
			Thread thread = new Thread(null, updateUnitSettings,
					"Start update unit");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.updating_data_text), true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	private void displayPanel(View handle, View content, boolean isExpand) {
		if (isExpand) {
			ImageView button = (ImageView) handle
					.findViewById(R.id.ivArrowUpDown);
			button.setImageResource(R.drawable.icon_arrow_up);

			LinearLayout container = (LinearLayout) content;
			TextView text = (TextView) container
					.findViewById(R.id.tvTitleTextTop);
			text.setTypeface(null, Typeface.BOLD);
		} else {
			ImageView button = (ImageView) handle
					.findViewById(R.id.ivArrowUpDown);
			button.setImageResource(R.drawable.icon_arrow_down);

			LinearLayout container = (LinearLayout) content;
			TextView text = (TextView) container
					.findViewById(R.id.tvTitleTextTop);
			text.setTypeface(null, Typeface.NORMAL);
		}
	}

	private void setExpandListener() {
		// TODO Auto-generated method stub
		erasePanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				displayPanel(handle, content, false);
			}

			@Override
			public void onExpand(View handle, View content) {
				displayPanel(handle, content, true);
			}
		});

		logoutPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				displayPanel(handle, content, false);
			}

			@Override
			public void onExpand(View handle, View content) {
				displayPanel(handle, content, true);
			}
		});

		deleteAcountPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						displayPanel(handle, content, false);
					}

					@Override
					public void onExpand(View handle, View content) {
						displayPanel(handle, content, true);
					}
				});

		changePassPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						displayPanel(handle, content, false);
					}

					@Override
					public void onExpand(View handle, View content) {
						displayPanel(handle, content, true);
					}
				});

		personalInfoPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						displayPanel(handle, content, false);
					}

					@Override
					public void onExpand(View handle, View content) {
						displayPanel(handle, content, true);
					}
				});

	}

	private void initialize() {

		context = AccountSettingsActivity.this;
		mHandler = new Handler();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);

		erasePanel = (ExpandablePanel) findViewById(R.id.eraseContainer);
		deleteAcountPanel = (ExpandablePanel) findViewById(R.id.delete_account_container);
		changePassPanel = (ExpandablePanel) findViewById(R.id.change_password_container);
		personalInfoPanel = (ExpandablePanel) findViewById(R.id.personal_info_container);
		btnSelectDate = (Button) findViewById(R.id.btnSelectDate);
		logoutPanel = (ExpandablePanel) findViewById(R.id.logoutContainer);

		etEmail = (EditText) findViewById(R.id.etEmail);

		etFirstName = (EditText) findViewById(R.id.etFirstName);
		etLastName = (EditText) findViewById(R.id.etLastName);
		etUserName = (EditText) findViewById(R.id.etUserName);
		etCity = (EditText) findViewById(R.id.etCity);
		etZipCode = (EditText) findViewById(R.id.etZipCode);
		// etCountry = (EditText) findViewById(R.id.etCountry);
		etInterest = (EditText) findViewById(R.id.etInterests);
		tvDateOfBirth = (TextView) findViewById(R.id.tvShowSelectedDate);
		etBio = (EditText) findViewById(R.id.etBiography);
		etStreetAddress = (EditText) findViewById(R.id.etStreetAddress);
		etService = (EditText) findViewById(R.id.etService);
		spRelationshipStatus = (Spinner) findViewById(R.id.spRelationshipStatus);
		spGender = (Spinner) findViewById(R.id.spGender);
		spCountry = (Spinner) findViewById(R.id.spCountry);

		ivProfilePicture = (ImageView) findViewById(R.id.ivProfilePicture);

		btnSelectDate = (Button) findViewById(R.id.btnSelectDate);

		btnUpdatePersonalInfo = (Button) findViewById(R.id.btnSubmit);
		btnChangePassword = (Button) findViewById(R.id.pass_save_btn);

		btnClearHistoryYes = (Button) findViewById(R.id.erase_yes_btn);
		btnClearHistoryNo = (Button) findViewById(R.id.erase_no_btn);
		btnDeleteAccountYes = (Button) findViewById(R.id.delete_account_yes_btn);
		btnDeleteAccountNo = (Button) findViewById(R.id.delete_account_no_btn);
		btnLogoutYes = (Button) findViewById(R.id.btnLogoutYes);
		btnLogoutNo = (Button) findViewById(R.id.btnLogoutNo);

		etOldPass = (EditText) findViewById(R.id.old_pass_edit_text);
		etNewPass = (EditText) findViewById(R.id.new_pass_edit_text);
		etNewPassRetype = (EditText) findViewById(R.id.retype_new_pass_edit_text);

		unitRadioGroup = (RadioGroup) findViewById(R.id.rgUnit);
		/*
		 * metricBtn=(RadioButton)findViewById(R.id.metric_radio);
		 * imperialBtn=(RadioButton)findViewById(R.id.imperial_radio);
		 */

		// fbAPIsAuthListener = new FbAPIsAuthListener();
		// fbAPIsLogoutListener = new FbAPIsLogoutListener();

	}

	private void setRadioGroupValue(RadioGroup rG, String status) {
		if ("Metric".equalsIgnoreCase(status)) {
			((RadioButton) rG.findViewById(R.id.metric_btn)).setChecked(true);
		} else if ("Imperial".equalsIgnoreCase(status)) {
			((RadioButton) rG.findViewById(R.id.imperial_btn)).setChecked(true);
		} else {
			((RadioButton) rG.findViewById(R.id.metric_btn)).setChecked(true);
		}

	}

	private void setFieldValue(MyInfo myInfo) {
		if (null != myInfo) {
			// Log.e("profileInfo", profileInfo.getUserName());
			if (myInfo.getDateOfBirth() != null) {
				String date = myInfo.getDateOfBirth().split("\\s+")[0];
				setDateValues(date);
				tvDateOfBirth.setText(date);
			} else {
				selectedYear = now.get(Calendar.YEAR);
				selectedMonth = now.get(Calendar.MONTH) + 1;
				selectedDay = now.get(Calendar.DATE);
			}

			if (myInfo.getEmail() != null)
				etEmail.setText(myInfo.getEmail());
			if (myInfo.getFirstName() != null)
				etFirstName.setText(myInfo.getFirstName());
			if (myInfo.getLastName() != null)
				etLastName.setText(myInfo.getLastName());
			if (myInfo.getUserName() != null)
				etUserName.setText(myInfo.getUserName());
			if (myInfo.getCity() != null)
				etCity.setText(myInfo.getCity());
			if (myInfo.getPostCode() != null)
				etZipCode.setText(myInfo.getPostCode());

			if (myInfo.getCountry() != null) {
				// etCountry.setText(accountSettingsEntity.getCountry());
				String countryValue = myInfo.getCountry();
				ArrayAdapter myAdap = (ArrayAdapter) spCountry.getAdapter();

				try {
					int spinnerPosition = myAdap.getPosition(countryValue);
					spCountry.setSelection(spinnerPosition);
				} catch (Exception e) {
					// TODO: handle exception
				}
			}

			if (myInfo.getBio() != null)
				etBio.setText(myInfo.getBio());
			if (myInfo.getStreetAddress() != null)
				etStreetAddress.setText(myInfo.getStreetAddress());
			if (myInfo.getWorkStatus() != null)
				etService.setText(myInfo.getWorkStatus());
			if (myInfo.getInterests() != null)
				etInterest.setText(myInfo.getInterests());

			// spDistanceUnit.setSelection(profileInfo.getUnit());

			if (myInfo.getGender().equalsIgnoreCase("male")) {
				spGender.setSelection(1);
			} else if (myInfo.getGender().equalsIgnoreCase("female")) {
				spGender.setSelection(2);
			}

			if (myInfo.getRelationshipStatus().equalsIgnoreCase("single")) {
				spRelationshipStatus.setSelection(1);
			} else if (myInfo.getRelationshipStatus().equalsIgnoreCase(
					"married")) {
				spRelationshipStatus.setSelection(2);
			} else if (myInfo.getRelationshipStatus().equalsIgnoreCase(
					"complicated")) {
				spRelationshipStatus.setSelection(3);
			}

			if (myInfo.getAvatar() != null && avatar == null) {

				// ivProfilePicture.setTag(myInfo.getAvatar());
				// new DownloadImagesTask().execute(ivProfilePicture);
				ImageLoader imageLoader = new ImageLoader(context);
				imageLoader.DisplayImage(myInfo.getAvatar(), ivProfilePicture,
						R.drawable.thumb);

			}
			if (myInfo.getSettings() != null) {
				setRadioGroupValue(unitRadioGroup, myInfo.getSettings()
						.getUnit());
			}

			if (myInfo.getFirstName() != null) {
				TextView tvConfirmLabel = (TextView) logoutPanel
						.findViewById(R.id.tvConfirmLabel);
				tvConfirmLabel
						.setText("Log out " + myInfo.getFirstName() + "?");
			}

		}

	}

	private void setDateValues(String date) {
		// TODO Auto-generated method stub

		try {
			String[] splits = date.split("-");
			selectedYear = Integer.parseInt(splits[0]);
			selectedMonth = Integer.parseInt(splits[1]);
			selectedDay = Integer.parseInt(splits[2]);
		} catch (Exception e) {
			// TODO: handle exception
			selectedYear = now.get(Calendar.YEAR);
			selectedMonth = now.get(Calendar.MONTH) + 1;
			selectedDay = now.get(Calendar.DATE);
		}

	}

	private Runnable returnResGetAccountSettings = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			m_ProgressDialog.dismiss();
			handleAccountSettingsResponse(responseStatus, responseString);

		}

	};

	public void handleAccountSettingsResponse(int status, String response) {
		Log.d("Account Settings", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(
					responseString, true);

			if (myInfo != null) {
				setFieldValue(myInfo);
				StaticValues.myInfo = myInfo;
			} else {
				Log.e("Account Settings",
						"Error occured during parsing GET response");
			}

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private Runnable getAccountSettingsInfo = new Runnable() {

		@Override
		public void run() {
			RestClient getAccountSettingsClient = new RestClient(
					Constant.smAccountSettingsUrl);
			getAccountSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();

			responseStatus = getAccountSettingsClient.getResponseCode();

			runOnUiThread(returnResGetAccountSettings);

		}
	};

	private void startDialogAndBgThread() {

		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, getAccountSettingsInfo,
					"Start update password");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	public boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case Constant.REQUEST_CODE_GALLERY:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(
					Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case Constant.REQUEST_CODE_CAMERA:
			Intent cameraIntent = new Intent(
					android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(cameraIntent, requestCode);
			break;
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {
				// avatar = (Bitmap) data.getExtras().get("data");
				// ivProfilePicture.setImageBitmap(avatar);

				if (avatar != null) {
					// avatar.recycle();
				}
				avatar = Utility.resizeBitmap(
						(Bitmap) data.getExtras().get("data"),
						Constant.thumbWidth, Constant.thumbHeight);
				ivProfilePicture.setImageBitmap(avatar);

			}
			if (resultCode == RESULT_CANCELED) {
				return;
			}
		} else if (requestCode == Constant.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {
				imageUri = data.getData();
				try {
					// avatar =
					// MediaStore.Images.Media.getBitmap(this.getContentResolver(),
					// imageUri);
					// ivProfilePicture.setImageBitmap(avatar);
					if (avatar != null) {
						// avatar.recycle();
					}
					avatar = Utility.resizeBitmap(
							MediaStore.Images.Media.getBitmap(
									this.getContentResolver(), data.getData()),
							Constant.thumbWidth, Constant.thumbHeight);
					ivProfilePicture.setImageBitmap(avatar);
				}
				catch(OutOfMemoryError e)
				{
					Log.e("Gallery image", "OutOfMemoryError");
					Toast.makeText(context, getString(R.string.errorMessageGallery), Toast.LENGTH_SHORT).show();
					e.printStackTrace();
				}
				catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
				// ivProfilePicture.setImageURI(imageUri);
			}
		}
	}

	/*
	 * public String getPath(Uri uri) { String[] projection = {
	 * MediaStore.Images.Media.DATA }; Cursor cursor = managedQuery(uri,
	 * projection, null, null, null); int column_index = cursor
	 * .getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
	 * cursor.moveToFirst(); return cursor.getString(column_index); }
	 */

	public void selectDate() {
		DatePickerDialog datePickerDialog = new DatePickerDialog(
				AccountSettingsActivity.this, new OnDateSetListener() {
					@Override
					public void onDateSet(DatePicker arg0, int arg1, int arg2,
							int arg3) {
						StringBuilder sb = new StringBuilder();
						String month, day;
						if (arg2 < 9) {
							month = "0".concat(Integer.toString(arg2 + 1));
						} else {
							month = Integer.toString(arg2 + 1);
						}
						if (arg3 < 9) {
							day = "0".concat(Integer.toString(arg3));
						} else {
							day = Integer.toString(arg3);
						}
						sb.append(arg1).append("-").append(month).append("-")
								.append(day);

						if (dob != null) {
							dob = sb.toString();
							setDateValues(dob);
							Log.d("dob", dob);
							tvDateOfBirth.setText(dob);
						}

					}

				}, selectedYear, selectedMonth - 1, selectedDay);
		datePickerDialog.show();
	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {
			handleResponseSavePersonalInfo(responseStatus, responseString);
			m_ProgressDialog.dismiss();
		}
	};

	private Runnable returnResPasswordChange = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponse(responseStatus, responseString);

			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			Toast.makeText(getApplicationContext(),
					"Information saved successfully!!", Toast.LENGTH_SHORT)
					.show();
			changePassPanel.togglePanel();
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	public void handleResponseSavePersonalInfo(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(getApplicationContext(),
					"Information saved successfully!!", Toast.LENGTH_SHORT)
					.show();
			updateLocalValue(response);
			if (flag.equals("INFO"))
				personalInfoPanel.togglePanel();
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void updateLocalValue(String responseString) {
		// TODO Auto-generated method stub
		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(
				responseString, false);
		if (myInfo != null)
			StaticValues.myInfo = myInfo;
	}

	private Runnable updatePersonalInfo = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendDataToServer();
		}

		private void sendDataToServer() {
			flag = "INFO";
			String avatarString = "";

			RestClient client = new RestClient(Constant.smAccountSettingsUrl);

			// client.AddHeader("GData-Version", "2");

			// String email=Utility.getEmail(context);

			client.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			client.AddParam("email", etEmail.getText().toString().trim());

			client.AddParam("firstName", etFirstName.getText().toString()
					.trim());
			client.AddParam("lastName", etLastName.getText().toString().trim());
			client.AddParam("username", etUserName.getText().toString().trim());

			client.AddParam("street", etStreetAddress.getText().toString());
			client.AddParam("city", etCity.getText().toString());
			client.AddParam("postCode", etZipCode.getText().toString());

			client.AddParam("dateOfBirth", tvDateOfBirth.getText().toString()
					.trim());
			client.AddParam("bio", etBio.getText().toString());
			client.AddParam("interests", etInterest.getText().toString());

			client.AddParam("workStatus", etService.getText().toString());

			if (spGender.getSelectedItemPosition() > 0) {
				client.AddParam("gender", spGender.getSelectedItem().toString());
			}

			if (spCountry.getSelectedItemPosition() > 0) {
				client.AddParam("country", spCountry.getSelectedItem()
						.toString());
			}

			if (spRelationshipStatus.getSelectedItemPosition() > 0) {
				client.AddParam("relationshipStatus", spRelationshipStatus
						.getSelectedItem().toString());
			}

			if (avatar != null) {

				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				// Bitmap resizedAvatar =
				// Utility.resizeBitmap(avatar,Constant.thumbWidth,
				// Constant.thumbHeight);
				// resizedAvatar.compress(Bitmap.CompressFormat.PNG,
				// 60,full_stream);
				avatar.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				avatarString = Base64
						.encodeToString(full_bytes, Base64.DEFAULT);

				client.AddParam("avatar", avatarString);

				// avatar.recycle();
			}

			try {
				client.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = client.getResponse();

			responseStatus = client.getResponseCode();

			runOnUiThread(returnRes);
		}
	};

	public void updateSettings() {
		boolean flag = true;
		if (!Utility.isValidEmailID(etEmail.getText().toString().trim())) {
			flag = false;
			etEmail.setError("Invalid Email Id");
		} else if (etFirstName.getText().toString().trim().equals("")) {
			flag = false;
			etFirstName.setError("First Name can not be empty.");
		} else if (etLastName.getText().toString().trim().equals("")) {
			flag = false;
			etLastName.setError("Last Name can not be empty.");
		} /*
		 * else if (etUserName.getText().toString().trim().equals("")) { flag =
		 * false; etUserName.setError("User Name can not be empty."); }
		 */

		if (flag) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				Thread thread = new Thread(null, updatePersonalInfo,
						"Start update password");
				thread.start();
				m_ProgressDialog = ProgressDialog.show(this, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.updating_data_text), true);

			} else {

				DialogsAndToasts.showNoInternetConnectionDialog(context);
			}
		}
	}

	public void selectPicture() {
		final CharSequence[] items = { "Gallery", "Camera" };
		AlertDialog.Builder builder = new AlertDialog.Builder(
				AccountSettingsActivity.this);
		builder.setTitle("Select");
		builder.setItems(items, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int item) {
				/*
				 * Toast.makeText(getApplicationContext(), items[item],
				 * Toast.LENGTH_SHORT).show();
				 */
				if (items[item].equals("Gallery")) {
					requestCode = Constant.REQUEST_CODE_GALLERY;
				} else {
					requestCode = Constant.REQUEST_CODE_CAMERA;
				}
				onOptionItemSelected(requestCode);
			}

		});
		AlertDialog alert = builder.create();
		alert.show();
	}

	public void promptClearHistory() {
		AlertDialog.Builder builder = new AlertDialog.Builder(
				AccountSettingsActivity.this);

		builder.setTitle("Clear History");
		builder.setMessage("This action will remove all your data of Social Maps. Are you sure?");
		builder.setCancelable(true)
				.setPositiveButton("Yes",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								clearHistory();
							}
						}).setNegativeButton("Cancel", null);
		AlertDialog alert = builder.create();
		alert.show();
	}

	public void promptDeleteAccount() {
		AlertDialog.Builder builder = new AlertDialog.Builder(
				AccountSettingsActivity.this);
		builder.setTitle("Delete Account");
		builder.setMessage("Are you sure you want to remove your account from Social Maps?");
		builder.setCancelable(true)
				.setPositiveButton("Yes",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								deleteAccount();
							}
						}).setNegativeButton("Cancel", null);
		AlertDialog alert = builder.create();
		alert.show();
	}

	public void clearHistory() {
		AlertDialog.Builder builder = new AlertDialog.Builder(
				AccountSettingsActivity.this);
		builder.setTitle("Success");
		builder.setMessage("History cleared successfully.");
		builder.setCancelable(true).setPositiveButton("Ok",
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int id) {

					}
				});
		AlertDialog alert = builder.create();
		alert.show();
	}

	public void deleteAccount() {
		AlertDialog.Builder builder = new AlertDialog.Builder(
				AccountSettingsActivity.this);
		builder.setTitle("Success");
		builder.setMessage("Account removed successfully.");
		builder.setCancelable(true).setPositiveButton("Ok",
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int id) {

					}
				});
		AlertDialog alert = builder.create();
		alert.show();
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
		}

		if (v == btnSelectDate) {
			selectDate();
		} else if (v == ivProfilePicture) {
			selectPicture();
		} else if (v == btnUpdatePersonalInfo) {
			updateSettings();
		} else if (v == btnChangePassword) {
			updatePassword();
		} else if (v == btnClearHistoryYes) {

		} else if (v == btnClearHistoryNo) {
			erasePanel.hidePanel();

		} else if (v == btnDeleteAccountYes) {

		} else if (v == btnDeleteAccountNo) {
			deleteAcountPanel.hidePanel();

		} else if (v == btnLogoutYes) {
			executeLogout();
		} else if (v == btnLogoutNo) {
			logoutPanel.hidePanel();
		}

	}

	private void executeLogout() {

		// AsyncFacebookRunner asyncRunner = new
		// AsyncFacebookRunner(FBUtility.mFacebook);
		// asyncRunner.logout(context, new LogoutRequestListener());

		Log.e("Account settings", "You have logged out! ");
		Utility.setFacebookImage(context, null);
		Utility.destroySession(context);

		Intent intent = new Intent(context, HomeActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		intent.putExtra("LOGOUT", true);
		startActivity(intent);

	}

	/*
	 * private class LogoutRequestListener extends BaseRequestListener { //
	 * @Override
	 * 
	 * @Override public void onComplete(String response, final Object state) {
	 * mHandler.post(new Runnable() { // @Override
	 * 
	 * @Override public void run() {
	 * 
	 * SessionEvents.onLogoutFinish(); } }); } }
	 * 
	 * public class FbAPIsAuthListener implements AuthListener {
	 * 
	 * // @Override
	 * 
	 * @Override public void onAuthSucceed() {
	 * 
	 * }
	 * 
	 * // @Override
	 * 
	 * @Override public void onAuthFail(String error) { Log.e("HomeActivity",
	 * "Login Failed: " + error); } }
	 * 
	 * 
	 * public class FbAPIsLogoutListener implements LogoutListener { //
	 * @Override
	 * 
	 * @Override public void onLogoutBegin() { Log.e("Account settings",
	 * "Logging out..."); }
	 * 
	 * // @Override
	 * 
	 * @Override public void onLogoutFinish() { Log.e("Account settings",
	 * "You have logged out! "); Utility.setFacebookImage(context, null);
	 * 
	 * Intent intent = new Intent(context, HomeActivity.class);
	 * intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
	 * intent.putExtra("LOGOUT", true); startActivity(intent);
	 * 
	 * } }
	 */

	private void updatePassword() {
		// TODO Auto-generated method stub
		boolean flag = true;
		if (etOldPass.getText().toString().trim().equals("")) {
			flag = false;
			etOldPass.setError("Please enter old password!");
		} else if (etNewPass.getText().toString().trim().equals("")) {
			flag = false;
			etNewPass.setError("Please enter a new password!");
		} else if (etNewPassRetype.getText().toString().trim().equals("")) {
			flag = false;
			etNewPassRetype.setError("Please Retype your password!");
		} else if (!etNewPass.getText().toString().trim()
				.equals(etNewPassRetype.getText().toString().trim())) {
			flag = false;
			etNewPassRetype.setError("Password did not match!!");
		}

		if (flag) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				Thread thread = new Thread(null, updatePassWordThread,
						"Start update");
				thread.start();
				m_ProgressDialog = ProgressDialog.show(this, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.updating_data_text), true);

			} else {

				DialogsAndToasts.showNoInternetConnectionDialog(context);
			}
		}

	}

	private Runnable updatePassWordThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendPasswordChangeRequest();
		}

	};

	private void sendPasswordChangeRequest() {
		newPassword = etNewPass.getText().toString();
		RestClient client = new RestClient(Constant.changePasswordUrl);

		client.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));

		client.AddParam("oldPassword", etOldPass.getText().toString());
		client.AddParam("password", etNewPass.getText().toString());
		try {
			client.Execute(RestClient.RequestMethod.PUT);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();

		responseStatus = client.getResponseCode();

		runOnUiThread(returnResPasswordChange);

	}

	/*
	 * public class DownloadImagesTask extends AsyncTask<ImageView, Void,
	 * Bitmap> {
	 * 
	 * ImageView imageView = null;
	 * 
	 * @Override protected Bitmap doInBackground(ImageView... imageViews) {
	 * this.imageView = imageViews[0]; return download_Image((String)
	 * imageView.getTag()); }
	 * 
	 * @Override protected void onPostExecute(Bitmap result) {
	 * imageView.setImageBitmap(result); }
	 * 
	 * private Bitmap download_Image(String url) {
	 * 
	 * return Utility.loadBitmapFromURL(url); }
	 * 
	 * }
	 */

}
