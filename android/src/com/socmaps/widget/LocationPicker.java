package com.socmaps.widget;

import android.app.Activity;
import android.app.FragmentManager;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMap.OnCameraChangeListener;
import com.google.android.gms.maps.GoogleMap.OnMapClickListener;
import com.google.android.gms.maps.GoogleMap.OnMarkerClickListener;
import com.google.android.gms.maps.GoogleMap.OnMarkerDragListener;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.socmaps.ui.R;
import com.socmaps.util.Utility;

/**
 * LocationPicker MapActivity for providing expected location.
 */
public class LocationPicker extends Activity implements OnClickListener,
		OnCameraChangeListener, OnMapClickListener, OnMarkerDragListener,OnMarkerClickListener {
	
	private TextView showLocation;
	private double lat = 0.0, lng = 0.0;
	private String address = null;
	private String name = null;
	private Button btnOk, btnCancel;
	private GoogleMap mapView;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.location_picker_layout);
		init();
		getIntentData();

		updateMap();

	}

	private void getIntentData() {
		// TODO Auto-generated method stub
		lat = getIntent().getDoubleExtra("LAT", 0);
		lng = getIntent().getDoubleExtra("LNG", 0);
	}

	private void updateMap() {
		LatLng latLng = new LatLng(lat, lng);
		MarkerOptions markerOptions = new MarkerOptions();
		markerOptions.title("");
		markerOptions.icon(BitmapDescriptorFactory.defaultMarker());
		markerOptions.position(latLng);
		markerOptions.draggable(true);
		mapView.addMarker(markerOptions);
		
		
		mapView.animateCamera(CameraUpdateFactory.newLatLngZoom(latLng,16));
		
		Utility.getAddressByCoordinate(lat, lng, new LocationAddressHandler());
		
	}

	private class LocationAddressHandler extends Handler {
		@Override
		public void handleMessage(Message message) {
			String result = null;
			String locName = null;
			switch (message.what) {
			case 0:
				// failed to get address
				break;
			case 1:
				Bundle bundle = message.getData();
				result = bundle.getString("address");
				locName = bundle.getString("name");

				break;
			default:
				result = null;
			}
			// replace by what you need to do
			if (result != null) {
				name = locName;
				address = result;
				showLocation.setText(result);
			} else {
				Log.e("ADDRESS", "Failed to get.");
			}

		}
	}

	private void init() {
		// TODO Auto-generated method stub
		showLocation = (TextView) findViewById(R.id.tvAddress);
		
		btnOk = (Button) findViewById(R.id.btnOk);
		btnOk.setOnClickListener(this);
		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

		FragmentManager myFragmentManager = getFragmentManager();
		MapFragment myMapFragment = (MapFragment) myFragmentManager
				.findFragmentById(R.id.map);
		mapView = myMapFragment.getMap();
		mapView.setMyLocationEnabled(true);
		// mapView.setMapType(GoogleMap.MAP_TYPE_HYBRID);
		mapView.setMapType(GoogleMap.MAP_TYPE_NORMAL);
		// mapView.setMapType(GoogleMap.MAP_TYPE_SATELLITE);
		// mapView.setMapType(GoogleMap.MAP_TYPE_TERRAIN);
		mapView.setOnMapClickListener(this);
		mapView.setOnCameraChangeListener(this);
		mapView.setOnMarkerDragListener(this);
		mapView.setOnMarkerClickListener(this);
	}

	@Override
	public void onResume() {
		super.onResume();

	}

	@Override
	public void onPause() {
		super.onPause();

	}

	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		

		return (super.onKeyDown(keyCode, event));
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnOk) {
			Intent i = getIntent();
			i.putExtra("ADDRESS", address);
			i.putExtra("LAT", lat);
			i.putExtra("LNG", lng);
			i.putExtra("NAME", name);
			setResult(RESULT_OK, i);
			finish();

		} else if (v == btnCancel) {
			Intent i = getIntent();
			i.putExtra("ADDRESS", address);
			i.putExtra("LAT", lat);
			i.putExtra("LNG", lng);
			i.putExtra("NAME", name);
			setResult(RESULT_CANCELED, i);
			finish();

		}
	}

	@Override
	public void onMapClick(LatLng point) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onCameraChange(CameraPosition position) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onMarkerDrag(Marker marker) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onMarkerDragEnd(Marker marker) {
	
		LatLng latLng = marker.getPosition();
		Utility.getAddressByCoordinate(latLng.latitude, latLng.longitude,
				new LocationAddressHandler());

	}

	@Override
	public void onMarkerDragStart(Marker marker) {
		// TODO Auto-generated method stub

	}



	@Override
	public boolean onMarkerClick(Marker marker) {
		// TODO Auto-generated method stub
		return true;
	}
}