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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Circle;
import com.socmaps.entity.MyGeoPoint;
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
	List<Place> placeList;
	List<LinearLayout> placeItemViewList;

	Button btnNewLocation;

	String customGroupPickerName = "customGroupPicker";
	List<String> customSelectedFriendList;
	List<String> customSelectedCircleList;
	List<String> customSelectedCircleFriendList;
	List<String> customSelectedFriendListAll;

	Button btnSave;

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

		generateDummyPlatformList();

		generateView();

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

	}

	private void initialize() {

		context = LocationSharingSettingsActivity.this;

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
		llPlatformPanel = (LinearLayout) findViewById(R.id.llPlatformPanel);
		llPlatformList = (LinearLayout) findViewById(R.id.llPlatformList);

		circleItemViewList = new ArrayList<LinearLayout>();
		platformList = new ArrayList<Platform>();
		platformItemViewList = new ArrayList<LinearLayout>();
		placeList = new ArrayList<Place>();
		placeItemViewList = new ArrayList<LinearLayout>();

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
		for (int i = 0; i < platforms.length; i++) {
			Platform platform = new Platform();
			platform.setId("" + i);
			platform.setName(platforms[i]);

			platformList.add(platform);
		}
	}

	private void generateView() {
		generateCustomSubgroupView();
		generateCircleView();
		generatePlatformView();
		generateStrangerView();
		// generatePlaceView();
	}

	private void generateCustomSubgroupView() {
		customSubgroupItem = new LocationPreferenceItemView(context, null,
				null, 0, 0, false, false, true);
		llCustomSubgroupContents.removeAllViews();
		llCustomSubgroupContents.addView(customSubgroupItem);
	}

	private void generateCircleView() {
		List<Circle> circleList = StaticValues.myInfo.getCircleList();
		llCircleList.removeAllViews();
		for (int i = 0; i < circleList.size(); i++) {
			Circle circle = circleList.get(i);
			if (circle != null) {
				LinearLayout circleItemView = new LocationPreferenceItemView(
						context, circle.getId(), circle.getName(), 0, 0, false);
				circleItemViewList.add(circleItemView);
				llCircleList.addView(circleItemView);
			}
		}
	}

	private void generatePlatformView() {
		llPlatformList.removeAllViews();
		for (int i = 0; i < platformList.size(); i++) {
			Platform platform = platformList.get(i);
			if (platform != null) {
				LinearLayout platformItemView = new LocationPreferenceItemView(
						context, platform.getId(), platform.getName(), 0, 0,
						false);
				llPlatformList.addView(platformItemView);
				platformItemViewList.add(platformItemView);
			}
		}
	}

	private void generateStrangerView() {
		strangerItem = new LocationPreferenceItemView(context, "1",
				"Customize sharing for strangers", 0, 0, false);
		llStrangerContents.removeAllViews();
		llStrangerContents.addView(strangerItem);
	}

	/*
	 * private void generatePlaceView() { //circleList =
	 * StaticValues.searchResult.getPlaces(); //llPlaceList.removeAllViews();
	 * 
	 * String timeLimitTitle =
	 * getString(R.string.locationSharingInvisibleRadiusTitle);
	 * 
	 * for (int i = 0; i < circleList.size(); i++) { Place place =
	 * circleList.get(i); if (place != null) { LinearLayout placeItemView = new
	 * LocationPreferenceItemView( context, place.getId(), place.getName(), 0,
	 * timeLimitTitle); placeItemViewList.add(placeItemView);
	 * llPlaceList.addView(placeItemView); } } }
	 */

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
			// toggleCirclePanel();
			togglePanel(llCircleTitlePanel, llCirclePanel);
		}

		else if (v == llPlatformTitlePanel) {
			// togglePlatformPanel();
			togglePanel(llPlatformTitlePanel, llPlatformPanel);
		} else if (v == llPlaceTitlePanel) {
			// togglePlacePanel();
			togglePanel(llPlaceTitlePanel, llPlacePanel);
		}

		else if (v == btnNewLocation) {
			getLocationFromMap();
		} else if (v == btnSave) {
			Toast.makeText(context, "Have to save the data.",
					Toast.LENGTH_SHORT).show();
		}

	}

	public void togglePanel(LinearLayout titlePanel, LinearLayout contentPanel) {
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
				isLocationShared = false;
				llLocationShareContents.setVisibility(View.GONE);

				TextView tvTitleTexTop = (TextView) rlLocationShareTitle
						.findViewById(R.id.tvTitleTextTop);
				tvTitleTexTop.setTypeface(null, Typeface.NORMAL);

			} else if (checkedId == R.id.rbLocationShareOn) {
				isLocationShared = true;
				llLocationShareContents.setVisibility(View.VISIBLE);

				TextView tvTitleTexTop = (TextView) rlLocationShareTitle
						.findViewById(R.id.tvTitleTextTop);
				tvTitleTexTop.setTypeface(null, Typeface.BOLD);
			}
		}

	};

	public void getLocationFromMap() {
		double currentLat = 0;
		double currentLng = 0;

		if (StaticValues.myPoint != null) {
			currentLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
			currentLng = StaticValues.myPoint.getLongitudeE6() / 1E6;

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

			// MyGeoPoint geoPoint = new MyGeoPoint((int) (lat * 1E6), (int)
			// (lng * 1E6), address);

			// add new place
			Place place = new Place();
			place.setName(name);
			place.setVicinity(address);
			place.setLatitude(lat);
			place.setLongitude(lng);

			placeList.add(place);
			// add to list

			String radiusTitle = getString(R.string.locationSharingInvisibleRadiusTitle);

			if (place != null) {
				LinearLayout placeItemView = new LocationPreferenceItemView(
						context, place.getId(), place.getVicinity(), 0,
						radiusTitle);
				placeItemViewList.add(placeItemView);
				llPlaceList.addView(placeItemView);
			}

		}
	}

	public void showPeoplePicker(String pickerName) {
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

		// remove this line finally
		// rbLocationShareOn.setChecked(true);

		if (null != myInfo) {

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
					"get location sharing");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	private void updateLocalValue(String responseString) {
		// TODO Auto-generated method stub
		MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(
				responseString, false);
		if (myInfo != null)
			StaticValues.myInfo = myInfo;
	}

}
