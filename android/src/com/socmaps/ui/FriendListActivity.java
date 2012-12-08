package com.socmaps.ui;

import java.security.acl.Owner;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class FriendListActivity extends Activity implements OnClickListener {

	private enum SelectedTab {
		ATOZ, DISTANCE, CIRCLES
	}

	private class Users {
		private List<People> friendList;
		private HashMap<String, List<String>> circles;
		private HashMap<String, People> friendMap;
	}

	private Context context;
	private Button btnBack, aToZBtn, distanceBtn, circleBtn, btnNotification;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	// boolean isSearchEnabled = false;
	private EditText etSearchField;
	private RelativeLayout searchPanel;
	private LinearLayout listContainer;

	private List<People> originalFriendList;
	private List<People> tempFriendList;

	private List<People> tempFriendListDistance;

	private LayoutInflater inflater;
	private int selectedTab;

	HashMap<String, Boolean> selectedPhoto;
	private ProgressDialog m_ProgressDialog;
	private String friendsResponse;
	private int friendsStatus;
	private ImageDownloader imageDownloader;

	private String personID = null;

	// String selectedId = null;

	// private View selectedView;

	private List<Circle> mainCircleList;

	private List<Circle> tempCircleList;

	private int colorButtonSelected;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_list_layout);

		initialize();

		//personID = StaticValues.myInfo.getId();
		personID = getIntent().getStringExtra("PERSON_ID");
		
		if(personID == null)
		{
			if(StaticValues.myInfo!=null)
			{
				personID = StaticValues.myInfo.getId();
			}
		}

		if (personID != null) {

			getFriendsOfFriendsFromServer();

			Log.w("FriendListActivity onCreate", "personID not null");

		}/* else {

			getFriendList();

			updateContentList(originalFriendList);

			updateCircleContentList(mainCircleList);

			generateListViewForAToZ();

			Log.w("FriendListActivity onCreate", "personID is null");

		}*/

	}

	@Override
	protected void onResume() {
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);
		// reSetView();

	}

	private void initialize() {

		context = FriendListActivity.this;

		personID = getIntent().getStringExtra("PERSON_ID");
		if (personID != null)
			Log.d("Person ID", personID);

		selectedTab = SelectedTab.ATOZ.ordinal();

		colorButtonSelected = getResources().getColor(R.color.gray_light);

		tempFriendList = new ArrayList<People>();
		originalFriendList = new ArrayList<People>();
		tempFriendListDistance = new ArrayList<People>();
		mainCircleList = new ArrayList<Circle>();
		tempCircleList = new ArrayList<Circle>();

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);
		btnToggleSearchPanel.setVisibility(View.VISIBLE);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);
		etSearchField = (EditText) findViewById(R.id.etSearchField);
		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		aToZBtn = (Button) findViewById(R.id.atozBtn);
		aToZBtn.setOnClickListener(this);
		aToZBtn.setBackgroundColor(colorButtonSelected);

		distanceBtn = (Button) findViewById(R.id.distanceFilterBtn);
		distanceBtn.setOnClickListener(this);

		circleBtn = (Button) findViewById(R.id.circleFilterBtn);
		circleBtn.setOnClickListener(this);

		listContainer = (LinearLayout) findViewById(R.id.list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		selectedPhoto = new HashMap<String, Boolean>();

		//imageDownloader = new ImageDownloader();
		//imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
		imageDownloader = ImageDownloader.getInstance();
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		Utility.hideKeyboardContext(context);

		if (v == btnBack) {
			finish();
		}

		else if (v == circleBtn && selectedTab != SelectedTab.CIRCLES.ordinal()) {

			generateListViewForCircles();

			resetButtonBackgroundColor(v);

			selectedTab = SelectedTab.CIRCLES.ordinal();

		} else if (v == aToZBtn && selectedTab != SelectedTab.ATOZ.ordinal()) {

			generateListViewForAToZ();

			resetButtonBackgroundColor(v);
			selectedTab = SelectedTab.ATOZ.ordinal();

		} else if (v == distanceBtn
				&& selectedTab != SelectedTab.DISTANCE.ordinal()) {

			generateListViewForDistance();

			resetButtonBackgroundColor(v);
			selectedTab = SelectedTab.DISTANCE.ordinal();

		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(context,
					NotificationActivity.class);

			startActivity(notificationIntent);

		}

		/*
		 * Search Related
		 */
		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			// isSearchEnabled = true;
			doSearch();

		} else if (v == btnClearSearch) {
			// isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();

		}

	}

	private void resetButtonBackgroundColor(View v) {
		// TODO Auto-generated method stub
		circleBtn.setBackgroundColor(Color.TRANSPARENT);
		aToZBtn.setBackgroundColor(Color.TRANSPARENT);
		distanceBtn.setBackgroundColor(Color.TRANSPARENT);

		v.setBackgroundColor(colorButtonSelected);

	}

	private void generateListViewForAToZ() {

		listContainer.removeAllViews();
		// Log.w("generateListViewForAToZ() a to z", tempFriendList.size()
		// + " before sort size of tempFriendList");

		sortDataAlphabetically();

		if (tempFriendList != null) {

			Log.i("generateListViewForAToZ() a to z", tempFriendList.size()
					+ "After sort size of tempFriendList");

			// if (tempFriendList.size() > 0) {
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

		// }
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

		name.setText(Utility.getFieldText(people));

		// if (people.getFirstName() != null && people.getFirstName() != "") {
		// name.setText(people.getFirstName());
		// }

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

				/*
				 * if (selectedPhoto.get(id)) { proficPicContainer
				 * .setBackgroundResource(R.color.transparent);
				 * selectedPhoto.put(id, false); } else { proficPicContainer
				 * .setBackgroundResource(R.color.highlightGreen);
				 * selectedPhoto.put(id, true); // selectedId = id; }
				 * selectedView = v;
				 */

				// go user profile

				if (people.getId().equals(StaticValues.myInfo.getId())) {
					Intent intent = new Intent(context, ProfileActivity.class);
					startActivity(intent);
				} else {
					Intent profileInt = new Intent(FriendListActivity.this,
							ProfileActivity2.class);
					profileInt.putExtra("otherUser", people);
					startActivity(profileInt);

				}

			}
		});

		return v;
	}

	// private void reSetView() {
	// // TODO Auto-generated method stub
	// if (selectedView != null) {
	//
	// // final RelativeLayout proficPicContainer = (RelativeLayout)
	// // selectedView
	// // .findViewById(R.id.proficPicContainer2);
	// // proficPicContainer.setBackgroundResource(R.color.transparent);
	//
	// selectedView.setBackgroundResource(R.color.transparent);
	// }
	// }

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

	private boolean isHeaderCircle(String startingChar, String firstName) {

		return !(firstName.equalsIgnoreCase(startingChar));

	}

	private boolean isHeaderDistance(String startingDistance, String firstName) {

		return !(firstName.equalsIgnoreCase(startingDistance));

	}

	// get friend list from server
	private void getFriendList() {

		for (People people : StaticValues.myInfo.getFriendList()) {

			originalFriendList.add(people);

		}

		for (Circle circle : StaticValues.myInfo.getCircleList()) {

			mainCircleList.add(circle);
		}

	}

	public void updateContentList(List<People> list) {

		if (list != null) {

			tempFriendList.clear();
			tempFriendList.addAll(list);

			tempFriendListDistance.clear();
			tempFriendListDistance.addAll(list);
		}

	}

	public void updateCircleContentList(List<Circle> list) {

		if (list != null) {

			tempCircleList.clear();
			tempCircleList.addAll(list);

		}

	}

	/*
	 * Friends from server
	 */
	private void getFriendsOfFriendsFromServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, friendsThread,
					"Start get friends from server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true,true);

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
			restClient = new RestClient(Constant.smServerUrl + "/" + personID
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
			if(m_ProgressDialog!=null){
			m_ProgressDialog.dismiss();
			}
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

			try {

				JSONObject jsonObject = new JSONObject(response);

				if (!jsonObject.isNull("friends")) {

					JSONArray jArrayFriends = jsonObject
							.getJSONArray("friends");

					originalFriendList = ServerResponseParser
							.parsePeoples(jArrayFriends);						

				}

				if (!jsonObject.isNull("circles")) {

					JSONArray jArrayCircles = jsonObject
							.getJSONArray("circles");

					mainCircleList = ServerResponseParser
							.getCircleList(jArrayCircles);
					

				}

				if(StaticValues.myInfo!=null)
				{
					if (originalFriendList != null && mainCircleList != null
							&& personID.equals(StaticValues.myInfo.getId())) {
						StaticValues.myInfo.setFriendList(originalFriendList);
						StaticValues.myInfo.setCircleList(mainCircleList);
					}
				}
				

				updateContentList(originalFriendList);
				updateCircleContentList(mainCircleList);

				generateListViewForAToZ();

			} catch (JSONException e) {
				// TODO: handle exception
			}

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

	// private List<People> sortDataWithDistance(List<People> friends) {
	// Collections.sort(friends, new ListComparatorName());
	// return friends;
	// }

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

	private void generateListViewForCircles() {

		listContainer.removeAllViews();

		if (tempCircleList != null) {

			for (int i = 0; i < tempCircleList.size(); i++) {

				List<People> circleFriendList = tempCircleList.get(i)
						.getFriendList();

				if (circleFriendList.size() > 0) {

					String startingCircleName = "";

					LinearLayout itemRow = getAFreshRow();

					int counter = 0;
					for (int j = 0; j < circleFriendList.size(); j++) {

						if (originalFriendList != null) {

							People people = Utility.getPeopleById(
									circleFriendList.get(j).getId(),
									originalFriendList);

							if (people != null) {
								if (isHeaderCircle(startingCircleName,
										tempCircleList.get(i).getName())) {
									if (j > 0) {
										addAlreadyCreatedRow(itemRow);

									}
									counter = 0;
									itemRow = getAFreshRow();
									startingCircleName = tempCircleList.get(i)
											.getName() + "";
									addHeader(startingCircleName);

								}
								if (counter % 4 == 0 && j > 0) {
									addAlreadyCreatedRow(itemRow);
									counter = 0;
									itemRow = getAFreshRow();
								}

								selectedPhoto.put(circleFriendList.get(j)
										.getId(), false);

								// itemRow.addView(getItemViewFriend(circleFriendList
								// .get(j)));

								itemRow.addView(getItemViewFriend(people));

								counter++;
							}

						}

						// String firstNameTemp = circleFriendList.get(j)
						// .getFirstName();

					}
					addAlreadyCreatedRow(itemRow);
				}

			}

		}
	}

	private void generateListViewForDistance() {

		listContainer.removeAllViews();

		sortMasterListDistance();

		// tempFriendList = originalFriendList;

		if (tempFriendListDistance != null) {
			String startingDistance = "";

			LinearLayout itemRow = getAFreshRow();

			int counter = 0;
			for (int i = 0; i < tempFriendListDistance.size(); i++) {

				People people = tempFriendListDistance.get(i);

				// String distance = Utility.getFormatedDistance(Utility
				// .calculateDistance(StaticValues.myPoint, new GeoPoint(
				// (int) (people.getCurrentLat() * 1E6),
				// (int) (people.getCurrentLng() * 1E6))),
				// StaticValues.myInfo.getSettings().getUnit());

				double distances = Utility.calculateDistance(
						StaticValues.myPoint,
						new GeoPoint((int) (people.getCurrentLat() * 1E6),
								(int) (people.getCurrentLng() * 1E6)));

				Log.w("distances:" + distances, "distanceLabel(distances):"
						+ distanceLabel(distances));

				if (isHeaderDistance(startingDistance, distanceLabel(distances))) {
					if (i > 0) {
						addAlreadyCreatedRow(itemRow);

					}
					counter = 0;
					itemRow = getAFreshRow();

					startingDistance = distanceLabel(distances);

					addHeader(startingDistance);

				}

				if (counter % 4 == 0 && i > 0) {
					addAlreadyCreatedRow(itemRow);
					counter = 0;
					itemRow = getAFreshRow();
				}

				selectedPhoto.put(tempFriendListDistance.get(i).getId(), false);

				itemRow.addView(getItemViewFriend(tempFriendListDistance.get(i)));
				counter++;

			}
			addAlreadyCreatedRow(itemRow);
		}
	}

	private String distanceLabel(double distances) {

		String distanceLabel = "";

		if (distances >= 0 && distances <= 500) {

			distanceLabel = "< 500 m";

		} else if (distances > 500 && distances <= 1000) {
			distanceLabel = "< 1 km";
		} else if (distances > 1000) {

			distanceLabel = "1 km +";

		}

		return distanceLabel;
	}

	private void sortDataAlphabetically() {

		if (this.tempFriendList != null) {
			Collections.sort(tempFriendList, new ListComparatorName());
		}

	}

	private void sortMasterListDistance() {

		if (this.tempFriendListDistance != null) {
			Collections.sort(this.tempFriendListDistance, new ListComparator());
		}
	}

	/*
	 * private void sortDisplayableListData() {
	 * Collections.sort(this.listDisplayableContent, new ListComparator()); }
	 */

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
			else if (object instanceof SecondDegreePeople)
				return ((SecondDegreePeople) object).getDistance();
			else
				return 0;
		}

	}

	private void toggleSearchPanel() {
		if (!searchPanel.isShown())
			searchPanel.setVisibility(View.VISIBLE);
		else
			searchPanel.setVisibility(View.GONE);
	}

	/*
	 * Search portion
	 */

	private void doSearch() {

		if (selectedTab == SelectedTab.ATOZ.ordinal()) {

			// It is for A to Z search
			List<Object> dataList = new ArrayList<Object>();
			dataList.addAll(originalFriendList);

			List<Object> list = Utility.getSearchResult(dataList, etSearchField
					.getText().toString().trim());

			tempFriendList.clear();

			Log.w("doSearch() a to z", list.size() + " size of list");

			for (Object obj : list) {
				tempFriendList.add((People) obj);
			}

			generateListViewForAToZ();

		} else if (selectedTab == SelectedTab.DISTANCE.ordinal()) {

			// It is for distance search

			List<Object> dataList = new ArrayList<Object>();
			dataList.addAll(originalFriendList);

			List<Object> list = Utility.getSearchResult(dataList, etSearchField
					.getText().toString().trim());

			tempFriendListDistance.clear();

			Log.w("doSearch() distance", list.size() + " size of list");

			for (Object obj : list) {
				tempFriendListDistance.add((People) obj);
			}

			generateListViewForDistance();

		} else if (selectedTab == SelectedTab.CIRCLES.ordinal()) {
			// It is for circle search

			// List<Circle> dataList = new ArrayList<Circle>();
			// dataList.addAll(mainCircleList);

			List<Circle> list = Utility.getSearchResultFromCircle(
					mainCircleList, originalFriendList, etSearchField.getText()
							.toString().trim());

			tempCircleList.clear();

			Log.w("doSearch() circle", list.size() + " size of list");

			tempCircleList.addAll(list);

			// for (Object obj : list) {
			// tempCircleList.add((Circle) obj);
			// }

			generateListViewForCircles();

		}

	}

	@Override
	protected void onPause() {
		super.onPause();
	}

}
