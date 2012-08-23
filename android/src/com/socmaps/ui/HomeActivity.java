package com.socmaps.ui;

import com.readystatesoftware.maps.OnSingleTapListener;
import com.readystatesoftware.maps.TapControlledMapView;
import com.readystatesoftware.mapviewballoons.R;

import com.socmaps.widget.MultiDirectionSlidingDrawer;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.location.Address;

import android.location.Geocoder;
import android.location.Location;

import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Handler.Callback;

import android.util.Log;
import android.view.KeyEvent;

import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;

import android.view.View.OnClickListener;

import android.widget.Button;

import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.fb.*;
import com.facebook.android.FacebookError;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;

import com.socmaps.customballons.BubleTapHandle;
import com.socmaps.customballons.CustomItemizedOverlay;
import com.socmaps.customballons.CustomOverlayItem;

import com.socmaps.entity.AccountSettingsEntity;
import com.socmaps.entity.FacebookFriendEntity;
import com.socmaps.entity.OtherUserEntity;
import com.socmaps.entity.StationContent;
import com.socmaps.entity.StationInfos;
import com.socmaps.fb.FBUtility;
import com.socmaps.gps.GpsService;
import com.socmaps.gps.LocationUpdateIndicator;
import com.socmaps.ui.AccountSettingsActivity.DownloadImagesTask;
import com.socmaps.util.AppStaticStorages;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.PreferenceConnector;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;

