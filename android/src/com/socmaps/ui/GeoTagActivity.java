package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Bundle;
import android.os.Debug;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Base64;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.LocationPicker;
import com.socmaps.widget.LocationRadioGroup;
import com.socmaps.widget.LocationRadioGroupListener;
import com.socmaps.widget.NearByPlacesPicker;
import com.socmaps.widget.NearByPlacesPickerListener;
import com.socmaps.widget.PeoplePickerListener;
import com.socmaps.widget.PermissionRadioGroup;


/**
 * GeoTagActivity class responsible for creating geo tag view.
 *
 */
public class GeoTagActivity extends Activity implements PeoplePickerListener {

	Button btnBack, btnNotification;
	Button btnList, btnDescription, btnPhoto, btnCancel, btnSave;

	EditText etTitle;
	Context context;

	PermissionRadioGroup permissionRadioGroupView;
	LocationRadioGroup locationRadioGroupView;

	LinearLayout locationRadioGroupContainer;
	LinearLayout selectedLocationInfoPanel;
	TextView tvSelectedLocationAddress;
	TextView tvSelectedLocationTitle;

	ImageView ivEventImage;

	ProgressDialog m_ProgressDialog;

	int requestCode;

	String responseString;
	int responseStatus = 0;

	ButtonActionListener buttonActionListener;

	private LayoutInflater inflater;
	private Button btnFriendSelect, btnCircleSelect, btnSelectAll,
			btnUnselectAll;
	EditText etFriendSearch;
	LinearLayout friendListContainer, circleListContainer;
	ScrollView scrollViewFriends, scrollViewCircles;
	HashMap<String, Boolean> selectedFriends = new HashMap<String, Boolean>();
	HashMap<String, Boolean> selectedCircles = new HashMap<String, Boolean>();

	List<String> shareWithSelectedFriendList;
	List<String> shareWithSelectedCircleList;
	List<String> shareWithSelectedCircleFriendList;
	List<String> shareWithSelectedFriendListAll;

	String shareWithPickerName = "sharewith";

	String eventName = "", eventSummary = "", eventDescription = "",
			eventAddress = "", eventListItem = "";
	double eventLat = 0, eventLng = 0;

	Bitmap eventPicture;
	Calendar now = Calendar.getInstance();

	String permissionValue = "";

