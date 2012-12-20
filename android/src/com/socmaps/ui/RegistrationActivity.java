package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Calendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
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

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MyInfo;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class RegistrationActivity extends Activity {
	EditText etEmail, etPassword, etFirstName, etLastName, etCity, etZipCode,
			etService, etStreetAddress, etBio, etInterests;
	EditText etUserName;
	LinearLayout toggleOptionalInfoLayout, optionalInfoLayout;
	Dialog locationSharingDisclaimerDialog;

	Button btnAcceptAndLogin;

	ImageView ivProfilePicture;
	Button btnSubmit, btnSelectDate, btnBack;
	Spinner spRelationshipStatus, spGender, spCountry;
	TextView tvTerms, tvShowSelectedDate;
	DatePicker dpDateOfBirth;
	private ProgressDialog m_ProgressDialog;

	Bitmap avatar;
	String tempURLString;

	int requestCode;
	String dob = "";
	Calendar now = Calendar.getInstance();

	private Runnable requestRunnable;

	int toggleNumber = 1;

	String responseString = "";
	int responseStatus = 0;

	Context context;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.registration_layout);

		initialize();

		toggleOptionalInfoLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if (isOdd(toggleNumber)) {
					optionalInfoLayout.setVisibility(View.VISIBLE);
					toggleNumber++;
				} else {
					optionalInfoLayout.setVisibility(View.GONE);
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
			@Override
			public void onClick(View v) {

				DatePickerDialog datePickerDialog = new DatePickerDialog(
						context, new OnDateSetListener() {
							@Override
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
			@Override
			public void onClick(View v) {

				final CharSequence[] items = { "Gallery", "Camera" };
				AlertDialog.Builder builder = new AlertDialog.Builder(context);
				builder.setTitle("Select");
				builder.setItems(items, new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int item) {
						Toast.makeText(getApplicationContext(), items[item],
								Toast.LENGTH_SHORT).show();
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
		});

		btnBack.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				onClose();
			}
		});

		btnSubmit.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				boolean flag = true;
				if (avatar == null) {
					flag = false;
					Toast.makeText(getApplicationContext(),
							"Profile picture not selected", Toast.LENGTH_SHORT)
							.show();
				} else if (!Utility
						.isValidEmailID(etEmail.getText().toString())) {
					flag = false;
					etEmail.setError("Invalid Email Id");
				} else if (etPassword.getText().toString().length() == 0) {
					flag = false;
					etPassword.setError("Password can not be empty.");
				} else if (etFirstName.getText().toString().length() == 0) {
					flag = false;
					etFirstName.setError("First name can not be empty.");
				} else if (etLastName.getText().toString().length() == 0) {
					flag = false;
					etLastName.setError("Last name can not be empty.");
				} else if (etUserName.getText().toString().length() == 0) {
					flag = false;
					etUserName.setError("User name can not be empty");
				}

				if (flag) {
					locationSharingDisclaimerDialog = new Dialog(context,
							android.R.style.Theme_Light_NoTitleBar);
					locationSharingDisclaimerDialog
							.setContentView(R.layout.location_sharing_disclaimer_layout);
					btnAcceptAndLogin = (Button) locationSharingDisclaimerDialog
							.findViewById(R.id.btnAcceptAndLogin);
					btnBack = (Button) locationSharingDisclaimerDialog
							.findViewById(R.id.btnBack);

					btnBack.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							locationSharingDisclaimerDialog.dismiss();
						}
					});

					btnAcceptAndLogin.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							sendRequest();
							locationSharingDisclaimerDialog.dismiss();
						}

						private void sendRequest() {

							if (Utility
									.isConnectionAvailble(getApplicationContext())) {

								requestRunnable = new Runnable() {
									@Override
									public void run() {

										sendRegistrationRequest();

									}
								};
								Thread thread = new Thread(null,
										requestRunnable, "MagentoBackground");
								thread.start();
								m_ProgressDialog = ProgressDialog.show(context,
										"Registration",
										"Sending request. Please wait...",
										true, true);

							} else {
								Toast.makeText(context,
										"Internet Connection Unavailable",
										Toast.LENGTH_SHORT).show();
							}

						}
					});

					locationSharingDisclaimerDialog.show();
				}

			}
		});
	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {

			// have to do something here

			handleResponse(responseStatus, responseString);

			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}
		}
	};

	private void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
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

	private void sendRegistrationRequest() {

		String email = etEmail.getText().toString().trim();
		String password = etPassword.getText().toString();

		String avatarString = "";
		if (avatar != null) {

			ByteArrayOutputStream full_stream = new ByteArrayOutputStream();
			avatar.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

			byte[] full_bytes = full_stream.toByteArray();
			avatarString = Base64.encodeToString(full_bytes, Base64.DEFAULT);

		}

		RestClient client = new RestClient(Constant.smRegistrationUrl);
		Log.d("userName", etUserName.getText().toString());

		client.AddParam("email", email);
		client.AddParam("password", password);

		client.AddParam("firstName", etFirstName.getText().toString());

		client.AddParam("lastName", etLastName.getText().toString());
		client.AddParam("userName", etUserName.getText().toString());
		client.AddParam("avatar", avatarString);

		client.AddParam("street", etStreetAddress.getText().toString());
		client.AddParam("city", etCity.getText().toString());
		client.AddParam("postCode", etZipCode.getText().toString());

		if (spCountry.getSelectedItemPosition() > 0) {
			client.AddParam("country", spCountry.getSelectedItem().toString());
		}

		if (spGender.getSelectedItemPosition() > 0) {
			client.AddParam("gender", spGender.getSelectedItem().toString());
		}

		client.AddParam("dateOfBirth", dob);
		client.AddParam("bio", etBio.getText().toString());
		client.AddParam("interests", etInterests.getText().toString());

		client.AddParam("workStatus", etService.getText().toString());

		if (spRelationshipStatus.getSelectedItemPosition() > 0) {
			client.AddParam("relationshipStatus", spRelationshipStatus
					.getSelectedItem().toString());
		}

		Log.e("Reg request", "Ready to send request");

		try {
			client.Execute(RestClient.RequestMethod.POST);
		} catch (Exception e) {
			Log.e("Reg request", e.getMessage());
			e.printStackTrace();
		}

		responseString = client.getResponse();
		responseStatus = client.getResponseCode();

		Log.e("Reg request", responseString);

		runOnUiThread(returnRes);

	}

	private void registrationSuccess(String response) {
		// Have to parse response

		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response,
				false);

		if (myInfo != null) {
			StaticValues.myInfo = myInfo;

			// save the authToken, id to the storage
			Utility.storeSession(StaticValues.myInfo.getId(),
					StaticValues.myInfo.getAuthToken(), response, context);

			finish();
			Intent myIntent = new Intent(context, HomeActivity.class);
			startActivity(myIntent);
		} else {
			Log.e("Facebook Login Error", "Error during parsing response");
		}

	}

	private boolean onOptionItemSelected(int requestCode) {
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

	private void initialize() {

		context = getApplicationContext();

		btnBack = (Button) findViewById(R.id.btnBack);
		etEmail = (EditText) findViewById(R.id.etEmail);
		etPassword = (EditText) findViewById(R.id.etPassword);
		ivProfilePicture = (ImageView) findViewById(R.id.ivProfilePicture);
		etFirstName = (EditText) findViewById(R.id.etFirstName);
		etLastName = (EditText) findViewById(R.id.etLastName);
		etUserName = (EditText) findViewById(R.id.etUserName);
		etCity = (EditText) findViewById(R.id.etCity);
		etZipCode = (EditText) findViewById(R.id.etZipCode);
		btnSelectDate = (Button) findViewById(R.id.btnSelectDate);
		tvShowSelectedDate = (TextView) findViewById(R.id.tvShowSelectedDate);
		etBio = (EditText) findViewById(R.id.etBiography);
		etInterests = (EditText) findViewById(R.id.etInterests);
		etStreetAddress = (EditText) findViewById(R.id.etStreetAddress);
		etService = (EditText) findViewById(R.id.etService);
		spRelationshipStatus = (Spinner) findViewById(R.id.spRelationshipStatus);
		spGender = (Spinner) findViewById(R.id.spGender);
		spCountry = (Spinner) findViewById(R.id.spCountry);
		btnSubmit = (Button) findViewById(R.id.btnSubmit);
		toggleOptionalInfoLayout = (LinearLayout) findViewById(R.id.toggleOptionalInfoLayout);
		optionalInfoLayout = (LinearLayout) findViewById(R.id.optionalInfoLayout);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {

				if (avatar != null) {
				}
				avatar = Utility.resizeBitmap(
						(Bitmap) data.getExtras().get("data"),
						Constant.thumbWidth, 0, true);
				ivProfilePicture.setImageBitmap(avatar);
			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == Constant.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {

				Uri selectedImage = data.getData();
				try {
					avatar = Utility.resizeBitmap(Utility.decodeUri(
							selectedImage, getContentResolver()),
							Constant.thumbWidth, 0, true);

					ivProfilePicture.setImageBitmap(avatar);

				} catch (FileNotFoundException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (OutOfMemoryError e) {
					Toast.makeText(context,
							getString(R.string.errorMessageGallery),
							Toast.LENGTH_SHORT).show();
					Log.e("Gallery image", "OutOfMemoryError");
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			onClose();
		}
		return false;

	}

	private void onClose() {
		finish();
		Intent myIntent = new Intent(context, LoginActivity.class);
		startActivity(myIntent);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (avatar != null) {
			avatar.recycle();
		}
	}

}
