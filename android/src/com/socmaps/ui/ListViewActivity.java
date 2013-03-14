package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageFetcher;
import com.socmaps.listrow.ListItemClickListenerPeople;
import com.socmaps.listrow.PeopleRowFactory;
import com.socmaps.listrow.PlaceRowFactory;
import com.socmaps.listrow.RowType;
import com.socmaps.listrow.SecondDegreePeopleRowFactory;
import com.socmaps.util.Constant;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.ListComparator;
import com.socmaps.widget.MultiDirectionSlidingDrawer;

/**
 * LayerPreferencesActivity class for generating all users and places list view
 * and some user interaction.
 * 
 */
public class ListViewActivity extends FragmentActivity implements
		OnCheckedChangeListener, OnClickListener, ListItemClickListenerPeople {

	Button btnNotification;
	Button topCloseButton, bottomCloseButton;
	MultiDirectionSlidingDrawer topDrawer, bottomDrawer;

	TopDrawerListener topDrawerListener;
	BottomDrawerListener bottomDrawerListener;

	private Context context;
	private ListView contentListView;
	private ContentListAdapter contentAdapter;
	private SearchResult peoplesAndPlacesEntity;
	private Button btnMapView, btnListView, btnCircle, btnToggleSearchPanel,
			btnDoSearch, btnClearSearch;
	private TextView tvMapView;
	private boolean checkBoxFlag = false;
	private CheckBox peopleCheckBox, placeCheckBox, dealCheckBox;
	private RelativeLayout searchPanel;
	private EditText etSearchField;

	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;

	boolean isSearchEnabled = false;

	RelativeLayout circleMenu;
	LinearLayout btnCloseCircleMenu;
	Button btnCircleMenuItemPeople, btnCircleMenuItemProfile,
			btnCircleMenuItemMessages, btnCircleMenuItemFriends,
			btnCircleMenuItemDeals, btnCircleMenuItemPlaces,
			btnCircleMenuItemNewsfeed, btnCircleMenuItemSettings;

	double lat;
	double lng;
	double latitude, longitude;

	private ImageFetcher mImageFetcher;
	private ListComparator listComparator;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.list_view_layout);

		initialize();
		getIntentData();
		setListParameters();

	}

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();

		mImageFetcher.setExitTasksEarly(false);

		Utility.updateNotificationBubbleCounter(btnNotification);

		setCheckBoxSelection();
		setOnCheckChangeListener();

		populateMasterList();

		updateContentList(listMasterContent);
		updateDisplayList(listContent);
	}

	private void setListParameters() {

		View footerView = new View(context);
		footerView.setBackgroundColor(Color.TRANSPARENT);
		footerView.setMinimumHeight(50);

		contentListView.addFooterView(footerView);

		contentListView.setAdapter(contentAdapter);
		int[] colors = { 0xFFFFFFFF, 0xFFFFFFFF };
		contentListView.setDivider(new GradientDrawable(Orientation.TOP_BOTTOM,
				colors));
		contentListView.setDividerHeight(2);
	}

	private void getIntentData() {
		peoplesAndPlacesEntity = StaticValues.searchResult;
	}

	private void initialize() {

		context = ListViewActivity.this;

		listComparator = new ListComparator();

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		topDrawerListener = new TopDrawerListener();
		bottomDrawerListener = new BottomDrawerListener();

		topDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.topDrawer);
		topDrawer.setOnDrawerOpenListener(topDrawerListener);
		topDrawer.setOnDrawerCloseListener(topDrawerListener);

		bottomDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.bottomDrawer);
		bottomDrawer.setOnDrawerOpenListener(bottomDrawerListener);
		bottomDrawer.setOnDrawerCloseListener(bottomDrawerListener);

		View v = topDrawer.findViewById(R.id.topSliderContent);
		peopleCheckBox = (CheckBox) v.findViewById(R.id.chkMenuItemPeople);
		placeCheckBox = (CheckBox) v.findViewById(R.id.chkMenuItemPlaces);
		dealCheckBox = (CheckBox) v.findViewById(R.id.chkMenuItemDeals);

		View vBottom = bottomDrawer.findViewById(R.id.bottomContent);
		btnMapView = (Button) vBottom.findViewById(R.id.btnMapView);
		btnMapView.setOnClickListener(this);

		tvMapView = (TextView) vBottom.findViewById(R.id.tvMapView);
		tvMapView.setOnClickListener(this);

		btnCircle = (Button) vBottom.findViewById(R.id.btnCircle);
		btnCircle.setOnClickListener(this);

		btnListView = (Button) vBottom.findViewById(R.id.btnListView);
		btnListView.setBackgroundDrawable(getResources().getDrawable(
				R.drawable.icon_list_view_selected));

		topCloseButton = (Button) topDrawer.findViewById(R.id.topHandle);
		bottomCloseButton = (Button) bottomDrawer
				.findViewById(R.id.bottomHandle);

		contentListView = (ListView) findViewById(R.id.content_list);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(getApplicationContext(),
				listDisplayableContent);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

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

		mImageFetcher = new ImageFetcher(context);

	}

	private void setOnCheckChangeListener() {
		// TODO Auto-generated method stub
		checkBoxFlag = true;
		peopleCheckBox.setOnCheckedChangeListener(this);
		placeCheckBox.setOnCheckedChangeListener(this);
		dealCheckBox.setOnCheckedChangeListener(this);

		checkBoxFlag = false;
	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();

		mImageFetcher.closeCache();
		

		peoplesAndPlacesEntity = null;
		listMasterContent = null;
		listContent = null;
		listDisplayableContent = null;
		mImageFetcher = null;

		contentAdapter = null;

		RelativeLayout rootLayout = (RelativeLayout) findViewById(R.id.rootLayout);
		rootLayout.removeAllViews();

		unbindReferences(ListViewActivity.this, R.id.rootLayout);

		System.gc();
	}

	public static void unbindReferences(FragmentActivity activity, int viewID) {
		try {
			View view = activity.findViewById(viewID);
			if (view != null) {

				if (view instanceof ViewGroup)
					unbindViewGroupReferences((ViewGroup) view);
			}
			System.gc();
		} catch (Throwable e) {
			// whatever exception is thrown just ignore it because a crash is
			// always worse than this method not doing what it's supposed to do
		}
	}

	private static void unbindViewGroupReferences(ViewGroup viewGroup) {
		int nrOfChildren = viewGroup.getChildCount();

		for (int i = 0; i < nrOfChildren; i++) {
			View view = viewGroup.getChildAt(i);
			// unbindViewReferences(view);
			if (view instanceof ViewGroup)
				unbindViewGroupReferences((ViewGroup) view);
		}

		try {
			viewGroup.removeAllViews();
		} catch (Throwable mayHappen) {
			// AdapterViews, ListViews and potentially other ViewGroups don't
			// support the removeAllViews operation
		}
	}

	private void updateContentList(List<Object> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	private void updateDisplayList(List<Object> list) {

		int displayedItemCounter = 0;

		listDisplayableContent.clear();
		for (int i = 0; i < list.size(); i++) {

			Object item = list.get(i);
			if (item instanceof People
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PEOPLE, true)) {
				listDisplayableContent.add(item);
				displayedItemCounter++;
			}
			if (item instanceof SecondDegreePeople
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PEOPLE, true)) {
				listDisplayableContent.add(item);
				displayedItemCounter++;
			}

			else if (item instanceof Place
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PLACE, false)) {
				listDisplayableContent.add(item);
				displayedItemCounter++;
			}

		}

		// update the list view
		updateListView();

		if (isSearchEnabled && displayedItemCounter == 0) {
			Toast.makeText(context, "No search result found.",
					Toast.LENGTH_SHORT).show();
		}
	}

	private void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private void populateMasterList() {
		listMasterContent.clear();

		if (peoplesAndPlacesEntity != null) {
			addPeoplesToMasterList();
			addSecondDegreePeoplesToMasterList();
			addPlacesToMasterList();
			sortMasterListData();
		}
	}

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, listComparator);
	}

	private void addPlacesToMasterList() {

		if (peoplesAndPlacesEntity.getPlaces() != null) {
			for (int i = 0; i < peoplesAndPlacesEntity.getPlaces().size(); i++) {
				listMasterContent
						.add(peoplesAndPlacesEntity.getPlaces().get(i));
			}
		}
	}

	private void addPeoplesToMasterList() {

		if (peoplesAndPlacesEntity.getPeoples() != null) {

			for (int i = 0; i < peoplesAndPlacesEntity.getPeoples().size(); i++) {
				listMasterContent.add(peoplesAndPlacesEntity.getPeoples()
						.get(i));
			}
		}
	}

	private void addSecondDegreePeoplesToMasterList() {

		if (peoplesAndPlacesEntity.getSecondDegreePeoples() != null) {
			for (int i = 0; i < peoplesAndPlacesEntity.getSecondDegreePeoples()
					.size(); i++) {
				listMasterContent.add(peoplesAndPlacesEntity
						.getSecondDegreePeoples().get(i));
			}
		}
	}

	private void setCheckBoxSelection() {
		peopleCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.PEOPLE, true));
		placeCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.PLACE, false));
		dealCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.DEAL, false));

	}

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();

		mImageFetcher.setExitTasksEarly(true);
		mImageFetcher.flushCache();

	}

	private class TopDrawerListener implements
			MultiDirectionSlidingDrawer.OnDrawerOpenListener,
			MultiDirectionSlidingDrawer.OnDrawerCloseListener {

		@Override
		public void onDrawerClosed() {
			// TODO Auto-generated method stub
			Drawable openIcon = getResources().getDrawable(
					R.drawable.btn_slider_open);
			topCloseButton.setBackgroundDrawable(openIcon);
		}

		@Override
		public void onDrawerOpened() {
			// TODO Auto-generated method stub

			if (bottomDrawer.isOpened()) {
				bottomDrawer.animateClose();
			}

			Drawable closeIcon = getResources().getDrawable(
					R.drawable.btn_slider_close);
			topCloseButton.setBackgroundDrawable(closeIcon);
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

	@Override
	public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		if (!checkBoxFlag) {
			if (buttonView == peopleCheckBox) {
				SharedPreferencesHelper.getInstance(context).setBoolean(
						Constant.PEOPLE, isChecked);

			}
			if (buttonView == placeCheckBox) {
				SharedPreferencesHelper.getInstance(context).setBoolean(
						Constant.PLACE, isChecked);

			}
			if (buttonView == dealCheckBox) {

			}

			updateDisplayList(listContent);
		}
	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Object> items;
		private Context context;

		public ContentListAdapter(Context context, List<Object> itemsList) {
			this.context = context;
			this.items = itemsList;
		}

		@Override
		public int getViewTypeCount() {
			return RowType.values().length;
		}

		@Override
		public int getItemViewType(int position) {
			if (items.get(position) instanceof People) {

				return RowType.PEOPLE.ordinal();
			} else if (items.get(position) instanceof Place) {

				return RowType.PLACE.ordinal();
			} else if (items.get(position) instanceof SecondDegreePeople) {

				return RowType.SECOND_DEGREE.ordinal();
			} else {
				return -1;
			}
		}

		@Override
		public int getCount() {
			return items.size();
		}

		@Override
		public Object getItem(int position) {
			return items.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (getItemViewType(position) == RowType.PEOPLE.ordinal()) {
				return PeopleRowFactory.getView(LayoutInflater.from(context),
						items.get(position), context, convertView,
						mImageFetcher, ListViewActivity.this);
			} else if (getItemViewType(position) == RowType.SECOND_DEGREE
					.ordinal()) {
				return SecondDegreePeopleRowFactory.getView(
						LayoutInflater.from(context), items.get(position),
						context, convertView, mImageFetcher,
						ListViewActivity.this);
			} else if (getItemViewType(position) == RowType.PLACE.ordinal()) {
				return PlaceRowFactory.getView(LayoutInflater.from(context),
						items.get(position), context, convertView,
						mImageFetcher, ListViewActivity.this);
			} else {
				return null;
			}
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
				finish();
			}

		}

		return false;

		// return super.onKeyDown(keyCode, event);

	}

	@Override
	public void onClick(View v) {

		Utility.hideKeyboardContext(context);

		if (v == btnMapView || v == tvMapView) {
			this.finish();
		} else if (v == btnCircle) {
			if (bottomDrawer.isOpened()) {
				bottomDrawer.animateClose();
			}
			circleMenu.setVisibility(View.VISIBLE);
		} else if (v == btnNotification) {
			Intent i = new Intent(context, NotificationActivity.class);
			startActivity(i);
		} else if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			isSearchEnabled = true;
			doSearch();
		} else if (v == btnClearSearch) {
			isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();
		} else if (v == circleMenu) {
			// do nothing. but keep it.
		} else if (v == btnCloseCircleMenu) {
			circleMenu.setVisibility(View.GONE);
		} else if (v == btnCircleMenuItemDeals) {
			Toast.makeText(context, "Coming soon.", Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemFriends) {

			Intent friendIntent = new Intent(getApplicationContext(),
					FriendListActivity.class);
			startActivity(friendIntent);

		} else if (v == btnCircleMenuItemMessages) {
			Intent messageIntent = new Intent(context, MessageActivity.class);
			finish();
			startActivity(messageIntent);
		} else if (v == btnCircleMenuItemNewsfeed) {
			Intent messageIntent = new Intent(getApplicationContext(),
					NewsFeedActivity.class);
			startActivity(messageIntent);
		} else if (v == btnCircleMenuItemPeople) {
			Intent peopleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			startActivity(peopleIntent);

		} else if (v == btnCircleMenuItemPlaces) {
			getLocationLatLong();

			Intent directionIntent = new Intent(context,
					DirectionActivity.class);

			directionIntent.putExtra("sourceLat", latitude);
			directionIntent.putExtra("sourceLng", longitude);
			directionIntent
					.putExtra("sourceAddress", "R#1, H#2, Banani, Dhaka");

			directionIntent.putExtra("destLat", 23.74866);
			directionIntent.putExtra("destLng", 90.37388);
			directionIntent.putExtra("destAddress", "R#11, Dhanmondi, Dhaka");

			finish();
			startActivity(directionIntent);

		} else if (v == btnCircleMenuItemPlaces) {

			Intent placeIntent = new Intent(getApplicationContext(),
					PlacesListActivity.class);
			startActivity(placeIntent);

		} else if (v == btnCircleMenuItemProfile) {
			Intent profileIntent = new Intent(context, ProfileActivity.class);
			finish();
			startActivity(profileIntent);
		} else if (v == btnCircleMenuItemSettings) {
			Intent settingsIntent = new Intent(context, SettingsActivity.class);
			finish();
			startActivity(settingsIntent);
		}
	}

	private void getLocationLatLong() {
		LocationManager locManager;
		locManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		locManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000L,
				500.0f, locationListener);
		Location location = locManager
				.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		if (location != null) {
			latitude = location.getLatitude();
			longitude = location.getLongitude();
		}
	}

	private void updateWithNewLocation(Location location) {
		String latLongString = "";
		if (location != null) {
			lat = location.getLatitude();
			lng = location.getLongitude();
			latLongString = "Lat:" + lat + "\nLong:" + lng;
		} else {
			latLongString = "No location found";
		}
	}

	private final LocationListener locationListener = new LocationListener() {
		public void onLocationChanged(Location location) {
			updateWithNewLocation(location);
		}

		public void onProviderDisabled(String provider) {
			updateWithNewLocation(null);
		}

		public void onProviderEnabled(String provider) {
		}

		public void onStatusChanged(String provider, int status, Bundle extras) {
		}
	};

	private void doSearch() {
		List<Object> list = (Utility.getSearchResult(listMasterContent,
				etSearchField.getText().toString()));

		listContent.clear();
		listContent.addAll(list);

		updateDisplayList(listContent);
	}

	private void toggleSearchPanel() {
		if (!searchPanel.isShown())
			searchPanel.setVisibility(View.VISIBLE);
		else
			searchPanel.setVisibility(View.GONE);
	}

	private void showSearchPanel(boolean display) {
		if (display) {
			searchPanel.setVisibility(View.VISIBLE);

		} else {
			searchPanel.setVisibility(View.GONE);
		}
	}

	@Override
	public void onItemClick(People people) {
		// send user to profile screen with people object

		Intent intent = new Intent(context, ProfileActivity2.class);
		intent.putExtra("otherUser", people);
		Log.d("People Age", people.getAge() + "");
		startActivity(intent);
		finish();

	}

	@Override
	public void onArrowButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onInviteButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onAddFriendButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onBlockButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onUnBlockButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onShowOnMapButtonClick(Object item) {
		// TODO Auto-generated method stub
		StaticValues.isHighlightAnnotation = true;
		StaticValues.highlightAnnotationItem = item;
		finish();
	}

	@Override
	public void onSendMessageButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onMeetupButtonClick(People people) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onCheckChange(String itemId, boolean isChecked) {
		// TODO Auto-generated method stub

	}

}
