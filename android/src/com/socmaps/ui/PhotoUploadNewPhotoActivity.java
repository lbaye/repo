package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.Place;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.LocationPicker;
import com.socmaps.widget.LocationRadioGroup;
import com.socmaps.widget.LocationRadioGroupListener;
import com.socmaps.widget.NearByPlacesPicker;
import com.socmaps.widget.NearByPlacesPickerListener;
import com.socmaps.widget.PeoplePicker;
import com.socmaps.widget.PeoplePickerListener;
import com.socmaps.widget.PermissionRadioGroup;
import com.socmaps.widget.PermissionRadioGroupListener;

/**
 * PhotoUploadNewPhotoActivity class is used to upload new photos to the web
 * server.
 */

public class PhotoUploadNewPhotoActivity extends FragmentActivity implements PeoplePickerListener {

	private Context context;
	private LocationRadioGroup locationRadioGroupView;
	private LinearLayout selectedLocationInfoPanel, shareWithRadioGroupContainer, locationRadioGroupContainer;
	private PermissionRadioGroup permissionRadioGroupView;

	private TextView tvSelectedLocationAddress, tvSelectedLocationTitle;

	private String permissionValue = "";
	private String shareWithPickerName = "sharewith";
	private Button btnBack, btnAddTakeAnotherPhoto, btnCancel, btnUploadPhoto, btnMyPhotos;

	private ButtonActionListener buttonActionListener;
	private ImageView ivPhoto;
	private Bitmap photoIcon;
	private int requestCode;
	private EditText editImageDiscription;
	private String address = "";
	private double latitude = 0, longitude = 0;

	List<String> shareWithSelectedFriendList;
	List<String> shareWithSelectedCircleList;
	List<String> shareWithSelectedCircleFriendList;
	List<String> shareWithSelectedFriendListAll;
	private ProgressDialog m_ProgressDialog;
	private String savePhotoResponse;
	private int savePhotoStatus;
	private String title, description;

