package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageFetcher;
import com.socmaps.listrow.ListItemClickListenerPeople;
import com.socmaps.listrow.ListItemClickListenerSecondDegreePeople;
import com.socmaps.listrow.PeopleRowFactory2;
import com.socmaps.listrow.RowType;
import com.socmaps.listrow.SecondDegreePeopleRowFactory2;
import com.socmaps.util.Constant;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.ListComparator;
import com.socmaps.widget.MultiDirectionSlidingDrawer;

/**
 * PeopleListActivity class is used show a list of people based on distance,
 * invitation, circle & block/unblock. Each tab has different actions; in
 * block/unblock, user can block/unblock a particular user, in circle, user can
 * create new circle & put people into it or put people from one circle to
 * another or rename a circle, in invitation, user can sent invitation to his
 * facebook friends to use socialmap.
 */

public class PeopleListActivity extends FragmentActivity implements
		OnClickListener, OnCheckedChangeListener {

	private Button btnBack, btnPeopleInvite, btnCirclePeople,
			btnBlockUnblockPeople, btnPeopleByDistance;
	private Button topCloseButton;

	private ListView contentListView;

	private Context context;
	private SearchResult peoplesAndPlacesEntity;
	private ContentListAdapter contentAdapter;

	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;

	boolean isSearchEnabled = false;
	private MultiDirectionSlidingDrawer topDrawer;
	private TopDrawerListener topDrawerListener;
	private CheckBox socialmapsCheckBox, facebookCheckBox;

	private boolean checkBoxFlag = false;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	private EditText etSearchField;
	private RelativeLayout searchPanel;
	private ImageFetcher imageFetcher;
	private ListComparator listComparator;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.people_list_layout);

		initialize();
		getIntentData();
		setListParameters();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		setCheckBoxSelection();
		populateMasterList();

		updateContentList(listMasterContent);
		updateDisplayList(listContent);

		imageFetcher.setExitTasksEarly(false);
	}
	
	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		imageFetcher.setExitTasksEarly(true);
	    imageFetcher.flushCache();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		imageFetcher.closeCache();
	}

	/*
	 * All initialize
	 */
	private void initialize() {

		context = PeopleListActivity.this;
		
		listComparator = new ListComparator();
		
		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnPeopleByDistance = (Button) findViewById(R.id.btnPeopleByDistance);
		btnPeopleByDistance.setOnClickListener(this);
		btnPeopleByDistance.setBackgroundColor(Color.LTGRAY);

		btnPeopleInvite = (Button) findViewById(R.id.btnPeopleInvite);
		btnPeopleInvite.setOnClickListener(this);

		btnCirclePeople = (Button) findViewById(R.id.btnPeopleCircle);
		btnCirclePeople.setOnClickListener(this);

		btnBlockUnblockPeople = (Button) findViewById(R.id.btnPeopleBlockUnblock);
		btnBlockUnblockPeople.setOnClickListener(this);

		contentListView = (ListView) findViewById(R.id.people_list);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

		topDrawerListener = new TopDrawerListener();
		topDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.topDrawer);
		topDrawer.setOnDrawerOpenListener(topDrawerListener);
		topDrawer.setOnDrawerCloseListener(topDrawerListener);
		topCloseButton = (Button) topDrawer.findViewById(R.id.topHandle);

		View v = topDrawer.findViewById(R.id.topSliderContent);
		socialmapsCheckBox = (CheckBox) v
				.findViewById(R.id.chkMenuItemSocialMaps);
		facebookCheckBox = (CheckBox) v.findViewById(R.id.chkMenuItemFacebook);

		setOnCheckChangeListener();

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		imageFetcher = new ImageFetcher(context);

	}

	@Override
	public void onClick(View v) {

		Utility.hideKeyboardContext(context);

		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {

			isSearchEnabled = true;
			doSearch();
			hideKeybord();

		} else if (v == btnClearSearch) {

			isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();
			hideKeybord();

		} else if (v == btnPeopleInvite) {

			Intent inviteIntent = new Intent(getApplicationContext(),
					PeopleInviteActivity.class);

			inviteIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(inviteIntent);

			finish();

		} else if (v == btnCirclePeople) {
			Intent circleIntent = new Intent(getApplicationContext(),
					PeopleCircleActivity.class);
			circleIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(circleIntent);
			finish();

		} else if (v == btnBlockUnblockPeople) {
			Intent blickUnblockiIntent = new Intent(getApplicationContext(),
					PeopleBlockUnblockActivity.class);
			blickUnblockiIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(blickUnblockiIntent);
			finish();
		} else if (v == btnBack) {
			finish();

		}

	}

	private void getIntentData() {

		peoplesAndPlacesEntity = StaticValues.searchResult;

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

	private void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Object> items;

		public ContentListAdapter(Context context, List<Object> itemsList) {

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
				return PeopleRowFactory2.getView(LayoutInflater.from(context),
						items.get(position), context, convertView,
						imageFetcher, new PeopleItemListener());
			}
			if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal()) {
				return SecondDegreePeopleRowFactory2.getView(
						LayoutInflater.from(context), items.get(position),
						context, convertView, imageFetcher,
						new SecondDegreePeopleItemListener());
			} else {
				return null;
			}

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
							Constant.PEOPLE_SOCIALMAPS, true)) {
				listDisplayableContent.add(item);
				displayedItemCounter++;
			}
			if (item instanceof SecondDegreePeople
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PEOPLE_FACEBOOK, true)) {
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

	private void setCheckBoxSelection() {

		socialmapsCheckBox.setChecked(SharedPreferencesHelper.getInstance(
				context).getBoolean(Constant.PEOPLE_SOCIALMAPS, true));
		facebookCheckBox.setChecked(SharedPreferencesHelper
				.getInstance(context)
				.getBoolean(Constant.PEOPLE_FACEBOOK, true));

	}

	private void setOnCheckChangeListener() {
		// TODO Auto-generated method stub
		checkBoxFlag = true;
		socialmapsCheckBox.setOnCheckedChangeListener(this);
		facebookCheckBox.setOnCheckedChangeListener(this);

		checkBoxFlag = false;
	}

	private void populateMasterList() {
		listMasterContent.clear();
		addPeoplesToMasterList();
		addSecondDegreePeoplesToMasterList();

		sortMasterListData();
	}

	private void addPeoplesToMasterList() {

		if (peoplesAndPlacesEntity != null) {

			if (peoplesAndPlacesEntity.getPeoples() != null) {
				for (int i = 0; i < peoplesAndPlacesEntity.getPeoples().size(); i++) {
					listMasterContent.add(peoplesAndPlacesEntity.getPeoples()
							.get(i));
				}
			}

		}
	}

	private void addSecondDegreePeoplesToMasterList() {
		if (peoplesAndPlacesEntity != null) {

			if (peoplesAndPlacesEntity.getSecondDegreePeoples() != null) {

				for (int i = 0; i < peoplesAndPlacesEntity
						.getSecondDegreePeoples().size(); i++) {
					listMasterContent.add(peoplesAndPlacesEntity
							.getSecondDegreePeoples().get(i));
				}
			}
		}
	}

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, listComparator);
	}

	

	private class PeopleItemListener implements ListItemClickListenerPeople {

		@Override
		public void onItemClick(People people) {
			// TODO Auto-generated method stub
			// send user to profile screen with people object
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
		public void onShowOnMapButtonClick(Object people) {
			// TODO Auto-generated method stub

			// StaticValues.isHighlightAnnotation = true;
			// StaticValues.highlightAnnotationItem = people;
			// finish();

			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);
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
		public void onSendMessageButtonClick(
				SecondDegreePeople secondDegreePeople) {
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
			Drawable closeIcon = getResources().getDrawable(
					R.drawable.btn_slider_close);
			topCloseButton.setBackgroundDrawable(closeIcon);
		}

	}

	@Override
	public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		// TODO Auto-generated method stub
		if (!checkBoxFlag) {
			if (buttonView == socialmapsCheckBox) {
				SharedPreferencesHelper.getInstance(context).setBoolean(
						Constant.PEOPLE_SOCIALMAPS, isChecked);

			}

			if (buttonView == facebookCheckBox) {

				SharedPreferencesHelper.getInstance(context).setBoolean(
						Constant.PEOPLE_FACEBOOK, isChecked);

			}

			updateDisplayList(listContent);
		}
	}

	/*
	 * Hide Keybord
	 */

	private void hideKeybord() {
		InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(etSearchField.getWindowToken(), 0);
	}

	/*
	 * Search portion
	 */

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

	private void showSearchPanel(boolean display) {
		if (display) {
			searchPanel.setVisibility(View.VISIBLE);

		} else {
			searchPanel.setVisibility(View.GONE);
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (searchPanel.isShown()) {
				showSearchPanel(false);
			} else {
				finish();
			}

		}
		return false;

	}
}