public class HomeActivity extends MapActivity implements
		LocationUpdateIndicator, BubleTapHandle {

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

	public static Context context;
	private Resources resources;
	private TapControlledMapView mapView;
	private static Handler handler;
	private Runnable runneable;
	private GpsService gpsService;
	private List<Overlay> mapOverlays;
	private MapController mapController;

	
	private ArrayList<StationContent> stationInfoList;

	private static double myLat, myLng;

	Drawable drawable, drawableSelf;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlay;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlay2;
	ArrayList<OtherUserEntity> userList;
	private static boolean flag = false;
	
	public ImageView avatar;
	public Dialog d,msgDialog,frndRequestDialog;

	
	
	public boolean isCheckedForFacebook = false;
	private ProgressDialog m_ProgressDialog;
	private double currentLat = 0;
	private double currentLng = 0;
	String responseStringUpdateLocation = "";
	int responseStatusUpdateLocation = 0;

	String friendRequestFriendId = "";
	String friendRequestMessage = "";
	String friendRequestResponse = "";
	int friendRequestStatus = 0;

	String sendMessageFriendId = "";
	String sendMessageSubject = "";
	String sendMessageContent = "";
	String sendMessageResponse = "";
	int sendMessageStatus = 0;
	

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.home);

		initialize();

		// setStationsOnMap();
		startGpsService();

		// check for Facebook
		facebookAuthentication();
	}

	/*public void setStationsOnMap() {

		drawable = getResources().getDrawable(R.drawable.marker2);
		itemizedOverlay = new CustomItemizedOverlay<CustomOverlayItem>(
				drawable, mapView, this);

		OtherUserEntity ase = new OtherUserEntity();
		ase.setFirstName("Others");

		GeoPoint point = new GeoPoint((int) (23.790116 * 1E6),
				(int) (90.422437 * 1E6));
		CustomOverlayItem overlayItem = new CustomOverlayItem(point,
				"Tomorrow Never Dies (1997)",
				"(M gives Bond his mission in Daimler car)", ase);
		itemizedOverlay.addOverlay(overlayItem);

		GeoPoint point2 = new GeoPoint((int) (23.790666 * 1E6),
				(int) (90.415957 * 1E6));
		CustomOverlayItem overlayItem2 = new CustomOverlayItem(point2,
				"Sliding Doors (1998)", "(interiors)", ase);

		itemizedOverlay.addOverlay(overlayItem2);

		GeoPoint point3 = new GeoPoint((int) (23.790469 * 1E6),
				(int) (90.413425 * 1E6));
		CustomOverlayItem overlayItem3 = new CustomOverlayItem(point3,
				"Sliding Doors (1998)", "(interiors)", ase);
		itemizedOverlay.addOverlay(overlayItem3);

		GeoPoint point4 = new GeoPoint((int) (23.789959 * 1E6),
				(int) (90.416214 * 1E6));
		CustomOverlayItem overlayItem4 = new CustomOverlayItem(point4,
				"Mission: Impossible (1996)", "(Ethan & Jim cafe meeting)", ase);
		itemizedOverlay.addOverlay(overlayItem4);

		mapOverlays.add(itemizedOverlay);
		mapView.invalidate();
		
	}*/

	private GeoPoint getGeoPoint(double latitude, double longitude) {
		GeoPoint geoPoint;
		geoPoint = new GeoPoint((int) (latitude * 1E6), (int) (longitude * 1E6));
		return geoPoint;
	}

	public void startGpsService() {
		gpsService.StartListener();

		handler = new Handler(new Callback() {
			@Override
			public boolean handleMessage(Message msg) {
				handler.removeCallbacks(runneable);
				return false;
			}
		});
		runneable = new Runnable() {
			Message msg;
			Location location = null;

			@Override
			public void run() {
				location = gpsService.getLastLocation();
				if (location != null) {
					catchLocationUpdate(location);
					msg = new Message();
					msg.what = 1;
					handler.sendMessage(msg);
					return;
				}
				handler.postDelayed(this, 2000);
			}
		};
		handler.post(runneable);
	}

	public String getAddress(double lat, double lng) {
		String address = "";
		Geocoder geoCoder = new Geocoder(context, Locale.getDefault());
		try {
			List<Address> addresses = geoCoder.getFromLocation(lat, lng, 7);
			if (addresses.size() > 0)
				for (int j = 0; j < addresses.get(0).getMaxAddressLineIndex(); j++)
					address += addresses.get(0).getAddressLine(j) + "\n";
		} catch (IOException e) {
			e.printStackTrace();
		}
		return address.trim();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		gpsService.stopListener();
	}

	@Override
	public synchronized void catchLocationUpdate(Location location) {

		GeoPoint point = getGeoPoint(location.getLatitude(),
				location.getLongitude());

		myLat = location.getLatitude();
		myLng = location.getLongitude();
		OtherUserEntity me = new OtherUserEntity();
		me.setCurrentLat(myLat);
		me.setCurrentLng(myLng);
		me.setFirstName("Me");
		me.setWorkStatus("Explorer");
		me.setAge(26);
		me.setDistance(0);
		me.setAvatar("http://ia.media-imdb.com/images/M/MV5BMTM1MTk2ODQxNV5BMl5BanBnXkFtZTcwOTY5MDg0NA@@._V1._SX40_CR0,0,40,54_.jpg");
		if (mapOverlays.size() == 0) {
			drawableSelf = getResources().getDrawable(R.drawable.marker1);
			itemizedOverlay2 = new CustomItemizedOverlay<CustomOverlayItem>(
					drawableSelf, mapView, this);
			CustomOverlayItem overlayItem = new CustomOverlayItem(point, "",
					"", me);
			itemizedOverlay2.addOverlay(overlayItem);
			mapOverlays.add(itemizedOverlay2);
		} else {

			itemizedOverlay2 = (CustomItemizedOverlay) mapOverlays.get(0);
			itemizedOverlay2.removeItem(0);
			CustomOverlayItem overlayItem = new CustomOverlayItem(point, "",
					"", me);
			itemizedOverlay2.addOverlay(overlayItem);
			mapOverlays.add(itemizedOverlay2);
		}

		mapController.animateTo(point);
		mapView.invalidate();
		if (!flag) {

			Thread userFetchThread = new Thread(null, getUserListThread,
					"Start geting user");
			userFetchThread.start();
		}
		updateLocation(myLat, myLng);
	}

	private Runnable getUserListThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendServerRequestForGetUserList();
		}
	};

	private Runnable returnResGetUserList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleGetUserResponse(responseStatus, responseString);
		}
	};

	public void handleGetUserResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		userList.clear();
		switch (status) {
		case Constant.STATUS_SUCCESS:
			userList = ServerResponseParser.parseSearchResultPeople(response);
			updateMap();
			flag = true;
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

	private void updateMap() {
		// TODO Auto-generated method stub
		if (userList.size() > 0) {
			int i;
			drawable = getResources().getDrawable(R.drawable.marker2);
			itemizedOverlay = new CustomItemizedOverlay<CustomOverlayItem>(
					drawable, mapView, this);
			Log.i("users", userList.size() + "");
			for (i = 0; i < userList.size(); i++) {

				OtherUserEntity user = userList.get(i);
				GeoPoint point = new GeoPoint(
						(int) (user.getCurrentLat() * 1E6),
						(int) (user.getCurrentLng() * 1E6));

				// user.setAvatar("http://ia.media-imdb.com/images/M/MV5BMTM1MTk2ODQxNV5BMl5BanBnXkFtZTcwOTY5MDg0NA@@._V1._SX40_CR0,0,40,54_.jpg");
				CustomOverlayItem overlayItem = new CustomOverlayItem(point,
						"", "", user);
				itemizedOverlay.addOverlay(overlayItem);

			}

			mapOverlays.add(itemizedOverlay);
			mapView.invalidate();
		}
		// setStationsOnMap();
	}

	private void sendServerRequestForGetUserList() {
		RestClient getUserClient = new RestClient(Constant.smGetUserUrl);
		getUserClient.AddHeader(Constant.authTokenParam,
				Utility.getAuthToken(context));
		getUserClient.AddParam("lat", myLat + "");
		getUserClient.AddParam("lng", myLng + "");
		try {
			getUserClient.Execute(RestClient.RequestMethod.POST);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = getUserClient.getResponse();

		responseStatus = getUserClient.getResponseCode();

		runOnUiThread(returnResGetUserList);
	}

	public void initialize() {

		context = HomeActivity.this;
		userList = new ArrayList<OtherUserEntity>();
		resources = getResources();
		gpsService = new GpsService(context, this);
		mapView = (TapControlledMapView) findViewById(R.id.myGMap);

		mapView.setBuiltInZoomControls(false);

		// dismiss balloon upon single tap of MapView (iOS behavior)
		mapView.setOnSingleTapListener(new OnSingleTapListener() {

			public boolean onSingleTap(MotionEvent e) {
				itemizedOverlay.hideAllBalloons();
				return true;
			}
		});
		mapController = mapView.getController();
		stationInfoList = StationInfos.getStationInfoList();
		mapOverlays = mapView.getOverlays();
		mapOverlays.clear();
		// mapView.setBuiltInZoomControls(true);
		mapView.setSatellite(false);
		mapController.setZoom(16);

		buttonActionListener = new ButtonActionListener();

		// geoMapView = (MapView) findViewById(R.id.myGMap);

		topCloseButton = (Button) findViewById(R.id.topHandle);
		topCloseButton.setOnClickListener(buttonActionListener);

		bottomCloseButton = (Button) findViewById(R.id.bottomHandle);
		bottomCloseButton.setOnClickListener(buttonActionListener);

		topDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.topDrawer);
		bottomDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.bottomDrawer);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

		drawable = getResources().getDrawable(R.drawable.marker2);
		itemizedOverlay = new CustomItemizedOverlay<CustomOverlayItem>(
				drawable, mapView, this);

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

		menu.add(Menu.NONE, MENU_ITEM_SETTINGS, Menu.NONE, "Settings").setIcon(
				R.drawable.icon_settings);

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

		// initialize();
	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();

	}

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();

	}

	public void facebookAuthentication() {

		if (AppStaticStorages.accountSettingsEntity != null) {

			// if (isCheckedForFacebook == false &&
			// AppStaticStorages.accountSettingsEntity.getLogInCount() == 0) {
			if (isCheckedForFacebook == false) {
				isCheckedForFacebook = true;
				if (AppStaticStorages.accountSettingsEntity.getRegMedia()
						.equalsIgnoreCase("fb")) {
					initInviteFriends();
				} else {
					askForFacebookAccount();
				}
			}

		}

	}

	public void initInviteFriends() {
		// Log.d("Facebook", "Have to invite");

		if (Utility.isConnectionAvailble(getApplicationContext())) {

			showInvitationDialog();

			/*
			 * requestRunnable = new Runnable() { public void run() {
			 * 
			 * getFbFriendList();
			 * 
			 * } }; Thread thread = new Thread(null, requestRunnable,
			 * "MagentoBackground"); thread.start(); m_ProgressDialog =
			 * ProgressDialog.show(HomeActivity.this, "Facebook",
			 * "Please wait...", false);
			 */

		} else {
			Toast.makeText(getApplicationContext(),
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}
	}

	public void showInvitationDialog() {
		Bundle params = new Bundle();
		params.putString("message", "Checkout the app.");
		FBUtility.mFacebook.dialog(HomeActivity.this, "apprequests", params,
				new AppRequestsListener());
	}

	public void askForFacebookAccount() {
		// have to implement later
	}

	/*
	 * callback for the apprequests dialog which sends an app request to user's
	 * friends.
	 */
	public class AppRequestsListener extends BaseDialogListener {
		// @Override
		public void onComplete(Bundle values) {
			Toast toast = Toast.makeText(getApplicationContext(),
					"App request sent", Toast.LENGTH_SHORT);
			toast.show();
		}

		@Override
		public void onFacebookError(FacebookError error) {
			Toast.makeText(getApplicationContext(),
					"Facebook Error: " + error.getMessage(), Toast.LENGTH_SHORT)
					.show();
		}

		@Override
		public void onCancel() {
			Toast toast = Toast.makeText(getApplicationContext(),
					"App request cancelled", Toast.LENGTH_SHORT);
			toast.show();
		}
	}

	

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
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

			else if (v == bottomCloseButton) {
				closeTopDrawer();

				if (bottomDrawer.isOpened()) {
					closeBottomDrawer();
				} else {
					openBottomDrawer();
				}
			} else if (v == btnNotification) {
				Intent i = new Intent(HomeActivity.this,
						NotificationActivity.class);
				startActivity(i);
			}

		}

	}

	
	
	private class FetchImageTask extends AsyncTask<String, Integer, Bitmap> {
		@Override
		protected Bitmap doInBackground(String... arg0) {
			Bitmap b = null;
			try {
				b = BitmapFactory.decodeStream((InputStream) new URL(arg0[0])
						.getContent());
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			return b;
		}
	}

	@Override
	public void catchBubleTap(final CustomOverlayItem item) {
		// TODO Auto-generated method stub

		if (item.getUser().getFirstName()!=null && !item.getUser().getFirstName().equalsIgnoreCase("me")) {
			d = DialogsAndToasts.showExtendedUserInfoDialog(context);
			TextView firstName = (TextView) d
					.findViewById(R.id.first_name_text);
			String fName = item.getUser().getFirstName();
			if (fName != null && !fName.equals("")) {
				firstName.setText(fName);
			}

			TextView age = (TextView) d.findViewById(R.id.age_text);
			int ageValue = item.getUser().getAge();
			if (ageValue != 0) {
				age.setText("-Age:" + ageValue);
			}

			TextView distance = (TextView) d.findViewById(R.id.distance_text);
			int distanceValue = item.getUser().getDistance();
			distance.setText(distanceValue + "m AWAY");

			TextView street = (TextView) d.findViewById(R.id.street_text);
			String sName = item.getUser().getStreetAddress();
			if (sName != null && !sName.equals("")) {
				street.setText(sName);
			}

			TextView gender = (TextView) d.findViewById(R.id.gender_text);
			String genderValue = item.getUser().getGender();
			if (genderValue != null && !genderValue.equals("")) {
				gender.setText(":" + genderValue);
			}

			TextView relationshipSatus = (TextView) d
					.findViewById(R.id.relationship_text);
			String relationshipValue = item.getUser().getRelationshipStatus();
			if (relationshipValue != null && !relationshipValue.equals("")) {
				relationshipSatus.setText(relationshipValue);
			}

			TextView city = (TextView) d.findViewById(R.id.city_text);
			String cityValue = item.getUser().getCity();
			if (cityValue != null && !cityValue.equals("")) {
				city.setText(cityValue);
			}

			TextView work = (TextView) d.findViewById(R.id.work_text);
			String workValue = item.getUser().getWorkStatus();
			if (workValue != null && !workValue.equals("")) {
				work.setText(workValue);
			}

			avatar = (ImageView) d.findViewById(R.id.avater_image);
			String avatarUrl = item.getUser().getAvatar();
			if (avatarUrl != null && !avatarUrl.equals("")) {

				avatar.setImageResource(R.drawable.icon);
				new FetchImageTask() {
					protected void onPostExecute(Bitmap result) {
						if (result != null) {
							avatar.setImageBitmap(result);
						}
					}
				}.execute(item.getUser().getAvatar());

				// city.setText(cityValue);
			}

			Button addFrndBtn = (Button) d.findViewById(R.id.add_frnd_btn);
			Button sendMessageBtn = (Button) d.findViewById(R.id.message_btn);
			ImageView closeBtn = (ImageView) d.findViewById(R.id.close_btn);
			closeBtn.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					d.dismiss();
				}
			});

			addFrndBtn.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					showFrndRequestDialog(item);
				}
			});
			sendMessageBtn.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					// d.dismiss();
					showMessageDialog(item);
					/*Dialog msgDialog = DialogsAndToasts
							.showSendMessage(context);
					msgDialog.show();*/
				}

				
			});

			d.show();
			// Toast.makeText(context, "test", Toast.LENGTH_SHORT).show();
		}
	}
	
	
	
	private void showFrndRequestDialog(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		frndRequestDialog=DialogsAndToasts.showAddFrnd(context);
		final EditText msgEditText=(EditText)frndRequestDialog.findViewById(R.id.message_body_text);
		Button send=(Button)frndRequestDialog.findViewById(R.id.btnSend);
		Button cancel=(Button)frndRequestDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				
					sendFriendRequest(item.getUser().getSmID(), msgEditText.getText().toString().trim());
				
			}
		});
		cancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				frndRequestDialog.dismiss();	
			}
		});
		frndRequestDialog.show();
	}
	
	private void showMessageDialog(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		msgDialog=DialogsAndToasts.showSendMessage(context);
		final EditText msgEditText=(EditText)msgDialog.findViewById(R.id.message_body_text);
		Button send=(Button)msgDialog.findViewById(R.id.btnSend);
		Button cancel=(Button)msgDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if(!msgEditText.getText().toString().trim().equals(""))
				{
					sendMessage(item.getUser().getSmID(), "Message", msgEditText.getText().toString().trim());
				}
				else
				{
					msgEditText.setError("Please enter your message!!");
				}
			}
		});
		cancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
			msgDialog.dismiss();	
			}
		});
		msgDialog.show();
	}
	
	// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		public void updateLocation(double lat, double lng) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				currentLat = lat;
				currentLng = lng;

				Thread thread = new Thread(null, updateLocationThread,
						"Start update location");
				thread.start();

				// show progress dialog if needed

			} else {

				Log.e("Location update", "No internet connection available.");
			}
		}

		private Runnable updateLocationThread = new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				RestClient restClient = new RestClient(Constant.smUpdateLocationUrl);
				restClient.AddHeader(Constant.authTokenParam,
						Utility.getAuthToken(context));

				restClient.AddParam("lat", "" + currentLat);
				restClient.AddParam("lng", "" + currentLng);

				try {
					restClient.Execute(RestClient.RequestMethod.PUT);
				} catch (Exception e) {
					e.printStackTrace();
				}
				responseStringUpdateLocation = restClient.getResponse();

				responseStatusUpdateLocation = restClient.getResponseCode();

				runOnUiThread(returnResponseUpdateLocation);
			}
		};

		private Runnable returnResponseUpdateLocation = new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				 handleResponseUpdateLocation(responseStatusUpdateLocation,
				 responseStringUpdateLocation);

				// dismiss progress dialog if needed
			}

			
		};

		private void handleResponseUpdateLocation(
				int responseStatusUpdateLocation,
				String responseStringUpdateLocation) {
			// TODO Auto-generated method stub
			Log.e("Update Location", responseStatusUpdateLocation+" "+responseStringUpdateLocation);
		}
		
		public void sendFriendRequest(String friendId, String message) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				friendRequestFriendId = friendId;
				friendRequestMessage = message;

				Thread thread = new Thread(null, friendRequestThread,
						"Start send message");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog.show(context, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.sending_request_text), true);

			} else {

				DialogsAndToasts
						.showNoInternetConnectionDialog(getApplicationContext());
			}
		}

		private Runnable friendRequestThread = new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				RestClient restClient = new RestClient(Constant.smFriendRequestUrl
						+ "/" + friendRequestFriendId);
				restClient.AddHeader(Constant.authTokenParam,
						Utility.getAuthToken(context));

				restClient.AddParam("message", friendRequestMessage);

				try {
					restClient.Execute(RestClient.RequestMethod.POST);
				} catch (Exception e) {
					e.printStackTrace();
				}

				friendRequestResponse = restClient.getResponse();
				friendRequestStatus = restClient.getResponseCode();

				runOnUiThread(friendRequestReturnResponse);
			}
		};

		private Runnable friendRequestReturnResponse = new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				handleResponseFriendRequest(friendRequestStatus,
						friendRequestResponse);

				// dismiss progress dialog if needed
				m_ProgressDialog.dismiss();
			}
		};

		public void handleResponseFriendRequest(int status, String response) {
			// show proper message through Toast or Dialog
			
			Log.d("Send Frnd Request", status + ":" + response);
			switch (status) {
			case Constant.STATUS_SUCCESS:
				// Log.d("Login", status+":"+response);
				Toast.makeText(context, "Request sent successfully.", Toast.LENGTH_SHORT).show();
				frndRequestDialog.dismiss();
				break;


			default:
				Toast.makeText(getApplicationContext(),
						"An unknown error occured. Please try again!!", Toast.LENGTH_SHORT).show();
				break;

			}
		}

		
		
		
		public void sendMessage(String friendId, String subject, String content) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				sendMessageFriendId = friendId;
				sendMessageSubject = subject;
				sendMessageContent = content;
				

				Thread thread = new Thread(null, sendMessageThread,
						"Start send message");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog.show(context, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.sending_request_text), true);

			} else {

				DialogsAndToasts
						.showNoInternetConnectionDialog(getApplicationContext());
			}
		}

		private Runnable sendMessageThread = new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				RestClient restClient = new RestClient(Constant.smMessagesUrl);
				restClient.AddHeader(Constant.authTokenParam,
						Utility.getAuthToken(context));
				

				restClient.AddParam("recipients[]", sendMessageFriendId);
				restClient.AddParam("subject", sendMessageSubject);
				restClient.AddParam("content", sendMessageContent);

				try {
					restClient.Execute(RestClient.RequestMethod.POST);
				} catch (Exception e) {
					e.printStackTrace();
				}

				sendMessageResponse = restClient.getResponse();
				sendMessageStatus = restClient.getResponseCode();

				runOnUiThread(sendMessageReturnResponse);
			}
		};

		private Runnable sendMessageReturnResponse = new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				handleResponseSendMessage(sendMessageStatus, sendMessageResponse);

				// dismiss progress dialog if needed
				m_ProgressDialog.dismiss();
			}
		};

		public void handleResponseSendMessage(int status, String response) {
			// show proper message through Toast or Dialog
			Log.d("Send Message", status + ":" + response);
			switch (status) {
			case Constant.STATUS_CREATED:
				// Log.d("Login", status+":"+response);
				Toast.makeText(context, "Message sent successfully.", Toast.LENGTH_SHORT).show();
				msgDialog.dismiss();
				break;


			default:
				Toast.makeText(getApplicationContext(),
						"An unknown error occured. Please try again!!", Toast.LENGTH_SHORT).show();
				break;

			}
			
			
		}
	
	
	/*
	 * public void getFbFriendList() {
	 * 
	 * String fbReqUrl = Constant.fbFriendListUrl +
	 * AppStaticStorages.accountSettingsEntity .getFacebookAuthToken();
	 * 
	 * 
	 * Log.e("Friend List URL", fbReqUrl); RestClient client = new
	 * RestClient(fbReqUrl);
	 * 
	 * try { client.Execute(RestClient.RequestMethod.GET); } catch (Exception e)
	 * { e.printStackTrace(); }
	 * 
	 * responseStringFb = client.getResponse(); responseStatusFb =
	 * client.getResponseCode();
	 * 
	 * runOnUiThread(returnResFb);
	 * 
	 * }
	 * 
	 * private Runnable returnResFb = new Runnable() {
	 * 
	 * public void run() {
	 * 
	 * // have to do something here //
	 * Toast.makeText(getApplicationContext(),pInfo.getUserName(), //
	 * Toast.LENGTH_SHORT).show();
	 * 
	 * handleResponseFb(responseStatusFb, responseStringFb);
	 * 
	 * m_ProgressDialog.dismiss(); } };
	 * 
	 * public void handleResponseFb(int status, String response) {
	 * 
	 * // remove parseFbFriendListResponse(response);
	 * 
	 * Log.d("Login", status + ":" + response); switch (status) { case
	 * Constant.STATUS_SUCCESS: // Log.d("Login", status+":"+response);
	 * parseFbFriendListResponse(response); break;
	 * 
	 * default: Toast.makeText(getApplicationContext(),
	 * "An unknown error occured.", Toast.LENGTH_SHORT).show(); break;
	 * 
	 * } }
	 * 
	 * public void parseFbFriendListResponse(String response) { // response = //
	 * "{   \"data\": [      {         \"name\": \"Shahriar Mohammed Ferdous\",         \"id\": \"501640703\"      },      {         \"name\": \"Ameen Chowdhury\",         \"id\": \"524089177\"      },      {         \"name\": \"Sabirat Rubya Bittamoni\",         \"id\": \"525679233\"      },      {         \"name\": \"Marufa Rahmi Tasneema\",         \"id\": \"529469967\"      },      {         \"name\": \"Samiul Monir\",         \"id\": \"531488824\"      },      {         \"name\": \"Moshlehuddin Mazumder\",         \"id\": \"532037478\"      },      {         \"name\": \"Partho Biswas\",         \"id\": \"1782404717\"      },      {         \"name\": \"Rakib U Shimul\",         \"id\": \"1789248965\"      },      {         \"name\": \"Mahbub Alam\",         \"id\": \"1840713486\"      },      {         \"name\": \"Dinesh Kumar Yadav\",         \"id\": \"100000004361699\"      }   ],   \"paging\": {      \"next\": \"https://graph.facebook.com/532013246/friends?access_token=AAAAAAITEghMBAMZCv6cm9E3Rww2OpjrTN8PAofNytSzoVWmV6Pvq8gcDfvl4SZBqbHCnZAYL9Rj4QAarMk4OtkIECmgkLrmjZA9QGMEKpgZDZD&limit=5000&offset=5000&__after_id=100004050156512\"   }}"
	 * ;
	 * 
	 * try { JSONObject jObj = new JSONObject(response);
	 * 
	 * JSONArray jArray = jObj.getJSONArray("data");
	 * 
	 * FacebookFriendEntity[] fbFriendEntityArrayList = new
	 * FacebookFriendEntity[jArray .length()];
	 * 
	 * for (int i = 0; i < jArray.length(); i++) { JSONObject itemObj =
	 * jArray.getJSONObject(i);
	 * 
	 * String friendId = itemObj.getString("id"); String friendName =
	 * itemObj.getString("name"); String profilePic =
	 * "http://graph.facebook.com/" + friendId + "/picture";
	 * 
	 * fbFriendEntityArrayList[i] = new FacebookFriendEntity();
	 * 
	 * fbFriendEntityArrayList[i].setId(friendId);
	 * fbFriendEntityArrayList[i].setName(friendName);
	 * fbFriendEntityArrayList[i].setProfilePic(profilePic);
	 * 
	 * // Log.d(friendId, friendName); }
	 * 
	 * showInvitationDialog(fbFriendEntityArrayList);
	 * 
	 * } catch (JSONException e) {
	 * 
	 * }
	 * 
	 * }
	 * 
	 * public void showInvitationDialog( FacebookFriendEntity[]
	 * fbFriendEntityArrayList) {
	 * 
	 * if (!inviteFbFriendsDialog.isShowing()) { // custom dialog
	 * inviteFbFriendsDialog = new Dialog(HomeActivity.this,
	 * R.style.CustomDialogTheme); inviteFbFriendsDialog
	 * .setContentView(R.layout.facebook_invite_friends);
	 * 
	 * LinearLayout friendListContainer = (LinearLayout) inviteFbFriendsDialog
	 * .findViewById(R.id.friend_list_container); LayoutInflater inflater =
	 * (LayoutInflater) context
	 * .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	 * 
	 * friendListContainer.removeAllViews(); for (int i = 0; i <
	 * fbFriendEntityArrayList.length; i++) { View v =
	 * inflater.inflate(R.layout.facebook_invite_item_row, null);
	 * 
	 * final ImageView profilePic = (ImageView) v
	 * .findViewById(R.id.profilePic); TextView friendName = (TextView) v
	 * .findViewById(R.id.friendName); CheckBox chkInviteFriend = (CheckBox) v
	 * .findViewById(R.id.chkInviteFriend);
	 * 
	 * friendName.setText(fbFriendEntityArrayList[i].getName());
	 * 
	 * profilePic.setImageResource(R.drawable.icon);
	 * 
	 * 
	 * 
	 * friendListContainer.addView(v); }
	 * 
	 * Button btnCancel = (Button) inviteFbFriendsDialog
	 * .findViewById(R.id.btnCancel); // if button is clicked, close the custom
	 * dialog btnCancel.setOnClickListener(new OnClickListener() { public void
	 * onClick(View v) { Log.e("InviteDialog", "Dismissed");
	 * inviteFbFriendsDialog.dismiss(); } });
	 * 
	 * Button btnInvite = (Button) inviteFbFriendsDialog
	 * .findViewById(R.id.btnInvite); // if button is clicked, close the custom
	 * dialog btnInvite.setOnClickListener(new OnClickListener() { public void
	 * onClick(View v) {
	 * 
	 * } });
	 * 
	 * inviteFbFriendsDialog.show(); }
	 * 
	 * }
	 */
}
