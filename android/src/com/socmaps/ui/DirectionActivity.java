package com.socmaps.ui;

import com.google.android.maps.GeoPoint;
import com.readystatesoftware.mapviewballoons.R;
//import com.socmaps.ui.MeetupRequestNewActivity.LocationSelectionListener;
import com.socmaps.entity.MyGeoPoint;
import com.socmaps.entity.Place;
//import com.socmaps.ui.MeetupRequestNewActivity.LocationAddressHandler;
//import com.socmaps.ui.MeetupRequestNewActivity.NearByPlacesPickerhandler;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.LocationPicker;
import com.socmaps.widget.LocationRadioGroup;
import com.socmaps.widget.LocationRadioGroupListener;
import com.socmaps.widget.NearByPlacesPicker;
import com.socmaps.widget.NearByPlacesPickerListener;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

public class DirectionActivity extends Activity implements OnClickListener {

	ImageView ivDirectionWalk, ivDirectionCar, ivDirectionCycle,
			ivDirectionTransit;
	String defaultSourceAdd, defaultDestAdd;

	// --- starts declaration --- //
	Button btnBack;
	Button btnOk, btnCancel;

	Context context;

	LocationRadioGroup locationRadioGroupViewSource;
	LocationRadioGroup locationRadioGroupViewDest;

	LinearLayout locationRadioGroupContainerSource;
	LinearLayout selectedLocationInfoPanelSource;
	TextView tvSelectedLocationAddressSource;
	TextView tvSelectedLocationTitleSource;

	LinearLayout locationRadioGroupContainerDest;
	LinearLayout selectedLocationInfoPanelDest;
	TextView tvSelectedLocationAddressDest;
	TextView tvSelectedLocationTitleDest;

	String sourceRequestAddress = "", destRequestAddressRe = "";
	double sourceLat = 0, sourceLng = 0;
	double destLat = 0, destLng = 0;

	String dirflg = "d";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		// setContentView(R.layout.direction_old);
		setContentView(R.layout.direction_path);

		sourceLat = getIntent().getDoubleExtra("sourceLat", 0);
		sourceLng = getIntent().getDoubleExtra("sourceLng", 0);
		defaultSourceAdd = getIntent().getStringExtra("sourceAddress");

		destLat = getIntent().getDoubleExtra("destLat", 0);
		destLng = getIntent().getDoubleExtra("destLng", 0);
		defaultDestAdd = getIntent().getStringExtra("destAddress");

		initialize();
		addLocationRadioGroupSource();
		addLocationRadioGroupDest();

