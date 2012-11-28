package com.socmaps.ui;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.Debug;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Place;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.DateTimePicker;
import com.socmaps.widget.LocationPicker;
import com.socmaps.widget.LocationRadioGroup;
import com.socmaps.widget.LocationRadioGroupListener;
import com.socmaps.widget.NearByPlacesPicker;
import com.socmaps.widget.NearByPlacesPickerListener;
import com.socmaps.widget.PeoplePicker;
import com.socmaps.widget.PeoplePickerListener;
import com.socmaps.widget.PermissionRadioGroup;
import com.socmaps.widget.PermissionRadioGroupListener;

public class PlanCreateActivity extends Activity implements PeoplePickerListener { 
	
	Button btnBack, btnNotification; 
	Button btnDate; 
	Button btnSend, btnCancel; 
	TextView tvDate;
	Context context; 
	
	PermissionRadioGroup permissionRadioGroupView;
	LocationRadioGroup locationRadioGroupView; 
	
	LinearLayout shareWithRadioGroupContainer;
	LinearLayout locationRadioGroupContainer;
	LinearLayout selectedLocationInfoPanel;
	TextView tvSelectedLocationAddress;
	TextView tvSelectedLocationTitle; 
	
	ProgressDialog m_ProgressDialog;

	int requestCode;
	String responseString;
	int responseStatus = 0; 
	
	ButtonActionListener buttonActionListener; 
	
	private LayoutInflater inflater; 
	
	EditText etMessage; 
	TextView tvShowSelectedDate; 
	
	String dob = ""; 
	String eventDateString = "";
	
	Calendar now = Calendar.getInstance();
	String permissionValue = "";
	
	double eventLat = 0, eventLng = 0; 
	String eventAddress = ""; 
	String description = "";
	
	String shareWithPickerName = "sharewith"; 
	
