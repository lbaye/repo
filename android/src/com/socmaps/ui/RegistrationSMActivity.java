package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Calendar;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.Response;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.Utility;

public class RegistrationSMActivity extends Activity {
	EditText etEmail, etPassword, etFirstName, etLastName, etCity, etZipCode,
			etCountry, etService, etStreetAddress, etBio, etInterests;
	EditText etUserName;
	LinearLayout toggleOptionalInfoLayout, optionalInfoLayout;
	Dialog locationSharingDisclaimerDialog;

	Button btnAcceptAndLogin;

	ImageView ivProfilePicture;
	Button btnSubmit, btnSelectDate, btnBack;
	Spinner spRelationshipStatus;
	// CheckBox chkRememberPassword;
	TextView tvTerms, tvShowSelectedDate;
	DatePicker dpDateOfBirth;
	private ProgressDialog m_ProgressDialog;
	Uri imageUri;
	Bitmap avatar;
	String tempURLString;

	int requestCode;
	Response responseObject;
	String dob = "";
	Calendar now = Calendar.getInstance();

	private static final int GALLERY_REQUEST = 0;
	private static final int IMAGE_CAPTURE = 1;

	private Runnable requestRunnable;

	int toggleNumber = 1;

	String responseString = "";
	int responseStatus = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.registrationsm);

		initialize();

		toggleOptionalInfoLayout.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				if (isOdd(toggleNumber)) {
					optionalInfoLayout.setVisibility(LinearLayout.VISIBLE);
					toggleNumber++;
				} else {
					optionalInfoLayout.setVisibility(LinearLayout.GONE);
					toggleNumber++;
				}
			}

			private boolean isOdd(int toggleNumber) {
				boolean temp;
				if (toggleNumber % 2 != 0) {
					temp = true;
				} else {
					temp = false;
				}
				return temp;
			}
		});

		btnSelectDate.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {

				DatePickerDialog datePickerDialog = new DatePickerDialog(
						RegistrationSMActivity.this, new OnDateSetListener() {
							public void onDateSet(DatePicker arg0, int arg1,
									int arg2, int arg3) {
								StringBuilder sb = new StringBuilder();
								String month, day;
								if (arg2 < 9) {
									month = "0".concat(Integer
											.toString(arg2 + 1));
								} else {
									month = Integer.toString(arg2 + 1);
								}
								if (arg3 < 9) {
									day = "0".concat(Integer.toString(arg3));
								} else {
									day = Integer.toString(arg3);
								}
								sb.append(arg1).append("-").append(month)
										.append("-").append(day);
								dob = sb.toString();
								Log.d("dob", dob);
								tvShowSelectedDate.setText(dob);
							}

						}, now.get(Calendar.YEAR), now.get(Calendar.MONTH), now
								.get(Calendar.DATE));
				datePickerDialog.show();
			}
		});

		ivProfilePicture.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {

				final CharSequence[] items = { "Gallery", "Camera" };
				AlertDialog.Builder builder = new AlertDialog.Builder(
						RegistrationSMActivity.this);
				builder.setTitle("Select");
				builder.setItems(items, new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int item) {
						Toast.makeText(getApplicationContext(), items[item],
								Toast.LENGTH_SHORT).show();
						if (items[item].equals("Gallery")) {
							requestCode = GALLERY_REQUEST;
						} else {
							requestCode = IMAGE_CAPTURE;
						}
						onOptionItemSelected(requestCode);
					}

				});
				AlertDialog alert = builder.create();
				alert.show();
			}
		});

		btnBack.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				onClose();
			}
		});

		btnSubmit.setOnClickListener(new OnClickListener()
		{
			public void onClick(View v) 
			{
				boolean flag = true;
				if (avatar == null)
				{
					flag = false;
					Toast.makeText(getApplicationContext(),	"Profile picture not selected",	Toast.LENGTH_SHORT).show();
				} 
				else if (!Utility.isValidEmailID(etEmail.getText().toString()))
				{
					flag = false;
					etEmail.setError("Invalid Email Id");
				}
				else if (etPassword.getText().toString().length() == 0) 
				{
					flag = false;
					etPassword.setError("Password can not be empty.");
				}
				else if (etFirstName.getText().toString().length() == 0)
				{
					flag = false;
					etFirstName.setError("First name can not be empty.");
				} 
				else if (etLastName.getText().toString().length() == 0)
				{
					flag = false;
					etLastName.setError("Last name can not be empty.");
				}
				
				if (flag)
				{
					locationSharingDisclaimerDialog = new Dialog(RegistrationSMActivity.this, android.R.style.Theme_Light_NoTitleBar);
					locationSharingDisclaimerDialog.setContentView(R.layout.locationsharingdisclaimer);
					btnAcceptAndLogin = (Button) locationSharingDisclaimerDialog.findViewById(R.id.btnAcceptAndLogin);
					btnBack = (Button) locationSharingDisclaimerDialog.findViewById(R.id.btnBack);
					
					btnBack.setOnClickListener(new OnClickListener()
					{
						public void onClick(View v)
						{
							locationSharingDisclaimerDialog.dismiss();
						}
					});

					
					btnAcceptAndLogin.setOnClickListener(new OnClickListener() 
					{
						public void onClick(View v)
						{
							sendRequest();
							locationSharingDisclaimerDialog.dismiss();
						}

						private void sendRequest()
						{

							 
							{
								if (Utility
										.isConnectionAvailble(getApplicationContext())) {

									requestRunnable = new Runnable() {
										public void run() {

											sendRegistrationRequest();

										}
									};
									Thread thread = new Thread(null,
											requestRunnable, "MagentoBackground");
									thread.start();
									m_ProgressDialog = ProgressDialog.show(
											RegistrationSMActivity.this,
											"Registration",
											"Sending request. Please wait...",
											false);

								} else {
									Toast.makeText(RegistrationSMActivity.this,
											"Internet Connection Unavailable",
											Toast.LENGTH_SHORT).show();
								}
							}
						}
					});

					locationSharingDisclaimerDialog.show();
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
	

	public void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
			// Log.d("Login", status+":"+response);
			registrationSuccess(response);
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

	public void sendRegistrationRequest() {

		String email = etEmail.getText().toString().trim();
		String password = etPassword.getText().toString();

		String avatarString = "";
		if (avatar != null) {
			/* Get the image as string */
			// Normal
			ByteArrayOutputStream full_stream = new ByteArrayOutputStream();
			
			//avatar = Utility..resizeBitmap
			
			Bitmap resizedAvatar = Utility.resizeBitmap(avatar, 0, Constant.thumbHeight);
			
			resizedAvatar.compress(Bitmap.CompressFormat.PNG, 60, full_stream);
			byte[] full_bytes = full_stream.toByteArray();
			avatarString = Base64.encodeToString(full_bytes, Base64.DEFAULT);

		}

		RestClient client = new RestClient(Constant.smRegistrationUrl);

		// client.AddHeader("GData-Version", "2");

		client.AddParam("email", email);
		client.AddParam("password", password);

		client.AddParam("firstName", etFirstName.getText().toString());
		client.AddParam("lastName", etLastName.getText().toString());
		client.AddParam("userName", etUserName.getText().toString());

		client.AddParam("avatar", avatarString);

		client.AddParam("street", etStreetAddress.getText().toString());
		client.AddParam("city", etCity.getText().toString());
		client.AddParam("postCode", etZipCode.getText().toString());
		client.AddParam("country", etCountry.getText().toString());

		client.AddParam("dateOfBirth", dob);
		client.AddParam("bio", etBio.getText().toString());
		client.AddParam("interests", etInterests.getText().toString());

		client.AddParam("workStatus", etService.getText().toString());
		client.AddParam("relationshipStatus", spRelationshipStatus
				.getSelectedItem().toString());

		try {
			client.Execute(RestClient.RequestMethod.POST);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();
		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);

	}

	public void registrationSuccess(String response) {
		// Have to parse response
		finish();
		Intent myIntent = new Intent(RegistrationSMActivity.this,
				HomeActivity.class);
		startActivity(myIntent);
	}

	public boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case 0:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(
					Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case 1:
			Log.d("ANDRO_CAMERA", "Starting camera on the phone...");
			String fileName = "testphoto.jpg";
			ContentValues values = new ContentValues();
			values.put(MediaStore.Images.Media.TITLE, fileName);
			values.put(MediaStore.Images.Media.DESCRIPTION,
					"Image capture by camera");
			values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
			imageUri = getContentResolver().insert(
					MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);

			try {
				avatar = MediaStore.Images.Media.getBitmap(
						this.getContentResolver(), imageUri);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			Intent intents = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			intents.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
			intents.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 1);
			startActivityForResult(intents, requestCode);
		}
		return true;
	}

	private void initialize() {
		btnBack = (Button) findViewById(R.id.btnBack);
		etEmail = (EditText) findViewById(R.id.etEmail);
		etPassword = (EditText) findViewById(R.id.etPassword);
		ivProfilePicture = (ImageView) findViewById(R.id.ivProfilePicture);
		etFirstName = (EditText) findViewById(R.id.etFirstName);
		etLastName = (EditText) findViewById(R.id.etLastName);
		etUserName = (EditText) findViewById(R.id.etUserName);
		etCity = (EditText) findViewById(R.id.etCity);
		etZipCode = (EditText) findViewById(R.id.etZipCode);
		etCountry = (EditText) findViewById(R.id.etCountry);
		btnSelectDate = (Button) findViewById(R.id.btnSelectDate);
		tvShowSelectedDate = (TextView) findViewById(R.id.tvShowSelectedDate);
		etBio = (EditText) findViewById(R.id.etBiography);
		etInterests = (EditText) findViewById(R.id.etInterests);
		etStreetAddress = (EditText) findViewById(R.id.etStreetAddress);
		etService = (EditText) findViewById(R.id.etService);
		spRelationshipStatus = (Spinner) findViewById(R.id.spRelationshipStatus);
		// chkRememberPassword=(CheckBox)
		// findViewById(R.id.chkRememberPassword);
		btnSubmit = (Button) findViewById(R.id.btnSubmit);
		// tvTerms=(TextView) findViewById(R.id.tvTerms);
		toggleOptionalInfoLayout = (LinearLayout) findViewById(R.id.toggleOptionalInfoLayout);
		optionalInfoLayout = (LinearLayout) findViewById(R.id.optionalInfoLayout);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == IMAGE_CAPTURE) {
			if (resultCode == RESULT_OK) {
				Log.d("ANDRO_CAMERA", "Picture taken!!!");
				ivProfilePicture.setImageURI(imageUri);
			}
			if (resultCode == RESULT_CANCELED) {
				return;
			}
		} else if (requestCode == GALLERY_REQUEST) {
			if (resultCode == RESULT_OK) {
				imageUri = data.getData();
				try {
					avatar = MediaStore.Images.Media.getBitmap(
							this.getContentResolver(), imageUri);
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				ivProfilePicture.setImageURI(imageUri);
			}
		}
	}

	public String getPath(Uri uri) {
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = managedQuery(uri, projection, null, null, null);
		int column_index = cursor
				.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		return cursor.getString(column_index);
	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			onClose();
		}
		return false;

	}

	public void onClose() {
		finish();
		Intent myIntent = new Intent(RegistrationSMActivity.this,
				LoginActivity.class);
		startActivity(myIntent);
	}

	

}