	ImageDownloader imageDownloader;
	HashMap<String, Boolean> backupSelectedFriends = new HashMap<String, Boolean>();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.geo_tag_test);

		initialize();
		addLocationRadioGroup();
		generateFriendList();
		showFriendList();
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
		if (eventPicture != null) {
			eventPicture.recycle();
		}
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

	private void initialize() {

		context = GeoTagActivity.this;

		imageDownloader = ImageDownloader.getInstance();

		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

		etTitle = (EditText) findViewById(R.id.etTitle);

		btnSave = (Button) findViewById(R.id.btnSave);
		btnSave.setOnClickListener(buttonActionListener);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener);

		btnList = (Button) findViewById(R.id.btnList);
		btnList.setOnClickListener(buttonActionListener);

		btnDescription = (Button) findViewById(R.id.btnDescription);
		btnDescription.setOnClickListener(buttonActionListener);

		btnPhoto = (Button) findViewById(R.id.btnPhoto);
		btnPhoto.setOnClickListener(buttonActionListener);

		ivEventImage = (ImageView) findViewById(R.id.ivEventImage);
		ivEventImage.setOnClickListener(buttonActionListener);

		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		btnFriendSelect = (Button) findViewById(R.id.btnFriendSelect);
		btnFriendSelect.setOnClickListener(buttonActionListener);
		btnCircleSelect = (Button) findViewById(R.id.btnCircleSelect);
		btnCircleSelect.setOnClickListener(buttonActionListener);
		btnSelectAll = (Button) findViewById(R.id.btnSelectAll);
		btnSelectAll.setOnClickListener(buttonActionListener);
		btnUnselectAll = (Button) findViewById(R.id.btnUnselectAll);
		btnUnselectAll.setOnClickListener(buttonActionListener);

		etFriendSearch = (EditText) findViewById(R.id.etFriendSearch);
		friendListContainer = (LinearLayout) findViewById(R.id.friendListContainer);
		circleListContainer = (LinearLayout) findViewById(R.id.circleListContainer);
		scrollViewFriends = (ScrollView) findViewById(R.id.scrollViewFriends);
		scrollViewCircles = (ScrollView) findViewById(R.id.scrollViewCircles);

		locationRadioGroupContainer = (LinearLayout) findViewById(R.id.locationRadioGroupContainer);

		etFriendSearch.addTextChangedListener(filterTextWatcher);
	}

	private TextWatcher filterTextWatcher = new TextWatcher() {

		@Override
		public void afterTextChanged(Editable s) {
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
		}

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
			Log.d("Do Search", "Do Search Method Called  "
					+ etFriendSearch.getText().toString().trim());
			doSearch();
		}

	};

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

		locationRadioGroupView
				.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

	}

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnBack) {
				finish();
			} else if (v == btnNotification) {
				Intent notificationIntent = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(notificationIntent);
			} else if (v == btnSave) {
				validateEvent();
			}

			else if (v == btnCancel) {
				finish();
			}

			else if (v == btnList) {
				selectItemFromSpinner();
			} else if (v == btnDescription) {
				showTextInputDialog(3);
			} else if (v == btnPhoto) {
				capturePhoto();
			} else if (v == ivEventImage) {
				capturePhoto();
			}

			else if (v == btnFriendSelect) {
				showFriendList();
			} else if (v == btnCircleSelect) {
				showCircleList();
			} else if (v == btnSelectAll) {
				selectAll();
			} else if (v == btnUnselectAll) {
				unselectAll();
			}

		}

	}

	private void selectItemFromSpinner() {
		AlertDialog dialog;

		final String str[] = getResources().getStringArray(
				R.array.geoTagListOption);

		final String[] relArray = new String[str.length - 1];

		for (int i = 0; i < str.length; i++) {
			if (i > 0) {
				relArray[i - 1] = str[i];
			}
		}

		AlertDialog.Builder builder = new AlertDialog.Builder(this);

		builder.setSingleChoiceItems(relArray, 1,
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int position) {

						String listItem = relArray[position];
						String listItem1 = listItem.toLowerCase().toString();
						eventListItem = listItem1.replace(" ", "_")
								.toLowerCase();
						Log.d("Item Selection", relArray[position] + " "
								+ listItem + " " + listItem1 + " "
								+ eventListItem);

						dialog.dismiss();
					}

				});
		dialog = builder.create();
		dialog.show();
	}

	private void validateEvent() {
		// TODO Auto-generated method stub
		boolean validated = true;
		String messageText = "";
		if (eventLat == 0 && eventLng == 0) {
			validated = false;
			messageText = "Location not found. Please select or pick a location.";
		} else if (etTitle.getText().toString().equals("")) {
			validated = false;
			messageText = "Please enter event name.";
		}

		if (validated) {
			initiateSendEventData();
		} else {
			Toast.makeText(context, messageText, Toast.LENGTH_SHORT).show();
		}
	}

	private void initiateSendEventData() {
		Thread thread = new Thread(null, sendEventDataThread,
				"Start send event data");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.sending_request_text), true, true);
	}

	private Runnable sendEventDataThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smGeoTag);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("title", etTitle.getText().toString());
			restClient.AddParam("description", eventDescription);

			// set event photo
			String eventPhotoString = "";
			if (eventPicture != null) {
				/* Get the image as string */
				// Normal
				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				eventPicture.compress(Bitmap.CompressFormat.PNG, 60,
						full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				eventPhotoString = Base64.encodeToString(full_bytes,
						Base64.DEFAULT);

				restClient.AddParam("photo", eventPhotoString);

			}
			// end of event photo

			restClient.AddParam("category", eventListItem);
			restClient.AddParam("address", eventAddress);
			restClient.AddParam("lat", eventLat + "");
			restClient.AddParam("lng", eventLng + "");

			List<String> invitedPeopleList = Utility
					.getListFromHashMap(selectedFriends);
			for (int i = 0; i < invitedPeopleList.size(); i++) {
				restClient.AddParam("friends[]", invitedPeopleList.get(i));
			}
			// end of invited people

			// add invited circles
			List<String> invitedCircleList = Utility
					.getListFromHashMap(selectedCircles);
			for (int i = 0; i < invitedCircleList.size(); i++) {
				restClient.AddParam("circles[]", invitedCircleList.get(i));
			}
			// end of invited circles

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

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}

			handleResponseSendEventData(responseStatus, responseString);

		}
	};

	private void handleResponseSendEventData(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("GeoTag CREATE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_CREATED) {

			Toast.makeText(context, "Geotag created Successfully.",
					Toast.LENGTH_SHORT).show();

			finish();
		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}


	private void generateFriendList() {

		friendListContainer.removeAllViews();
		List<People> friends = StaticValues.myInfo.getFriendList();

		if (friends != null) {

			for (int i = 0; i < friends.size(); i++) {
				View v = getItemViewFriend(friends.get(i));
				friendListContainer.addView(v);
			}
		}

		circleListContainer.removeAllViews();
		List<Circle> circles = StaticValues.myInfo.getCircleList();
		if (circles != null) {
			for (int i = 0; i < circles.size(); i++) {

				String circleId = circles.get(i).getId();
				if (circleId != null) {

					selectedCircles.put(circleId, false);

					if (circles.get(i).getFriendList() != null) {
						if (circles.get(i).getFriendList().size() > 0) {
							View v = getItemViewCircle(circles.get(i));
							circleListContainer.addView(v);
						}
					}
				}
			}
		}

	}

	private View getItemViewFriend(People fEntity) {

		View v = inflater.inflate(R.layout.people_item, null);

		TextView nameView = (TextView) v.findViewById(R.id.name);
		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);

		final LinearLayout proficPicContainer = (LinearLayout) v
				.findViewById(R.id.proficPicContainer);

		final String id = fEntity.getId();
		String avatarUrl = fEntity.getAvatar();

		String name = "";
		name = Utility.getFieldText(fEntity);
		nameView.setText(name);

		selectedFriends.put(id, false);

		if (avatarUrl != null && !avatarUrl.equals("")) {

			imageDownloader.download(avatarUrl, profilePic);

		}

		if (backupSelectedFriends.containsKey(id)) {
			boolean preValue = backupSelectedFriends.get(id);

			if (preValue) {
				proficPicContainer
						.setBackgroundResource(R.color.highlightGreen);
				selectedFriends.put(id, preValue);
			}
		}

		profilePic.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				boolean isSelected = selectedFriends.get(id);
				if (isSelected) {
					proficPicContainer
							.setBackgroundResource(R.color.transparent);
				} else {
					proficPicContainer
							.setBackgroundResource(R.color.highlightGreen);
				}
				selectedFriends.put(id, !isSelected);

			}
		});

		return v;
	}

	private View getItemViewCircle(Circle cEntity) {

		View v = inflater.inflate(R.layout.circle_item, null);

		TextView titleView = (TextView) v.findViewById(R.id.circleTitle);
		CheckBox chkCircle = (CheckBox) v.findViewById(R.id.chkCircle);

		String title = cEntity.getName();
		final String id = cEntity.getId();
		List<People> friends = cEntity.getFriendList();

		if (friends != null) {
			title += " (" + friends.size() + ")";
		}

		titleView.setText(title);

		chkCircle.setOnCheckedChangeListener(new OnCheckedChangeListener() {

			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				// TODO Auto-generated method stub
				if (isChecked) {
					selectedCircles.put(id, true);
				} else {
					selectedCircles.put(id, false);
				}
			}
		});

		return v;
	}

	private void showFriendList() {

		btnFriendSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);
		btnCircleSelect.setTextAppearance(context,
				R.style.ButtonTextStyleNormal);

		if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			scrollViewCircles.setVisibility(View.GONE);
		}

		scrollViewFriends.setVisibility(View.VISIBLE);
	}

	private void showCircleList() {
		btnFriendSelect.setTextAppearance(context,
				R.style.ButtonTextStyleNormal);
		btnCircleSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);

		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			scrollViewFriends.setVisibility(View.GONE);
		}

		scrollViewCircles.setVisibility(View.VISIBLE);
	}

	private void selectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(true);
		} else if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			selectionCircles(true);
		}
	}

	private void unselectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(false);
		} else if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			selectionCircles(false);
		}
	}

	private void selectionFriends(boolean isSelect) {
		int selectionColor;
		if (isSelect) {
			selectionColor = R.color.highlightGreen;
		} else {
			selectionColor = R.color.transparent;
		}

		int totalChild = friendListContainer.getChildCount();
		for (int i = 0; i < totalChild; i++) {
			View v = friendListContainer.getChildAt(i);
			LinearLayout proficPicContainer = (LinearLayout) v
					.findViewById(R.id.proficPicContainer);
			proficPicContainer.setBackgroundResource(selectionColor);
		}

		Set set = selectedFriends.entrySet();
		Iterator iterator = set.iterator();
		while (iterator.hasNext()) {
			Map.Entry me = (Map.Entry) iterator.next();

			String key = (String) me.getKey();
			selectedFriends.put(key, isSelect);
		}
	}

	private void selectionCircles(boolean isSelect) {

		int totalChild = circleListContainer.getChildCount();
		for (int i = 0; i < totalChild; i++) {
			View v = circleListContainer.getChildAt(i);
			CheckBox chkCircle = (CheckBox) v.findViewById(R.id.chkCircle);
			chkCircle.setChecked(isSelect);
		}

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

	// TODO Auto-generated method stub
	private void showTextInputDialog(final int type) {
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

					switch (type) {
					case 1:
						eventName = inputText;
						break;
					case 2:
						eventSummary = inputText;
						break;
					case 3:
						eventDescription = inputText;
						break;
					default:
						break;
					}
					Utility.hideKeyboard(GeoTagActivity.this);
					dialog.dismiss();
				}

			}
		});

		String title = "";
		String hint = "";
		String text = "";

		switch (type) {
		case 1:
			title = "Enter name:";
			hint = "Name";
			text = eventName;
			break;
		case 2:
			title = "Enter summary:";
			hint = "Summary";
			text = eventSummary;
			break;
		case 3:
			title = "Enter description:";
			hint = "Description";
			text = eventDescription;
			break;
		default:
			break;
		}

		tvTitle.setText(title);
		etInputText.setHint(hint);
		if (!text.equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		dialog.show();
	}

	private void capturePhoto() {
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

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {

				if (eventPicture != null) {

				}
				eventPicture = Utility.resizeBitmap((Bitmap) data.getExtras()
						.get("data"), Constant.eventPhotoWidth, 0, true);

				ivEventImage.setImageBitmap(eventPicture);
			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == Constant.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {

				Uri selectedImage = data.getData();
				try {
					eventPicture = Utility.resizeBitmap(Utility.decodeUri(
							selectedImage, getContentResolver()),
							Constant.eventPhotoWidth, 0, true);

					ivEventImage.setImageBitmap(eventPicture);

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
		} else if (requestCode == Constant.REQUEST_CODE_MAP_PICKER
				&& resultCode == RESULT_OK) {
			eventAddress = data.getStringExtra("ADDRESS");
			eventLat = data.getDoubleExtra("LAT", 0.0);
			eventLng = data.getDoubleExtra("LNG", 0.0);

			displayAddress(null, eventAddress);
		}
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

	private void displayAddress(String title, String address) {
		tvSelectedLocationAddress.setText(address);

		if (title != null) {
			if (!title.equalsIgnoreCase("")) {
				tvSelectedLocationTitle.setText(title);
				tvSelectedLocationTitle.setVisibility(View.VISIBLE);
			}
		}

		selectedLocationInfoPanel.setVisibility(View.VISIBLE);

	}

	private void getCurrentLocationAddress() {
		if (StaticValues.myPoint != null) {
			if (StaticValues.myPoint != null) {
				eventLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
				eventLng = StaticValues.myPoint.getLongitudeE6() / 1E6;
				Utility.getAddressByCoordinate(eventLat, eventLng,
						new LocationAddressHandler());

			}
		}

	}

	private void getNearByPlaces() {
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

	private void getLocationFromMap() {
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

	private void doSearch() {

		List<Object> dataList = new ArrayList<Object>();
		dataList.addAll(StaticValues.myInfo.getFriendList());

		List<Object> list = (Utility.getSearchResult(dataList, etFriendSearch
				.getText().toString().trim()));
		friendListContainer.removeAllViews();

		backupSelectedFriends = new HashMap<String, Boolean>(selectedFriends);
		selectedFriends.clear();
		for (int i = 0; i < list.size(); i++) {
			View v = getItemViewFriend((People) list.get(i));
			friendListContainer.addView(v);
		}

	}

}