		setDefaultValues();
	}

	private void setDefaultValues() {
		selectTransport(ivDirectionCar, "d");
	}

	private void initialize() {
		context = DirectionActivity.this;

		ivDirectionWalk = (ImageView) findViewById(R.id.ivDirectionWalk);
		ivDirectionWalk.setOnClickListener(this);
		ivDirectionCar = (ImageView) findViewById(R.id.ivDirectionCar);
		ivDirectionCar.setOnClickListener(this);
		ivDirectionCycle = (ImageView) findViewById(R.id.ivDirectionCycle);
		ivDirectionCycle.setOnClickListener(this);
		ivDirectionTransit = (ImageView) findViewById(R.id.ivDirectionTransit);
		ivDirectionTransit.setOnClickListener(this);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				finish();
			}
		});

		btnOk = (Button) findViewById(R.id.btnOk);
		btnOk.setOnClickListener(this);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

		locationRadioGroupContainerSource = (LinearLayout) findViewById(R.id.locationRadioGroupContainer);
		locationRadioGroupContainerDest = (LinearLayout) findViewById(R.id.locationRadioGroupContainerRe);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_MAP_PICKER
				&& resultCode == RESULT_OK) {

			sourceRequestAddress = data.getStringExtra("ADDRESS");
			sourceLat = data.getDoubleExtra("LAT", 0.0);
			sourceLng = data.getDoubleExtra("LNG", 0.0);

			Log.d("InsideOnActivityForSource", String.valueOf(sourceLat) + "~"
					+ String.valueOf(sourceLng));
			/*
			 * Toast.makeText( context, "For Source" + String.valueOf(sourceLat)
			 * + "~" + String.valueOf(sourceLng), Toast.LENGTH_SHORT) .show();
			 */

			displayAddress(null, sourceRequestAddress);
		}

		if (requestCode == 666 && resultCode == RESULT_OK) {

			destRequestAddressRe = data.getStringExtra("ADDRESS");
			destLat = data.getDoubleExtra("LAT", 0.0);
			destLng = data.getDoubleExtra("LNG", 0.0);

			Log.d("InsideOnActivityForDestination", String.valueOf(destLat)
					+ "~" + String.valueOf(destLng));
			/*
			 * Toast.makeText( context, "For Destination" +
			 * String.valueOf(destLat) + "~" + String.valueOf(destLng),
			 * Toast.LENGTH_SHORT) .show();
			 */

			displayAddressRe(null, destRequestAddressRe);
		}
	}

	// - - - for Source - - - //

	private void addLocationRadioGroupSource() {
		// TODO Auto-generated method stub

		locationRadioGroupViewSource = new LocationRadioGroup(context,
				new LocationSelectionListenerSource());

		selectedLocationInfoPanelSource = (LinearLayout) locationRadioGroupViewSource
				.findViewById(R.id.selectedLocationInfoPanel);
		tvSelectedLocationAddressSource = (TextView) locationRadioGroupViewSource
				.findViewById(R.id.tvSelectedLocationAddress);

		tvSelectedLocationTitleSource = (TextView) locationRadioGroupViewSource
				.findViewById(R.id.tvSelectedLocationTitle);

		locationRadioGroupContainerSource.addView(locationRadioGroupViewSource);

		// locationRadioGroupViewSource.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

		if (sourceLat != 0 && sourceLng != 0) {
			locationRadioGroupViewSource
					.setValue(LocationRadioGroup.SelectedItem.POINT_ON_MAP);
			getDefaultLocationAddressForSource();
		}

		else
			locationRadioGroupViewSource
					.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

	}

	private class LocationSelectionListenerSource implements
			LocationRadioGroupListener {

		@Override
		public void onLocationSelectionChanged(RadioGroup group,
				RadioButton radio, LocationRadioGroup.SelectedItem selectedItem) {
			// TODO Auto-generated method stub

			selectedLocationInfoPanelSource.setVisibility(View.GONE);
			tvSelectedLocationAddressSource.setText("");
			tvSelectedLocationTitleSource.setText("");
			tvSelectedLocationTitleSource.setVisibility(View.GONE);
			sourceRequestAddress = "";

			switch (selectedItem) {
			case CURRENT_LOCATION:
				getCurrentLocationAddressForSource();
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

	public void getCurrentLocationAddressForSource() {
		if (StaticValues.myPoint != null) {
			if (StaticValues.myPoint != null) {
				sourceLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
				sourceLng = StaticValues.myPoint.getLongitudeE6() / 1E6;
				Log.d("MM Cur Lat LNG", String.valueOf(sourceLat) + " "
						+ String.valueOf(sourceLng));
				Utility.getAddressByCoordinate(sourceLat, sourceLng,
						new LocationAddressHandler());

			}
		}
	}

	public void getDefaultLocationAddressForSource() {
		if (sourceLat != 0 && sourceLng != 0) {
			Utility.getAddressByCoordinate(sourceLat, sourceLng,
					new LocationAddressHandler());

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
				sourceRequestAddress = result;
				displayAddress(null, sourceRequestAddress);
			} else {
				Log.e("ADDRESS", "Failed to get.");
			}

		}
	}

	public void getLocationFromMap() {
		double currentLat = 0;
		double currentLng = 0;

		if (sourceLat != 0 && sourceLng != 0) {
			currentLat = sourceLat;
			currentLng = sourceLng;
			Log.d("Gone with Received lat long LP", currentLat + "" + "~"
					+ currentLng);
		} else {
			currentLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
			currentLng = StaticValues.myPoint.getLongitudeE6() / 1E6;
			Log.d("Gone with Current lat long LP", currentLat + "" + "-"
					+ currentLng + "");

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
				// MyGeoPoint myGeoPoint = selectedPlace.getLocation();

				sourceLat = selectedPlace.getLatitude();
				sourceLng = selectedPlace.getLongitude();
				sourceRequestAddress = selectedPlace.getVicinity();
				displayAddress(selectedPlace.getName(), sourceRequestAddress);

			}
		}

	}

	public void displayAddress(String title, String address) {
		tvSelectedLocationAddressSource.setText(address);

		if (title != null) {
			if (!title.equalsIgnoreCase("")) {
				tvSelectedLocationTitleSource.setText(title);
				tvSelectedLocationTitleSource.setVisibility(View.VISIBLE);
			}
		}

		selectedLocationInfoPanelSource.setVisibility(View.VISIBLE);
	}

	// - - - Source Ends - - - //

	// - - - for Destination Starts - - - //

	private void addLocationRadioGroupDest() {
		// TODO Auto-generated method stub

		locationRadioGroupViewDest = new LocationRadioGroup(context,
				new LocationSelectionListenerDest());

		selectedLocationInfoPanelDest = (LinearLayout) locationRadioGroupViewDest
				.findViewById(R.id.selectedLocationInfoPanel);
		tvSelectedLocationAddressDest = (TextView) locationRadioGroupViewDest
				.findViewById(R.id.tvSelectedLocationAddress);

		tvSelectedLocationTitleDest = (TextView) locationRadioGroupViewDest
				.findViewById(R.id.tvSelectedLocationTitle);

		locationRadioGroupContainerDest.addView(locationRadioGroupViewDest);

		// locationRadioGroupViewDest.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

		if (destLat != 0 && destLng != 0) {
			locationRadioGroupViewDest
					.setValue(LocationRadioGroup.SelectedItem.POINT_ON_MAP);
			getDefaultLocationAddressDest();
		}

		else
			locationRadioGroupViewDest
					.setValue(LocationRadioGroup.SelectedItem.CURRENT_LOCATION);

	}

	private class LocationSelectionListenerDest implements
			LocationRadioGroupListener {

		@Override
		public void onLocationSelectionChanged(RadioGroup group,
				RadioButton radio, LocationRadioGroup.SelectedItem selectedItem) {
			// TODO Auto-generated method stub

			selectedLocationInfoPanelDest.setVisibility(View.GONE);
			tvSelectedLocationAddressDest.setText("");
			tvSelectedLocationTitleDest.setText("");
			tvSelectedLocationTitleDest.setVisibility(View.GONE);
			destRequestAddressRe = "";

			switch (selectedItem) {
			case CURRENT_LOCATION:
				getCurrentLocationAddressDest();
				break;
			case MY_PLACES:

				break;
			case NEAR_TO_ME:
				getNearByPlacesDest();
				break;
			case POINT_ON_MAP:
				getLocationFromMapDest();
				break;
			default:
				break;
			}

		}
	}

	public void getNearByPlacesDest() {
		if (StaticValues.searchResult != null) {

			if (StaticValues.searchResult.getPlaces() != null) {
				NearByPlacesPicker nearByPlacesPickerRe = new NearByPlacesPicker(
						context, new NearByPlacesPickerhandlerRe(),
						"NEAR_BY_PACES", StaticValues.searchResult.getPlaces());

				nearByPlacesPickerRe.show();
			}
		}

	}

	public void getCurrentLocationAddressDest() {
		if (StaticValues.myPoint != null) {
			if (StaticValues.myPoint != null) {
				destLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
				destLng = StaticValues.myPoint.getLongitudeE6() / 1E6;
				Utility.getAddressByCoordinate(destLat, destLng,
						new LocationAddressHandlerRe());

			}
		}
	}

	public void getDefaultLocationAddressDest() {

		if (destLat != 0 && destLng != 0) {

			Utility.getAddressByCoordinate(destLat, destLng,
					new LocationAddressHandlerRe());

		}
	}

	private class LocationAddressHandlerRe extends Handler {
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
				destRequestAddressRe = result;
				displayAddressRe(null, destRequestAddressRe);
			} else {
				Log.e("ADDRESS", "Failed to get.");
			}

		}
	}

	public void getLocationFromMapDest() {
		double currentLat = 0;
		double currentLng = 0;

		if (destLat != 0 && destLng != 0) {
			currentLat = destLat;
			currentLng = destLng;
		} else {
			currentLat = StaticValues.myPoint.getLatitudeE6() / 1E6;
			currentLng = StaticValues.myPoint.getLongitudeE6() / 1E6;

		}

		Intent intent = new Intent(context, LocationPicker.class);
		intent.putExtra("LAT", currentLat);
		intent.putExtra("LNG", currentLng);
		startActivityForResult(intent, 666);

	}

	private class NearByPlacesPickerhandlerRe implements
			NearByPlacesPickerListener {

		@Override
		public void onPlaceSelect(String pickerName, Place selectedPlace) {
			// TODO Auto-generated method stub
			if (selectedPlace != null) {
				

				destLat = selectedPlace.getLatitude();
				destLng = selectedPlace.getLongitude();
				destRequestAddressRe = selectedPlace.getVicinity();
				displayAddressRe(selectedPlace.getName(), destRequestAddressRe);

			}
		}

	}

	public void displayAddressRe(String title, String address) {
		tvSelectedLocationAddressDest.setText(address);

		if (title != null) {
			if (!title.equalsIgnoreCase("")) {
				tvSelectedLocationTitleDest.setText(title);
				tvSelectedLocationTitleDest.setVisibility(View.VISIBLE);
			}
		}

		selectedLocationInfoPanelDest.setVisibility(View.VISIBLE);
	}

	public void selectTransport(View v, String transport) {
		dirflg = transport;
		ivDirectionCar.setBackgroundResource(R.drawable.button_bg_direction);
		ivDirectionCycle.setBackgroundResource(R.drawable.button_bg_direction);
		ivDirectionTransit
				.setBackgroundResource(R.drawable.button_bg_direction);
		ivDirectionWalk.setBackgroundResource(R.drawable.button_bg_direction);

		v.setBackgroundResource(R.drawable.button_bg_direction_selected);
	}

	// - - - for Destination Ends - - - //

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == ivDirectionCar) {
			selectTransport(v, "d");
		}
		if (v == ivDirectionCycle) {
			selectTransport(v, "b");
		}
		if (v == ivDirectionTransit) {
			selectTransport(v, "r");
		}
		if (v == ivDirectionWalk) {
			selectTransport(v, "w");
		} else if (v == btnOk) {
			goToMapToShowRoute();
		} else if (v == btnCancel) {
			finish();
		}

	}

	private void goToMapToShowRoute() {

		String link = "http://maps.google.com/maps?saddr=" + sourceLat + ","
				+ sourceLng + "&daddr=" + destLat + "," + destLng + "&dirflg="
				+ dirflg;
		Log.d("directionLINK", link);

		Intent intentGoForDirection = new Intent(Intent.ACTION_VIEW,
				Uri.parse(link));

		startActivity(intentGoForDirection);
	}

}
