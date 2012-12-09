package com.socmaps.ui;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PixelFormat;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Debug;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
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
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.google.android.gcm.GCMRegistrar;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.readystatesoftware.maps.OnSingleTapListener;
import com.readystatesoftware.maps.TapControlledMapView;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.customballons.BubleTapHandle;
import com.socmaps.customballons.CustomItemizedOverlay;
import com.socmaps.customballons.CustomOverlayItem;
import com.socmaps.entity.CirclesAndFriends;
import com.socmaps.entity.Event;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.MyGeoPoint;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.Plan;
import com.socmaps.entity.PushData;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.fb.BaseDialogListener;
import com.socmaps.fb.FBUtility;
import com.socmaps.fb.SessionEvents;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;
import com.socmaps.gps.GpsService;
import com.socmaps.gps.ILocationUpdateIndicator;
import com.socmaps.images.ImageDownloader;
import com.socmaps.notificationBroadcast.BroadcastListener;
import com.socmaps.notificationBroadcast.BroadcastService;
import com.socmaps.notificationBroadcast.NotificationCountBroadcastReciever;
import com.socmaps.pushNotification.CommonUtilities;
import com.socmaps.pushNotification.ServerUtilities;
import com.socmaps.util.Constant;
import com.socmaps.util.Constant.Permission;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.MultiDirectionSlidingDrawer;
import com.socmaps.widget.PeoplePicker;
import com.socmaps.widget.PeoplePickerListener;
import com.socmaps.widget.PermissionRadioGroup;
import com.socmaps.widget.PermissionRadioGroupLess;
import com.socmaps.widget.PermissionRadioGroupListener;

