package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.MyInfo;
import com.socmaps.entity.People;
import com.socmaps.images.ImageFetcher;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.NewsFeedPhotoZoomDialogPicker;

/**
 * ProfileActiviy describes the details user's own profile. It also shows, the
 * activities of users through Newsfeed.
 * 
 */

public class ProfileActivity extends FragmentActivity implements OnClickListener {
	Context context;

	Button btnBack, btnNotification;

	ImageView ivProfilePic, ivCoverPic, ivRegMedia;
	ImageView btnEditProfilePic, btnEditCoverPic, btnEditStatus, btnNavigateToMap;
	ImageView photos_icon_image, friends_icon_image, btnEvent, places_icon_image, meetup_icon_image, btnPlan;
	TextView tvName, tvStatusMessage, tvAddress, tvTime, tvDistance, tvAge, tvCity, tvCompany, tvRelationshipStatus;

	LinearLayout age_layout, relationship_layout, living_in_layout, work_at_layout, layEditCoverPic, layEditStatus, layEditProfilePic;

	RelativeLayout relativeLayoutForGeoTag, relativeLayoutForUploadPhoto;
	RelativeLayout relativeLayoutForStatus;

	int responseStatus = 0;
	String responseString = "";

	ImageFetcher imageFetcher;

	private String flag = "";
	private ProgressDialog m_ProgressDialog = null;

	private final static int REQUEST_CODE_CAMERA = 700;
	private final static int REQUEST_CODE_GALLERY = 701;
	boolean isCoverPic = true;

	int requestCode;
	Bitmap avatar, coverPic;
	String dob = "";
	Calendar now = Calendar.getInstance();

	String strRelationshipStatus;
	String status, age, city, workStatus;

	boolean isChanged = false;

