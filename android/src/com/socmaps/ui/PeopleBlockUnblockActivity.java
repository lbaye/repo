package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.ListItemClickListener;
import com.socmaps.listrow.ListItemClickListenerPeople;
import com.socmaps.listrow.PeopleRowFactoryBlockUnblock;
import com.socmaps.listrow.RowType;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * PeopleBlockUnblockActivity class is used to block & unblock of a particular user or a group of users from the list of people. 
 */

public class PeopleBlockUnblockActivity extends Activity implements
		OnClickListener, ListItemClickListener {

	private Context context;
	private boolean isSearchEnabled = false;
	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch,
			btnSeleceUnselectAllUser, btnCancelInvite, btnBack,
			btnInvitePeople, btnCirclePeople, btnBlockUnblockPeople,
			btnSelectedFriends, btnPeopleByDistance;

	private EditText etSearchField;
	private RelativeLayout searchPanel;

	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;
	private ListView contentListView;
	private ContentListAdapter contentAdapter;
	private SearchResult peoplesAndPlacesEntity;

	private boolean isAllSelect = false;

	private HashMap<String, Boolean> selectedArrayList;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.people_block_unblock_tab_layout);

		initialize();

		setListParameters();
		populateListData();

	}

	private void populateListData() {
		populateMasterList();
		updateContentList(listMasterContent);
		updateDisplayList(listContent);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

	}

	private void initialize() {

		context = PeopleBlockUnblockActivity.this;

		selectedArrayList = new HashMap<String, Boolean>();

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnPeopleByDistance = (Button) findViewById(R.id.btnPeopleByDistance);
		btnPeopleByDistance.setOnClickListener(this);

		btnInvitePeople = (Button) findViewById(R.id.btnInvitePeople);
		btnInvitePeople.setOnClickListener(this);

		btnCirclePeople = (Button) findViewById(R.id.btnCirclePeople);
		btnCirclePeople.setOnClickListener(this);

		btnBlockUnblockPeople = (Button) findViewById(R.id.btnBlockUnblockPeople);
		btnBlockUnblockPeople.setOnClickListener(this);
		btnBlockUnblockPeople.setBackgroundColor(Color.LTGRAY);

		contentListView = (ListView) findViewById(R.id.people_block_unblock_list);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

		btnSeleceUnselectAllUser = (Button) findViewById(R.id.btnSeleceUnselectAllUser);
		btnSeleceUnselectAllUser.setOnClickListener(this);

		btnCancelInvite = (Button) findViewById(R.id.btnCancelInvite);
		btnCancelInvite.setOnClickListener(this);

		btnSelectedFriends = (Button) findViewById(R.id.btnSelectedFriends);
		btnSelectedFriends.setOnClickListener(this);

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

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
		} else if (v == btnPeopleByDistance) {

			Intent circleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			circleIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(circleIntent);
			finish();

		} else if (v == btnInvitePeople) {

			Intent inviteIntent = new Intent(getApplicationContext(),
					PeopleInvityActivity.class);

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

		} else if (v == btnSeleceUnselectAllUser) {

			isAllSelect = !isAllSelect;

			String unit = "";
			if (isAllSelect) {

				btnSeleceUnselectAllUser
						.setText(getString(R.string.unselectAllLabel));
				unit = getString(R.string.unselectAllLabel);
			} else {

				btnSeleceUnselectAllUser
						.setText(getString(R.string.selectAllLabel));
				unit = getString(R.string.selectAllLabel);
			}

			for (int i = 0; i < listDisplayableContent.size(); i++) {

				((People) listDisplayableContent.get(i)).setUnit(unit);

			}

			updateListView();

			for (int i = 0; i < listDisplayableContent.size(); i++) {

				selectedArrayList.put(
						((People) listDisplayableContent.get(i)).getId(),
						isAllSelect);

			}

		} else if (v == btnCancelInvite) {
			Intent peopleList = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			peopleList.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(peopleList);
			finish();

		} else if (v == btnSelectedFriends) {
			Log.w("PeopleBlockUnblockActivity listDisplayableContent ",
					"Size : " + listDisplayableContent.size());

			Log.w("PeopleBlockUnblockActivity selectedArrayList ", "Size : "
					+ selectedArrayList.size());

			int checkCounter = 0;

			for (String key : selectedArrayList.keySet()) {

				boolean value = selectedArrayList.get(key);

				if (value) {

					checkCounter++;
				}

			}
			Log.i("Total Checked:", "" + checkCounter);

			blockOrUnblockSelectedUsers();

		} else if (v == btnBack) {

			finish();

		}

	}

	private void blockOrUnblockSelectedUsers() {

		String url = Constant.smBlockUnblockUrl;

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		for (String key : selectedArrayList.keySet()) {

			boolean value = selectedArrayList.get(key);

			if (value) {

				params.add(new BasicNameValuePair("users[]", key));
			}

		}

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.GET_SERVER_DATA, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.PUT);

	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String result, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :",
					status + ":" + result);
			switch (status) {
			case Constant.STATUS_SUCCESS:
				Toast.makeText(context, "Request sent successfully.",
						Toast.LENGTH_SHORT).show();

				for (int i = 0; i < StaticValues.searchResult.getPeoples()
						.size(); i++) {

					People p = StaticValues.searchResult.getPeoples().get(i);

					StaticValues.searchResult.getPeoples().get(i)
							.setBlocked(selectedArrayList.get(p.getId()));

					StaticValues.searchResult.getPeoples().get(i).setUnit("");

				}

				populateListData();

				break;

			default:
				Toast.makeText(getApplicationContext(),
						"An unknown error occured. Please try again!!",
						Toast.LENGTH_SHORT).show();
				break;

			}

		}

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

		for (Object peopleObj : listDisplayableContent) {
			People people = (People) peopleObj;
			selectedArrayList.put(people.getId(), people.isBlocked());
		}

		contentAdapter.notifyDataSetChanged();
	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Object> items;
		private ImageDownloader imageDownloader;

		public ContentListAdapter(Context context, List<Object> itemsList) {

			this.items = itemsList;
			imageDownloader = ImageDownloader.getInstance();
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
				return PeopleRowFactoryBlockUnblock.getView(
						LayoutInflater.from(context), items.get(position),
						context, PeopleBlockUnblockActivity.this, convertView,
						imageDownloader, new PeopleItemListener());
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

	private void populateMasterList() {

		peoplesAndPlacesEntity = StaticValues.searchResult;

		if (peoplesAndPlacesEntity != null) {

			listMasterContent.clear();

			addPeoplesToMasterList();

			sortMasterListData();
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

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, new ListComparator());
	}

	private class ListComparator implements Comparator<Object> {

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
				return ((SecondDegreePeople) object).getDistance();
			else
				return 0;
		}

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
		public void onShowOnMapButtonClick(People people) {
			// TODO Auto-generated method stub
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);

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
			selectedArrayList.put(itemId, isChecked);
		}

	}



	@Override
	public void onMapButtonClick(int flag) {
		// TODO Auto-generated method stub
		Intent intent = new Intent(context, ShowItemOnMap.class);
		intent.putExtra("FLAG", flag);
		startActivity(intent);
	}

	

	/*
	 * Hide Keybord
	 */

	private void hideKeybord() {
		InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(etSearchField.getWindowToken(), 0);
	}

	/*
	 * Search Partion
	 */
	private void doSearch() {

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

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
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

		for (int i = 0; i < StaticValues.searchResult.getPeoples().size(); i++) {

			StaticValues.searchResult.getPeoples().get(i).setUnit("");

		}

	}

}
