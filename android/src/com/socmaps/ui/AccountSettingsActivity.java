package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Calendar;
import java.util.HashMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.AccountSettingsEntity;
import com.socmaps.entity.ProfileInfo;
import com.socmaps.entity.Response;
import com.socmaps.util.AppStaticStorages;
import com.socmaps.util.Constant;
import com.socmaps.util.Data;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.RestClient;
import com.socmaps.util.Utility;
import com.socmaps.widget.ExpandablePanel;

public class AccountSettingsActivity extends Activity implements
		OnClickListener {

	private Context context;

	EditText etEmail, etFirstName, etLastName, etUserName, etCity, etZipCode,
			etCountry, etService, etStreetAddress, etBio, etInterest,
			etOldPass, etNewPass, etNewPassRetype;
	ImageView ivProfilePicture;
	Button btnUpdatePersonalInfo, btnSelectDate, btnChangePassword,
			btnClearHistoryYes, btnClearHistoryNo, btnDeleteAccountYes,
			btnDeleteAccountNo;
	Spinner spRelationshipStatus, spGender;
	TextView tvDateOfBirth;
	DatePicker dpDateOfBirth;

	Uri imageUri;
	String tempURLString;

	int requestCode;
	String responseString;

	ExpandablePanel erasePanel, deleteAcountPanel, changePassPanel,
			personalInfoPanel;
	String dob = "";
	Bitmap avatar;
	Calendar now = Calendar.getInstance();

	int selectedYear,selectedMonth,selectedDay;
	
	
	
	private static final int GALLERY_REQUEST = 0;
	private static final int IMAGE_CAPTURE = 1;

	int responseStatus = 0;

	private ProgressDialog m_ProgressDialog = null;
	ProfileInfo pInfo;

	Button btnBack, btnNotification;

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
		
		
			

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		if(AppStaticStorages.accountSettingsEntity==null)
			startDialogAndBgThread();
		else
			setFieldValue(AppStaticStorages.accountSettingsEntity);
	}

	private void setViewOnClickListener() {
		// TODO Auto-generated method stub
		ivProfilePicture.setOnClickListener(this);
		btnSelectDate.setOnClickListener(this);

		btnBack.setOnClickListener(this);
		btnChangePassword.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		btnClearHistoryYes.setOnClickListener(this);
		btnDeleteAccountYes.setOnClickListener(this);
		btnUpdatePersonalInfo.setOnClickListener(this);
	}

	private void setExpandListener() {
		// TODO Auto-generated method stub
		erasePanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			public void onCollapse(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.arrowImageUpDownErase);
				button.setImageResource(R.drawable.icon_arrow_down);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container.findViewById(R.id.toptext);
				text.setTypeface(null, Typeface.NORMAL);
			}

			public void onExpand(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.arrowImageUpDownErase);
				button.setImageResource(R.drawable.icon_arrow_up);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container.findViewById(R.id.toptext);
				text.setTypeface(null, Typeface.BOLD);
			}
		});

		deleteAcountPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.arrowImageUpDownDelete);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.top_text_delete_account);
						text.setTypeface(null, Typeface.NORMAL);
					}

					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.arrowImageUpDownDelete);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.top_text_delete_account);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		changePassPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.arrowImageUpDownChangePass);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.top_text_change_pass);
						text.setTypeface(null, Typeface.NORMAL);
					}

					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.arrowImageUpDownChangePass);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.top_text_change_pass);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		personalInfoPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.arrowImageUpDownPersonal);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.top_text_personal_info);
						text.setTypeface(null, Typeface.NORMAL);
					}

					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.arrowImageUpDownPersonal);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.top_text_personal_info);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

	}

	private void initialize() {

		context = AccountSettingsActivity.this;

		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);

		erasePanel = (ExpandablePanel) findViewById(R.id.eraseContainer);
		deleteAcountPanel = (ExpandablePanel) findViewById(R.id.delete_account_container);
		changePassPanel = (ExpandablePanel) findViewById(R.id.change_password_container);
		personalInfoPanel = (ExpandablePanel) findViewById(R.id.personal_info_container);
		btnSelectDate = (Button) findViewById(R.id.btnSelectDate);

		etEmail = (EditText) findViewById(R.id.etEmail);

		etFirstName = (EditText) findViewById(R.id.etFirstName);
		etLastName = (EditText) findViewById(R.id.etLastName);
		etUserName = (EditText) findViewById(R.id.etUserName);
		etCity = (EditText) findViewById(R.id.etCity);
		etZipCode = (EditText) findViewById(R.id.etZipCode);
		etCountry = (EditText) findViewById(R.id.etCountry);
		etInterest = (EditText) findViewById(R.id.etInterests);
		tvDateOfBirth = (TextView) findViewById(R.id.tvShowSelectedDate);
		etBio = (EditText) findViewById(R.id.etBiography);
		etStreetAddress = (EditText) findViewById(R.id.etStreetAddress);
		etService = (EditText) findViewById(R.id.etService);
		spRelationshipStatus = (Spinner) findViewById(R.id.spRelationshipStatus);
		spGender = (Spinner) findViewById(R.id.spGender);

		ivProfilePicture = (ImageView) findViewById(R.id.ivProfilePicture);

		btnSelectDate = (Button) findViewById(R.id.btnSelectDate);

		btnUpdatePersonalInfo = (Button) findViewById(R.id.btnSubmit);

		btnChangePassword = (Button) findViewById(R.id.pass_save_btn);

		btnClearHistoryYes = (Button) findViewById(R.id.erase_yes_btn);
		btnClearHistoryNo = (Button) findViewById(R.id.erase_no_btn);
		btnDeleteAccountYes = (Button) findViewById(R.id.delete_account_yes_btn);
		btnDeleteAccountNo = (Button) findViewById(R.id.delete_account_no_btn);

		etOldPass = (EditText) findViewById(R.id.old_pass_edit_text);
		etNewPass = (EditText) findViewById(R.id.new_pass_edit_text);
		etNewPassRetype = (EditText) findViewById(R.id.retype_new_pass_edit_text);

	}

	private void setFieldValue(AccountSettingsEntity accountSettingsEntity) {
		if (null != accountSettingsEntity) {
			// Log.e("profileInfo", profileInfo.getUserName());
			if(accountSettingsEntity.getDateOfBirth()!=null)
			{
				String date=accountSettingsEntity.getDateOfBirth().split("\\s+")[0];
				setDateValues(date);
				tvDateOfBirth.setText(date);
			}
			else
			{
				selectedYear=now.get(Calendar.YEAR); 
				selectedMonth=now.get(Calendar.MONTH);
				selectedDay=now.get(Calendar.DATE);
			}
			
			if(accountSettingsEntity.getEmail()!=null)
				etEmail.setText(accountSettingsEntity.getEmail());
			if(accountSettingsEntity.getFirstName()!=null)
				etFirstName.setText(accountSettingsEntity.getFirstName());
			if(accountSettingsEntity.getLastName()!=null)
				etLastName.setText(accountSettingsEntity.getLastName());
			if(accountSettingsEntity.getUserName()!=null)
				etUserName.setText(accountSettingsEntity.getUserName());
			if(accountSettingsEntity.getCity()!=null)
				etCity.setText(accountSettingsEntity.getCity());
			if(accountSettingsEntity.getPostCode()!=null)
				etZipCode.setText(accountSettingsEntity.getPostCode());
			if(accountSettingsEntity.getCountry()!=null)
				etCountry.setText(accountSettingsEntity.getCountry());
			
			if(accountSettingsEntity.getBio()!=null)
				etBio.setText(accountSettingsEntity.getBio());
			if(accountSettingsEntity.getStreetAddress()!=null)
				etStreetAddress.setText(accountSettingsEntity.getStreetAddress());
			if(accountSettingsEntity.getWorkStatus()!=null)
				etService.setText(accountSettingsEntity.getWorkStatus());
			if(accountSettingsEntity.getInterests()!=null)
				etInterest.setText(accountSettingsEntity.getInterests());

			// spDistanceUnit.setSelection(profileInfo.getUnit());
			
			if (accountSettingsEntity.getGender().equalsIgnoreCase("male")) {
				spGender.setSelection(1);
			} else if (accountSettingsEntity.getGender().equalsIgnoreCase(
					"female")) {
				spGender.setSelection(2);
			}

			if (accountSettingsEntity.getRelationshipStatus().equalsIgnoreCase("single")) {
				spRelationshipStatus.setSelection(1);
			} else if (accountSettingsEntity.getRelationshipStatus().equalsIgnoreCase(
					"married")) {
				spRelationshipStatus.setSelection(2);
			} else if (accountSettingsEntity.getRelationshipStatus().equalsIgnoreCase(
					"complicated")) {
				spRelationshipStatus.setSelection(3);
			}

			if(accountSettingsEntity.getAvatar()!=null){
			ivProfilePicture.setTag(accountSettingsEntity.getAvatar());

			new DownloadImagesTask().execute(ivProfilePicture);
			}

			
			
		}

		/*
		 * if(pInfo.getRegMedia().equals("fb")) {
		 * ivRegistationMedium.setImageResource(R.drawable.facebookicon); } else
		 * { ivRegistationMedium.setImageResource(R.drawable.ic_launcher); }
		 */
	}

	
	private void setDateValues(String date) {
		// TODO Auto-generated method stub
		String[] splits=date.split("-");
		selectedYear=Integer.parseInt(splits[0]);
		selectedMonth=Integer.parseInt(splits[1]);
		selectedDay=Integer.parseInt(splits[2]);
	}


	private Runnable returnResGetAccountSettings=new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			
			m_ProgressDialog.dismiss();
			handleAccountSettingsResponse(responseStatus, responseString);
			
			/*AccountSettingsEntity accountSettingsEntity=parseServerResponse();
			AppStaticStorages.accountSettingsEntity=accountSettingsEntity;*/
			
			
		}

		
	};
	
	public void handleAccountSettingsResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			AccountSettingsEntity accountSettingsEntity=ServerResponseParser.parseAccountSettings(responseString,1);
			setFieldValue(accountSettingsEntity);
			AppStaticStorages.accountSettingsEntity=accountSettingsEntity;
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
	
	
	
	
	private Runnable getAccountSettingsInfo=new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient getAccountSettingsClient=new RestClient(Constant.smAccountSettingsUrl);
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
		
		
		

		/*pInfo = new ProfileInfo();

		pInfo.setSmID(1);
		pInfo.setFirstName("John");
		pInfo.setLastName("Doe");
		pInfo.setUserName("JDoe");
		pInfo.setEmail("hasan.mahadi@genweb2.com");
		pInfo.setDateOfBirth("2012-08-09");
		pInfo.setBio("My Bio");
		pInfo.setProfilePic("http://clubpeople.com/Images/features/person128.jpg");
		pInfo.setGender("male");
		pInfo.setInterest("My Interest");
		pInfo.setRegMedia("SM");
		pInfo.setService("My service");
		pInfo.setStreetAddress("My Address");
		pInfo.setPostCode("1207");
		pInfo.setCity("My City");
		pInfo.setCountry("My country");
		pInfo.setRelationshipStatus("single");
		pInfo.setUnit(1);*/

		//setFieldValue(pInfo);

		// runOnUiThread(returnRes);

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

	public void selectDate() {
		DatePickerDialog datePickerDialog = new DatePickerDialog(
				AccountSettingsActivity.this, new OnDateSetListener() {
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
						dob = sb.toString();
						setDateValues(dob);
						Log.d("dob", dob);
						tvDateOfBirth.setText(dob);
					}

				}, selectedYear, selectedMonth-1,
				selectedDay);
		datePickerDialog.show();
	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
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
			// Log.d("Login", status+":"+response);
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
		AppStaticStorages.accountSettingsEntity=ServerResponseParser.parseAccountSettings(responseString,2);
	}


	private Runnable updatePersonalInfo = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendDataToServer();
		}

		private void sendDataToServer() {
			// TODO Auto-generated method stub
			String avatarString = "";

			RestClient client = new RestClient(Constant.smAccountSettingsUrl);

			// client.AddHeader("GData-Version", "2");
			
			//String email=Utility.getEmail(context);
			
			client.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			client.AddParam("email", etEmail.getText().toString().trim());

			client.AddParam("gender", spGender.getSelectedItem().toString());
			client.AddParam("firstName", etFirstName.getText().toString()
					.trim());
			client.AddParam("lastName", etLastName.getText().toString().trim());
			client.AddParam("username", etUserName.getText().toString().trim());

			if (avatar != null) {

				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				Bitmap resizedAvatar = Utility.resizeBitmap(avatar, 0,
						Constant.thumbHeight);

				resizedAvatar.compress(Bitmap.CompressFormat.PNG, 60,
						full_stream);
				byte[] full_bytes = full_stream.toByteArray();
				avatarString = Base64
						.encodeToString(full_bytes, Base64.DEFAULT);

				client.AddParam("avatar", avatarString);
			}

			client.AddParam("street", etStreetAddress.getText().toString());
			client.AddParam("city", etCity.getText().toString());
			client.AddParam("postCode", etZipCode.getText().toString());
			client.AddParam("country", etCountry.getText().toString());

			client.AddParam("dateOfBirth", tvDateOfBirth.getText().toString()
					.trim());
			client.AddParam("bio", etBio.getText().toString());
			client.AddParam("interests", etInterest.getText().toString());

			client.AddParam("workStatus", etService.getText().toString());
			client.AddParam("relationshipStatus", spRelationshipStatus
					.getSelectedItem().toString());

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
		} else if (etUserName.getText().toString().trim().equals("")) {
			flag = false;
			etUserName.setError("User Name can not be empty.");
		}

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
			public void onClick(DialogInterface dialog, int item) {
				/*
				 * Toast.makeText(getApplicationContext(), items[item],
				 * Toast.LENGTH_SHORT).show();
				 */
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

	public void promptClearHistory() {
		AlertDialog.Builder builder = new AlertDialog.Builder(
				AccountSettingsActivity.this);

		builder.setTitle("Clear History");
		builder.setMessage("This action will remove all your data of Social Maps. Are you sure?");
		builder.setCancelable(true)
				.setPositiveButton("Yes",
						new DialogInterface.OnClickListener() {
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
		}

	}

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

	
	private Runnable updatePassWordThread=new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendPasswordChangeRequest();
		}

	};
	private void sendPasswordChangeRequest() {
		// TODO Auto-generated method stub
		RestClient client = new RestClient(Constant.changePasswordUrl);
		
		client.AddHeader(Constant.authTokenParam,
				Utility.getAuthToken(context));
		
		
	
		client.AddParam("oldPassword", etOldPass.getText().toString().trim());
		client.AddParam("password", etNewPass.getText().toString().trim());
		try {
			client.Execute(RestClient.RequestMethod.PUT);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();

		responseStatus = client.getResponseCode();

		runOnUiThread(returnResPasswordChange);
		
	}
	
	public class DownloadImagesTask extends AsyncTask<ImageView, Void, Bitmap> {

		ImageView imageView = null;

		@Override
		protected Bitmap doInBackground(ImageView... imageViews) {
			this.imageView = imageViews[0];
			return download_Image((String) imageView.getTag());
		}

		@Override
		protected void onPostExecute(Bitmap result) {
			imageView.setImageBitmap(result);
		}

		private Bitmap download_Image(String url) {

			return Utility.loadBitmapFromURL(url);
		}

	}

}