	private WebView wViewNewsFeed;
	private ProgressBar progressBar;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.profile_info_layout);

		initialize();
		setDefaultValues();

	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);

		imageFetcher.setExitTasksEarly(false);
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		imageFetcher.setExitTasksEarly(true);
		imageFetcher.flushCache();

	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();

		if (avatar != null) {
			avatar.recycle();
		}
		if (coverPic != null) {
			coverPic.recycle();
		}
		imageFetcher.closeCache();
		System.gc();
	}

	private void initialize() {

		context = ProfileActivity.this;

		imageFetcher = new ImageFetcher(context);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		ivProfilePic = (ImageView) findViewById(R.id.ivProfilePic);
		ivCoverPic = (ImageView) findViewById(R.id.ivCoverPic);
		ivRegMedia = (ImageView) findViewById(R.id.ivRegMedia);

		btnEditProfilePic = (ImageView) findViewById(R.id.btnEditProfilePic);
		btnEditProfilePic.setOnClickListener(this);

		btnEditCoverPic = (ImageView) findViewById(R.id.btnEditCoverPic);
		btnEditCoverPic.setOnClickListener(this);

		btnEditStatus = (ImageView) findViewById(R.id.btnEditStatus);
		btnEditStatus.setOnClickListener(this);

		btnNavigateToMap = (ImageView) findViewById(R.id.btnNavigateToMap);
		btnNavigateToMap.setOnClickListener(this);

		photos_icon_image = (ImageView) findViewById(R.id.photos_icon_image);
		photos_icon_image.setOnClickListener(this);

		friends_icon_image = (ImageView) findViewById(R.id.friends_icon_image);
		friends_icon_image.setOnClickListener(this);

		btnEvent = (ImageView) findViewById(R.id.btnEvent);
		btnEvent.setOnClickListener(this);

		places_icon_image = (ImageView) findViewById(R.id.places_icon_image);
		places_icon_image.setOnClickListener(this);

		meetup_icon_image = (ImageView) findViewById(R.id.meetup_icon_image);
		meetup_icon_image.setOnClickListener(this);

		btnPlan = (ImageView) findViewById(R.id.btnPlan);
		btnPlan.setOnClickListener(this);

		tvName = (TextView) findViewById(R.id.tvName);
		tvStatusMessage = (TextView) findViewById(R.id.tvStatusMessage);
		tvAddress = (TextView) findViewById(R.id.tvAddress);
		tvTime = (TextView) findViewById(R.id.tvTime);
		tvDistance = (TextView) findViewById(R.id.tvDistance);
		tvAge = (TextView) findViewById(R.id.tvAge);

		tvCity = (TextView) findViewById(R.id.tvCity);
		tvCompany = (TextView) findViewById(R.id.tvCompany);

		age_layout = (LinearLayout) findViewById(R.id.age_layout);
		relationship_layout = (LinearLayout) findViewById(R.id.relationship_layout);
		living_in_layout = (LinearLayout) findViewById(R.id.living_in_layout);
		work_at_layout = (LinearLayout) findViewById(R.id.work_at_layout);
		layEditCoverPic = (LinearLayout) findViewById(R.id.layEditCoverPic);
		layEditStatus = (LinearLayout) findViewById(R.id.layEditStatus);
		layEditProfilePic = (LinearLayout) findViewById(R.id.layEditProfilePic);

		relativeLayoutForGeoTag = (RelativeLayout) findViewById(R.id.relativeLayoutForGeoTag);
		relativeLayoutForUploadPhoto = (RelativeLayout) findViewById(R.id.relativeLayoutForUploadPhoto);

		relativeLayoutForStatus = (RelativeLayout) findViewById(R.id.relativeLayoutForStatus);

		age_layout.setOnClickListener(this);
		relationship_layout.setOnClickListener(this);
		living_in_layout.setOnClickListener(this);
		work_at_layout.setOnClickListener(this);
		layEditCoverPic.setOnClickListener(this);
		layEditStatus.setOnClickListener(this);
		layEditProfilePic.setOnClickListener(this);

		relativeLayoutForStatus.setOnClickListener(this);

		relativeLayoutForGeoTag.setOnClickListener(this);
		relativeLayoutForUploadPhoto.setOnClickListener(this);

		tvRelationshipStatus = (TextView) findViewById(R.id.tvRelationshipStatus);

		// newsfeed portion
		progressBar = (ProgressBar) findViewById(R.id.progressBar);
		wViewNewsFeed = (WebView) findViewById(R.id.wViewNewsFeed);
		wViewNewsFeed.setBackgroundColor(Color.parseColor("#00000000"));

		WebSettings webSettings = wViewNewsFeed.getSettings();
		webSettings.setJavaScriptEnabled(true);
		webSettings.setPluginsEnabled(false);
		webSettings.setJavaScriptCanOpenWindowsAutomatically(false);

		webSettings.setSupportMultipleWindows(false);

		webSettings.setSupportZoom(true);
		wViewNewsFeed.setVerticalScrollBarEnabled(true);
		wViewNewsFeed.setHorizontalScrollBarEnabled(false);
		wViewNewsFeed.getSettings().setBuiltInZoomControls(false);

		wViewNewsFeed.loadUrl(Constant.smServerUrl + "/" + StaticValues.myInfo.getId() + "/newsfeed.html?authToken=" + StaticValues.myInfo.getAuthToken());

		wViewNewsFeed.setWebViewClient(new MyWebViewClient());

		wViewNewsFeed.setWebChromeClient(new WebChromeClient() {

			@Override
			public void onProgressChanged(WebView view, int progress) {

				progressBar.setVisibility(View.VISIBLE);

				if (progress == 100)
					progressBar.setVisibility(View.INVISIBLE);
			}

		});
	}

	private void setDefaultValues() {

		if (StaticValues.myInfo != null) {

			status = StaticValues.myInfo.getStatusMsg();
			age = StaticValues.myInfo.getAge() + "";
			city = StaticValues.myInfo.getCity();
			workStatus = StaticValues.myInfo.getWorkStatus();

			if (StaticValues.myInfo.getAvatar() != null) {

				ivProfilePic.setImageResource(R.drawable.thumb);
				imageFetcher.loadImage(StaticValues.myInfo.getAvatar(), ivProfilePic);
			}

			if (StaticValues.myInfo.getCoverPhoto() != null) {
				ivCoverPic.setImageResource(R.drawable.img_blank);
				imageFetcher.loadImage(StaticValues.myInfo.getCoverPhoto(), ivCoverPic);
			} else {
				ivCoverPic.setImageResource(R.drawable.cover_pic_default);
			}

			if (StaticValues.myInfo.getRegMedia() != null) {
				if (StaticValues.myInfo.getRegMedia().equals("fb")) {
					ivRegMedia.setVisibility(View.VISIBLE);
				}
			}

			String name = "";
			if (StaticValues.myInfo.getFirstName() != null) {
				name = StaticValues.myInfo.getFirstName() + " ";
			}
			if (StaticValues.myInfo.getLastName() != null) {
				name += StaticValues.myInfo.getLastName();
			}
			tvName.setText(name);

			if (StaticValues.myInfo.getStatusMsg() != null && !StaticValues.myInfo.getStatusMsg().equals("")) {
				tvStatusMessage.setText(StaticValues.myInfo.getStatusMsg());
			}

			if (StaticValues.myInfo.getStreetAddress() != null) {
				tvAddress.setText(StaticValues.myInfo.getStreetAddress());
			} else {
				tvAddress.setText("");
			}

			if (StaticValues.myInfo.getLastLogInDate() != null) {
				tvTime.setText(Utility.getFormattedDisplayDate(StaticValues.myInfo.getLastLoginTime()));
			}

			Log.w("Date of birth in setDefaultValues", StaticValues.myInfo.getAge() + " got it");

			if (StaticValues.myInfo.getAge() > 0) {

				tvAge.setText(StaticValues.myInfo.getAge() + " years");
			}

			if (StaticValues.myInfo.getRelationshipStatus() != null) {
				tvRelationshipStatus.setText(StaticValues.myInfo.getRelationshipStatus());
			}

			if (StaticValues.myInfo.getCity() != null) {
				tvCity.setText(StaticValues.myInfo.getCity());
			}

			if (StaticValues.myInfo.getWorkStatus() != null) {
				tvCompany.setText(StaticValues.myInfo.getWorkStatus());
			}

		}

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnNavigateToMap) {

		} else if (v == btnBack) {
			if (isChanged == false)
				finish();
			else
				showDialogToUpdateInfo();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(context, NotificationActivity.class);
			startActivity(notificationIntent);

			finish();
		}

		if (v.getId() == R.id.btnEditProfilePic) {
			isCoverPic = false;
			uploadIconFromGalaryOrCamara();
		}

		else if (v == photos_icon_image) {
			showPhotos();
		}

		else if (v == friends_icon_image) {
			showFriends();
		}

		else if (v == btnEvent) {
			Intent i = new Intent(context, EventListActivity.class);
			startActivity(i);
		}

		else if (v == places_icon_image) {
			showPlaces();
		}

		else if (v == meetup_icon_image) {
			showMeetUp();
		}

		else if (v == btnPlan) {
			showPlanList();
		}

		switch (v.getId()) {

		case R.id.age_layout:
			showDatePicker();
			break;

		case R.id.relationship_layout:
			spinnerShowRelationshipOption();
			break;

		case R.id.living_in_layout:
			showTextInputDialog(R.id.living_in_layout, city, getString(R.string.cityLabel));
			break;

		case R.id.work_at_layout:
			showTextInputDialog(R.id.work_at_layout, workStatus, getString(R.string.servicelabel));
			break;

		case R.id.relativeLayoutForStatus:
			showTextInputDialog(R.id.btnEditStatus, status, getString(R.string.status));
			break;

		case R.id.btnEditStatus:
			showTextInputDialog(R.id.btnEditStatus, status, getString(R.string.status));
			break;

		case R.id.layEditStatus:
			showTextInputDialog(R.id.btnEditStatus, status, getString(R.string.status));
			break;

		case R.id.btnEditCoverPic:
			isCoverPic = true;
			uploadIconFromGalaryOrCamara();
			break;

		case R.id.layEditCoverPic:
			isCoverPic = true;
			uploadIconFromGalaryOrCamara();
			break;

		case R.id.layEditProfilePic:
			isCoverPic = false;
			uploadIconFromGalaryOrCamara();
			break;

		case R.id.relativeLayoutForGeoTag:
			geoTagFunction();
			break;

		case R.id.relativeLayoutForUploadPhoto:
			uploadPhoto();
			break;

		default:
			break;
		}

	}

	private void showPlanList() {
		Intent intent = new Intent(getApplicationContext(), PlanListActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		startActivity(intent);
	}

	private void showPhotos() {
		Intent intent = new Intent(getApplicationContext(), PhotoListActivity.class);
		startActivity(intent);
	}

	private void showFriends() {

		Intent friendIntent = new Intent(getApplicationContext(), FriendListActivity.class);
		startActivity(friendIntent);
	}

	private void showPlaces() {
		Intent intentToGoPlace = new Intent(context, PlacesListActivity.class);
		startActivity(intentToGoPlace);
	}

	private void showMeetUp() {
		Intent intentToShowMeetUp = new Intent(context, MeetupRequestNewActivity.class);
		startActivity(intentToShowMeetUp);
	}

	private void spinnerShowRelationshipOption() {
		AlertDialog dialog;

		final String str[] = getResources().getStringArray(R.array.relationshipOptions);

		final String[] relArray = new String[str.length - 1];

		for (int i = 0; i < str.length; i++) {
			if (i > 0) {
				relArray[i - 1] = str[i];
			}
		}

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setItems(relArray, new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int position) {

				tvRelationshipStatus.setText(relArray[position]);
				isChanged = true;
			}

		});
		dialog = builder.create();
		dialog.show();

	}

	private void showDialogToUpdateInfo() {
		// TODO Auto-generated method stub
		final AlertDialog.Builder aBuilder = new AlertDialog.Builder(context);
		aBuilder.setTitle("Save changes");
		aBuilder.setIcon(R.drawable.icon_alert);
		aBuilder.setMessage("Do you want save changes before exit from Profile?");

		aBuilder.setPositiveButton(getString(R.string.yesLabel), new DialogInterface.OnClickListener() {

			@Override
			public void onClick(final DialogInterface dialog, final int which) {

				updateSettings();
				dialog.dismiss();
			}

		});

		aBuilder.setNegativeButton(getString(R.string.noLabel), new DialogInterface.OnClickListener() {

			@Override
			public void onClick(final DialogInterface dialog, final int which) {
				dialog.dismiss();
				ProfileActivity.this.finish();
			}

		});

		aBuilder.show();
	}

	private void showDatePicker() {
		// TODO Auto-generated method stub

		String date = StaticValues.myInfo.getDateOfBirth().split("\\s+")[0];

		Log.w("Date of birth in showDatePicker after spliting \\s", date);

		int selectedYear = 0;
		int selectedMonth = 0;
		int selectedDay = 0;

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

		DatePickerDialog datePickerDialog = new DatePickerDialog(ProfileActivity.this, new OnDateSetListener() {
			@Override
			public void onDateSet(DatePicker arg0, int arg1, int arg2, int arg3) {
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
				sb.append(arg1).append("-").append(month).append("-").append(day);
				dob = sb.toString();

				Log.d("dob", dob);

				age = Utility.calculateAge(sb.toString()) + " years";
				tvAge.setText(age);

				isChanged = true;

			}

		}, selectedYear, selectedMonth - 1, selectedDay);

		datePickerDialog.show();
	}

	private void uploadIconFromGalaryOrCamara() {
		// TODO Auto-generated method stub
		final CharSequence[] items = { "Gallery", "Camera" };
		AlertDialog.Builder builder = new AlertDialog.Builder(ProfileActivity.this);
		builder.setTitle("Select");
		builder.setItems(items, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int item) {
				Toast.makeText(getApplicationContext(), items[item], Toast.LENGTH_SHORT).show();
				if (items[item].equals("Gallery")) {
					requestCode = ProfileActivity.REQUEST_CODE_GALLERY;
				} else {
					requestCode = ProfileActivity.REQUEST_CODE_CAMERA;
				}
				onOptionItemSelected(requestCode);
			}

		});
		AlertDialog alert = builder.create();
		alert.show();
	}

	private boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case ProfileActivity.REQUEST_CODE_GALLERY:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case ProfileActivity.REQUEST_CODE_CAMERA:
			Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(cameraIntent, requestCode);
			break;
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == ProfileActivity.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {
				if (isCoverPic) {

					if (coverPic != null) {
					}

					coverPic = Utility.resizeBitmap((Bitmap) data.getExtras().get("data"), Constant.profileCoverWidth, 0, true);

					ivCoverPic.setImageBitmap(coverPic);

				} else {

					if (avatar != null) {
					}

					avatar = Utility.resizeBitmap((Bitmap) data.getExtras().get("data"), Constant.thumbWidth, 0, true);

					ivProfilePic.setImageBitmap(avatar);

				}
				isChanged = true;
			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == ProfileActivity.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {

				Uri selectedImage = data.getData();
				try {

					if (isCoverPic) {
						coverPic = Utility.resizeBitmap(Utility.decodeUri(selectedImage, getContentResolver()), Constant.profileCoverWidth, 0, true);
						ivCoverPic.setImageBitmap(coverPic);
					} else {
						avatar = Utility.resizeBitmap(Utility.decodeUri(selectedImage, getContentResolver()), Constant.thumbWidth, 0, true);
						ivProfilePic.setImageBitmap(avatar);
					}

					isChanged = true;
				} catch (FileNotFoundException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (OutOfMemoryError e) {
					Toast.makeText(context, getString(R.string.errorMessageGallery), Toast.LENGTH_SHORT).show();
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

	// TODO Auto-generated method stub
	private void showTextInputDialog(final int id, final String text, String hint) {

		Log.w("showTextInputDialog into", "id: " + id + " text:" + text);

		// custom dialog
		final Dialog dialog = new Dialog(context, R.style.CustomDialogTheme);
		dialog.setContentView(R.layout.input_text_dialog_layout);

		dialog.setOnDismissListener(new OnDismissListener() {

			@Override
			public void onDismiss(DialogInterface dialog) {
				// TODO Auto-generated method stub
				Utility.hideKeyboard(ProfileActivity.this);
			}
		});

		final EditText etInputText = (EditText) dialog.findViewById(R.id.etInputText);

		etInputText.setHint(hint);
		if (text != null && !text.trim().equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		Button btnCancel = (Button) dialog.findViewById(R.id.btnCancel);
		// if button is clicked, close the custom dialog
		btnCancel.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				dialog.dismiss();

			}
		});

		Button btnOk = (Button) dialog.findViewById(R.id.btnOk);
		// if button is clicked, close the custom dialog
		btnOk.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				String inputText = etInputText.getText().toString().trim();

				Log.w("showTextInputDialog into", "btnOk: " + inputText);

				if (!inputText.equalsIgnoreCase("")) {

					isChanged = true;

					switch (id) {

					case R.id.living_in_layout:
						city = inputText;
						tvCity.setText(inputText);
						if (inputText.equalsIgnoreCase(StaticValues.myInfo.getCity()))
							isChanged = false;
						break;

					case R.id.work_at_layout:
						workStatus = inputText;
						tvCompany.setText(inputText);
						if (inputText.equalsIgnoreCase(StaticValues.myInfo.getWorkStatus()))
							isChanged = false;
						break;
					case R.id.btnEditStatus:
						status = inputText;
						tvStatusMessage.setText(inputText);
						if (inputText.equalsIgnoreCase(StaticValues.myInfo.getStatusMsg()))
							isChanged = false;
						break;

					default:
						break;
					}
					dialog.dismiss();
				}

			}
		});

		dialog.show();
	}

	private void updateSettings() {
		boolean flag = true;

		if (flag) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				Thread thread = new Thread(null, updatePersonalInfo, "Start update password");
				thread.start();
				m_ProgressDialog = ProgressDialog.show(this, getResources().getString(R.string.please_wait_text), getResources().getString(R.string.updating_data_text), true, true);

			} else {

				DialogsAndToasts.showNoInternetConnectionDialog(context);
			}
		}
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
			String coverPicString = "";

			RestClient client = new RestClient(Constant.smAccountSettingsUrl);

			client.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));

			if (status != null) {
				client.AddParam("status", status);
			}

			Log.w("Date of birth in addParam  >>>>>>>", dob);
			if (dob != null) {
				if (!dob.equals("")) {
					client.AddParam("dateOfBirth", dob);
				}
			}

			if (tvRelationshipStatus != null) {
				client.AddParam("relationshipStatus", tvRelationshipStatus.getText().toString().trim());
			}

			if (city != null) {
				client.AddParam("city", city);
			}

			if (workStatus != null) {
				client.AddParam("workStatus", workStatus);
			}

			if (avatar != null) {

				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				avatar.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				avatarString = Base64.encodeToString(full_bytes, Base64.DEFAULT);

				client.AddParam("avatar", avatarString);
			}

			if (coverPic != null) {

				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();
				coverPic.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				coverPicString = Base64.encodeToString(full_bytes, Base64.DEFAULT);

				Log.w("Cover Pic >>>>>>>>", coverPicString);

				client.AddParam("coverPhoto", coverPicString);
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

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {
			handleResponseSavePersonalInfo(responseStatus, responseString);

			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}

		}
	};

	private void handleResponseSavePersonalInfo(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			Toast.makeText(getApplicationContext(), "Profile changed successfully.", Toast.LENGTH_SHORT).show();

			MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response, false);

			if (myInfo != null) {
				StaticValues.myInfo.setStatusMsg(myInfo.getStatusMsg());
				StaticValues.myInfo.setAvatar(myInfo.getAvatar());
				StaticValues.myInfo.setCoverPhoto(myInfo.getCoverPhoto());
				StaticValues.myInfo.setAge(myInfo.getAge());
				StaticValues.myInfo.setDateOfBirth(myInfo.getDateOfBirth());
				StaticValues.myInfo.setRelationshipStatus(myInfo.getRelationshipStatus());
				StaticValues.myInfo.setCity(myInfo.getCity());
				StaticValues.myInfo.setWorkStatus(myInfo.getWorkStatus());
			}

			ProfileActivity.this.finish();
			if (flag.equals("INFO"))
				break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(), Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG).show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(), Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG).show();

			break;
		default:
			Toast.makeText(getApplicationContext(), "An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void geoTagFunction() {
		Intent intentForGeoTag = new Intent(context, GeoTagActivity.class);
		startActivity(intentForGeoTag);
	}

	private void uploadPhoto() {
		Intent intent = new Intent(context, PhotoUploadNewPhotoActivity.class);
		startActivity(intent);

	}

	private class MyWebViewClient extends WebViewClient {
		@Override
		public void onPageFinished(final WebView view, final String url) {
			Log.d("web status", "onPageFinished");

			wViewNewsFeed.loadUrl("javascript:window.HTMLOUT.showHTML('<head>'+document.getElementsByTagName('html')[0].innerHTML+'</head>');");

		}

		@Override
		public void onPageStarted(final WebView view, final String url, final Bitmap favicon) {
			Log.d("web status", "onPageStarted");

		}

		@Override
		public boolean shouldOverrideUrlLoading(final WebView view, final String url) {

			Log.i("URL URL URL ", url);

			String subURL = url.substring(6);
			if (subURL.startsWith("profile")) {
				String id = subURL.substring(8);
				Log.d("URL", id);
				if (id.equalsIgnoreCase(StaticValues.myInfo.getId())) {

				} else {

					People p = new People();
					p.setId(id);

					Intent intent = new Intent(context, ProfileActivity2.class);

					intent.putExtra("otherUser", p);
					startActivity(intent);

				}
			} else if (subURL.startsWith("image")) {
				String imageURL = subURL.substring(6);
				Log.d("URL", imageURL);

				NewsFeedPhotoZoomDialogPicker photoZoomPicker = new NewsFeedPhotoZoomDialogPicker(context, imageURL, imageFetcher);
				photoZoomPicker.getWindow().setLayout(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
				photoZoomPicker.show();
			} else if (subURL.startsWith("geotag")) {
			} else if (subURL.startsWith("report")) {

				final String[] typeId = subURL.split(":");

				if (typeId.length > 2) {

					AlertDialog.Builder adb = new AlertDialog.Builder(context);
					adb.setTitle("Report");
					// adb.setIcon(R.drawable.icon_alert);
					adb.setMessage("Do you want to report this post?");
					adb.setPositiveButton("Report", new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int id) {
							// server call
							dialog.dismiss();
							reportToServer(typeId[1], typeId[2]);
						

						}
					});
					adb.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int id) {
							dialog.dismiss();
						}
					});
					adb.show();

				}
			}

			return true;
		}

	}

	private void reportToServer(String type, String id) {

		String url = Constant.smServerUrl + "/report";

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("objectType", type));
		params.add(new BasicNameValuePair("objectId", id));

		BackProcess backProcess = new BackProcess(context, params, url, REQUEST_TYPE.REPORT, false, null, null, new BackProcessCallBackListener(), false);

		backProcess.execute(RestClient.RequestMethod.POST);
	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String result, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :", status + ":" + result);
			switch (status) {
			case Constant.STATUS_SUCCESS:

				Toast.makeText(getApplicationContext(), "Report sent successfully.", Toast.LENGTH_SHORT).show();
				break;

			default:
				Toast.makeText(getApplicationContext(), "An unknown error occured. Please try again!!", Toast.LENGTH_SHORT).show();

				break;

			}

		}

	}

}