	List<String> shareWithSelectedFriendList;
	List<String> shareWithSelectedCircleList;
	List<String> shareWithSelectedCircleFriendList;
	List<String> shareWithSelectedFriendListAll;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState); 
		setContentView(R.layout.plan_layout);  
		
		eventLat = getIntent().getDoubleExtra("destLat", 0);
		eventLng = getIntent().getDoubleExtra("destLng", 0); 
		eventAddress = getIntent().getStringExtra("destAddress"); 
		
		Log.d("Received Place GTag", String.valueOf(eventLat)+" "+ String.valueOf(eventLng));

		initialize(); 
		addLocationRadioGroup();
		addPermissionRadioGroup();
	} 
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		
		Utility.updateNotificationBubbleCounter(btnNotification);

		Log.i("PlanNewActivity:onResume memory before",
				"" + Debug.getNativeHeapAllocatedSize());

	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			//Intent intent = new Intent(context, EventListActivity.class);
			finish();
			//startActivity(intent);
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
	
	private void initialize()
	{
		context = PlanCreateActivity.this; 
		
		buttonActionListener = new ButtonActionListener(); 
		
		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

		btnSend = (Button) findViewById(R.id.btnSend);
		btnSend.setOnClickListener(buttonActionListener);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener);  
		
		tvDate = (TextView) findViewById(R.id.tvDate); 
		//tvDate.setOnClickListener(buttonActionListener);
		
		btnDate = (Button) findViewById(R.id.btnSelectDate); 
		btnDate.setOnClickListener(buttonActionListener); 
		
		etMessage = (EditText) findViewById(R.id.etMessage); 
		tvShowSelectedDate = (TextView) findViewById(R.id.tvShowSelectedDate); 
		
		inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE); 
		
		shareWithRadioGroupContainer = (LinearLayout) findViewById(R.id.shareWithRadioGroupContainer);
		locationRadioGroupContainer = (LinearLayout) findViewById(R.id.locationRadioGroupContainer); 
		
		
	} 
	
	private class ButtonActionListener implements OnClickListener
	{

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			
			if(v == btnBack)
				finish(); 
			else if(v == btnNotification)
			{
				Intent notificationIntent = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(notificationIntent);
			} 
			else if (v == btnSend) {
				//Toast.makeText(context, "Coming Soon", Toast.LENGTH_SHORT).show();
				validPlan(); 
			}
			else if (v == btnCancel) {
				finish();
			} 
			else if (v == btnDate)
			{
				//selectDate(); 
				selectDateDetails(); 
				//tvShowSelectedDate.setText(eventDateString);
			} 
			else if (v == tvDate)
			{
				selectDateDetails(); 
			}
		}
		
	} 
	
	private void addPermissionRadioGroup() {
		// TODO Auto-generated method stub
		permissionRadioGroupView = new PermissionRadioGroup(context,
				new ShareWithSelectionListener());
		shareWithRadioGroupContainer.addView(permissionRadioGroupView);

	}
	
	private void addLocationRadioGroup() {
		// TODO Auto-generated method stub
		locationRadioGroupView = new LocationRadioGroup(context,
				new LocationSelectionListener());

		selectedLocationInfoPanel = (LinearLayout) locationRadioGroupView
				.findViewById(R.id.selectedLocationInfoPanel);
		tvSelectedLocationAddress = (TextView) locationRadioGroupView
				.findViewById(R.id.tvSelectedLocationAddress);

		tvSelectedLocationTitle = (TextView) locationRadioGroupView
				.findViewById(R.id.tvSelectedLocationTitle);

		locationRadioGroupContainer.addView(locationRadioGroupView);

		/*locationRadioGroupView
				.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);*/ 
		
		if(eventLat != 0 && eventLng != 0) 
		{
			locationRadioGroupView.setValue(LocationRadioGroup.SelectedItem.POINT_ON_MAP);
			getDefaultLocationAddress();
		}
		else
			locationRadioGroupView.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

	} 
	
	private class LocationSelectionListener implements
	LocationRadioGroupListener {

	@Override
	public void onLocationSelectionChanged(RadioGroup group,
			RadioButton radio, LocationRadioGroup.SelectedItem selectedItem) {
		// TODO Auto-generated method stub
			selectedLocationInfoPanel.setVisibility(View.GONE);
			tvSelectedLocationAddress.setText("");
			tvSelectedLocationTitle.setText("");
			tvSelectedLocationTitle.setVisibility(View.GONE);
			eventAddress = "";
		
			switch (selectedItem) {
			case CURRENT_LOCATION:
				getCurrentLocationAddress();
				break;
			case MY_PLACES:
		
				break;
			case NEAR_TO_ME:
				getNearByPlaces();
				break;
			case POINT_ON_MAP:
				getLocationFromMap();
				break;
			default:
				break;
			}
	
		}
	
	}

	public void displayAddress(String title, String address) {
		tvSelectedLocationAddress.setText(address);
		
		if (title != null) {
			if (!title.equalsIgnoreCase("")) {
				tvSelectedLocationTitle.setText(title);
				tvSelectedLocationTitle.setVisibility(View.VISIBLE);
			}
		}
		
		selectedLocationInfoPanel.setVisibility(View.VISIBLE);
	
	}

	public void getCurrentLocationAddress() {
		if (StaticValues.myPoint != null) {
			if (StaticValues.myPoint != null) {
				eventLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
				eventLng = StaticValues.myPoint.getLongitudeE6() / 1E6;
				Utility.getAddressByCoordinate(eventLat, eventLng,
						new LocationAddressHandler());
		
			}
		}
	
	}

	public void getNearByPlaces() {
		if (StaticValues.searchResult != null) {
			if (StaticValues.searchResult.getPlaces() != null) {
				NearByPlacesPicker nearByPlacesPicker = new NearByPlacesPicker(
						context, new NearByPlacesPickerhandler(),
						"NEAR_BY_PACES", StaticValues.searchResult.getPlaces());
		
				nearByPlacesPicker.show();
			}
		}
	
	}

	private class LocationAddressHandler extends Handler {
		@Override
		public void handleMessage(Message message) {
				String result = null;
				switch (message.what) {
				case 0:
					// failed to get address
					break;
				case 1:
					Bundle bundle = message.getData();
					result = bundle.getString("address");
					break;
				default:
					result = null;
				}
				// replace by what you need to do
				if (result != null) {
					eventAddress = result;
					displayAddress(null, eventAddress);
				} else {
					Log.e("ADDRESS", "Failed to get.");
			}
		
		}
	}

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

	private class NearByPlacesPickerhandler implements
		NearByPlacesPickerListener {
	
			@Override
			public void onPlaceSelect(String pickerName, Place selectedPlace) {
				// TODO Auto-generated method stub
				if (selectedPlace != null) {
					
						eventLat = selectedPlace.getLatitude();
						eventLng = selectedPlace.getLongitude();
						eventAddress = selectedPlace.getVicinity();
						displayAddress(selectedPlace.getName(), eventAddress);
					
			
				}
		} 
	
	} 

	private void getDefaultLocationAddress() 
	{
		if (eventLat != 0 && eventLng != 0) {
		
			Utility.getAddressByCoordinate(eventLat, eventLng,
					new LocationAddressHandler());
	
	}
	} 
	
	private class ShareWithSelectionListener implements
	PermissionRadioGroupListener {

		@Override
		public void onPermissionChanged(RadioGroup group, RadioButton radio,
				Constant.Permission selectedItem) {
			// TODO Auto-generated method stub
		
			permissionValue = "";
		
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
		}
	} 
	
	public void showPeoplePicker(String pickerName) {
		// custom dialog
		//Dialog peoplePicker = new PeoplePicker(context, this, pickerName, shareWithSelectedFriendList, shareWithSelectedCircleList);
		
		Dialog peoplePicker = new PeoplePicker(context, (PeoplePickerListener) this, pickerName, shareWithSelectedFriendList, shareWithSelectedCircleList);
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
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_MAP_PICKER && resultCode == RESULT_OK) {
			eventAddress = data.getStringExtra("ADDRESS");
			eventLat = data.getDoubleExtra("LAT", 0.0);
			eventLng = data.getDoubleExtra("LNG", 0.0);

			displayAddress(null, eventAddress);
		}
	} 
	
	private void selectDate() 
	{
		DatePickerDialog datePickerDialog = new DatePickerDialog(
				PlanCreateActivity.this, new OnDateSetListener() {
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
	
	private void selectDateDetails() 
	{
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

				// final boolean is24h = true;

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
								
								/*Calendar cal=Calendar.getInstance();
								SimpleDateFormat month_date = new SimpleDateFormat("MMMMMMMMM");
								String month_name = month_date.format(cal.getTime());*/

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
								
								String dateFormate = selectedDateTime + " " + "at" + " " + hourString + ":"+ minuteString;

								selectedDateTime += " " + hourString + ":"
										+ minuteString + ":00"; 
								Log.e("Selected date time", selectedDateTime); 
								
								
								if (Utility.getTimeDifference(selectedDateTime) > 0) {
									eventDateString = selectedDateTime; 
									//tvShowSelectedDate.setText(eventDateString); 
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
	
	private void validPlan()
	{
		boolean validated = true;
		String messageText = ""; 
		
		description = etMessage.getText().toString().trim(); 
		
		if (eventLat == 0 && eventLng == 0) {
			validated = false;
			messageText = "Location not found. Please select or pick a location.";
		} 
		else if (eventDateString.equals("")) {
			validated = false;
			messageText = "Please enter plan date.";
		} 
		else if (description.equals("")) { 
			validated = false;
			messageText = "Please enter description.";
		}
		
		if (validated) {
			initiateSendEventData();
		} else {
			Toast.makeText(context, messageText, Toast.LENGTH_SHORT).show();
		}
	} 
	
	public void initiateSendEventData() {
		Thread thread = new Thread(null, sendPlanThread,
				"Start send plan data");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.sending_request_text), true);
	} 
	
	private Runnable sendPlanThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smPlanUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context)); 
			
			//description = etMessage.getText().toString().trim(); 
			Log.d("Description", description);

			restClient.AddParam("description", description); 
			restClient.AddParam("address", eventAddress);
			restClient.AddParam("time", eventDateString + " " + Utility.getTimezoneOffset());
			restClient.AddParam("lat", eventLat + "");
			restClient.AddParam("lng", eventLng + "");

			// add permitted users
			if (!permissionValue.equals("")) {
				restClient.AddParam("permission", permissionValue); 
				Log.d("Permission", "Inside Permission Request: "+permissionValue);

				if (permissionValue
						.equalsIgnoreCase(Constant.PERMISSION_CUSTOM)) {
					if (shareWithSelectedCircleList != null) {
						for (int i = 0; i < shareWithSelectedCircleList.size(); i++) {
							restClient.AddParam("permittedCircles[]",
									shareWithSelectedCircleList.get(i)); 
							Log.d("permitted_person_circle", shareWithSelectedCircleList.get(i));
						}
					}
					if (shareWithSelectedFriendList != null) {
						for (int i = 0; i < shareWithSelectedFriendList.size(); i++) {
							restClient.AddParam("permittedUsers[]",
									shareWithSelectedFriendList.get(i)); 
							Log.d("permitted_person_list", shareWithSelectedFriendList.get(i));
						}
					}
				}

			}
			// end of permitted users


			try {
				restClient.Execute(RestClient.RequestMethod.POST);
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
			m_ProgressDialog.dismiss();

			handleResponseSendEventData(responseStatus, responseString);

		}
	}; 
	
	public void handleResponseSendEventData(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("Plan CREATE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_CREATED) {

			// etNewMessage.setText("");
			Toast.makeText(context, "Plan created successfully.",
					Toast.LENGTH_SHORT).show();

			// EventListActivity.isUpdateList = true;
			//Intent intent = new Intent(context, EventListActivity.class);
			finish();
			//startActivity(intent);

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

}
