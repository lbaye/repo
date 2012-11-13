package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.Bundle;
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
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.images.ImageLoader;
import com.socmaps.listrow.ListItemClickListener;
import com.socmaps.listrow.ListItemClickListenerPeople;
import com.socmaps.listrow.ListItemClickListenerPlace;
import com.socmaps.listrow.ListItemClickListenerSecondDegreePeople;
import com.socmaps.listrow.PeopleRowFactory;
import com.socmaps.listrow.PlaceRowFactory;
import com.socmaps.listrow.RowType;
import com.socmaps.listrow.SecondDegreePeopleRowFactory;
import com.socmaps.util.Constant;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.MultiDirectionSlidingDrawer;

public class ListViewActivity extends Activity implements
		OnCheckedChangeListener, OnClickListener, ListItemClickListener {

	Button btnNotification;
	Button topCloseButton, bottomCloseButton;
	MultiDirectionSlidingDrawer topDrawer, bottomDrawer;

	TopDrawerListener topDrawerListener;
	BottomDrawerListener bottomDrawerListener;

	public Context context;
	private ListView contentListView;
	private ContentListAdapter contentAdapter;
	private SearchResult peoplesAndPlacesEntity;
	private Button btnMapView, btnListView, btnCircle, btnToggleSearchPanel,
			btnDoSearch, btnClearSearch;
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

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.list_view_layout);

		initialize();
		getIntentData();
		setListParameters();

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

	public void initialize() {

		context = ListViewActivity.this;

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

		btnCircle = (Button) vBottom.findViewById(R.id.btnCircle);
		btnCircle.setOnClickListener(this);

		btnListView = (Button) vBottom.findViewById(R.id.btnListView);
		btnListView.setBackgroundDrawable(getResources().getDrawable(
				R.drawable.icon_list_view_selected));

		setOnCheckChangeListener();
		topCloseButton = (Button) topDrawer.findViewById(R.id.topHandle);
		bottomCloseButton = (Button) bottomDrawer
				.findViewById(R.id.bottomHandle);

		contentListView = (ListView) findViewById(R.id.content_list);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

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

		// objects=new ArrayList<Object>();

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

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();
		setCheckBoxSelection();
		populateMasterList();

		updateContentList(listMasterContent);
		updateDisplayList(listContent);

	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}

	public void updateContentList(List<Object> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	public void updateDisplayList(List<Object> list) {

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
							Constant.PLACE, true)) {
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

	public void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private void populateMasterList() {
		listMasterContent.clear();
		addPeoplesToMasterList();
		addSecondDegreePeoplesToMasterList();
		addPlacesToMasterList();
		sortMasterListData();
	}

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, new ListComparator());
	}

	/*
	 * private void sortDisplayableListData() {
	 * Collections.sort(this.listDisplayableContent, new ListComparator()); }
	 */

	class ListComparator implements Comparator<Object> {

		@Override
		public int compare(Object first, Object last) {
			double firstDistance = getDistance(first);
			double lastDistance = getDistance(last);

			if (firstDistance > lastDistance)
				return 1;
			else if (firstDistance == lastDistance)
				return 0;
			else
				return -1;
		}

		private double getDistance(Object object) {
			if (object instanceof People)
				return ((People) object).getDistance();
			else if (object instanceof Place)
				return ((Place) object).getDistance();
			else if (object instanceof SecondDegreePeople)
				return ((SecondDegreePeople) object).getDistance();
			else
				return 0;
		}

	}

	private void addPlacesToMasterList() {
		for (int i = 0; i < peoplesAndPlacesEntity.getPlaces().size(); i++) {
			listMasterContent.add(peoplesAndPlacesEntity.getPlaces().get(i));
		}
	}

	private void addPeoplesToMasterList() {
		for (int i = 0; i < peoplesAndPlacesEntity.getPeoples().size(); i++) {
			listMasterContent.add(peoplesAndPlacesEntity.getPeoples().get(i));
		}
	}

	private void addSecondDegreePeoplesToMasterList() {
		for (int i = 0; i < peoplesAndPlacesEntity.getSecondDegreePeoples()
				.size(); i++) {
			listMasterContent.add(peoplesAndPlacesEntity
					.getSecondDegreePeoples().get(i));
		}
	}

	private void setCheckBoxSelection() {
		peopleCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.PEOPLE, true));
		placeCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.PLACE, true));
		dealCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
				.getBoolean(Constant.DEAL, true));

	}

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();

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
		// private ImageLoader imageLoader;

		private ImageDownloader imageDownloader;// = new ImageDownloader();

		public ContentListAdapter(Context context, List<Object> itemsList) {

			this.items = itemsList;
			// imageLoader = new ImageLoader(context);
			imageDownloader = new ImageDownloader();
			imageDownloader.setMode(ImageDownloader.Mode.CORRECT);

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
						items.get(position), context, ListViewActivity.this,
						convertView, imageDownloader, new PeopleItemListener());
			}
			if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal()) {
				return SecondDegreePeopleRowFactory.getView(
						LayoutInflater.from(context), items.get(position),
						context, ListViewActivity.this, convertView,
						imageDownloader, new SecondDegreePeopleItemListener());
			} else if (getItemViewType(position) == RowType.PLACE.ordinal()) {
				return PlaceRowFactory.getView(LayoutInflater.from(context),
						items.get(position), context, ListViewActivity.this,
						convertView, imageDownloader, new PlaceItemListener());
			} else {
				return null;
			}
		}

		public ImageDownloader getImageDownloader() {
			return imageDownloader;
		}

	}

	private class PeopleItemListener implements ListItemClickListenerPeople {

		@Override
		public void onItemClick(People people) {
			// TODO Auto-generated method stub
			// send user to profile screen with people object

			/*
			 * Log.d("People Info",
			 * "Avater: "+people.getAvatar()+"~"+"CoverPhoto: "
			 * +people.getCoverPhoto()+"~"+"Reg Media: "+
			 * people.getRegMedia()+"~"+
			 * "First Name: "+people.getFirstName()+"~"
			 * +"Last Name: "+people.getLastName
			 * ()+"~"+"Status: "+people.getStatusMsg
			 * ()+"~"+"Address: "+people.getStreetAddress()+
			 * "~"+"Last Log: "+people
			 * .getLastLogIn()+"~"+"Age: "+people.getAge()
			 * +"~"+"RShip Status: "+people
			 * .getRelationshipStatus()+"~"+"City: "+ people.getCity()+
			 * "~"+"Work Info: "+people.getWorkStatus());
			 */

			Intent intent = new Intent(context, ProfileActivity2.class);
			intent.putExtra("otherUser", people);
			startActivity(intent);

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
		public void onShowOnMapButtonClick(People people) {
			// TODO Auto-generated method stub

			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;
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

	private class SecondDegreePeopleItemListener implements
			ListItemClickListenerSecondDegreePeople {

		@Override
		public void onItemClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onArrowButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onInviteButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onAddFriendButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onBlockButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onUnBlockButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onShowOnMapButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;
			finish();
		}

		@Override
		public void onSendMessageButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onMeetupButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onCheckChange(String itemId, boolean isChecked) {
			// TODO Auto-generated method stub

		}

	}

	private class PlaceItemListener implements ListItemClickListenerPlace {

		@Override
		public void onItemClick(Place place) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onArrowButtonClick(Place place) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onReviewButtonClick(Place place) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onShowOnMapButtonClick(Place place) {
			// TODO Auto-generated method stub
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = place;
			finish();
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

	}

	@Override
	public void onClick(View v) {

		Utility.hideKeyboardContext(context);

		if (v == btnMapView) {
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
			// toggleSearchPanel();
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
			Toast.makeText(context, "Coming soon.", Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemMessages) {
			Intent messageIntent = new Intent(context, MessageActivity.class);
			finish();
			startActivity(messageIntent);
		} else if (v == btnCircleMenuItemNewsfeed) {
			Toast.makeText(context, "Coming soon.", Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemPeople) {

			Intent peopleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			startActivity(peopleIntent);

			// Toast.makeText(context, "Coming soon People functionality.",
			// Toast.LENGTH_SHORT).show();

		} else if (v == btnCircleMenuItemPlaces) {
			Toast.makeText(context, "Coming soon.", Toast.LENGTH_SHORT).show();

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

	@Override
	public void onMapButtonClick(int flag) {
		Intent intent = new Intent(context, ShowItemOnMap.class);
		intent.putExtra("FLAG", flag);
		startActivity(intent);
	}

	private void doSearch() {
		//
		List<Object> list = (Utility.getSearchResult(listMasterContent,
				etSearchField.getText().toString().trim()));

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

	public void showSearchPanel(boolean display) {
		if (display) {
			searchPanel.setVisibility(View.VISIBLE);

		} else {
			searchPanel.setVisibility(View.GONE);
		}
	}

}
