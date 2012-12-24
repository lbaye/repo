package com.socmaps.ui;

import java.util.Calendar;
import java.util.List;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.Debug;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Plan;
import com.socmaps.util.Constant;
import com.socmaps.util.Constant.Permission;
import com.socmaps.util.RestClient;
import com.socmaps.util.Utility;
import com.socmaps.widget.DateTimePicker;
import com.socmaps.widget.LocationRadioGroup;
import com.socmaps.widget.PeoplePicker;
import com.socmaps.widget.PeoplePickerListener;
import com.socmaps.widget.PermissionRadioGroup;
import com.socmaps.widget.PermissionRadioGroupListener;

/**
 * PlanEditActivity class is used to edit a particular plan from the plan list 
 * and that updated plan is send to server to update. 
 *
 */

public class PlanEditActivity extends Activity implements PeoplePickerListener {

	Button btnBack, btnNotification;
	Button btnDate;
	Button btnUpdate, btnCancel;
	TextView tvDate;
	Context context;

	PermissionRadioGroup permissionRadioGroupView;
	LocationRadioGroup locationRadioGroupView;

	LinearLayout shareWithRadioGroupContainer;
	LinearLayout locationRadioGroupContainer;
	LinearLayout selectedLocationInfoPanel;
	TextView tvSelectedLocationAddress;
	TextView tvSelectedLocationTitle;
	TextView tvTitle, tvTitleDescription;

	ProgressDialog m_ProgressDialog;

	int requestCode;
	String responseString;
	int responseStatus = 0;

	ButtonActionListener buttonActionListener;

	EditText etMessage;
	TextView tvShowSelectedDate;

	String dob = "";
	String eventDateString = "";

	Calendar now = Calendar.getInstance();
	String permissionValue = "";

	double eventLat = 0, eventLng = 0;
	String eventAddress = "";
	String planId = "", planDescription = "";

	String shareWithPickerName = "sharewith";

	boolean isPermissionValueSet = false;

	List<String> shareWithSelectedFriendList;
	List<String> shareWithSelectedCircleList;
	List<String> shareWithSelectedCircleFriendList;
	List<String> shareWithSelectedFriendListAll;

