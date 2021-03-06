package com.socmaps.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.LocationSharing;
import com.socmaps.entity.LsValues;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.Place;
import com.socmaps.entity.Platform;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.LocationPicker;
import com.socmaps.widget.LocationPreferenceItemView;
import com.socmaps.widget.PeoplePicker;
import com.socmaps.widget.PeoplePickerListener;


/**
 * LocationSharingSettingsActivity class for generating location sharing setting view and some user interaction.
 *
 */
public class LocationSharingSettingsActivity extends Activity implements
		OnClickListener {

	private Context context;

	int responseStatus = 0;
	String responseString = "";

	private ProgressDialog m_ProgressDialog = null;

	Button btnBack, btnNotification;

	RadioGroup rgLocationShare;
	RadioButton rbLocationShareOff, rbLocationShareOn;
	boolean isLocationShared = false;

	RelativeLayout rlLocationShareTitle;
	LinearLayout llLocationShareContents;

	LinearLayout llCustomSubgroupTitlePanel;
	LinearLayout llCustomSubgroupContents;

	LinearLayout llCircleTitlePanel;
	LinearLayout llCirclePanel, llCircleList;

	LinearLayout llPlatformTitlePanel;
	LinearLayout llPlatformPanel, llPlatformList;

	LinearLayout llStrangerContents;

	LinearLayout llPlaceTitlePanel;
	LinearLayout llPlacePanel, llPlaceList;

	List<Platform> platformList;
	List<LinearLayout> platformItemViewList;
	List<LinearLayout> circleItemViewList;
	LinearLayout customSubgroupItem;
	LinearLayout strangerItem;
	List<LinearLayout> placeItemViewList;

	Button btnNewLocation;

	String customGroupPickerName = "customGroupPicker";
	List<String> customSelectedFriendList;
	List<String> customSelectedCircleList;
	List<String> customSelectedCircleFriendList;
	List<String> customSelectedFriendListAll;

	Button btnSave;

	private String locationResponse;
	private int locationStatus;

	private LocationSharing locationSharing;

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
		setContentView(R.layout.location_sharing_preferences_layout);

		initialize();
		getLocationSharingDataFromServer();

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub

		Utility.updateNotificationBubbleCounter(btnNotification);

		super.onResume();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

	}

	private void initialize() {

		context = LocationSharingSettingsActivity.this;

		locationSharing = new LocationSharing();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		rgLocationShare = (RadioGroup) findViewById(R.id.rgLocationShare);
		rgLocationShare.setOnCheckedChangeListener(locationShareRgListener);

		rbLocationShareOff = (RadioButton) rgLocationShare
				.findViewById(R.id.rbLocationShareOff);
		rbLocationShareOn = (RadioButton) rgLocationShare
				.findViewById(R.id.rbLocationShareOn);

		rlLocationShareTitle = (RelativeLayout) findViewById(R.id.rlLocationShareTitle);
		llLocationShareContents = (LinearLayout) findViewById(R.id.llLocationShareContents);

		llCustomSubgroupTitlePanel = (LinearLayout) findViewById(R.id.llCustomSubgroupTitlePanel);
		llCustomSubgroupTitlePanel.setOnClickListener(this);
		llCustomSubgroupContents = (LinearLayout) findViewById(R.id.llCustomSubgroupContents);

		llCircleTitlePanel = (LinearLayout) findViewById(R.id.llCircleTitlePanel);
		llCircleTitlePanel.setOnClickListener(this);
		llCirclePanel = (LinearLayout) findViewById(R.id.llCirclePanel);
		llCircleList = (LinearLayout) findViewById(R.id.llCircleList);

		llPlatformTitlePanel = (LinearLayout) findViewById(R.id.llPlatformTitlePanel);
		llPlatformTitlePanel.setOnClickListener(this);
		llPlatformTitlePanel.setVisibility(View.GONE);

		llPlatformPanel = (LinearLayout) findViewById(R.id.llPlatformPanel);
		llPlatformList = (LinearLayout) findViewById(R.id.llPlatformList);

		circleItemViewList = new ArrayList<LinearLayout>();
		platformList = new ArrayList<Platform>();
		platformItemViewList = new ArrayList<LinearLayout>();
		placeItemViewList = new ArrayList<LinearLayout>();

		customSelectedFriendList = new ArrayList<String>();
		customSelectedCircleList = new ArrayList<String>();
		customSelectedCircleFriendList = new ArrayList<String>();
		customSelectedFriendListAll = new ArrayList<String>();

		llStrangerContents = (LinearLayout) findViewById(R.id.llStrangerContents);

		llPlaceTitlePanel = (LinearLayout) findViewById(R.id.llPlaceTitlePanel);
		llPlaceTitlePanel.setOnClickListener(this);
		llPlacePanel = (LinearLayout) findViewById(R.id.llPlacePanel);
		llPlaceList = (LinearLayout) findViewById(R.id.llPlaceList);

		btnNewLocation = (Button) findViewById(R.id.btnNewLocation);
		btnNewLocation.setOnClickListener(this);

		btnSave = (Button) findViewById(R.id.btnSave);
		btnSave.setOnClickListener(this);

	}

	private void generateDummyPlatformList() {

		String[] platforms = { "Facebook", "Twitter", "Foursqure" };
		String[] platformIds = { "fb", "twitter", "fs" };
		for (int i = 0; i < platforms.length; i++) {
			Platform platform = new Platform();
			platform.setId(platformIds[i]);
			platform.setName(platforms[i]);

			platformList.add(platform);
		}
	}

	private void generateView() {
		generateGeoFencesView();
		setStatus();
	}

	private void setStatus() {

		if (locationSharing.getStatus() != null) {
			if (locationSharing.getStatus().equalsIgnoreCase("on")) {

				rbLocationShareOn.setChecked(true);
				displayDetailsUI(true);

			} else {

				rbLocationShareOn.setChecked(false);
				displayDetailsUI(false);
			}

		}

	}

	private void displayDetailsUI(boolean isDisplay) {

		if (isDisplay) {
			isLocationShared = true;
			llLocationShareContents.setVisibility(View.VISIBLE);

			TextView tvTitleTexTop = (TextView) rlLocationShareTitle
					.findViewById(R.id.tvTitleTextTop);
			tvTitleTexTop.setTypeface(null, Typeface.BOLD);
		} else {
			isLocationShared = false;
			llLocationShareContents.setVisibility(View.GONE);

			TextView tvTitleTexTop = (TextView) rlLocationShareTitle
					.findViewById(R.id.tvTitleTextTop);
			tvTitleTexTop.setTypeface(null, Typeface.NORMAL);
		}

	}

	private void generateGeoFencesView() {

		if (locationSharing.getGeo_fences() != null) {

			for (LsValues values : locationSharing.getGeo_fences()) {

				Place place = new Place();

				place.setName(values.getName());
				place.setLatitude(values.getLatitude());
				place.setLongitude(values.getLongitude());

				int radius = values.getRadius();

				addNewLocation(place, radius);

			}

		}
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
		} else if (v == llCustomSubgroupTitlePanel) {
			showPeoplePicker(customGroupPickerName);
		} else if (v == llCircleTitlePanel) {
			togglePanel(llCircleTitlePanel, llCirclePanel);
		}

		else if (v == llPlatformTitlePanel) {

			togglePanel(llPlatformTitlePanel, llPlatformPanel);

		} else if (v == llPlaceTitlePanel) {

			togglePanel(llPlaceTitlePanel, llPlacePanel);
		}

		else if (v == btnNewLocation) {
			getLocationFromMap();
		} else if (v == btnSave) {
			saveLocationSharingDataToServer();
		}

	}

	private void togglePanel(LinearLayout titlePanel, LinearLayout contentPanel) {
		if (contentPanel.getVisibility() == View.VISIBLE) {
			contentPanel.setVisibility(View.GONE);

			TextView tvTitleTexTop = (TextView) titlePanel
					.findViewById(R.id.tvTitleTextTop);
			tvTitleTexTop.setTypeface(null, Typeface.NORMAL);

			ImageView ivArrowUpDown = (ImageView) titlePanel
					.findViewById(R.id.ivArrowUpDown);
			ivArrowUpDown.setImageResource(R.drawable.icon_arrow_down);

			View headerSeperator = titlePanel
					.findViewById(R.id.headerSeperator);
			headerSeperator.setVisibility(View.VISIBLE);

		} else {
			contentPanel.setVisibility(View.VISIBLE);

			TextView tvTitleTexTop = (TextView) titlePanel
					.findViewById(R.id.tvTitleTextTop);
			tvTitleTexTop.setTypeface(null, Typeface.BOLD);

			ImageView ivArrowUpDown = (ImageView) titlePanel
					.findViewById(R.id.ivArrowUpDown);
			ivArrowUpDown.setImageResource(R.drawable.icon_arrow_up);

			View headerSeperator = titlePanel
					.findViewById(R.id.headerSeperator);
			headerSeperator.setVisibility(View.GONE);
		}
	}

	RadioGroup.OnCheckedChangeListener locationShareRgListener = new RadioGroup.OnCheckedChangeListener() {

		@Override
		public void onCheckedChanged(RadioGroup group, int checkedId) {

			if (checkedId == R.id.rbLocationShareOff) {

				displayDetailsUI(false);

			} else if (checkedId == R.id.rbLocationShareOn) {

				displayDetailsUI(true);
			}
		}

	};

	private void getLocationFromMap() {
		double currentLat = 0;
		double currentLng = 0;

		if (StaticValues.myPoint != null) {
			currentLat = StaticValues.myPoint.latitude;
			currentLng = StaticValues.myPoint.longitude;

		}

		Intent intent = new Intent(context, LocationPicker.class);
		intent.putExtra("LAT", currentLat);
		intent.putExtra("LNG", currentLng);
		startActivityForResult(intent, Constant.REQUEST_CODE_MAP_PICKER);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_MAP_PICKER
				&& resultCode == RESULT_OK) {
			String name = data.getStringExtra("NAME");
			String address = data.getStringExtra("ADDRESS");
			double lat = data.getDoubleExtra("LAT", 0.0);
			double lng = data.getDoubleExtra("LNG", 0.0);

			// add new place
			Place place = new Place();
			place.setName(name);
			place.setVicinity(address);
			place.setLatitude(lat);
			place.setLongitude(lng);

			showInputDialog(place);

		}
	}

	private void addNewLocation(Place place, int radius) {

		// add to list

		String radiusTitle = getString(R.string.locationSharingInvisibleRadiusTitle);

		if (place != null) {
			LinearLayout placeItemView = new LocationPreferenceItemView(
					context, place.getId(), place.getName(), radius,
					radiusTitle, place.getLatitude(), place.getLongitude());
			placeItemViewList.add(placeItemView);
			llPlaceList.addView(placeItemView);
		}
	}

	private void showInputDialog(final Place place) {
		// custom dialog
		final Dialog dialog = new Dialog(context, R.style.CustomDialogTheme);
		dialog.setContentView(R.layout.input_text_dialog_layout);

		final EditText etInputText = (EditText) dialog
				.findViewById(R.id.etInputText);
		TextView tvTitle = (TextView) dialog.findViewById(R.id.tvTitle);

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

				if (!inputText.equalsIgnoreCase("")) {
					place.setName(inputText);
					addNewLocation(place, 0);

					Utility.hideKeyboard((Activity) context);
					dialog.dismiss();
				}

			}

		});

		String title = "Name";
		String hint = "Enter location name";
		String text = "";

		tvTitle.setText(title);
		etInputText.setHint(hint);
		if (!text.equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		dialog.show();
	}

	private void showPeoplePicker(String pickerName) {
		// custom dialog
		Dialog peoplePicker = new PeoplePicker(context,
				new PeoplePickerHandler(), pickerName,
				customSelectedFriendList, customSelectedCircleList);

		peoplePicker.show();
	}

	private class PeoplePickerHandler implements PeoplePickerListener {
		@Override
		public void onSelect(String pickerName,
				List<String> selectedFriendList,
				List<String> selectedCircleList,
				List<String> selectedCircleFriendList,
				List<String> selectedFriendListAll) {

			if (pickerName.equalsIgnoreCase(customGroupPickerName)) {
				customSelectedFriendList = selectedFriendList;
				customSelectedCircleList = selectedCircleList;
				customSelectedCircleFriendList = selectedCircleFriendList;
				customSelectedFriendListAll = selectedFriendListAll;
			}

		}
	}

	private void setFieldValue(MyInfo myInfo) {

		if (null != myInfo) {

		}

	}

	private Runnable returnResGetAccountSettings = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
			handleAccountSettingsResponse(responseStatus, responseString);

		}

	};

	private void handleAccountSettingsResponse(int status, String response) {
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

	/*
	 * Get Location Sharing data from server
	 */
	private void getLocationSharingDataFromServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, locationSharingThread,
					"Start get places from server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable locationSharingThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub

			RestClient restClient = new RestClient(Constant.smServerUrl
					+ "/settings/share/location");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			locationResponse = restClient.getResponse();
			locationStatus = restClient.getResponseCode();

			runOnUiThread(locationResponseFromServer);
		}
	};

	private Runnable locationResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseLocation(locationStatus, locationResponse);

			// dismiss progress dialog if needed
			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	private void handleResponseLocation(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("Got location response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			locationSharing = ServerResponseParser
					.savedLocationSharingParser(response);

			generateDummyPlatformList();
			generateView();

			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();

			generateDummyPlatformList();
			generateView();
			break;

		}

	}

	// ******************* save *********************************************

	/*
	 * Save Location Sharing data to server
	 */
	private void saveLocationSharingDataToServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, saveLocationSharingThread,
					"Start get places from server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable saveLocationSharingThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub

			RestClient restClient = new RestClient(Constant.smServerUrl
					+ "/settings/share/location");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			generateParams(restClient);

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			locationResponse = restClient.getResponse();
			locationStatus = restClient.getResponseCode();

			runOnUiThread(saveLocationSharingResponseFromServer);
		}
	};

	private Runnable saveLocationSharingResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleSaveLocationSharingResponse(locationStatus, locationResponse);

			// dismiss progress dialog if needed
			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	private void handleSaveLocationSharingResponse(int status, String response) {

		Log.w("Save Location Sharing  response from server", status + ":"
				+ response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			Toast.makeText(context,
					"Location sharing data saved successfully.",
					Toast.LENGTH_SHORT).show();

			finish();

			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	protected void generateParams(RestClient restClient) {
		// TODO Auto-generated method stub

		if (isLocationShared) {
			restClient.AddParam("status", "on");
		} else {
			restClient.AddParam("status", "off");
		}

		for (int i = 0; i < placeItemViewList.size(); i++) {
			LocationPreferenceItemView itemView = (LocationPreferenceItemView) placeItemViewList
					.get(i);

			restClient.AddParam("geo_fences[" + i + "][location][lat]",
					itemView.getLatitude() + "");
			restClient.AddParam("geo_fences[" + i + "][location][lng]",
					itemView.getLongitude() + "");
			restClient.AddParam("geo_fences[" + i + "][radius]",
					"" + itemView.getRadius());
			restClient.AddParam("geo_fences[" + i + "][name]",
					itemView.getTitle());
		}
	}

}