	private final int REQUEST_CODE_CAMERA = 100;
	private final int REQUEST_CODE_GALLERY = 101;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.photo_upload_new_photo_layout);

		initialize();
		addLocationRadioGroup();
		addPermissionRadioGroup();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
	}

	private void initialize() {

		context = PhotoUploadNewPhotoActivity.this;
		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener);

		btnAddTakeAnotherPhoto = (Button) findViewById(R.id.btnAddTakeAnotherPhoto);
		btnAddTakeAnotherPhoto.setOnClickListener(buttonActionListener);

		btnUploadPhoto = (Button) findViewById(R.id.btnUploadPhoto);
		btnUploadPhoto.setOnClickListener(buttonActionListener);

		btnMyPhotos = (Button) findViewById(R.id.btnMyPhotos);
		btnMyPhotos.setOnClickListener(buttonActionListener);

		ivPhoto = (ImageView) findViewById(R.id.ivPhoto);

		editImageDiscription = (EditText) findViewById(R.id.editImageDiscription);

		locationRadioGroupContainer = (LinearLayout) findViewById(R.id.locationRadioGroupContainerPhoto);
		shareWithRadioGroupContainer = (LinearLayout) findViewById(R.id.shareWithRadioGroupContainerPhoto);

	}

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnBack) {

				finish();

			} else if (v == btnCancel) {
				finish();

			} else if (v == btnAddTakeAnotherPhoto) {
				takeIconFromGalaryOrCamara();

			} else if (v == btnUploadPhoto) {

				uploadImageToServer();

			} else if (v == btnMyPhotos) {

				Intent uploadPhotoIntent = new Intent(context, PhotoListActivity.class);
				uploadPhotoIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
				startActivity(uploadPhotoIntent);
				finish();

			}

		}

	}

	private void takeIconFromGalaryOrCamara() {
		// TODO Auto-generated method stub
		final CharSequence[] items = { "Gallery", "Camera" };
		AlertDialog.Builder builder = new AlertDialog.Builder(PhotoUploadNewPhotoActivity.this);
		builder.setTitle("Select");
		builder.setItems(items, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int item) {
				Toast.makeText(getApplicationContext(), items[item], Toast.LENGTH_SHORT).show();
				if (items[item].equals("Gallery")) {
					requestCode = REQUEST_CODE_GALLERY;
				} else {
					requestCode = REQUEST_CODE_CAMERA;
				}
				onOptionItemSelected(requestCode);
			}

		});
		AlertDialog alert = builder.create();
		alert.show();
	}

	private boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case REQUEST_CODE_GALLERY:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case REQUEST_CODE_CAMERA:
			Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(cameraIntent, requestCode);
			break;
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {

				photoIcon = Utility.resizeBitmap((Bitmap) data.getExtras().get("data"), Constant.photoWidth * 2, 0, true);

				ivPhoto.setImageBitmap(photoIcon);

			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {

				Uri selectedImage = data.getData();
				try {
					photoIcon = Utility.resizeBitmap(Utility.decodeUri(selectedImage, getContentResolver()), Constant.photoWidth, 0, true);

					ivPhoto.setImageBitmap(photoIcon);

				} catch (FileNotFoundException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (OutOfMemoryError e) {
					Toast.makeText(context, getString(R.string.errorMessageGallery), Toast.LENGTH_SHORT).show();
					Log.e("Gallery image", "OutOfMemoryError");
					e.printStackTrace();
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}

			}
		}

		else if (requestCode == Constant.REQUEST_CODE_MAP_PICKER && resultCode == RESULT_OK) {
			address = data.getStringExtra("ADDRESS");
			latitude = data.getDoubleExtra("LAT", 0.0);
			longitude = data.getDoubleExtra("LNG", 0.0);

			displayAddress(null, address);
		}
	}

	private void addLocationRadioGroup() {
		// TODO Auto-generated method stub
		locationRadioGroupView = new LocationRadioGroup(context, new LocationSelectionListener());

		selectedLocationInfoPanel = (LinearLayout) locationRadioGroupView.findViewById(R.id.selectedLocationInfoPanel);
		tvSelectedLocationAddress = (TextView) locationRadioGroupView.findViewById(R.id.tvSelectedLocationAddress);

		tvSelectedLocationTitle = (TextView) locationRadioGroupView.findViewById(R.id.tvSelectedLocationTitle);

		locationRadioGroupContainer.addView(locationRadioGroupView);

		locationRadioGroupView.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

	}

	private void addPermissionRadioGroup() {
		// TODO Auto-generated method stub
		permissionRadioGroupView = new PermissionRadioGroup(context, new ShareWithSelectionListener());
		shareWithRadioGroupContainer.addView(permissionRadioGroupView);

	}

	private class ShareWithSelectionListener implements PermissionRadioGroupListener {

		@Override
		public void onPermissionChanged(RadioGroup group, RadioButton radio, Constant.Permission selectedItem) {
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

	private class LocationSelectionListener implements LocationRadioGroupListener {

		@Override
		public void onLocationSelectionChanged(RadioGroup group, RadioButton radio, LocationRadioGroup.SelectedItem selectedItem) {
			// TODO Auto-generated method stub
			selectedLocationInfoPanel.setVisibility(View.GONE);
			tvSelectedLocationAddress.setText("");
			tvSelectedLocationTitle.setText("");
			tvSelectedLocationTitle.setVisibility(View.GONE);
			address = "";

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

	private void getCurrentLocationAddress() {
		if (StaticValues.myPoint != null) {
			if (StaticValues.myPoint != null) {
				latitude = StaticValues.myPoint.latitude;
				longitude = StaticValues.myPoint.longitude;
				Utility.getAddressByCoordinate(latitude, longitude, new LocationAddressHandler());

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
				address = result;
				displayAddress(null, address);
			} else {
				Log.e("ADDRESS", "Failed to get.");
			}

		}
	}

	private void getNearByPlaces() {
		if (StaticValues.searchResult != null) {
			if (StaticValues.searchResult.getPlaces() != null) {
				NearByPlacesPicker nearByPlacesPicker = new NearByPlacesPicker(context, new NearByPlacesPickerhandler(), "NEAR_BY_PACES", StaticValues.searchResult.getPlaces());

				nearByPlacesPicker.show();
			}
		}

	}

	private class NearByPlacesPickerhandler implements NearByPlacesPickerListener {

		@Override
		public void onPlaceSelect(String pickerName, Place selectedPlace) {
			// TODO Auto-generated method stub
			if (selectedPlace != null) {

				latitude = selectedPlace.getLatitude();
				longitude = selectedPlace.getLongitude();
				address = selectedPlace.getVicinity();
				displayAddress(selectedPlace.getName(), address);

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

	private void showPeoplePicker(String pickerName) {
		// custom dialog
		Dialog peoplePicker = new PeoplePicker(context, this, pickerName, shareWithSelectedFriendList, shareWithSelectedCircleList);

		peoplePicker.show();
	}

	@Override
	public void onSelect(String pickerName, List<String> selectedFriendList, List<String> selectedCircleList, List<String> selectedCircleFriendList, List<String> selectedFriendListAll) {
		// TODO Auto-generated method stub

		if (pickerName.equalsIgnoreCase(shareWithPickerName)) {
			shareWithSelectedFriendList = selectedFriendList;
			shareWithSelectedCircleList = selectedCircleList;
			shareWithSelectedCircleFriendList = selectedCircleFriendList;
			shareWithSelectedFriendListAll = selectedFriendListAll;
		}

	}

	/*
	 * Places create/save to server
	 */
	private void uploadImageToServer() {
		// TODO Auto-generated method stub

		description = editImageDiscription.getText().toString().trim();
		title = "";

		if (photoIcon != null) {

			if (Utility.isConnectionAvailble(getApplicationContext())) {

				Thread thread = new Thread(null, uploadPhotoThread, "Start upload image to server");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog.show(context, getResources().getString(R.string.please_wait_text), getResources().getString(R.string.sending_request_text), true, true);

			} else {

				DialogsAndToasts.showNoInternetConnectionDialog(context);
			}

		} else {
			Toast.makeText(context, "Photo should not be empty.", Toast.LENGTH_SHORT).show();
		}

	}

	private Runnable uploadPhotoThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smUploadPhoto);
			restClient.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));

			if (title != null) {
				if (!title.equals("")) {
					restClient.AddParam("title", title);
				}
			}

			if (description != null) {
				if (!description.equals("")) {
					restClient.AddParam("description", description);
				}
			}

			if (latitude != 0 && longitude != 0) {
				restClient.AddParam("lat", latitude + "");
				restClient.AddParam("lng", longitude + "");
			}

			if (address != null) {
				if (!address.equals("")) {
					restClient.AddParam("address", address);
				}
			}

			if (permissionValue != null) {
				if (!permissionValue.equals("")) {
					restClient.AddParam("permission", permissionValue);

					if (permissionValue.equalsIgnoreCase(Constant.PERMISSION_CUSTOM)) {
						if (shareWithSelectedCircleList != null) {
							for (int i = 0; i < shareWithSelectedCircleList.size(); i++) {
								restClient.AddParam("permittedCircles[]", shareWithSelectedCircleList.get(i));
							}
						}
						if (shareWithSelectedFriendList != null) {
							for (int i = 0; i < shareWithSelectedFriendList.size(); i++) {
								restClient.AddParam("permittedUsers[]", shareWithSelectedFriendList.get(i));
							}
						}
					}

				}
			}

			if (photoIcon != null) {

				String placeImageString = "";
				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				photoIcon.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				placeImageString = Base64.encodeToString(full_bytes, Base64.DEFAULT);
				restClient.AddParam("image", placeImageString);

				photoIcon = null;

			}

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			savePhotoResponse = restClient.getResponse();
			savePhotoStatus = restClient.getResponseCode();

			runOnUiThread(uploadPhotoResponseFromServer);
		}
	};

	private Runnable uploadPhotoResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseUploadPhpto(savePhotoStatus, savePhotoResponse);

			// dismiss progress dialog if needed
			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	private void handleResponseUploadPhpto(int status, String response) {

		Log.w("Photo upload response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:

			Toast.makeText(context, "Photo uploaded successfully.", Toast.LENGTH_SHORT).show();

			PhotoListActivity.isUploadNewPhoto = true;

			Intent uploadPhotoIntent = new Intent(context, PhotoListActivity.class);

			uploadPhotoIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

			startActivity(uploadPhotoIntent);

			finish();

			break;

		default:
			Toast.makeText(getApplicationContext(), "An unknown error occured. Please try again!!", Toast.LENGTH_SHORT).show();
			break;

		}

	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();

	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (photoIcon != null) {
			photoIcon.recycle();
		}
		System.gc();
	}

}