	Plan selectedPlan;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.plan_layout_update);

		Object selectedItem = getIntent().getSerializableExtra("selectedPlan");
		if (selectedItem != null) {
			selectedPlan = (Plan) (selectedItem);
			selectedItem = null;
		}

		setLatLngFromSeletedPlan();

		initialize();
		addPermissionRadioGroup();
		setDefaultValues();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);

		Log.i("EventNewActivity:onResume memory before",
				"" + Debug.getNativeHeapAllocatedSize());

	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			finish();
		}
		return false;

	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void setLatLngFromSeletedPlan() {
		if (selectedPlan != null) {
			eventLat = selectedPlan.getLatitude();
			eventLng = selectedPlan.getLongitude();

			Log.d("Lat LNG", eventLat + "" + " " + eventLng + "");
		}
	}

	private void initialize() {
		context = PlanEditActivity.this;

		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

		btnUpdate = (Button) findViewById(R.id.btnUpdate);
		btnUpdate.setOnClickListener(buttonActionListener);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener);

		tvDate = (TextView) findViewById(R.id.tvDate);

		btnDate = (Button) findViewById(R.id.btnSelectDate);
		btnDate.setOnClickListener(buttonActionListener);

		etMessage = (EditText) findViewById(R.id.etMessage);
		tvShowSelectedDate = (TextView) findViewById(R.id.tvShowSelectedDate);

		shareWithRadioGroupContainer = (LinearLayout) findViewById(R.id.shareWithRadioGroupContainer);
		locationRadioGroupContainer = (LinearLayout) findViewById(R.id.locationRadioGroupContainer);

		tvTitle = (TextView) findViewById(R.id.tvTitle);
		tvTitleDescription = (TextView) findViewById(R.id.tvTitleDescription);

	}

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub

			if (v == btnBack)
				finish();
			else if (v == btnNotification) {
				Intent notificationIntent = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(notificationIntent);
			} else if (v == btnUpdate) {
				updatePlan();
			} else if (v == btnCancel) {
				finish();
			} else if (v == btnDate) {
				selectDateDetails();
			} else if (v == tvDate) {
				selectDateDetails();
			}
		}

	}

	private void setDefaultValues() {
		if (selectedPlan != null) {
			planId = selectedPlan.getPlanId();
			eventLat = selectedPlan.getLatitude();
			eventLng = selectedPlan.getLongitude();
			eventAddress = selectedPlan.getAddress();

			if (selectedPlan.getDescription() != null) {
				planDescription = selectedPlan.getDescription();
				Log.d("PLAN DESCRIPTION", planDescription);
			}

			if (selectedPlan.getPlanTime().getDateTimeValue() != null) {
				eventDateString = Utility
						.getFormattedDisplayDateEventList(selectedPlan
								.getPlanTime());
				Log.d("Date & Time", eventDateString);
			}

			if (eventAddress != null && !eventAddress.equals("")) {
				eventAddress = selectedPlan.getAddress();
			}

			etMessage.setText(planDescription);
			tvShowSelectedDate.setText(eventDateString);
			tvTitle.setText("Venue: " + selectedPlan.getAddress());
		}
	}

	private void addPermissionRadioGroup() {
		// TODO Auto-generated method stub

		String permission = selectedPlan.getPermission();
		Permission preSelectedItem = Permission.NONE;

		if (permission != null) {
			if (permission.equalsIgnoreCase(Constant.PERMISSION_CIRCLES)) {
				preSelectedItem = Permission.CIRCLES;
			} else if (permission.equalsIgnoreCase(Constant.PERMISSION_CUSTOM)) {
				preSelectedItem = Permission.CUSTOM;
			} else if (permission.equalsIgnoreCase(Constant.PERMISSION_FRIENDS)) {
				preSelectedItem = Permission.FRIENDS;
			} else if (permission.equalsIgnoreCase(Constant.PERMISSION_NONE)) {
				preSelectedItem = Permission.NONE;
			} else if (permission.equalsIgnoreCase(Constant.PERMISSION_PUBLIC)) {
				preSelectedItem = Permission.PUBLIC;
			}
		}

		permissionRadioGroupView = new PermissionRadioGroup(context,
				new ShareWithSelectionListener(), preSelectedItem);
		shareWithRadioGroupContainer.addView(permissionRadioGroupView);

	}

	private class ShareWithSelectionListener implements
			PermissionRadioGroupListener {

		@Override
		public void onPermissionChanged(RadioGroup group, RadioButton radio,
				Permission selectedItem) {
			// TODO Auto-generated method stub

			permissionValue = "";

			if (isPermissionValueSet) {
				switch (selectedItem) {
				case PUBLIC:
					permissionValue = Constant.PERMISSION_PUBLIC;
					break;
				case FRIENDS:
					permissionValue = Constant.PERMISSION_FRIENDS;
					break;
				case NONE:
					permissionValue = Constant.PERMISSION_NONE;
					break;
				case CIRCLES:
					permissionValue = Constant.PERMISSION_CIRCLES;
					break;
				case CUSTOM:
					permissionValue = Constant.PERMISSION_CUSTOM;
					showPeoplePicker(shareWithPickerName);
					break;
				default:
					permissionValue = Constant.PERMISSION_NONE;
					break;
				}
			} else {
				isPermissionValueSet = true;
			}
		}
	}

	private void showPeoplePicker(String pickerName) {
		// custom dialog

		Dialog peoplePicker = new PeoplePicker(context,
				(PeoplePickerListener) this, pickerName,
				shareWithSelectedFriendList, shareWithSelectedCircleList);
		peoplePicker.show();
	}

	@Override
	public void onSelect(String pickerName, List<String> selectedFriendList,
			List<String> selectedCircleList,
			List<String> selectedCircleFriendList,
			List<String> selectedFriendListAll) {

		if (pickerName.equalsIgnoreCase(shareWithPickerName)) {
			shareWithSelectedFriendList = selectedFriendList;
			shareWithSelectedCircleList = selectedCircleList;
			shareWithSelectedCircleFriendList = selectedCircleFriendList;
			shareWithSelectedFriendListAll = selectedFriendListAll;
		}

	}

	private void selectDateDetails() {
		// Create the dialog
		final Dialog mDateTimeDialog = new Dialog(context);

		// Inflate the root layout
		final RelativeLayout mDateTimeDialogView = (RelativeLayout) getLayoutInflater()
				.inflate(R.layout.date_time_dialog, null);
		// Grab widget instance
		final DateTimePicker mDateTimePicker = (DateTimePicker) mDateTimeDialogView
				.findViewById(R.id.DateTimePicker);
		// Check is system is set to use 24h time (this doesn't seem to work as
		// expected though)
		final String timeS = android.provider.Settings.System.getString(
				getContentResolver(),
				android.provider.Settings.System.TIME_12_24);
		final boolean is24h = !(timeS == null || timeS.equals("12"));

		if (!eventDateString.equals("")) {
			Calendar calendar = Utility.stringToCalendar(eventDateString);
			if (calendar != null) {
				mDateTimePicker.updateDate(calendar.get(Calendar.YEAR),
						calendar.get(Calendar.MONTH),
						calendar.get(Calendar.DAY_OF_MONTH));
				mDateTimePicker.updateTime(calendar.get(Calendar.HOUR_OF_DAY),
						calendar.get(Calendar.MINUTE));
			}
		}

		// Update demo TextViews when the "OK" button is clicked
		((Button) mDateTimeDialogView.findViewById(R.id.SetDateTime))
				.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View v) {
						mDateTimePicker.clearFocus();
						// TODO Auto-generated method stub

						String selectedDateTime = "";

						int month = mDateTimePicker.get(Calendar.MONTH) + 1;
						String monthString = "" + month;
						if (month < 10) {
							monthString = "0" + month;
						}

						int day = mDateTimePicker.get(Calendar.DAY_OF_MONTH);
						String dayString = "" + day;
						if (day < 10) {
							dayString = "0" + day;
						}

						selectedDateTime = mDateTimePicker.get(Calendar.YEAR)
								+ "-" + monthString + "-" + dayString;

						int hour = mDateTimePicker.get(Calendar.HOUR_OF_DAY) + 1;
						String hourString = "" + hour;
						if (hour < 10) {
							hourString = "0" + hour;
						}

						int minute = mDateTimePicker.get(Calendar.MINUTE);
						String minuteString = "" + minute;
						if (minute < 10) {
							minuteString = "0" + minute;
						}

						String dateFormate = selectedDateTime + " " + "at"
								+ " " + hourString + ":" + minuteString;

						selectedDateTime += " " + hourString + ":"
								+ minuteString + ":00";
						Log.e("Selected date time", selectedDateTime);

						if (Utility.getTimeDifference(selectedDateTime) > 0) {
							eventDateString = selectedDateTime;
							tvShowSelectedDate.setText(dateFormate);
							mDateTimeDialog.dismiss();
						} else {
							Toast.makeText(context, "Invalid date and time.",
									Toast.LENGTH_SHORT).show();
						}

					}
				});

		// Cancel the dialog when the "Cancel" button is clicked
		((Button) mDateTimeDialogView.findViewById(R.id.CancelDialog))
				.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View v) {
						// TODO Auto-generated method stub
						mDateTimeDialog.cancel();
					}
				});

		// Reset Date and Time pickers when the "Reset" button is clicked
		((Button) mDateTimeDialogView.findViewById(R.id.ResetDateTime))
				.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View v) {
						// TODO Auto-generated method stub
						mDateTimePicker.reset();
					}
				});

		// Setup TimePicker
		mDateTimePicker.setIs24HourView(is24h);
		// No title on the dialog window
		mDateTimeDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		// Set the dialog content view
		mDateTimeDialog.setContentView(mDateTimeDialogView);
		// Display the dialog
		mDateTimeDialog.show();
	}

	private void updatePlan() {
		boolean validated = true;
		String messageText = "";

		planDescription = etMessage.getText().toString().trim();

		if (eventLat == 0 && eventLng == 0) {
			validated = false;
			messageText = "Location not found. Please select or pick a location.";
		} else if (eventDateString.equals("")) {
			validated = false;
			messageText = "Please enter plan date.";
		} else if (planDescription.equals("")) {
			validated = false;
			messageText = "Please enter plan description";
		}

		if (validated) {
			initiateSendEventData();
		} else {
			Toast.makeText(context, messageText, Toast.LENGTH_SHORT).show();
		}
	}

	private void initiateSendEventData() {
		Thread thread = new Thread(null, sendPlanThread,
				"Start send event data");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.sending_request_text), true, true);
	}

	private Runnable sendPlanThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smPlanUrl + "/"
					+ selectedPlan.getPlanId());
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			Log.d("Description", planDescription);
			Log.d("Lat LNG Recheck", eventLat + "" + " " + eventLng + "");

			restClient.AddParam("description", planDescription);
			restClient.AddParam("address", eventAddress);
			restClient.AddParam("time",
					eventDateString + " " + Utility.getTimezoneOffset());
			Log.d("DATE CHECK", eventDateString);
			restClient.AddParam("lat", eventLat + "");
			restClient.AddParam("lng", eventLng + "");

			// add permitted users
			if (!permissionValue.equals("")) {
				restClient.AddParam("permission", permissionValue);
				Log.d("Permission", "Inside Permission Request: "
						+ permissionValue);

				if (permissionValue
						.equalsIgnoreCase(Constant.PERMISSION_CUSTOM)) {
					if (shareWithSelectedCircleList != null) {
						for (int i = 0; i < shareWithSelectedCircleList.size(); i++) {
							restClient.AddParam("permittedCircles[]",
									shareWithSelectedCircleList.get(i));
							Log.d("permitted_person_circle",
									shareWithSelectedCircleList.get(i));
						}
					}
					if (shareWithSelectedFriendList != null) {
						for (int i = 0; i < shareWithSelectedFriendList.size(); i++) {
							restClient.AddParam("permittedUsers[]",
									shareWithSelectedFriendList.get(i));
							Log.d("permitted_person_list",
									shareWithSelectedFriendList.get(i));
						}
					}
				}

			}
			// end of permitted users

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(sendEventDataResponse);
		}
	};

	private Runnable sendEventDataResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}

			handleResponseSendEventData(responseStatus, responseString);

		}
	};

	private void handleResponseSendEventData(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("Plan Update RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {

			Toast.makeText(context, "Plan updated successfully.",
					Toast.LENGTH_SHORT).show();

			Intent intent = new Intent(context, ProfileActivity.class);
			finish();
			startActivity(intent);

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

}
