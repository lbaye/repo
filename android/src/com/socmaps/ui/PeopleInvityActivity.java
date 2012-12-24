package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

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

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.fb.BaseDialogListener;
import com.socmaps.fb.FBUtility;
import com.socmaps.fb.SessionEvents;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.ListItemClickListener;
import com.socmaps.listrow.ListItemClickListenerSecondDegreePeople;
import com.socmaps.listrow.RowType;
import com.socmaps.listrow.SecondDegreePeopleRowFactoryPeopleInvite;
import com.socmaps.util.Constant;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * PeopleInvityActivity class is used to send invitation to second degree friends(facebook friends) of user. 
 */

public class PeopleInvityActivity extends Activity implements OnClickListener,
		ListItemClickListener {

	private Context context;

	View requestItemView;

	private boolean isSearchEnabled = false;
	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch,
			btnSeleceUnselectAllUser, btnCancelInvite, btnBack,
			btnInvitePeople, btnCirclePeople, btnBlockUnblockPeople,
			btnPeopleByDistance, btnInviteSelectedUsers;

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

	private FbAPIsAuthListener fbAPIsAuthListener;
	private FbAPIsLogoutListener fbAPIsLogoutListener;

	private List<String> idList = new ArrayList<String>();

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.people_invite_tab_layout);

		initialize();
		setListParameters();
		populateListData();

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

	}

	private void populateListData() {
		populateMasterList();
		updateContentList(listMasterContent);
		updateDisplayList(listContent);
	}

	private void initialize() {
		
		context = PeopleInvityActivity.this;
		
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
		btnInvitePeople.setBackgroundColor(Color.LTGRAY);

		btnCirclePeople = (Button) findViewById(R.id.btnCirclePeople);
		btnCirclePeople.setOnClickListener(this);

		btnBlockUnblockPeople = (Button) findViewById(R.id.btnBlockUnblockPeople);
		btnBlockUnblockPeople.setOnClickListener(this);

		contentListView = (ListView) findViewById(R.id.people_list);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

		btnSeleceUnselectAllUser = (Button) findViewById(R.id.btnSeleceUnselectAllUser);
		btnSeleceUnselectAllUser.setOnClickListener(this);

		btnCancelInvite = (Button) findViewById(R.id.btnCancelInvite);
		btnCancelInvite.setOnClickListener(this);

		btnInviteSelectedUsers = (Button) findViewById(R.id.btnInviteSelectedUsers);
		btnInviteSelectedUsers.setOnClickListener(this);

		fbAPIsAuthListener = new FbAPIsAuthListener();
		fbAPIsLogoutListener = new FbAPIsLogoutListener();

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

			hideKeybord();

			doSearch();

		} else if (v == btnPeopleByDistance) {

			Intent circleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			circleIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(circleIntent);
			finish();

		} else if (v == btnInvitePeople) {

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
		} else if (v == btnSeleceUnselectAllUser) {

			if (isAllSelect) {
				StaticValues.PEOPLE_SELECT_ALL_USERS = false;
				btnSeleceUnselectAllUser
						.setText(getString(R.string.selectAllLabel));
			} else {
				StaticValues.PEOPLE_SELECT_ALL_USERS = true;
				btnSeleceUnselectAllUser
						.setText(getString(R.string.unselectAllLabel));
			}

			isAllSelect = !isAllSelect;

			for (int i = 0; i < listDisplayableContent.size(); i++) {

				selectedArrayList.put(
						((SecondDegreePeople) listDisplayableContent.get(i))
								.getRefId(), isAllSelect);

			}

			updateListView();

		} else if (v == btnCancelInvite) {

			Intent peopleList = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			peopleList.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(peopleList);
			finish();

		} else if (v == btnInviteSelectedUsers) {

			int checkCounter = 0;

			idList.clear();

			for (String key : selectedArrayList.keySet()) {

				boolean value = selectedArrayList.get(key);

				if (value) {
					checkCounter++;
					idList.add(key);
				}

			}
			Log.i("Total Checked:", "" + checkCounter);

			// sendSelectedPeopleToServer();
			if (checkCounter == 0) {
				Toast.makeText(context, "No friend is selected to invite.",
						Toast.LENGTH_SHORT).show();
			} else if (checkCounter > 50) {
				Toast.makeText(context,
						"You can't invite more than 50 users at a time.",
						Toast.LENGTH_SHORT).show();
			} else {
				if (StaticValues.myInfo.getRegMedia().equalsIgnoreCase("fb")
						&& FBUtility.mFacebook != null) {
					initInviteFriends();
				} else {
					initInvitationDialog();
				}
			}

		} else if (v == btnBack) {
			finish();
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
			if (items.get(position) instanceof SecondDegreePeople) {

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

			if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal()) {
				return SecondDegreePeopleRowFactoryPeopleInvite.getView(
						LayoutInflater.from(context), items.get(position),
						context, PeopleInvityActivity.this, convertView,
						imageDownloader, new SecondDegreePeopleItemListener(),
						selectedArrayList.get(((SecondDegreePeople) items
								.get(position)).getRefId()));

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

				selectedArrayList.put(((SecondDegreePeople) item).getRefId(),
						false);

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

		listMasterContent.clear();

		if (peoplesAndPlacesEntity != null) {

			addSecondDegreePeoplesToMasterList();

			sortMasterListData();
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
				return ((Place) object).getDistance();
			else
				return 0;
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
			Toast.makeText(context, "Comming soon", Toast.LENGTH_SHORT).show();

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

	// **** Invite fb friends ******************************

	private void initInvitationDialog() {
		// TODO Auto-generated method stub
		FBUtility.mFacebook = new Facebook(Constant.FB_APP_ID);
		FBUtility.mAsyncRunner = new AsyncFacebookRunner(FBUtility.mFacebook);

		SessionEvents.addAuthListener(fbAPIsAuthListener);
		SessionEvents.addLogoutListener(fbAPIsLogoutListener);

		FBUtility.mFacebook.authorize((Activity) context,
				Constant.facebookPermissions, new LoginDialogListener());

	}

	private class FbAPIsAuthListener implements AuthListener {

		// @Override
		@Override
		public void onAuthSucceed() {

			initInviteFriends();

		}

		// @Override
		@Override
		public void onAuthFail(String error) {
			Log.e("PeopleInviteActivity", "Login Failed: " + error);
		}
	}

	/*
	 * The Callback for notifying the application when log out starts and
	 * finishes.
	 */
	private class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		@Override
		public void onLogoutBegin() {
			Log.e("PeopleInviteActivity", "Logging out...");
		}

		// @Override
		@Override
		public void onLogoutFinish() {
			Log.e("PeopleInviteActivity", "You have logged out! ");

			Utility.setFacebookImage(context, null);
			FBUtility.mFacebook.authorize((Activity) context,
					Constant.facebookPermissions, Facebook.FORCE_DIALOG_AUTH,
					new LoginDialogListener());
		}
	}

	private final class LoginDialogListener implements DialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			Log.e(" PeopleInviteActivity LoginDialogListener", "onComplete");
			SessionEvents.onLoginSuccess();
		}

		// @Override
		@Override
		public void onFacebookError(FacebookError error) {
			Log.e("PeopleInviteActivity LoginDialogListener", "onFacebookError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onError(DialogError error) {
			Log.e("PeopleInviteActivity LoginDialogListener", "onError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		@Override
		public void onCancel() {
			Log.e("PeopleInviteActivity LoginDialogListener", "onCancel");
			SessionEvents.onLoginError("Action Canceled");
		}
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		FBUtility.mFacebook.authorizeCallback(requestCode, resultCode, data);
	}

	private void initInviteFriends() {
		Log.d("PeopleInviteActivity Facebook", "Have to invite");

		if (Utility.isConnectionAvailble(context)) {

			showInvitationDialog();

		} else {
			Toast.makeText(getApplicationContext(),
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}
	}

	private void showInvitationDialog() {

		String idString = "";
		if (idList != null) {
			for (int i = 0; i < idList.size(); i++) {
				idString += idList.get(i) + ",";
			}
		}
		if (idString.length() > 1) {
			idString = idString.substring(0, idString.length() - 1);
		}
		Log.i("IdList", idString);

		Bundle params = new Bundle();
		params.putString("message", "Checkout the app.");
		params.putString("to", idString);
		FBUtility.mFacebook.dialog(context, "apprequests", params,
				new AppRequestsListener());
	}

	/*
	 * callback for the apprequests dialog which sends an app request to user's
	 * friends.
	 */
	private class AppRequestsListener extends BaseDialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {

		}

		@Override
		public void onFacebookError(FacebookError error) {

		}

		@Override
		public void onCancel() {

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
		StaticValues.PEOPLE_SELECT_ALL_USERS = false;
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		SessionEvents.removeAuthListener(fbAPIsAuthListener);
		SessionEvents.removeLogoutListener(fbAPIsLogoutListener);

		System.gc();
		super.onDestroy();

	}

}