public class HomeActivity extends MapActivity implements
		ILocationUpdateIndicator, BubleTapHandle, OnCheckedChangeListener,
		OnClickListener {

	private NotificationCountBroadcastReciever broadcastReceiver;
	// private Intent countServiceIntent;
	private final int MENU_ITEM_PEOPLE = Menu.FIRST + 1;
	private final int MENU_ITEM_PROFILE = Menu.FIRST + 2;
	private final int MENU_ITEM_DEAL = Menu.FIRST + 3;
	private final int MENU_ITEM_VENUE = Menu.FIRST + 4;
	private final int MENU_ITEM_SETTINGS = Menu.FIRST + 5;
	private final int MENU_ITEM_LOGOUT = Menu.FIRST + 6;
	private final int MENU_ITEM_MESSAGE = Menu.FIRST + 7;
	private final int MENU_ITEM_EVENT = Menu.FIRST + 8;
	private final int MENU_ITEM_MEETUP = Menu.FIRST + 9;

	Button btnNotification;
	Button topCloseButton, bottomCloseButton;
	// Button mOpenButton;
	MultiDirectionSlidingDrawer topDrawer, bottomDrawer;

	TopDrawerListener topDrawerListener;
	BottomDrawerListener bottomDrawerListener;

	public Context context;
	private TapControlledMapView mapView;
	private static Handler handler;
	private Runnable runneable;
	private GpsService gpsService;
	private List<Overlay> mapOverlays;

	private LinearLayout btnEvent, btnMeetup;

	private MapController mapController;

	private double myLat, myLng;

	// Drawable drawable, drawableSelf, drawablePlace, drawableSecondDegree;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlayOtherPeople;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlaySecondDegreePeople;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlayEvent;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlayGeotag;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlaySelf;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlayPlace;

	// private static boolean flag = false;

	public ImageView avatar, placeIconImage;
	public Dialog d, msgDialog, frndRequestDialog;

	private ProgressDialog m_ProgressDialog;

	String responseStringUpdateLocation;
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
	AsyncTask<Void, Void, Void> mRegisterTask;

	private CheckBox peopleCheckBox, placeCheckBox, eventCheckBox,
			dealCheckBox;
	private Button btnListView, btnMapView, btnCircle;
	private Button btnUpdateLocation, btnCircleMenu;

	MyGeoPoint point;
	boolean isFirstLocationUpdate = true;
	boolean isLocationFound = false;

	public List<String> friendRequestSentList = new ArrayList<String>();
	public Dialog currentBubbleDialog;

	PermissionRadioGroupLess permissionRadioGroupView;
	LinearLayout shareWithRadioGroupContainer;
	Permission locationSharingPermission;
	String shareWithPickerName = "sharewith";
	ShareWithSelectionListener shareWithSelectionListener;

	// List<String> shareWithSelectedFriendList;
	// List<String> shareWithSelectedCircleList;
	// List<String> shareWithSelectedCircleFriendList;
	// List<String> shareWithSelectedFriendListAll;

	RelativeLayout circleMenu;
	LinearLayout btnCloseCircleMenu;

	Button btnCircleMenuItemPeople, btnCircleMenuItemProfile,
			btnCircleMenuItemMessages, btnCircleMenuItemFriends,
			btnCircleMenuItemDeals, btnCircleMenuItemPlaces,
			btnCircleMenuItemNewsfeed, btnCircleMenuItemSettings;

	Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	RelativeLayout searchPanel;
	EditText etSearchField;

	boolean isSearchEnabled = false;

	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;

	int responseEventStatus = 0;
	String responseEventString;

	int responseGeotagStatus = 0;
	String responseGeotagString;

	List<Event> eventList;
	List<GeoTag> geotagList;

	ImageDownloader imageDownloader;
	Dialog isFirstTimeFbdialog;
	Button btnFBLogin;

	FbAPIsAuthListener fbAPIsAuthListener;
	FbAPIsLogoutListener fbAPIsLogoutListener;
	SessionEvents sessionEvents;

	TimerTask task;
	Timer timer;
	boolean isRunning = true;
	long updateInterval = 60000; // 1 min

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.home_layout);

		initialize();

		setCheckBoxSelection();
		setOnCheckChangeListener();

		addPermissionRadioGroup();

		try {
			registerPushNotification();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO: handle exception
		}

		facebookAuthentication();

		handleNavigationFromNotificationBar(getIntent());
		initializeNotificationBroadcast();

	}

	/*
	 * private void setDefaultNotificationValue() { // TODO Auto-generated
	 * method stub if (StaticValues.myInfo != null && btnNotification !=null) {
	 * btnNotification.setText("" + StaticValues.myInfo.getNotificationCount()
	 * .getTotalCount()); } }
	 */

	public void initialize() {

		context = HomeActivity.this;
		gpsService = new GpsService(context, this);
		mapView = (TapControlledMapView) findViewById(R.id.myGMap);

		// imageDownloader = new ImageDownloader();
		// imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
		imageDownloader = ImageDownloader.getInstance();

		mapView.setBuiltInZoomControls(false);

		// dismiss balloon upon single tap of MapView (iOS behavior)
		mapView.setOnSingleTapListener(new OnSingleTapListener() {

			@Override
			public boolean onSingleTap(MotionEvent e) {
				itemizedOverlayOtherPeople.hideAllBalloons();
				return true;
			}
		});
		mapController = mapView.getController();
		mapOverlays = mapView.getOverlays();

		mapOverlays.clear();

		Drawable drawableSelf = getResources().getDrawable(
				R.drawable.self_marker);
		itemizedOverlaySelf = new CustomItemizedOverlay<CustomOverlayItem>(
				drawableSelf, mapView, this, Constant.FLAG_SELF,
				imageDownloader);
		itemizedOverlaySelf.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlaySelf);

		Drawable drawable = getResources().getDrawable(R.drawable.user_marker);
		itemizedOverlayOtherPeople = new CustomItemizedOverlay<CustomOverlayItem>(
				drawable, mapView, this, Constant.FLAG_PEOPLE, imageDownloader);
		itemizedOverlayOtherPeople.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlayOtherPeople);

		Drawable drawablePlace = getResources().getDrawable(
				R.drawable.place_marker);
		itemizedOverlayPlace = new CustomItemizedOverlay<CustomOverlayItem>(
				drawablePlace, mapView, this, Constant.FLAG_PLACE,
				imageDownloader);
		itemizedOverlayPlace.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlayPlace);

		Drawable drawableSecondDegree = getResources().getDrawable(
				R.drawable.map_marker_fb);
		itemizedOverlaySecondDegreePeople = new CustomItemizedOverlay<CustomOverlayItem>(
				drawableSecondDegree, mapView, this,
				Constant.FLAG_SECOND_DEGREE, imageDownloader);
		itemizedOverlaySecondDegreePeople.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlaySecondDegreePeople);

		Drawable drawableEvent = getResources().getDrawable(
				R.drawable.marker_event);
		itemizedOverlayEvent = new CustomItemizedOverlay<CustomOverlayItem>(
				drawableEvent, mapView, this, Constant.FLAG_EVENT,
				imageDownloader);
		itemizedOverlayEvent.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlayEvent);

		Drawable drawableGeotag = getResources().getDrawable(
				R.drawable.marker_geotag);
		itemizedOverlayGeotag = new CustomItemizedOverlay<CustomOverlayItem>(
				drawableGeotag, mapView, this, Constant.FLAG_GEOTAG,
				imageDownloader);
		itemizedOverlayGeotag.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlayGeotag);

		// mapView.setBuiltInZoomControls(true);

		mapView.setSatellite(false);
		mapController.setZoom(16);

		topDrawerListener = new TopDrawerListener();
		bottomDrawerListener = new BottomDrawerListener();
		shareWithSelectionListener = new ShareWithSelectionListener();

		// geoMapView = (MapView) findViewById(R.id.myGMap);

		topDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.topDrawer);
		topDrawer.setOnDrawerOpenListener(topDrawerListener);
		topDrawer.setOnDrawerCloseListener(topDrawerListener);

		bottomDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.bottomDrawer);
		bottomDrawer.setOnDrawerOpenListener(bottomDrawerListener);
		bottomDrawer.setOnDrawerCloseListener(bottomDrawerListener);

		View vTop = topDrawer.findViewById(R.id.topSliderContent);
		peopleCheckBox = (CheckBox) vTop.findViewById(R.id.chkMenuItemPeople);
		placeCheckBox = (CheckBox) vTop.findViewById(R.id.chkMenuItemPlaces);
		eventCheckBox = (CheckBox) vTop.findViewById(R.id.chkMenuItemEvents);
		dealCheckBox = (CheckBox) vTop.findViewById(R.id.chkMenuItemDeals);

		btnEvent = (LinearLayout) vTop.findViewById(R.id.event_btn);
		btnEvent.setOnClickListener(this);

		btnMeetup = (LinearLayout) vTop.findViewById(R.id.meetup_button);
		btnMeetup.setOnClickListener(this);

		shareWithRadioGroupContainer = (LinearLayout) vTop
				.findViewById(R.id.shareWithRadioGroupContainer);

		View vBottom = bottomDrawer.findViewById(R.id.bottomContent);

		btnMapView = (Button) vBottom.findViewById(R.id.btnMapView);
		btnMapView.setBackgroundDrawable(getResources().getDrawable(
				R.drawable.icon_map_view_selected));

		btnListView = (Button) vBottom.findViewById(R.id.btnListView);
		btnListView.setOnClickListener(this);

		btnCircle = (Button) vBottom.findViewById(R.id.btnCircle);
		btnCircle.setOnClickListener(this);

		topCloseButton = (Button) topDrawer.findViewById(R.id.topHandle);
		bottomCloseButton = (Button) bottomDrawer
				.findViewById(R.id.bottomHandle);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		btnUpdateLocation = (Button) findViewById(R.id.btnUpdateLocation);
		btnUpdateLocation.setOnClickListener(this);

		btnCircleMenu = (Button) findViewById(R.id.btnCircleMenu);
		btnCircleMenu.setOnClickListener(this);

		circleMenu = (RelativeLayout) findViewById(R.id.circleMenu);
		circleMenu.setOnClickListener(this);

		btnCloseCircleMenu = (LinearLayout) circleMenu
				.findViewById(R.id.btnCloseCircleMenu);
		btnCloseCircleMenu.setOnClickListener(this);

		btnCircleMenuItemPeople = (Button) findViewById(R.id.btnCircleMenuItemPeople);
		btnCircleMenuItemPeople.setOnClickListener(this);
		btnCircleMenuItemProfile = (Button) findViewById(R.id.btnCircleMenuItemProfile);
		btnCircleMenuItemProfile.setOnClickListener(this);
		btnCircleMenuItemMessages = (Button) findViewById(R.id.btnCircleMenuItemMessages);
		btnCircleMenuItemMessages.setOnClickListener(this);
		btnCircleMenuItemFriends = (Button) findViewById(R.id.btnCircleMenuItemFriends);
		btnCircleMenuItemFriends.setOnClickListener(this);
		btnCircleMenuItemDeals = (Button) findViewById(R.id.btnCircleMenuItemDeals);
		btnCircleMenuItemDeals.setOnClickListener(this);
		btnCircleMenuItemPlaces = (Button) findViewById(R.id.btnCircleMenuItemPlaces);
		btnCircleMenuItemPlaces.setOnClickListener(this);
		btnCircleMenuItemNewsfeed = (Button) findViewById(R.id.btnCircleMenuItemNewsfeed);
		btnCircleMenuItemNewsfeed.setOnClickListener(this);
		btnCircleMenuItemSettings = (Button) findViewById(R.id.btnCircleMenuItemSettings);
		btnCircleMenuItemSettings.setOnClickListener(this);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);

		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();

		fbAPIsAuthListener = new FbAPIsAuthListener();
		fbAPIsLogoutListener = new FbAPIsLogoutListener();
		sessionEvents = new SessionEvents();

	}

	public void getMapDataFromServer() {
		// sendSelfLocationToServer();
		getSearchResult();
		getEventList();
		getGeotagList();
	}

	public void initTimeTask() {
		task = new TimerTask() {
			public void run() {
				if (isLocationFound && isRunning) {
					getMapDataFromServer();
				}
			}
		};
		timer = new Timer();
		timer.schedule(task, 500, updateInterval);
	}

	/*
	 * private final BroadcastReceiver mHandleMessageReceiver = new
	 * BroadcastReceiver() {
	 * 
	 * @Override public void onReceive(Context context, Intent intent) {
	 * 
	 * PushData pushData = (PushData)intent.getSerializableExtra("intent");
	 * 
	 * //String newMessage = intent.getExtras().getString(EXTRA_MESSAGE);
	 * Log.e("GCM: HOME", pushData.getMessage()); } };
	 */

	private void checkNotNull(Object reference, String name) {
		if (reference == null) {
			throw new NullPointerException(getString(R.string.error_config,
					name));
		}
	}

	/*
	 * private void registerPushNotification() { // TODO Auto-generated method
	 * stub checkNotNull(CommonUtilities.SERVER_URL, "SERVER_URL");
	 * checkNotNull(CommonUtilities.SENDER_ID, "SENDER_ID"); // Make sure the
	 * device has the proper dependencies. GCMRegistrar.checkDevice(this); //
	 * Make sure the manifest was properly set - comment out this line // while
	 * developing the app, then uncomment it when it's ready.
	 * GCMRegistrar.checkManifest(this);
	 * 
	 * // registerReceiver(mHandleMessageReceiver, new //
	 * IntentFilter(DISPLAY_MESSAGE_ACTION)); final String regId =
	 * GCMRegistrar.getRegistrationId(this); if (regId.equals("")) { //
	 * Automatically registers application on startup.
	 * GCMRegistrar.register(getApplicationContext(),
	 * CommonUtilities.SENDER_ID); } else { // Device is already registered on
	 * GCM, check server. if (GCMRegistrar.isRegisteredOnServer(this)) { //
	 * Skips registration. //
	 * mDisplay.append(getString(R.string.already_registered) + // "\n");
	 * Log.e("GCM", getString(R.string.already_registered)); } else { // Try to
	 * register again, but not in the UI thread. // It's also necessary to
	 * cancel the thread onDestroy(), // hence the use of AsyncTask instead of a
	 * raw thread. final Context context = this; mRegisterTask = new
	 * AsyncTask<Void, Void, Void>() {
	 * 
	 * @Override protected Void doInBackground(Void... params) { boolean
	 * registered = ServerUtilities.register(context, regId); // At this point
	 * all attempts to register with the app // server failed, so we need to
	 * unregister the device // from GCM - the app will try to register again
	 * when // it is restarted. Note that GCM will send an // unregistered
	 * callback upon completion, but // GCMIntentService.onUnregistered() will
	 * ignore it. if (!registered) { GCMRegistrar.unregister(context); } return
	 * null; }
	 * 
	 * @Override protected void onPostExecute(Void result) { mRegisterTask =
	 * null; }
	 * 
	 * }; mRegisterTask.execute(null, null, null); } } }
	 */

	private void registerPushNotification() throws IOException {
		// TODO Auto-generated method stub
		checkNotNull(CommonUtilities.SERVER_URL, "SERVER_URL");
		checkNotNull(CommonUtilities.SENDER_ID, "SENDER_ID");
		// Make sure the device has the proper dependencies.
		GCMRegistrar.checkDevice(this);
		// Make sure the manifest was properly set - comment out this line
		// while developing the app, then uncomment it when it's ready.
		GCMRegistrar.checkManifest(this);

		// registerReceiver(mHandleMessageReceiver, new
		// IntentFilter(DISPLAY_MESSAGE_ACTION));
		final String regId = GCMRegistrar.getRegistrationId(this);

		boolean forceRegister = true;

		Log.i("GCM RegID", "inside registerPushNotification");

		if (regId == null || regId.equals("")) {
			Log.i("GCM RegID", "regId is null");
			// Automatically registers application on startup.
			GCMRegistrar.register(getApplicationContext(),
					CommonUtilities.SENDER_ID);
		} else {
			registerDeviceOnServer(regId);
			/*
			 * // Device is already registered on GCM, check server. if
			 * (GCMRegistrar.isRegisteredOnServer(this)) { // Skips
			 * registration. //
			 * mDisplay.append(getString(R.string.already_registered) + //
			 * "\n"); Log.e("GCM", getString(R.string.already_registered)); }
			 * else { // Try to register again, but not in the UI thread. //
			 * It's also necessary to cancel the thread onDestroy(), // hence
			 * the use of AsyncTask instead of a raw thread.
			 * 
			 * registerDeviceOnServer(regId); }
			 */
		}

	}

	private void registerDeviceOnServer(final String regId) {
		// TODO Auto-generated method stub

		Log.i("GCM RegId", regId);
		final Context context = this;
		mRegisterTask = new AsyncTask<Void, Void, Void>() {

			@Override
			protected Void doInBackground(Void... params) {
				boolean registered = ServerUtilities.register(context, regId);
				// At this point all attempts to register with the app
				// server failed, so we need to unregister the device
				// from GCM - the app will try to register again when
				// it is restarted. Note that GCM will send an
				// unregistered callback upon completion, but
				// GCMIntentService.onUnregistered() will ignore it.
				if (!registered) {
					GCMRegistrar.unregister(context);
				}
				return null;
			}

			@Override
			protected void onPostExecute(Void result) {
				mRegisterTask = null;
			}

		};
		mRegisterTask.execute(null, null, null);
	}

	/*
	 * private void registerPushNotification() throws IOException {
	 * 
	 * checkNotNull(CommonUtilities.SERVER_URL, "SERVER_URL");
	 * checkNotNull(CommonUtilities.SENDER_ID, "SENDER_ID");
	 * 
	 * GCMRegistrar.checkDevice(this);
	 * 
	 * GCMRegistrar.checkManifest(this);
	 * 
	 * 
	 * final String regId = GCMRegistrar.getRegistrationId(this);
	 * 
	 * boolean forceRegister = true; Log.i("GCM REG_ID", regId+"");
	 * 
	 * if(regId==null || regId.equals("")) { try {
	 * GCMRegistrar.register(getApplicationContext(),
	 * CommonUtilities.SENDER_ID);
	 * 
	 * } catch (Exception e) {
	 * 
	 * } }
	 * 
	 * Log.i("GCM REG_ID", regId); if (regId != null) { final Context context =
	 * this; mRegisterTask = new AsyncTask<Void, Void, Void>() {
	 * 
	 * @Override protected Void doInBackground(Void... params) { boolean
	 * registered = ServerUtilities.register(context, regId);
	 * 
	 * if (!registered) { GCMRegistrar.unregister(context); } return null; }
	 * 
	 * @Override protected void onPostExecute(Void result) { mRegisterTask =
	 * null; }
	 * 
	 * }; mRegisterTask.execute(null, null, null);
	 * 
	 * }
	 * 
	 * 
	 * }
	 */

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

	@Override
	protected void onDestroy() {
		if (mRegisterTask != null) {
			mRegisterTask.cancel(true);
		}
		// stopService(countServiceIntent);// delete this line for production

		try {
			unregisterReceiver(broadcastReceiver);
		} catch (IllegalArgumentException e) {

		} catch (Exception e) {
			// TODO: handle exception
		}

		GCMRegistrar.onDestroy(getApplicationContext());

		SessionEvents.removeAuthListener(fbAPIsAuthListener);
		SessionEvents.removeLogoutListener(fbAPIsLogoutListener);

		System.gc();

		super.onDestroy();
	}

	@Override
	public synchronized void catchLocationUpdate(Location location) {

		isLocationFound = true;
		point = ServerResponseParser.getGeoPointByLatLong(
				location.getLatitude(), location.getLongitude());
		StaticValues.myPoint = point;
		myLat = location.getLatitude();
		myLng = location.getLongitude();

		// isFirstLocationUpdate = true;

		Log.e("Size mapoverlay self", mapOverlays.size() + "");

		itemizedOverlaySelf = (CustomItemizedOverlay) mapOverlays.get(0);

		itemizedOverlaySelf.removeAllItem();
		CustomOverlayItem overlayItem = new CustomOverlayItem(point, "self",
				"", StaticValues.myInfo);
		itemizedOverlaySelf.addOverlay(overlayItem);
		// mapOverlays.add(itemizedOverlay2);
		// }

		if (isFirstLocationUpdate) {
			relocationCurrentPosition();
			isFirstLocationUpdate = false;

			initTimeTask();
		}
		mapView.invalidate();

		sendSelfLocationToServer();

		// make them periodic
		// getSearchResult();
		// getEventList();
		// getGeotagList();

	}

	public void getSearchResult() {
		Thread userFetchThread = new Thread(null, getSearchResultThread,
				"Start geting searchResult");
		userFetchThread.start();
	}

	private Runnable getSearchResultThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendServerRequestToGetSearchResult();
		}
	};

	private void sendServerRequestToGetSearchResult() {
		RestClient restClient = new RestClient(Constant.smGetUserUrl);
		restClient.AddHeader(Constant.authTokenParam,
				Utility.getAuthToken(context));
		restClient.AddParam("lat", myLat + "");
		restClient.AddParam("lng", myLng + "");
		try {
			restClient.Execute(RestClient.RequestMethod.POST);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = restClient.getResponse();

		responseStatus = restClient.getResponseCode();

		runOnUiThread(returnResGetSearchResult);
	}

	private Runnable returnResGetSearchResult = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleGetSearchResultResponse(responseStatus, responseString);
			// responseString = null;
		}
	};

	public void handleGetSearchResultResponse(int status, String response) {
		Log.d("Get Search result", status + ":" + response);
		// userList.clear();
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// userList =
			// ServerResponseParser.parseSearchResultPeople(response);
			StaticValues.searchResult = ServerResponseParser
					.parseSeachResult(response);
			populateMasterList();

			if (isSearchEnabled == false) {

				Log.e("UpdateMap", "Inside it");
				updateContentList(listMasterContent);
				updateMapDisplay(listContent);
			}

			// flag = true;
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
			// Toast.makeText(getApplicationContext(),"An unknown error occured.",
			// Toast.LENGTH_LONG).show();
			break;

		}
	}

	public void getGeotagList() {
		Thread userFetchThread = new Thread(null, getGeotagListThread,
				"Start geting geotag list");
		userFetchThread.start();
	}

	private Runnable getGeotagListThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendServerRequestToGetGeotagList();
		}
	};

	private void sendServerRequestToGetGeotagList() {
		RestClient restClient = new RestClient(Constant.smGeoTag);
		restClient.AddHeader(Constant.authTokenParam,
				Utility.getAuthToken(context));

		try {
			restClient.Execute(RestClient.RequestMethod.GET);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseGeotagString = restClient.getResponse();

		responseGeotagStatus = restClient.getResponseCode();

		runOnUiThread(returnResGetGeotagList);
	}

	private Runnable returnResGetGeotagList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleGetGeotagListResponse(responseGeotagStatus,
					responseGeotagString);
			responseGeotagString = null;
		}
	};

	public void handleGetGeotagListResponse(int status, String response) {
		// Log.d("Get Search result", status + ":" + response);
		// userList.clear();
		switch (status) {
		case Constant.STATUS_SUCCESS:

			geotagList = ServerResponseParser.parseGeotags(response);

			populateMasterList();

			if (isSearchEnabled == false) {

				updateContentList(listMasterContent);
				updateMapDisplay(listContent);
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
			// Toast.makeText(getApplicationContext(),"An unknown error occured.",
			// Toast.LENGTH_LONG).show();
			break;

		}
	}

	public void getEventList() {
		Thread userFetchThread = new Thread(null, getEventListThread,
				"Start geting event list");
		userFetchThread.start();
	}

	private Runnable getEventListThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendServerRequestToGetEventList();
		}
	};

	private void sendServerRequestToGetEventList() {
		RestClient getUserClient = new RestClient(Constant.smEventUrl);
		getUserClient.AddHeader(Constant.authTokenParam,
				Utility.getAuthToken(context));

		try {
			getUserClient.Execute(RestClient.RequestMethod.GET);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseEventString = getUserClient.getResponse();

		responseEventStatus = getUserClient.getResponseCode();

		runOnUiThread(returnResGetEventList);
	}

	private Runnable returnResGetEventList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleGetEventListResponse(responseEventStatus, responseEventString);
		}
	};

	public void handleGetEventListResponse(int status, String response) {
		// Log.d("Get Search result", status + ":" + response);
		// userList.clear();
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// userList =
			// ServerResponseParser.parseSearchResultPeople(response);
			eventList = ServerResponseParser.parseGetEventListResult(response);

			populateMasterList();

			if (isSearchEnabled == false) {

				Log.e("UpdateEventMap", "Inside it");
				updateContentList(listMasterContent);
				updateMapDisplay(listContent);
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
			// Toast.makeText(getApplicationContext(),"An unknown error occured.",
			// Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void populateMasterList() {
		listMasterContent.clear();

		if (StaticValues.searchResult != null) {
			addPeoplesToMasterList();
			addPlacesToMasterList();
			addFacebbokPeoplesToMasterList();
		}

		if (eventList != null) {
			addEventsToMasterList();
		}

		if (geotagList != null) {
			addGeotagsToMasterList();
		}

		/*
		 * if (listMasterContent.size() > 0) { sortMasterListData(); }
		 */

	}

	private void addPlacesToMasterList() {
		if (StaticValues.searchResult.getPlaces() != null) {
			for (int i = 0; i < StaticValues.searchResult.getPlaces().size(); i++) {
				listMasterContent.add(StaticValues.searchResult.getPlaces()
						.get(i));
			}
		}

	}

	private void addPeoplesToMasterList() {
		if (StaticValues.searchResult.getPeoples() != null) {
			for (int i = 0; i < StaticValues.searchResult.getPeoples().size(); i++) {
				listMasterContent.add(StaticValues.searchResult.getPeoples()
						.get(i));
			}
		}

	}

	private void addFacebbokPeoplesToMasterList() {
		if (StaticValues.searchResult.getSecondDegreePeoples() != null) {
			for (int i = 0; i < StaticValues.searchResult
					.getSecondDegreePeoples().size(); i++) {
				listMasterContent.add(StaticValues.searchResult
						.getSecondDegreePeoples().get(i));
			}
		}

	}

	private void addEventsToMasterList() {
		for (int i = 0; i < eventList.size(); i++) {
			listMasterContent.add(eventList.get(i));
		}
	}

	private void addGeotagsToMasterList() {
		for (int i = 0; i < geotagList.size(); i++) {
			listMasterContent.add(geotagList.get(i));
		}
	}

	/*
	 * private void sortMasterListData() {
	 * Collections.sort(this.listMasterContent, new ListComparator()); }
	 * 
	 * class ListComparator implements Comparator<Object> {
	 * 
	 * @Override public int compare(Object first, Object last) { double
	 * firstDistance = getDistance(first); double lastDistance =
	 * getDistance(last);
	 * 
	 * if (firstDistance > lastDistance) return 1; else if (firstDistance ==
	 * lastDistance) return 0; else return -1; }
	 * 
	 * private double getDistance(Object object) { if (object instanceof People)
	 * return ((People) object).getDistance(); else if (object instanceof Place)
	 * return ((Place) object).getDistance(); else if (object instanceof
	 * SecondDegreePeople) return ((SecondDegreePeople) object).getDistance();
	 * else if (object instanceof Event) return ((Event) object).getDistance();
	 * else return 0; }
	 * 
	 * }
	 */

	public void updateContentList(List<Object> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	public void clearMap(int index, boolean all) {
		if (all) {
			removeAllItemFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(1));
			removeAllItemFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(2));
			removeAllItemFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(3));
			removeAllItemFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(4));
			removeAllItemFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(5));
		} else {
			removeAllItemFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(index));
		}

	}

	public void hideBallons(int index, boolean all) {
		if (all) {

			hideAllBallonsFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(1));
			hideAllBallonsFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(2));
			hideAllBallonsFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(3));
			hideAllBallonsFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(4));
			hideAllBallonsFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(5));
		} else {
			hideAllBallonsFromItemizedOverlay((CustomItemizedOverlay) mapOverlays
					.get(index));
		}

	}

	public void updateMapDisplay(List<Object> list) {

		CustomOverlayItem focusedItemPeople = itemizedOverlayOtherPeople
				.getFocus();
		CustomOverlayItem focusedItemPlace = itemizedOverlayPlace.getFocus();

		CustomOverlayItem focusedItemSecondDegreePeople = itemizedOverlaySecondDegreePeople
				.getFocus();

		CustomOverlayItem focusedItemEvent = itemizedOverlayEvent.getFocus();
		CustomOverlayItem focusedItemGeotag = itemizedOverlayGeotag.getFocus();

		clearMap(0, true);
		listDisplayableContent.clear();

		int displayedItemCounter = 0;
		Object onlyItem = null;

		for (int i = 0; i < list.size(); i++) {

			Object item = list.get(i);
			if (item instanceof People
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PEOPLE, true)) {
				listDisplayableContent.add(item);

				People user = (People) item;
				onlyItem = item;

				GeoPoint geoPoint = new GeoPoint(
						(int) (user.getCurrentLat() * 1E6),
						(int) (user.getCurrentLng() * 1E6));

				CustomOverlayItem overlayItem = new CustomOverlayItem(geoPoint,
						"", "", user);
				itemizedOverlayOtherPeople.addOverlay(overlayItem);

				displayedItemCounter++;

			} else if (item instanceof Place
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PLACE, false)) {
				listDisplayableContent.add(item);

				Place place = (Place) item;
				onlyItem = item;

				GeoPoint geoPoint = new GeoPoint(
						(int) (place.getLatitude() * 1E6),
						(int) (place.getLongitude() * 1E6));

				CustomOverlayItem overlayItem = new CustomOverlayItem(geoPoint,
						"", "", place);
				itemizedOverlayPlace.addOverlay(overlayItem);

				displayedItemCounter++;
			} else if (item instanceof SecondDegreePeople
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PEOPLE, true)) {
				listDisplayableContent.add(item);

				SecondDegreePeople user = (SecondDegreePeople) item;
				onlyItem = item;

				GeoPoint geoPoint = new GeoPoint(
						(int) (user.getCurrentLat() * 1E6),
						(int) (user.getCurrentLng() * 1E6));

				CustomOverlayItem overlayItem = new CustomOverlayItem(geoPoint,
						"", "", user);
				itemizedOverlaySecondDegreePeople.addOverlay(overlayItem);

				displayedItemCounter++;

			} else if (item instanceof Event
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.EVENT, false)) {
				listDisplayableContent.add(item);

				Event event = (Event) item;
				onlyItem = item;

				GeoPoint geoPoint = new GeoPoint(
						(int) (event.getLatitude() * 1E6),
						(int) (event.getLongitude() * 1E6));

				CustomOverlayItem overlayItem = new CustomOverlayItem(geoPoint,
						"", "", event);
				itemizedOverlayEvent.addOverlay(overlayItem);

				displayedItemCounter++;

			} else if (item instanceof GeoTag
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PEOPLE, true)) {
				listDisplayableContent.add(item);

				GeoTag geoTag = (GeoTag) item;
				onlyItem = item;

				GeoPoint geoPoint = new GeoPoint(
						(int) (geoTag.getLatitude() * 1E6),
						(int) (geoTag.getLongitude() * 1E6));

				CustomOverlayItem overlayItem = new CustomOverlayItem(geoPoint,
						"", "", geoTag);
				itemizedOverlayGeotag.addOverlay(overlayItem);

				displayedItemCounter++;
			}

		}

		itemizedOverlayPlace.populateItemizedOverlay();
		itemizedOverlayOtherPeople.populateItemizedOverlay();
		itemizedOverlaySecondDegreePeople.populateItemizedOverlay();
		itemizedOverlayEvent.populateItemizedOverlay();
		itemizedOverlayGeotag.populateItemizedOverlay();

		mapView.invalidate();

		if (isSearchEnabled && displayedItemCounter == 1) {
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = onlyItem;
		}

		if (displayedItemCounter > 0) {
			GeoPoint selectedGeoPoint;

			if (StaticValues.isHighlightAnnotation
					&& StaticValues.highlightAnnotationItem != null
					&& (StaticValues.searchResult != null
							|| eventList.size() > 0 || geotagList.size() > 0)) {

				highlightAnnotation();

				/*
				 * circleMenu.setVisibility(View.GONE);
				 * 
				 * selectedGeoPoint = new GeoPoint(0, 0);
				 * 
				 * if (StaticValues.highlightAnnotationItem instanceof People) {
				 * 
				 * People selectedPeople = (People)
				 * StaticValues.highlightAnnotationItem;
				 * 
				 * selectedGeoPoint = new GeoPoint( (int)
				 * (selectedPeople.getCurrentLat() * 1E6), (int)
				 * (selectedPeople.getCurrentLng() * 1E6));
				 * 
				 * // selectedGeoPoint = ((People) //
				 * StaticValues.highlightAnnotationItem).getCurrentPosition();
				 * itemizedOverlayOtherPeople.onTap(selectedGeoPoint, mapView);
				 * 
				 * } else if (StaticValues.highlightAnnotationItem instanceof
				 * Place) { selectedGeoPoint = ((Place)
				 * StaticValues.highlightAnnotationItem) .getLocation();
				 * itemizedOverlayPlace.onTap(selectedGeoPoint, mapView); } else
				 * if (StaticValues.highlightAnnotationItem instanceof
				 * SecondDegreePeople) { // selectedGeoPoint =
				 * ((SecondDegreePeople) //
				 * StaticValues.highlightAnnotationItem).getCurrentPosition();
				 * 
				 * SecondDegreePeople selectedPeople = (SecondDegreePeople)
				 * StaticValues.highlightAnnotationItem; selectedGeoPoint = new
				 * GeoPoint( (int) (selectedPeople.getCurrentLat() * 1E6), (int)
				 * (selectedPeople.getCurrentLng() * 1E6));
				 * 
				 * itemizedOverlaySecondDegreePeople.onTap(selectedGeoPoint,
				 * mapView);
				 * 
				 * } else if (StaticValues.highlightAnnotationItem instanceof
				 * Event) { // selectedGeoPoint = ((SecondDegreePeople) //
				 * StaticValues.highlightAnnotationItem).getCurrentPosition();
				 * 
				 * Event event = (Event) StaticValues.highlightAnnotationItem;
				 * selectedGeoPoint = new GeoPoint( (int) (event.getLatitude() *
				 * 1E6), (int) (event.getLongitude() * 1E6));
				 * 
				 * itemizedOverlayEvent.onTap(selectedGeoPoint, mapView);
				 * 
				 * }
				 * 
				 * 
				 * StaticValues.highlightAnnotationItem = null;
				 * StaticValues.isHighlightAnnotation = false;
				 */

			}

			else if (focusedItemPeople != null) {
				selectedGeoPoint = focusedItemPeople.getPoint();
				itemizedOverlayOtherPeople.onTap(selectedGeoPoint, mapView);
			} else if (focusedItemPlace != null) {
				selectedGeoPoint = focusedItemPlace.getPoint();
				itemizedOverlayPlace.onTap(selectedGeoPoint, mapView);
			} else if (focusedItemSecondDegreePeople != null) {
				selectedGeoPoint = focusedItemSecondDegreePeople.getPoint();
				itemizedOverlaySecondDegreePeople.onTap(selectedGeoPoint,
						mapView);
			} else if (focusedItemEvent != null) {
				selectedGeoPoint = focusedItemEvent.getPoint();
				itemizedOverlayEvent.onTap(selectedGeoPoint, mapView);
			} else if (focusedItemGeotag != null) {
				selectedGeoPoint = focusedItemGeotag.getPoint();
				itemizedOverlayGeotag.onTap(selectedGeoPoint, mapView);
			}
		} else {
			if (isSearchEnabled) {
				Toast.makeText(context, "No search result found.",
						Toast.LENGTH_SHORT).show();
			}
		}

		listDisplayableContent.clear();

	}

	/*
	 * private void updateMap() { // TODO Auto-generated method stub
	 * 
	 * if (peopleCheckBox.isChecked()) putPeopleOnMap(); if
	 * (placeCheckBox.isChecked()) putPlacesOnMap();
	 * 
	 * mapView.invalidate();
	 * 
	 * // setStationsOnMap(); }
	 */

	/*
	 * private void putPlacesOnMap() { // TODO Auto-generated method stub if
	 * (searchResultEntity.getPlaces().size() > 0) { int i;
	 * 
	 * itemizedOverlayPlace = (CustomItemizedOverlay) mapOverlays.get(2);
	 * Log.e("size of itemized overlay", itemizedOverlayPlace.size() + "");
	 * 
	 * itemizedOverlayPlace.removeAllItem(); Log.e("size of itemized overlay",
	 * itemizedOverlayPlace.size() + ""); Log.e("places",
	 * searchResultEntity.getPlaces().size() + ""); for (i = 0; i <
	 * searchResultEntity.getPlaces().size(); i++) {
	 * 
	 * PlaceEntity place = searchResultEntity.getPlaces().get(i);
	 * CustomOverlayItem overlayItem = new CustomOverlayItem(
	 * place.getLocation(), "", "", place);
	 * itemizedOverlayPlace.addOverlay(overlayItem);
	 * 
	 * } Log.e("size of itemized overlay", itemizedOverlayPlace.size() + "");
	 * 
	 * itemizedOverlayPlace.populateItemizedOverlay(); }
	 * 
	 * }
	 * 
	 * private void putPeopleOnMap() { // TODO Auto-generated method stub if
	 * (searchResultEntity.getPeoples().size() > 0) { int i;
	 * 
	 * itemizedOverlayOtherPeople = (CustomItemizedOverlay) mapOverlays .get(1);
	 * Log.e("size of itemized overlay", itemizedOverlayOtherPeople.size() +
	 * "");
	 * 
	 * itemizedOverlayOtherPeople.removeAllItem();
	 * Log.e("size of itemized overlay", itemizedOverlayOtherPeople.size() +
	 * ""); Log.e("users", searchResultEntity.getPeoples().size() + ""); for (i
	 * = 0; i < searchResultEntity.getPeoples().size(); i++) {
	 * 
	 * OtherUserEntity user = searchResultEntity.getPeoples().get(i);
	 * 
	 * CustomOverlayItem overlayItem = new CustomOverlayItem(
	 * user.getCurrentPosition(), "", "", user);
	 * itemizedOverlayOtherPeople.addOverlay(overlayItem);
	 * 
	 * } Log.e("size of itemized overlay", itemizedOverlayOtherPeople.size() +
	 * ""); itemizedOverlayOtherPeople.populateItemizedOverlay(); }
	 * 
	 * }
	 */

	private void setOnCheckChangeListener() {
		// TODO Auto-generated method stub
		peopleCheckBox.setOnCheckedChangeListener(this);
		placeCheckBox.setOnCheckedChangeListener(this);
		eventCheckBox.setOnCheckedChangeListener(this);
		dealCheckBox.setOnCheckedChangeListener(this);
	}

	private void addPermissionRadioGroup() {
		// TODO Auto-generated method stub

		locationSharingPermission = Permission.PUBLIC;
		try {
			locationSharingPermission = Permission.values()[StaticValues.myInfo
					.getSettings().getShareLocation()];
		} catch (NullPointerException e) {

		} catch (Exception e) {
			// TODO: handle exception
		}

		if (locationSharingPermission.ordinal() < 1) {
			locationSharingPermission = Permission.PUBLIC;
		}

		// Log.i("Permission value:login", locationSharingPermission.ordinal()+
		// ":" + StaticValues.myInfo.getSettings().getShareLocation());

		permissionRadioGroupView = new PermissionRadioGroupLess(context,
				shareWithSelectionListener, locationSharingPermission);
		shareWithRadioGroupContainer.addView(permissionRadioGroupView);

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		/*
		 * menu.add(Menu.NONE, MENU_ITEM_SETTINGS, Menu.NONE,
		 * "Settings").setIcon( R.drawable.icon_settings_small);
		 * menu.add(Menu.NONE, MENU_ITEM_MESSAGE, Menu.NONE,
		 * "Messages").setIcon( R.drawable.icon_messages_small);
		 * menu.add(Menu.NONE, MENU_ITEM_PROFILE, Menu.NONE, "Profile").setIcon(
		 * R.drawable.icon_profile); menu.add(Menu.NONE, MENU_ITEM_EVENT,
		 * Menu.NONE, "Events").setIcon( R.drawable.icon_event_small);
		 * 
		 * menu.add(Menu.NONE, MENU_ITEM_MEETUP, Menu.NONE, "Meet-up").setIcon(
		 * R.drawable.icon_meet_up_small);
		 */

		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		/*
		 * switch (item.getItemId()) { case MENU_ITEM_PEOPLE:
		 * 
		 * break;
		 * 
		 * case MENU_ITEM_PROFILE: // finish(); Intent profileIntent = new
		 * Intent(getApplicationContext(), ProfileActivity.class);
		 * startActivity(profileIntent); break;
		 * 
		 * case MENU_ITEM_DEAL:
		 * 
		 * break; case MENU_ITEM_VENUE:
		 * 
		 * break; case MENU_ITEM_SETTINGS: // finish(); Intent settingsIntent =
		 * new Intent(getApplicationContext(), SettingsActivity.class);
		 * startActivity(settingsIntent); break; case MENU_ITEM_LOGOUT:
		 * PreferenceConnector.writeBoolean(getApplicationContext(),
		 * "isLoggedInKey", false); finish(); Intent logoutIntent = new
		 * Intent(getApplicationContext(), LoginActivity.class);
		 * startActivity(logoutIntent); break; case MENU_ITEM_MESSAGE: //
		 * finish(); Intent messageIntent = new Intent(getApplicationContext(),
		 * MessageActivity.class); startActivity(messageIntent); break;
		 * 
		 * case MENU_ITEM_EVENT: // finish(); Intent eventIntent = new
		 * Intent(getApplicationContext(), ListOfEvents.class);
		 * startActivity(eventIntent); break;
		 * 
		 * case MENU_ITEM_MEETUP: // finish(); Intent meetupIntent = new
		 * Intent(getApplicationContext(), MeetupNewActivity.class);
		 * startActivity(meetupIntent); break; }
		 */
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

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();

		isRunning = false;
		Log.i("Home:onPause memory before",
				"" + Debug.getNativeHeapAllocatedSize());

		gpsService.stopListener();

		// unregisterReceiver(broadcastReceiver);

		StaticValues.highlightAnnotationItem = null;
		StaticValues.isHighlightAnnotation = false;

		// clearMap(0, true);

		listMasterContent.clear();
		listContent.clear();
		listDisplayableContent.clear();

		System.gc();

		Log.i("Home:onPause memory after",
				"" + Debug.getNativeHeapAllocatedSize());

	}

	public void handleNavigationFromNotificationBar(Intent intent) {
		if (StaticValues.myInfo == null) {
			if (Utility.getUserData(context) != null) {
				StaticValues.myInfo = ServerResponseParser
						.parseUserProfileInfo(Utility.getUserData(context),
								false);
			}

			if (StaticValues.myInfo == null) {
				Toast.makeText(context, "An unknown error occured.",
						Toast.LENGTH_SHORT).show();
				finish();
			}

		}

		Bundle extras = intent.getExtras();
		Log.i("dbg", "onNewIntent");

		if (extras != null) {
			if (extras.containsKey("pushData")) {
				Log.i("dbg", "containsKey(PushData)");
				PushData pushData = (PushData) extras.get("pushData");
				if (pushData != null) {
					Log.i("Home:PushData:Type", pushData.getObjectType());
					if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_MESSAGE_NEW)) {
						/*
						 * Intent intent2 = new Intent(context,
						 * MessageActivity.class); startActivity(intent2);
						 */

						Intent i = new Intent(
								context,
								MessageConversationFromNotificationActivity.class);
						i.putExtra("itemThreadId", pushData.getObjectId());
						i.putExtra("itemMessageId", pushData.getObjectId());

						startActivity(i);

					} else if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_MESSAGE_REPLY)) {
						/*
						 * Intent intent2 = new Intent(context,
						 * MessageActivity.class); startActivity(intent2);
						 */
						Intent i = new Intent(context, MessageConversationFromNotificationActivity.class);
						i.putExtra("itemThreadId", pushData.getObjectId());
						i.putExtra("itemMessageId", pushData.getObjectId());
						i.putExtra("status", true);
						startActivity(i);
					} else if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_EVENT)) {
						Intent intent2 = new Intent(context,
								EventListActivity.class);
						startActivity(intent2);
					} else if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_FRIEND_REQUEST)) {
						Intent intent2 = new Intent(context,
								NotificationActivity.class);
						intent2.putExtra("selectedTab",
								Constant.PUSH_NOTIFICATION_FRIEND_REQUEST);
						startActivity(intent2);
					} else if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_FRIEND_REQUEST_ACCEPT)) {

						updateFriendList();
						Intent intent2 = new Intent(context,
								ProfileActivity2.class);
						intent2.putExtra("peopleId", pushData.getObjectId());
						startActivity(intent2);

					} else if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_MEETUP)) {
						Intent intent2 = new Intent(context,
								MessageActivity.class);
						intent2.putExtra("selectedTab",
								Constant.PUSH_NOTIFICATION_MEETUP);
						startActivity(intent2);
					} else if (pushData.getObjectType().equals(
							Constant.PUSH_NOTIFICATION_PROXIMITY_ALERT)) {
						if (StaticValues.searchResult != null) {
							if (isSearchEnabled) {
								disableSearch();
								doSearch();
							}

							People people = Utility.getPeopleById(
									pushData.getObjectId(),
									StaticValues.searchResult.getPeoples());
							if (people != null) {
								StaticValues.isHighlightAnnotation = true;
								StaticValues.highlightAnnotationItem = people;
								highlightAnnotation();

							}
						}

					}
				} else {
					Log.i("Home:PushData:Type", "PushData is null");
				}
			}

		}
	}

	public void updateFriendList() {

		Thread thread = new Thread(friendListUpdateRunnable);

		thread.start();
	}

	Runnable friendListUpdateRunnable = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendList);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			// restClient.getResponse();
			if (restClient.getResponseCode() == Constant.STATUS_SUCCESS) {
				// StaticValues.myInfo.getSettings().setShareLocation(locationSharingPermission.ordinal());
				if (restClient.getResponse() != null
						&& !restClient.getResponse().equals("")) {
					CirclesAndFriends circlesAndFriends = ServerResponseParser
							.parseCircleAndFriends(restClient.getResponse());

					if (circlesAndFriends != null) {
						StaticValues.myInfo.setCircleList(circlesAndFriends
								.getCircles());
						StaticValues.myInfo.setFriendList(circlesAndFriends
								.getFriends());
					}

				}
			}

		}
	};

	@Override
	public void onNewIntent(Intent intent) {

		handleNavigationFromNotificationBar(intent);
	}

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();
		// setCheckBoxSelection();

		isRunning = true;
		Log.i("Home:onResume memory before",
				"" + Debug.getNativeHeapAllocatedSize());

		if (getIntent().getBooleanExtra("LOGOUT", false)) {
			finish();
			StaticValues.myInfo = null;
			StaticValues.searchResult = null;
			System.gc();
			Intent intent = new Intent(context, LoginActivity.class);
			startActivity(intent);
		}

		disableSearch();

		if (StaticValues.isHighlightAnnotation
				&& StaticValues.highlightAnnotationItem != null
				&& (StaticValues.searchResult != null || eventList.size() > 0 || geotagList
						.size() > 0)) {

			populateMasterList();
			updateContentList(listMasterContent);

			updateMapDisplay(listContent);

			// highlightAnnotation();
		}

		startGpsService();

		Log.i("Home:onResume memory after",
				"" + Debug.getNativeHeapAllocatedSize());

		// handleNavigationFromNotificationBar(getIntent());
		Utility.updateNotificationBubbleCounter(btnNotification);

	}

	private void initializeNotificationBroadcast() {
		// TODO Auto-generated method stub

		Log.i("inside", "initializeNotificationBroadcast");

		broadcastReceiver = NotificationCountBroadcastReciever.getInstance();
		broadcastReceiver.setCallback(new NotificationBroadcastListener());
		registerReceiver(broadcastReceiver, new IntentFilter(
				CommonUtilities.DISPLAY_MESSAGE_ACTION));
	}

	private class NotificationBroadcastListener implements BroadcastListener {
		@Override
		public void updateNotificationCountBuble(Intent intent) {

			Log.i("inside updateNotificationCountBuble", "");

			PushData pushData = (PushData) intent
					.getSerializableExtra("pushData");

			Utility.updateNotificationCountFromPush(pushData);
			/*
			 * if(StaticValues.myInfo!=null) {
			 * btnNotification.setText(""+StaticValues
			 * .myInfo.getNotificationCount() .getTotalCount()); }
			 */

			Utility.updateNotificationBubbleCounter(btnNotification);

		}
	}

	public void highlightAnnotation() {

		circleMenu.setVisibility(View.GONE);

		GeoPoint selectedGeoPoint = new GeoPoint(0, 0);

		if (StaticValues.highlightAnnotationItem instanceof People) {

			People selectedPeople = (People) StaticValues.highlightAnnotationItem;

			selectedGeoPoint = new GeoPoint(
					(int) (selectedPeople.getCurrentLat() * 1E6),
					(int) (selectedPeople.getCurrentLng() * 1E6));

			// selectedGeoPoint = ((People)
			// StaticValues.highlightAnnotationItem).getCurrentPosition();
			itemizedOverlayOtherPeople.onTap(selectedGeoPoint, mapView);

		} else if (StaticValues.highlightAnnotationItem instanceof Place) {
			Place place = (Place) StaticValues.highlightAnnotationItem;
			selectedGeoPoint = new GeoPoint((int) (place.getLatitude() * 1E6),
					(int) (place.getLongitude() * 1E6));

			itemizedOverlayPlace.onTap(selectedGeoPoint, mapView);
		} else if (StaticValues.highlightAnnotationItem instanceof SecondDegreePeople) {
			// selectedGeoPoint = ((SecondDegreePeople)
			// StaticValues.highlightAnnotationItem).getCurrentPosition();

			SecondDegreePeople selectedPeople = (SecondDegreePeople) StaticValues.highlightAnnotationItem;
			selectedGeoPoint = new GeoPoint(
					(int) (selectedPeople.getCurrentLat() * 1E6),
					(int) (selectedPeople.getCurrentLng() * 1E6));

			itemizedOverlaySecondDegreePeople.onTap(selectedGeoPoint, mapView);

		} else if (StaticValues.highlightAnnotationItem instanceof Event) {
			// selectedGeoPoint = ((SecondDegreePeople)
			// StaticValues.highlightAnnotationItem).getCurrentPosition();

			Event event = (Event) StaticValues.highlightAnnotationItem;
			selectedGeoPoint = new GeoPoint((int) (event.getLatitude() * 1E6),
					(int) (event.getLongitude() * 1E6));

			itemizedOverlayEvent.onTap(selectedGeoPoint, mapView);

		} else if (StaticValues.highlightAnnotationItem instanceof GeoTag) {
			// selectedGeoPoint = ((SecondDegreePeople)
			// StaticValues.highlightAnnotationItem).getCurrentPosition();

			GeoTag geoTag = (GeoTag) StaticValues.highlightAnnotationItem;
			selectedGeoPoint = new GeoPoint((int) (geoTag.getLatitude() * 1E6),
					(int) (geoTag.getLongitude() * 1E6));

			itemizedOverlayGeotag.onTap(selectedGeoPoint, mapView);

		}

		StaticValues.highlightAnnotationItem = null;
		StaticValues.isHighlightAnnotation = false;
	}

	public void disableSearch() {
		etSearchField.setText("");
		showSearchPanel(false);
		isSearchEnabled = false;
	}

	/*
	 * private void initializeNotificationCountBroadcast() {
	 * 
	 * // For production following is not necessary //countServiceIntent = new
	 * Intent(this, BroadcastService.class); //startService(countServiceIntent);
	 * // .......................................................
	 * 
	 * broadcastReceiver = NotificationCountBroadcastReciever.getInstance();
	 * broadcastReceiver.setCallback(this); registerReceiver(broadcastReceiver,
	 * new IntentFilter( BroadcastService.BROADCAST_ACTION)); }
	 */

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void setCheckBoxSelection() {
		// TODO Auto-generated method stub

		peopleCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.PEOPLE, true));
		placeCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.PLACE, false));
		eventCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.EVENT, false));
		dealCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.DEAL, false));

	}

	public void facebookAuthentication() {

		Log.i("HomeActivity", "facebookAuthentication");

		// initInviteFriends();
		// askForFacebookAccount();

		if (StaticValues.myInfo != null
				&& !Utility.getFacebookInvitationDisplayStatus(context)
				&& StaticValues.myInfo.getLogInCount() == 1) {

			Utility.setFacebookInvitationDisplayStatus(context, true);

			Log.i("HomeActivity", "inside facebookAuthentication");

			if (StaticValues.myInfo.getRegMedia().equalsIgnoreCase("fb")) {
				initInviteFriends();
			} else {
				askForFacebookAccount();
			}

		}

	}

	public void initInviteFriends() {
		Log.d("Facebook", "Have to invite");

		if (Utility.isConnectionAvailble(context)) {

			showInvitationDialog();

		} else {
			Toast.makeText(getApplicationContext(),
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}
	}

	public void showInvitationDialog() {
		Bundle params = new Bundle();
		params.putString("message", "Checkout the app.");
		FBUtility.mFacebook.dialog(context, "apprequests", params,
				new AppRequestsListener());
	}

	public void askForFacebookAccount() {
		// have to implement later

		if (!Utility.getFacebookInvitationDisplayStatus(context)) {

			showFirstTimeDialog(context);

		}

	}

	/*
	 * callback for the apprequests dialog which sends an app request to user's
	 * friends.
	 */
	public class AppRequestsListener extends BaseDialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			/*
			 * Toast toast = Toast.makeText(getApplicationContext(),
			 * "App request sent", Toast.LENGTH_SHORT); toast.show();
			 */
		}

		@Override
		public void onFacebookError(FacebookError error) {
			/*
			 * Toast.makeText(getApplicationContext(), "Facebook Error: " +
			 * error.getMessage(), Toast.LENGTH_SHORT) .show();
			 */
		}

		@Override
		public void onCancel() {
			/*
			 * Toast toast = Toast.makeText(getApplicationContext(),
			 * "App request cancelled", Toast.LENGTH_SHORT); toast.show();
			 */
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (circleMenu.getVisibility() == View.VISIBLE) {
				circleMenu.setVisibility(View.GONE);
			} else if (topDrawer.isOpened()) {
				topDrawer.animateClose();
			} else if (bottomDrawer.isOpened()) {
				bottomDrawer.animateClose();
			} else if (searchPanel.isShown()) {
				showSearchPanel(false);
			} else {
				AlertDialog.Builder adb = new AlertDialog.Builder(this);
				adb.setTitle("Exit");
				adb.setIcon(R.drawable.icon_alert);
				adb.setMessage("Are you sure you want to exit from this application?");
				adb.setPositiveButton("Yes",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								finish();
							}
						});
				adb.setNegativeButton("No",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								dialog.cancel();
							}
						});
				adb.show();
			}

		}
		return false;

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
	public void catchBubleTap(CustomOverlayItem item, int typeFlag) {
		// TODO Auto-generated method stub

		if (typeFlag == Constant.FLAG_PEOPLE) {

			showPeoplePopUpDetails(item);

			// Toast.makeText(context, "test", Toast.LENGTH_SHORT).show();
		}

		else if (typeFlag == Constant.FLAG_PLACE) {

			// temporarily off for beta

			showPlacePopUpDetails(item);
		}
		if (typeFlag == Constant.FLAG_SELF) {

			// Log.e("Self click", "clicked");

			Intent profileIntent = new Intent(context, ProfileActivity.class);
			startActivity(profileIntent);
		} else if (typeFlag == Constant.FLAG_SECOND_DEGREE) {

			// showSecondDegreePeoplePopUpDetails(item);

			// Toast.makeText(context, "test", Toast.LENGTH_SHORT).show();
		} else {
			// do nothing
		}
	}

	private void showPlacePopUpDetails(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		d = DialogsAndToasts.showExtendedInfoDialog(context,
				R.layout.dialog_on_map_place_extended);

		TextView titleText = (TextView) d.findViewById(R.id.title_text);
		String title = item.getPlace().getName();
		if (title != null && !title.equals("")) {
			titleText.setText(title);
		}

		TextView addressText = (TextView) d.findViewById(R.id.address_text);
		String address = item.getPlace().getVicinity();
		if (address != null && !address.equals("")) {
			addressText.setText(address);
		}

		TextView distance = (TextView) d.findViewById(R.id.distance_text);
		double distanceValue = item.getPlace().getDistance();
		// String distanceString = String.format("%.2f", distanceValue);
		// distance.setText(distanceString + " miles AWAY");
		distance.setText(Utility.getFormatedDistance(distanceValue,
				StaticValues.myInfo.getSettings().getUnit()) + " away");

		ImageView closeBtn = (ImageView) d.findViewById(R.id.close_btn);
		closeBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				d.dismiss();
			}
		});

		placeIconImage = (ImageView) d.findViewById(R.id.place_icon_image);
		String iconUrl = item.getPlace().getIconUrl();
		if (iconUrl != null && !iconUrl.equals("")) {

			// placeIconImage.setImageResource(R.drawable.icon);
			new FetchImageTask() {
				@Override
				protected void onPostExecute(Bitmap result) {
					if (result != null) {
						placeIconImage.setImageBitmap(result);
					}
				}
			}.execute(iconUrl);

			// imageLoader.DisplayImage(iconUrl, placeIconImage,
			// R.drawable.icon);

		}

		Button save_place_btn = (Button) d.findViewById(R.id.save_place_btn);
		save_place_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				Place place = item.getPlace();
				Intent peopleIntent = new Intent(context,
						PlaceEditSaveActivity.class);
				peopleIntent.putExtra("ISHOME", true);
				peopleIntent.putExtra("PLACE_OBJECT", place);

				startActivity(peopleIntent);
			}
		});

		// -- for meet up when Place Pop Up appear -- //

		Button meet_up = (Button) d.findViewById(R.id.meet_up_btn);
		meet_up.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				Log.d("PLACE MEET UP",
						String.valueOf(item.getPlace().getLatitude())
								+ " "
								+ String.valueOf(item.getPlace().getLongitude()));

				Intent intentForMeetup = new Intent(context,
						MeetupRequestNewActivity.class);
				intentForMeetup.putExtra("destLat", item.getPlace()
						.getLatitude());
				intentForMeetup.putExtra("destLng", item.getPlace()
						.getLongitude());
				intentForMeetup.putExtra("destAddress", item.getPlace()
						.getVicinity());
				// intentForMeetup.putExtra("flagToIdentify", 1);
				intentForMeetup.putExtra("selectedPlace", item.getPlace());
				startActivity(intentForMeetup);
			}
		});

		// -- for event when Place Pop Up appear -- //

		Button event_btn = (Button) d.findViewById(R.id.event_btn);
		event_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				Log.d("PLACE MEET UP",
						String.valueOf(item.getPlace().getLatitude())
								+ " "
								+ String.valueOf(item.getPlace().getLongitude()));

				Intent intentForEvent = new Intent(context,
						EventNewActivity.class);
				/*
				 * intentForMeetup.putExtra("destLat", item.getPlace()
				 * .getLatitude()); intentForMeetup.putExtra("destLng",
				 * item.getPlace() .getLongitude());
				 * intentForMeetup.putExtra("destAddress", item.getPlace()
				 * .getAddress());
				 */
				intentForEvent.putExtra("flag", 1);
				intentForEvent.putExtra("selectedPlace", item.getPlace());
				startActivity(intentForEvent);
			}
		});

		// -- for recommandation when Place Pop Up appear -- //

		Button recommend_btn = (Button) d.findViewById(R.id.recommend_btn);
		recommend_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				Place place = item.getPlace();

				Intent intent = new Intent(context,
						RecommendationActivity.class);
				intent.putExtra("place", place);
				startActivity(intent);
			}
		});

		Button plan_btn = (Button) d.findViewById(R.id.plan_btn);
		plan_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				// Toast.makeText(context, "Plan feature is coming soon",
				// Toast.LENGTH_SHORT).show();

				Place place = item.getPlace();

				Intent intent = new Intent(context, PlanCreateActivity.class);
				/*
				 * intent.putExtra("destLat", item.getPlace().getLatitude());
				 * intent.putExtra("destLng", item.getPlace().getLongitude());
				 * intent.putExtra("destAddress", item.getPlace().getAddress());
				 */

				intent.putExtra("selectedPlace", place);

				startActivity(intent);
			}
		});

		Button review_btn = (Button) d.findViewById(R.id.review_btn);
		review_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Toast.makeText(context, "Review feature is coming soon",
						Toast.LENGTH_SHORT).show();
			}
		});

		Button direction_btn = (Button) d.findViewById(R.id.direction_btn);
		direction_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				Place place = item.getPlace();

				Intent intent = new Intent(context, DirectionActivity.class);
				/*
				 * intent.putExtra("destLat", place.getLatitude());
				 * intent.putExtra("destLng", place.getLongitude());
				 * intent.putExtra("destAddress", place.getAddress());
				 */
				intent.putExtra("selectedPlace", item.getPlace());
				Log.d("Place Check", item.getPlace().getName() + " "
						+ item.getPlace().getVicinity() + " "
						+ item.getPlace().getLatitude() + " "
						+ item.getPlace().getLongitude());
				startActivity(intent);
			}
		});

		Button check_in_btn = (Button) d.findViewById(R.id.check_in_btn);
		check_in_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Toast.makeText(context, "Check In feature is coming soon",
						Toast.LENGTH_SHORT).show();
			}
		});

		d.show();
	}

	private void showPeoplePopUpDetails(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		d = DialogsAndToasts.showExtendedInfoDialog(context,
				R.layout.dialog_on_map_extended);

		currentBubbleDialog = d;

		String userId = item.getUser().getId();

		TextView firstName = (TextView) d.findViewById(R.id.first_name_text);
		firstName.setText(Utility.getFieldText(item.getUser()));
		/*
		 * String fName = item.getUser().getFirstName(); if (fName != null &&
		 * !fName.equals("")) { firstName.setText(fName); }
		 */

		LinearLayout genderInfoContainer = (LinearLayout) d
				.findViewById(R.id.genderInfoContainer);
		LinearLayout relationshipInfoContainer = (LinearLayout) d
				.findViewById(R.id.relationshipInfoContainer);
		LinearLayout cityInfoContainer = (LinearLayout) d
				.findViewById(R.id.cityInfoContainer);
		LinearLayout workInfoContainer = (LinearLayout) d
				.findViewById(R.id.workInfoContainer);

		TextView tvStatus = (TextView) d.findViewById(R.id.status_text);
		TextView age = (TextView) d.findViewById(R.id.age_text);

		if (Utility.isValidString(item.getUser().getStatusMsg())) {
			tvStatus.setText(item.getUser().getStatusMsg());
			tvStatus.setVisibility(View.VISIBLE);
		} else
			tvStatus.setVisibility(View.GONE);

		int ageValue = item.getUser().getAge();
		if (ageValue != 0) {
			age.setText("-Age: " + ageValue);
			age.setVisibility(View.VISIBLE);
		} else
			age.setVisibility(View.GONE);

		TextView distance = (TextView) d.findViewById(R.id.distance_text);
		double distanceValue = item.getUser().getDistance();

		distance.setText(Utility.getFormatedDistance(distanceValue,
				StaticValues.myInfo.getSettings().getUnit()) + " away");

		TextView street = (TextView) d.findViewById(R.id.street_text);
		String sName = item.getUser().getCurrentAddress();
		if (sName != null && !sName.equals("")) {
			street.setText(sName);
		} else {
			// street.setVisibility(View.GONE);
		}

		TextView gender = (TextView) d.findViewById(R.id.gender_text);
		String genderValue = item.getUser().getGender();
		if (genderValue != null && !genderValue.equals("")) {
			gender.setText(": " + genderValue);
		} else {
			genderInfoContainer.setVisibility(View.GONE);
		}

		TextView relationshipSatus = (TextView) d
				.findViewById(R.id.relationship_text);
		String relationshipValue = item.getUser().getRelationshipStatus();
		if (relationshipValue != null && !relationshipValue.equals("")
				&& !relationshipValue.equalsIgnoreCase("select...")) {
			relationshipSatus.setText(relationshipValue);
		} else {
			relationshipInfoContainer.setVisibility(View.GONE);
		}

		TextView city = (TextView) d.findViewById(R.id.city_text);
		String cityValue = item.getUser().getCity();
		if (cityValue != null && !cityValue.equals("")) {
			city.setText(cityValue);
		} else {
			cityInfoContainer.setVisibility(View.GONE);
		}

		TextView work = (TextView) d.findViewById(R.id.work_text);
		String workValue = item.getUser().getWorkStatus();
		if (workValue != null && !workValue.equals("")) {
			work.setText(workValue);
		} else {
			workInfoContainer.setVisibility(View.GONE);
		}
		
		ImageView ivOnline = (ImageView) d.findViewById(R.id.ivOnline);
		if(item.getUser().isOnline())
		{
			ivOnline.setImageResource(R.drawable.online);
		}

		avatar = (ImageView) d.findViewById(R.id.avater_image);
		avatar.setImageResource(R.drawable.img_blank);
		String avatarUrl = item.getUser().getAvatar();
		if (avatarUrl != null && !avatarUrl.equals("")) {

			// avatar.setImageResource(R.drawable.icon);
			/*
			 * new FetchImageTask() {
			 * 
			 * @Override protected void onPostExecute(Bitmap result) { if
			 * (result != null) { avatar.setImageBitmap(result); } }
			 * }.execute(item.getUser().getAvatar());
			 */
			imageDownloader.download(avatarUrl, avatar);

			// imageLoader.DisplayImage(avatarUrl, avatar, R.drawable.icon);
		}

		avatar.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(context, ProfileActivity2.class);
				intent.putExtra("otherUser", item.getUser());
				startActivity(intent);
			}
		});

		Button meetupBtn = (Button) d.findViewById(R.id.meet_up_btn);
		Button meetupBtnDisabled = (Button) d
				.findViewById(R.id.meet_up_btn_disabled);
		Button sendMessageBtn = (Button) d.findViewById(R.id.message_btn);
		ImageView closeBtn = (ImageView) d.findViewById(R.id.close_btn);
		Button addFrndBtn = (Button) d.findViewById(R.id.add_frnd_btn);
		Button directionBtn = (Button) d.findViewById(R.id.directions_btn);
		// Button profileBtn = (Button) d.findViewById(R.id.profile_btn);

		TextView tvFriendshipStatus = (TextView) d
				.findViewById(R.id.tvFriendshipStatus);

		String friendshipStatus = item.getUser().getFriendshipStatus();

		Log.e("friendshipStatus", friendshipStatus);

		if (friendRequestSentList.contains(userId)) {
			tvFriendshipStatus
					.setText(getString(R.string.status_friend_request_pending));
			meetupBtnDisabled.setVisibility(View.VISIBLE);
		} else {
			if (friendshipStatus
					.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_NONE)) {
				tvFriendshipStatus.setVisibility(View.GONE);
				addFrndBtn.setVisibility(View.VISIBLE);
			} else if (friendshipStatus
					.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {
				tvFriendshipStatus.setVisibility(View.GONE);
				meetupBtn.setVisibility(View.VISIBLE);
			} else {
				tvFriendshipStatus.setVisibility(View.VISIBLE);
				meetupBtnDisabled.setVisibility(View.VISIBLE);

				String status = "";
				if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {
					status = getString(R.string.status_friend_request_friend);
					meetupBtnDisabled.setVisibility(View.GONE);
					meetupBtn.setVisibility(View.VISIBLE);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_PENDING)) {
					status = getString(R.string.status_friend_request_pending);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REQUESTED)) {
					status = getString(R.string.status_friend_request_sent);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REJECTED_BY_ME)) {
					status = getString(R.string.status_friend_request_declined_by_me);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REJECTED_BY_HIM)) {
					status = getString(R.string.status_friend_request_declined_by_him);
				} else {
					status = "";
					meetupBtnDisabled.setVisibility(View.GONE);
					addFrndBtn.setVisibility(View.VISIBLE);

				}
				tvFriendshipStatus.setText(status);
			}
		}

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

		/*
		 * profileBtn.setOnClickListener(new OnClickListener() {
		 * 
		 * @Override public void onClick(View arg0) { // TODO Auto-generated
		 * method stub Intent intent = new Intent(context,
		 * ProfileActivity2.class); intent.putExtra("otherUser",
		 * item.getUser()); startActivity(intent); } });
		 */

		sendMessageBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				// d.dismiss();
				showMessageDialog(item);
				/*
				 * Dialog msgDialog = DialogsAndToasts
				 * .showSendMessage(context); msgDialog.show();
				 */
			}

		});

		meetupBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				// d.dismiss();
				Log.d("LAT LNG Meetup People",
						String.valueOf(item.getUser().getCurrentLat())
								+ " "
								+ String.valueOf(item.getUser().getCurrentLng()));

				People people = item.getUser();

				Intent intent = new Intent(context,
						MeetupRequestNewActivity.class);
				/*
				 * intent.putExtra("destLat", item.getUser().getCurrentLat());
				 * intent.putExtra("destLng", item.getUser().getCurrentLng());
				 * intent.putExtra("destAddress",
				 * item.getUser().getCurrentAddress());
				 */
				intent.putExtra("selectedPeople", people);
				startActivity(intent);
				/*
				 * Dialog msgDialog = DialogsAndToasts
				 * .showSendMessage(context); msgDialog.show();
				 */
			}

		});

		meetupBtnDisabled.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Toast.makeText(
						context,
						"To send Meet-up request, recipient should be your friend.",
						Toast.LENGTH_SHORT).show();
			}
		});

		directionBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(context, DirectionActivity.class);
				intent.putExtra("destLat", item.getUser().getCurrentLat());
				intent.putExtra("destLng", item.getUser().getCurrentLng());
				intent.putExtra("destAddress", item.getUser()
						.getCurrentAddress());
				startActivity(intent);
			}
		});

		d.show();
	}

	private void showSecondDegreePeoplePopUpDetails(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		d = DialogsAndToasts.showExtendedInfoDialog(context,
				R.layout.dialog_on_map_second_degree_extended);

		currentBubbleDialog = d;

		SecondDegreePeople secondDegreePeople = item.getSecondDegreePeople();

		TextView firstName = (TextView) d.findViewById(R.id.first_name_text);
		firstName.setText(Utility.getFieldText(secondDegreePeople));

		TextView distance = (TextView) d.findViewById(R.id.distance_text);
		double distanceValue = secondDegreePeople.getDistance();

		distance.setText(Utility.getFormatedDistance(distanceValue,
				StaticValues.myInfo.getSettings().getUnit()) + " away");

		TextView street = (TextView) d.findViewById(R.id.street_text);
		String sName = secondDegreePeople.getCurrentAddress();
		if (sName != null && !sName.equals("")) {
			street.setText(sName);
		} else {
			// street.setVisibility(View.GONE);
		}

		avatar = (ImageView) d.findViewById(R.id.avater_image);
		String avatarUrl = secondDegreePeople.getAvatar();
		if (avatarUrl != null && !avatarUrl.equals("")) {

			// avatar.setImageResource(R.drawable.icon);
			new FetchImageTask() {
				@Override
				protected void onPostExecute(Bitmap result) {
					if (result != null) {
						avatar.setImageBitmap(result);
					}
				}
			}.execute(secondDegreePeople.getAvatar());

			// imageLoader.DisplayImage(avatarUrl, avatar, R.drawable.icon);
		}

		ImageView closeBtn = (ImageView) d.findViewById(R.id.close_btn);
		closeBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				d.dismiss();
			}
		});

		// --- Secondary People's meet up & direction --- //
		Button meet_up_btn_2 = (Button) d.findViewById(R.id.meet_up_btn_2);
		meet_up_btn_2.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(context,
						MeetupRequestNewActivity.class);
				startActivity(intent);
			}
		});

		Button directions_btn = (Button) d.findViewById(R.id.directions_btn);
		directions_btn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(context, DirectionActivity.class);
				intent.putExtra("destLat", item.getSecondDegreePeople()
						.getCurrentLat());
				intent.putExtra("destLng", item.getSecondDegreePeople()
						.getCurrentLng());
				intent.putExtra("destAddress", item.getSecondDegreePeople()
						.getCurrentAddress());
				startActivity(intent);
			}
		});

		d.show();
	}

	private void showFrndRequestDialog(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		frndRequestDialog = DialogsAndToasts.showAddFrnd(context);
		final EditText msgEditText = (EditText) frndRequestDialog
				.findViewById(R.id.message_body_text);

		Button send = (Button) frndRequestDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) frndRequestDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				sendFriendRequest(item.getUser().getId(), msgEditText.getText()
						.toString().trim());

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
		msgDialog = DialogsAndToasts.showSendMessage(context);
		final EditText msgEditText = (EditText) msgDialog
				.findViewById(R.id.message_body_text);
		Button send = (Button) msgDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if (!msgEditText.getText().toString().trim().equals("")) {
					sendMessage(item.getUser().getId(), "Message", msgEditText
							.getText().toString().trim());
				} else {
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

	public void sendSelfLocationToServer() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

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

			restClient.AddParam("lat", "" + myLat);
			restClient.AddParam("lng", "" + myLng);

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

			responseStringUpdateLocation = null;

			// dismiss progress dialog if needed
		}

	};

	private void handleResponseUpdateLocation(int responseStatusUpdateLocation,
			String responseStringUpdateLocation) {
		// TODO Auto-generated method stub
		Log.e("Update Location", responseStatusUpdateLocation + " "
				+ responseStringUpdateLocation);
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
					.getString(R.string.sending_request_text), true, true);

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
			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	public void handleResponseFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Send Frnd Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);

			handleSuccssfulFriendRequest();

			Toast.makeText(context, "Request sent successfully.",
					Toast.LENGTH_SHORT).show();
			frndRequestDialog.dismiss();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(context,
					"Friend request already sent to this user.",
					Toast.LENGTH_SHORT).show();
			frndRequestDialog.dismiss();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}

	public void handleSuccssfulFriendRequest() {
		currentBubbleDialog.dismiss();
		if (!friendRequestSentList.contains(friendRequestFriendId)) {
			friendRequestSentList.add(friendRequestFriendId);
		}

		ArrayList<People> peopleList = StaticValues.searchResult.getPeoples();

		for (int i = 0; i < peopleList.size(); i++) {
			String userId = peopleList.get(i).getId();
			if (friendRequestSentList.contains(userId)) {
				peopleList.get(i).setFriendshipStatus(
						Constant.STATUS_FRIENDSHIP_PENDING);
			}
		}

		StaticValues.searchResult.setPeoples(peopleList);

		// updateMap();

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
					.getString(R.string.sending_request_text), true, true);

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
			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	public void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog
		Log.d("Send Message", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Message sent successfully.",
					Toast.LENGTH_SHORT).show();
			msgDialog.dismiss();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	private class TopDrawerListener implements
			MultiDirectionSlidingDrawer.OnDrawerOpenListener,
			MultiDirectionSlidingDrawer.OnDrawerCloseListener {

		@Override
		public void onDrawerClosed() {
			// TODO Auto-generated method stub
			Drawable openIcon = getResources().getDrawable(
					R.drawable.btn_slider_open);
			topCloseButton.setBackgroundResource(R.drawable.btn_slider_open);
		}

		@Override
		public void onDrawerOpened() {
			// TODO Auto-generated method stub

			if (bottomDrawer.isOpened()) {
				bottomDrawer.animateClose();
			}

			topCloseButton.setBackgroundResource(R.drawable.btn_slider_close);
		}

	}

	private class BottomDrawerListener implements
			MultiDirectionSlidingDrawer.OnDrawerOpenListener,
			MultiDirectionSlidingDrawer.OnDrawerCloseListener {
		@Override
		public void onDrawerClosed() {
			// TODO Auto-generated method stub
			Drawable openIcon = getResources().getDrawable(
					R.drawable.btn_footer_slider_open);
			bottomCloseButton.setBackgroundDrawable(openIcon);
		}

		@Override
		public void onDrawerOpened() {
			// TODO Auto-generated method stub

			if (topDrawer.isOpened()) {
				topDrawer.animateClose();
			}

			Drawable closeIcon = getResources().getDrawable(
					R.drawable.btn_footer_slider_close);
			bottomCloseButton.setBackgroundDrawable(closeIcon);
		}

	}

	/*
	 * private void hideShowMarkers(CustomItemizedOverlay<OverlayItem> items,
	 * boolean flag) { items.setIsVisible(flag); items.hideAllBalloons();
	 * items.populateItemizedOverlay(); }
	 */

	private void removeAllItemFromItemizedOverlay(
			CustomItemizedOverlay<OverlayItem> items) {
		items.removeAllItem();
		items.hideAllBalloons();
		items.populateItemizedOverlay();
		mapView.invalidate();
	}

	private void hideAllBallonsFromItemizedOverlay(
			CustomItemizedOverlay<OverlayItem> items) {
		items.hideAllBalloons();
		mapView.invalidate();
	}

	@Override
	public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		// TODO Auto-generated method stub
		if (buttonView == peopleCheckBox) {
			SharedPreferencesHelper.getInstance(context).setBoolean(
					Constant.PEOPLE, isChecked);

			updateMapDisplay(listContent);

			/*
			 * if (isChecked) { putPeopleOnMap(); mapView.invalidate(); } else {
			 * removeAllItemFromItemizedOverlay((CustomItemizedOverlay)
			 * mapOverlays .get(1)); }
			 */

		}
		if (buttonView == placeCheckBox) {

			SharedPreferencesHelper.getInstance(context).setBoolean(
					Constant.PLACE, isChecked);

			updateMapDisplay(listContent);

			/*
			 * if (isChecked) { putPlacesOnMap(); mapView.invalidate(); } else {
			 * removeAllItemFromItemizedOverlay((CustomItemizedOverlay)
			 * mapOverlays .get(2)); }
			 */

		}
		if (buttonView == eventCheckBox) {

			SharedPreferencesHelper.getInstance(context).setBoolean(
					Constant.EVENT, isChecked);

			updateMapDisplay(listContent);

			/*
			 * if (isChecked) { putPlacesOnMap(); mapView.invalidate(); } else {
			 * removeAllItemFromItemizedOverlay((CustomItemizedOverlay)
			 * mapOverlays .get(2)); }
			 */

		}
		if (buttonView == dealCheckBox) {
			SharedPreferencesHelper.getInstance(context).setBoolean(
					Constant.DEAL, isChecked);
			// Toast.makeText(context, "Deals", Toast.LENGTH_SHORT).show();
		}
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		Utility.hideKeyboardContext(context);

		if (v == btnListView) {
			if (StaticValues.searchResult != null) {
				Intent showListIntent = new Intent(context,
						ListViewActivity.class);
				startActivity(showListIntent);
			} else
				Toast.makeText(context, "No data found yet.",
						Toast.LENGTH_SHORT).show();
		} else if (v == btnCircle) {
			if (bottomDrawer.isOpened()) {
				bottomDrawer.animateClose();
			}
			circleMenu.setVisibility(View.VISIBLE);
		} else if (v == btnNotification) {
			Intent i = new Intent(HomeActivity.this, NotificationActivity.class);
			startActivity(i);
		} else if (v == btnEvent) {
			Intent i = new Intent(context, EventListActivity.class);
			startActivity(i);
		} else if (v == btnMeetup) {
			Intent i = new Intent(context, MeetupRequestNewActivity.class);
			startActivity(i);
		}

		else if (v == btnUpdateLocation) {
			relocationCurrentPosition();
		} else if (v == btnCircleMenu) {
			circleMenu.setVisibility(View.VISIBLE);
		}

		else if (v == circleMenu) {
			// do nothing. but keep it.
		}

		else if (v == btnCloseCircleMenu) {
			circleMenu.setVisibility(View.GONE);
		}

		else if (v == btnCircleMenuItemDeals) {

			Toast.makeText(context, "Coming soon.", Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemFriends) {

			Intent messageIntent = new Intent(getApplicationContext(),
					FriendListActivity.class);
			startActivity(messageIntent);

			// Toast.makeText(context, "Coming soon.",
			// Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemMessages) {
			Intent messageIntent = new Intent(getApplicationContext(),
					MessageActivity.class);
			startActivity(messageIntent);
		} else if (v == btnCircleMenuItemNewsfeed) {

			Intent messageIntent = new Intent(getApplicationContext(),
					NewsFeedActivity.class);
			startActivity(messageIntent);

			// Toast.makeText(context, "Coming soon.",
			// Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemPeople) {

			Intent peopleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			startActivity(peopleIntent);

			// Toast.makeText(context, "Coming soon.",
			// Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemPlaces) {

			Intent placeIntent = new Intent(getApplicationContext(),
					PlacesListActivity.class);
			startActivity(placeIntent);

			// Toast.makeText(context, "Coming soon.",
			// Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemProfile) {
			Intent profileIntent = new Intent(getApplicationContext(),
					ProfileActivity.class);
			startActivity(profileIntent);
		} else if (v == btnCircleMenuItemSettings) {
			Intent settingsIntent = new Intent(getApplicationContext(),
					SettingsActivity.class);
			startActivity(settingsIntent);
		}

		else if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			if (listMasterContent.size() > 0
					&& !etSearchField.getText().toString().trim()
							.equalsIgnoreCase("")) {
				isSearchEnabled = true;
				doSearch();
			}

			// toggleSearchPanel();
		} else if (v == btnClearSearch) {
			if (listMasterContent.size() > 0
					&& !etSearchField.getText().toString().trim()
							.equalsIgnoreCase("")) {
				isSearchEnabled = false;
				etSearchField.setText("");
				doSearch();
			}

		}

	}

	private void doSearch() {
		//
		List<Object> list = Utility.getSearchResult(listMasterContent,
				etSearchField.getText().toString().trim());

		listContent.clear();
		listContent.addAll(list);

		updateMapDisplay(listContent);
	}

	private void toggleSearchPanel() {
		if (!searchPanel.isShown())
			showSearchPanel(true);
		else
			showSearchPanel(false);
	}

	public void showSearchPanel(boolean display) {
		if (display) {
			searchPanel.setVisibility(View.VISIBLE);

		} else {
			searchPanel.setVisibility(View.GONE);
		}
	}

	public void relocationCurrentPosition() {
		if (point != null) {
			hideBallons(0, true);
			mapController.animateTo(point);
		}
	}

	private class ShareWithSelectionListener implements
			PermissionRadioGroupListener {

		@Override
		public void onPermissionChanged(RadioGroup group, RadioButton radio,
				Permission selectedItem) {
			// TODO Auto-generated method stub

			if (locationSharingPermission != selectedItem) {
				locationSharingPermission = selectedItem;

				updateLocationSharingPermission();
			}

			/*
			 * switch (selectedItem) { case PUBLIC: permissionValue =
			 * Constant.PERMISSION_PUBLIC; break; case FRIENDS: permissionValue
			 * = Constant.PERMISSION_FRIENDS; break; case NONE: permissionValue
			 * = Constant.PERMISSION_NONE; break; case CIRCLES: permissionValue
			 * = Constant.PERMISSION_CIRCLES; break; case CUSTOM:
			 * permissionValue = Constant.PERMISSION_CUSTOM;
			 * showPeoplePicker(shareWithPickerName); break; default:
			 * permissionValue = Constant.PERMISSION_NONE; break; }
			 */
		}
	}

	public void updateLocationSharingPermission() {

		Thread thread = new Thread(sharingUpdateRunnable);

		thread.start();
	}

	Runnable sharingUpdateRunnable = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(
					Constant.smLocationSharingUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("shareLocation",
					"" + locationSharingPermission.ordinal());

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			// restClient.getResponse();
			if (restClient.getResponseCode() == Constant.STATUS_SUCCESS) {
				StaticValues.myInfo.getSettings().setShareLocation(
						locationSharingPermission.ordinal());
			}

			Log.i("LocationSharing update", restClient.getResponseCode() + ":"
					+ restClient.getResponse());
		}
	};

	/*
	 * public void showPeoplePicker(String pickerName) { // custom dialog Dialog
	 * peoplePicker = new PeoplePicker(context, new
	 * ShareWithPeoplePickerListener(), pickerName, shareWithSelectedFriendList,
	 * shareWithSelectedCircleList);
	 * 
	 * peoplePicker.show(); }
	 */

	/*
	 * public class ShareWithPeoplePickerListener implements
	 * PeoplePickerListener {
	 * 
	 * @Override public void onSelect(String pickerName, List<String>
	 * selectedFriendList, List<String> selectedCircleList, List<String>
	 * selectedCircleFriendList, List<String> selectedFriendListAll) {
	 * 
	 * if (pickerName.equalsIgnoreCase(shareWithPickerName)) {
	 * shareWithSelectedFriendList = selectedFriendList;
	 * shareWithSelectedCircleList = selectedCircleList;
	 * shareWithSelectedCircleFriendList = selectedCircleFriendList;
	 * shareWithSelectedFriendListAll = selectedFriendListAll; }
	 * 
	 * }
	 * 
	 * }
	 */

	public void showFirstTimeDialog(final Context c) {

		isFirstTimeFbdialog = new Dialog(c, R.style.CustomDialogTheme);
		isFirstTimeFbdialog.setContentView(R.layout.first_time_dialog);

		isFirstTimeFbdialog.getWindow().setLayout(LayoutParams.FILL_PARENT,
				LayoutParams.FILL_PARENT);

		btnFBLogin = (Button) isFirstTimeFbdialog
				.findViewById(R.id.btnFBLoginDialog);

		// Create the Facebook Object using the app id.
		FBUtility.mFacebook = new Facebook(Constant.FB_APP_ID);
		FBUtility.mAsyncRunner = new AsyncFacebookRunner(FBUtility.mFacebook);

		// restore session if one exists
		// SessionStore.restore(FBUtility.mFacebook, c);
		SessionEvents.addAuthListener(fbAPIsAuthListener);
		SessionEvents.addLogoutListener(fbAPIsLogoutListener);

		/*
		 * btnFBLogin.init(HomeActivity.this,
		 * Constant.AUTHORIZE_ACTIVITY_RESULT_CODE, FBUtility.mFacebook,
		 * Constant.facebookPermissions, getString(R.string.connectWithFbLabel),
		 * getString(R.string.connectWithFbLabel));
		 */
		/*
		 * btnFBLogin.init(HomeActivity.this,
		 * Constant.AUTHORIZE_ACTIVITY_RESULT_CODE, FBUtility.mFacebook,
		 * Constant.facebookPermissions);
		 */

		btnFBLogin.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				FBUtility.mFacebook
						.authorize(HomeActivity.this,
								Constant.facebookPermissions,
								new LoginDialogListener());
			}
		});

		Button btnCrossFb = (Button) isFirstTimeFbdialog
				.findViewById(R.id.btnCrossFb);
		// if button is clicked, close the custom dialog
		btnCrossFb.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				isFirstTimeFbdialog.dismiss();
			}
		});

		isFirstTimeFbdialog.show();

	}

	/*
	 * The Callback for notifying the application when authorization succeeds or
	 * fails.
	 */

	public class FbAPIsAuthListener implements AuthListener {

		// @Override
		@Override
		public void onAuthSucceed() {

			initInviteFriends();
			isFirstTimeFbdialog.dismiss();

		}

		// @Override
		@Override
		public void onAuthFail(String error) {
			Log.e("HomeActivity", "Login Failed: " + error);
		}
	}

	/*
	 * The Callback for notifying the application when log out starts and
	 * finishes.
	 */
	public class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		@Override
		public void onLogoutBegin() {
			Log.e("HomeActivity", "Logging out...");
		}

		// @Override
		@Override
		public void onLogoutFinish() {
			Log.e("HomeActivity", "You have logged out! ");

			// mahadi:start login again
			// btnFBLogin.setVisibility(View.GONE);
			// btnFBLogin2.setVisibility(View.VISIBLE);
			Utility.setFacebookImage(context, null);
			// ivFacebookProfile.setImageDrawable(getResources().getDrawable(
			// R.drawable.icon_facebook));

			FBUtility.mFacebook.authorize(HomeActivity.this,
					Constant.facebookPermissions, Facebook.FORCE_DIALOG_AUTH,
					new LoginDialogListener());
		}
	}

	private final class LoginDialogListener implements DialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			Log.e("LoginDialogListener", "onComplete");
			SessionEvents.onLoginSuccess();
		}

		// @Override
		@Override
		public void onFacebookError(FacebookError error) {
			Log.e("LoginDialogListener", "onFacebookError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onError(DialogError error) {
			Log.e("LoginDialogListener", "onError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onCancel() {
			Log.e("LoginDialogListener", "onCancel");
			SessionEvents.onLoginError("Action Canceled");
		}
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		FBUtility.mFacebook.authorizeCallback(requestCode, resultCode, data);
	}

}
