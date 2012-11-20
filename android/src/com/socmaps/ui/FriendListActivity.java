package com.socmaps.ui;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class FriendListActivity extends Activity implements OnClickListener {

	private enum Audio {
		ATOZ, DISTANCE, CIRCLES
	}

	private class Users {
		private List<People> friendList;
		private HashMap<String, List<String>> circles;
		private HashMap<String, People> friendMap;
	}

	private Context context;
	private Button btnBack, searchBtn, doSearchBtn, aToZBtn, distanceBtn,
			circleBtn;
	private EditText searchQueryEditText;
	private RelativeLayout searchPanel;
	private LinearLayout listContainer;
	private List<People> originalFriendList;
	private List<People> tempFriendList;
	private LayoutInflater inflater;
	private int selectedTab = Audio.ATOZ.ordinal();

	HashMap<String, Boolean> selectedPhoto;
	private ProgressDialog m_ProgressDialog;
	private String friendsResponse;
	private int friendsStatus;
	ImageDownloader imageDownloader;

	String personID = null;

	// String selectedId = null;

	private View selectedView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_list_layout);

		initialize();

		// getFriendsFromServer();

		getFriendList();

		tempFriendList = sortDataAlphabetically(originalFriendList);
		generateListViewForAToZ();

		showHideSearchPanel(true);
	}

	@Override
	protected void onResume() {
		super.onResume();

		reSetView();

	}

	private void initialize() {

		context = FriendListActivity.this;

		personID = getIntent().getStringExtra("ID");
		if (personID != null)
			Log.d("Person ID", personID);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		searchBtn = (Button) findViewById(R.id.btnSearch);
		doSearchBtn = (Button) findViewById(R.id.doSearchBtn);
		aToZBtn = (Button) findViewById(R.id.atozBtn);
		distanceBtn = (Button) findViewById(R.id.distanceFilterBtn);
		circleBtn = (Button) findViewById(R.id.circleFilterBtn);
		searchQueryEditText = (EditText) findViewById(R.id.etFriendSearch);
		searchPanel = (RelativeLayout) findViewById(R.id.searchContainer);
		listContainer = (LinearLayout) findViewById(R.id.list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		selectedPhoto = new HashMap<String, Boolean>();

		imageDownloader = new ImageDownloader();
		imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		if (v == btnBack) {
			finish();
		}

	}

	private void generateListViewForAToZ() {

		listContainer.removeAllViews();
		if (tempFriendList.size() > 0) {
			String startingChar = "";

			LinearLayout itemRow = getAFreshRow();

			int counter = 0;
			for (int i = 0; i < tempFriendList.size(); i++) {
				String firstNameTemp = tempFriendList.get(i).getFirstName();
				if (isHeader(startingChar, firstNameTemp)) {
					if (i > 0) {
						addAlreadyCreatedRow(itemRow);

					}
					counter = 0;
					itemRow = getAFreshRow();
					startingChar = firstNameTemp.charAt(0) + "";
					addHeader(startingChar);

				}
				if (counter % 4 == 0 && i > 0) {
					addAlreadyCreatedRow(itemRow);
					counter = 0;
					itemRow = getAFreshRow();
				}

				selectedPhoto.put(tempFriendList.get(i).getId(), false);

				itemRow.addView(getItemViewFriend(tempFriendList.get(i)));
				counter++;

			}
			addAlreadyCreatedRow(itemRow);
		}
	}

	public View getItemViewFriend(final People people) {

		View v = inflater.inflate(R.layout.friend_item, null);

		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);
		final TextView name = (TextView) v.findViewById(R.id.txtFriendName);

		final RelativeLayout proficPicContainer = (RelativeLayout) v
				.findViewById(R.id.proficPicContainer2);

		Display display = getWindowManager().getDefaultDisplay();

		int width = display.getWidth();

		v.setLayoutParams(new LinearLayout.LayoutParams(width / 4,
				LayoutParams.WRAP_CONTENT));

		final String id = people.getId();

		if (people.getAvatar() != null && people.getAvatar() != "") {
			imageDownloader.download(people.getAvatar(), profilePic);
		}

		if (people.getFirstName() != null && people.getFirstName() != "") {
			name.setText(people.getFirstName());
		}

		/*
		 * if (avatarUrl != null && !avatarUrl.equals("")) {
		 * 
		 * BitmapManager.INSTANCE.setPlaceholder(
		 * BitmapFactory.decodeResource(getResources(),
		 * R.drawable.user_default));
		 * 
		 * BitmapManager.INSTANCE.loadBitmap( avatarUrl, profilePic, 55, 55);
		 * 
		 * 
		 * }
		 */

		profilePic.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (selectedPhoto.get(id)) {
					proficPicContainer
							.setBackgroundResource(R.color.transparent);
					selectedPhoto.put(id, false);
				} else {
					proficPicContainer
							.setBackgroundResource(R.color.highlightGreen);
					selectedPhoto.put(id, true);
					// selectedId = id;
				}
				selectedView = v;

				// go user profile
				Intent profileInt = new Intent(FriendListActivity.this,
						ProfileActivity2.class);
				profileInt.putExtra("otherUser", people);
				startActivity(profileInt);

			}
		});

		return v;
	}

	private void reSetView() {
		// TODO Auto-generated method stub
		if (selectedView != null) {

			// final RelativeLayout proficPicContainer = (RelativeLayout)
			// selectedView
			// .findViewById(R.id.proficPicContainer2);
			// proficPicContainer.setBackgroundResource(R.color.transparent);

			selectedView.setBackgroundResource(R.color.transparent);
		}
	}

	private LinearLayout getAFreshRow() {

		/*
		 * LinearLayout row = new LinearLayout(this);
		 * row.setOrientation(LinearLayout.HORIZONTAL); row.setLayoutParams(new
		 * LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));
		 * row.setPadding(10, 10, 10, 0);
		 */

		LinearLayout row = (LinearLayout) inflater.inflate(
				R.layout.friend_list_row, null);

		return row;
	}

	private void addAlreadyCreatedRow(LinearLayout row) {
		if (row.getChildCount() > 0)
			listContainer.addView(row);

	}

	private void addHeader(String headerText) {
		View header = inflater.inflate(R.layout.friend_list_header, null);
		TextView headerTextView = (TextView) header
				.findViewById(R.id.headerText);
		headerTextView.setText(headerText);
		listContainer.addView(header);
	}

	private boolean isHeader(String startingChar, String firstName) {

		return !(firstName.charAt(0) + "").equalsIgnoreCase(startingChar);

	}

	private void showHideSearchPanel(boolean flag) {

		if (flag)
			searchPanel.setVisibility(View.VISIBLE);
		else
			searchPanel.setVisibility(View.GONE);

	}

	// get friend list from server
	private void getFriendList() {

		originalFriendList = StaticValues.myInfo.getFriendList();

		// // for testing
		// for (int i = 0; i < 10; i++) {
		// People frnd = new People();
		// frnd.setFirstName("Name");
		// frnd.setId("a" + i);
		// originalFriendList.add(frnd);
		// }
		// for (int i = 0; i < 10; i++) {
		// People frnd = new People();
		// frnd.setFirstName("Name");
		// frnd.setId("b" + i);
		// originalFriendList.add(frnd);
		// }
		// for (int i = 0; i < 10; i++) {
		// People frnd = new People();
		// frnd.setFirstName("Name");
		// frnd.setId("c" + i);
		// originalFriendList.add(frnd);
		// }
		// for testing
	}

	/*
	 * Friends from server
	 */
	private void getFriendsFromServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, friendsThread,
					"Start get friends from server");
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

	private Runnable friendsThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient;
			// if(personID == null)
			// {
			// restClient = new RestClient(Constant.smPlaces);
			// }
			// else
			// {
			restClient = new RestClient(Constant.smServerUrl + "/me"
					+ "/friends");
			// }

			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			// restClient.AddParam("users[]", unblockId);

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			friendsResponse = restClient.getResponse();
			friendsStatus = restClient.getResponseCode();

			runOnUiThread(friendsResponseFromServer);
		}
	};

	private Runnable friendsResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseFriends(friendsStatus, friendsResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseFriends(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("Got friends response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			// Toast.makeText(context, "Places response successful.",
			// Toast.LENGTH_SHORT).show();

			// listMasterContent.clear();
			// listMasterContent =
			// ServerResponseParser.parseSavedPlaces(response);
			//
			// sortMasterListData();
			//
			// updateContentList(listMasterContent);
			// updateDisplayList(listContent);

			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	private List<People> sortDataAlphabetically(List<People> friends) {
		Collections.sort(friends, new ListComparatorName());
		return friends;
	}

	private List<People> sortDataWithDistance(List<People> friends) {
		Collections.sort(friends, new ListComparatorName());
		return friends;
	}

	class ListComparatorName implements Comparator<People> {

		@Override
		public int compare(People first, People last) {
			String firstString = first.getFirstName();
			String secondString = last.getFirstName();
			return firstString.compareToIgnoreCase(secondString);
		}

	}

	class ListComparatorDistance implements Comparator<People> {

		@Override
		public int compare(People first, People last) {

			return 0;
		}

	}

	@Override
	protected void onPause() {
		super.onPause();
	}

}
