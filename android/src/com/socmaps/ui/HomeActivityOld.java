package com.socmaps.ui;

import com.socmaps.widget.MultiDirectionSlidingDrawer;

import java.util.List;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Point;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;
import android.widget.ZoomControls;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.socmaps.util.PreferenceConnector;

public class HomeActivityOld extends MapActivity implements LocationListener {
	MapView geoMapView;
	MapController mapController;

	private LocationManager locationManager;

	double latitude = 0, longitude = 0;
	GeoPoint geoPoint = null;
	

	private String bestProvider;

	private static final int MENU_ITEM_PEOPLE = Menu.FIRST + 1;
	private static final int MENU_ITEM_PROFILE = Menu.FIRST + 2;
	private static final int MENU_ITEM_DEAL = Menu.FIRST + 3;
	private static final int MENU_ITEM_VENUE = Menu.FIRST + 4;
	private static final int MENU_ITEM_SETTINGS = Menu.FIRST + 5;
	private static final int MENU_ITEM_LOGOUT = Menu.FIRST + 6;

	Button btnNotification;

	Button topCloseButton, bottomCloseButton;
	Button mOpenButton;
	MultiDirectionSlidingDrawer topDrawer, bottomDrawer;

	ButtonActionListener buttonActionListener;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.home);

		// String currentLocation = "Lat: " + latitude + " Lng: " + longitude;
		
		initialize();

		geoMapView.setSatellite(false);
		mapController = geoMapView.getController();
		mapController.setZoom(14);

		geoPoint = new GeoPoint((int) (latitude * 1000000),
				(int) (longitude * 1000000));
		mapController.setCenter(geoPoint);

		MyLocationOverlay myLocationOverlay = new MyLocationOverlay();
		List<Overlay> list = geoMapView.getOverlays();
		list.add(myLocationOverlay);

		@SuppressWarnings("deprecation")
		ZoomControls zoomControls = (ZoomControls) geoMapView.getZoomControls();
		zoomControls.setLayoutParams(new ViewGroup.LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));

		zoomControls.setGravity(Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
		geoMapView.addView(zoomControls);
		geoMapView.displayZoomControls(true);

		/*
		 * LocationManager locationManager = (LocationManager)
		 * getSystemService(Context.LOCATION_SERVICE);
		 * locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,
		 * 1000L, 500.0f, this);
		 */

		// Get the location manager
		locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);

		// List all providers:
		List<String> providers = locationManager.getAllProviders();
		for (String provider : providers) {
			// printProvider(provider);
		}

		Criteria criteria = new Criteria();
		bestProvider = locationManager.getBestProvider(criteria, false);
		// output.append("\n\nBEST Provider:\n");
		// printProvider(bestProvider);

		// output.append("\n\nLocations (starting with last known):");
		Location location = locationManager.getLastKnownLocation(bestProvider);
		updateMapLocation(location);

	}
	
	public void initialize()
	{
		buttonActionListener = new ButtonActionListener();

		geoMapView = (MapView) findViewById(R.id.myGMap);

		topCloseButton = (Button) findViewById(R.id.topHandle);
		topCloseButton.setOnClickListener(buttonActionListener);

		bottomCloseButton = (Button) findViewById(R.id.bottomHandle);
		bottomCloseButton.setOnClickListener(buttonActionListener);

		topDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.topDrawer);
		bottomDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.bottomDrawer);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);
	}

	public void openTopDrawer() {
		if (!topDrawer.isOpened()) {
			topDrawer.animateOpen();
		}

	}

	public void closeTopDrawer() {
		if (topDrawer.isOpened()) {
			topDrawer.animateClose();
		}
	}

	public void openBottomDrawer() {
		if (!bottomDrawer.isOpened()) {
			bottomDrawer.animateOpen();
		}
	}

	public void closeBottomDrawer() {
		if (bottomDrawer.isOpened()) {
			bottomDrawer.animateClose();
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// menu.add(Menu.NONE, MENU_ITEM_PEOPLE,
		// Menu.NONE,"People").setIcon(R.drawable.ic_launcher);
		// menu.add(Menu.NONE, MENU_ITEM_PROFILE,
		// Menu.NONE,"Profile").setIcon(R.drawable.ic_launcher);
		// menu.add(Menu.NONE, MENU_ITEM_DEAL,
		// Menu.NONE,"Deal").setIcon(R.drawable.ic_launcher);
		// menu.add(Menu.NONE, MENU_ITEM_VENUE,
		// Menu.NONE,"Venue").setIcon(R.drawable.ic_launcher);
		// menu.add(Menu.NONE, MENU_ITEM_SETTINGS,
		// Menu.NONE,"Settings").setIcon(R.drawable.ic_launcher);
		// menu.add(Menu.NONE, MENU_ITEM_LOGOUT,
		// Menu.NONE,"Logout").setIcon(R.drawable.ic_launcher);

		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case MENU_ITEM_PEOPLE:
			// finish();
			Intent peopleIntent = new Intent(getApplicationContext(),
					PeopleActivity.class);
			startActivity(peopleIntent);
			break;

		case MENU_ITEM_PROFILE:
			// finish();
			Intent profileIntent = new Intent(getApplicationContext(),
					ProfileActivity.class);
			startActivity(profileIntent);
			break;

		case MENU_ITEM_DEAL:
			// finish();
			Intent dealIntent = new Intent(getApplicationContext(),
					DealsActivity.class);
			startActivity(dealIntent);
			break;
		case MENU_ITEM_VENUE:
			// finish();
			Intent venueIntent = new Intent(getApplicationContext(),
					VenueActivity.class);
			startActivity(venueIntent);
			break;
		case MENU_ITEM_SETTINGS:
			// finish();
			Intent settingsIntent = new Intent(getApplicationContext(),
					SettingsActivity.class);
			startActivity(settingsIntent);
			break;
		case MENU_ITEM_LOGOUT:
			PreferenceConnector.writeBoolean(getApplicationContext(),
					"isLoggedInKey", false);
			finish();
			Intent logoutIntent = new Intent(getApplicationContext(),
					LoginActivity.class);
			startActivity(logoutIntent);
			break;
		}
		return super.onOptionsItemSelected(item);
	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();

		//initialize();
	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();
		locationManager.requestLocationUpdates(bestProvider, 30000, 1, this);
	}

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();
		locationManager.removeUpdates(this);
	}

	public void onLocationChanged(Location location) {
		updateMapLocation(location);
	}

	private void updateMapLocation(Location location) {
		if (location != null) {
			latitude = location.getLatitude();
			longitude = location.getLongitude();
			// String currentLocation = "Lat: " + latitude + " Lng: " +
			// longitude;
			geoPoint = new GeoPoint((int) (latitude * 1000000),
					(int) (longitude * 1000000));
			mapController.animateTo(geoPoint);
		}
	}

	public void onProviderDisabled(String provider) {
		Toast.makeText(getApplicationContext(), "GPS Disabled",
				Toast.LENGTH_SHORT).show();
	}

	public void onProviderEnabled(String provider) {
		Toast.makeText(getApplicationContext(), "GPS Enabled",
				Toast.LENGTH_SHORT).show();
	}

	public void onStatusChanged(String provider, int status, Bundle extras) {
	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_I) {
			geoMapView.getController().setZoom(geoMapView.getZoomLevel() + 1);
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_O) {
			geoMapView.getController().setZoom(geoMapView.getZoomLevel() - 1);
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_S) {
			geoMapView.setSatellite(false);
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_T) {
			geoMapView.setTraffic(true);
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_BACK) {
			AlertDialog.Builder adb = new AlertDialog.Builder(this);
			// adb.setTitle("Set Title here");
			adb.setMessage("Are you sure you want to exit from this application?");
			adb.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					finish();
				}
			});
			adb.setNegativeButton("No", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			});
			adb.show();
		}
		return false;

	}

	protected class MyLocationOverlay extends com.google.android.maps.Overlay {
		@Override
		public boolean draw(Canvas canvas, MapView mapView, boolean shadow,
				long when) {
			Paint paint = new Paint();

			super.draw(canvas, mapView, shadow);

			Point myScreenCoords = new Point();
			mapView.getProjection().toPixels(geoPoint, myScreenCoords);

			paint.setStrokeWidth(1);
			paint.setARGB(255, 255, 255, 255);
			paint.setStyle(Paint.Style.STROKE);

			Bitmap bmp = BitmapFactory.decodeResource(getResources(),
					R.drawable.map_pointer_round);

			canvas.drawBitmap(bmp, myScreenCoords.x, myScreenCoords.y, paint);
			canvas.drawText("", myScreenCoords.x, myScreenCoords.y, paint);
			return true;
		}

		// @Override
		// public boolean onTouchEvent(MotionEvent e, MapView mapView)
		// {
		// if (e.getAction() == 1)
		// {
		// geoPoint = mapView.getProjection().fromPixels((int) e.getX(),(int)
		// e.getY());
		// latitude = geoPoint.getLatitudeE6() / 1E6;
		// longitude = geoPoint.getLongitudeE6() / 1E6;
		// String currentLocation = "Lat: " + latitude + " Lng: " + longitude;
		// Toast.makeText(getBaseContext(), geoPoint.getLatitudeE6() /
		// 1E6 + "," + geoPoint.getLongitudeE6() /1E6
		// ,Toast.LENGTH_SHORT).show();
		// }
		// return false;
		// }
	}

	private class ButtonActionListener implements OnClickListener {

		/*
		 * (non-Javadoc)
		 * 
		 * @see android.view.View.OnClickListener#onClick(android.view.View)
		 */
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == topCloseButton) {

				closeBottomDrawer();

				if (topDrawer.isOpened()) {
					openTopDrawer();
				} else {
					closeTopDrawer();
				}

			}
			
			else if (v == bottomCloseButton)
			{
				closeTopDrawer();
				
				if(bottomDrawer.isOpened())
				{
					closeBottomDrawer();
				}
				else
				{
					openBottomDrawer();
				}
			}
			else if(v == btnNotification)
			{
				Intent i = new Intent(HomeActivityOld.this, NotificationActivity.class);
				startActivity(i);				
			}
				
			
		}

	}
}
