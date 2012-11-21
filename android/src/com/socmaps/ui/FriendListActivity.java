package com.socmaps.ui;

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
import android.widget.PopupWindow;
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
import com.socmaps.ui.ListViewActivity.ListComparator;
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

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	//boolean isSearchEnabled = false;
	private EditText etSearchField;
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
	private List<Circle> circleList;

	private int tabIdentity = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_list_layout);

		initialize();

		personID = getIntent().getStringExtra("PERSON_ID");

		if (personID != null) {

			getFriendsOfFriendsFromServer();

			Log.w("FriendListActivity onCreate", "personID not null");

		} else {

			getFriendList();

			generateListViewForAToZ();

			circleList = StaticValues.myInfo.getCircleList();

			Log.w("FriendListActivity onCreate", "personID is null");

		}
		
		

		// showHideSearchPanel(false);
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
		
		tabIdentity=3;

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);
		etSearchField = (EditText) findViewById(R.id.etSearchField);
		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		searchBtn = (Button) findViewById(R.id.btnSearch);
		// doSearchBtn = (Button) findViewById(R.id.doSearchBtn);

		aToZBtn = (Button) findViewById(R.id.atozBtn);
		aToZBtn.setOnClickListener(this);
		aToZBtn.setBackgroundColor(Color.GRAY);

		distanceBtn = (Button) findViewById(R.id.distanceFilterBtn);
		distanceBtn.setOnClickListener(this);

		circleBtn = (Button) findViewById(R.id.circleFilterBtn);
		circleBtn.setOnClickListener(this);

		searchQueryEditText = (EditText) findViewById(R.id.etFriendSearch);
		// searchPanel = (RelativeLayout) findViewById(R.id.searchContainer);
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

		Utility.hideKeyboardContext(context);

		if (v == btnBack) {
			finish();
		}

		else if (v == circleBtn) {

			generateListViewForCircles();

			resetButtonBackgroundColor(v);

			tabIdentity = 7;

		} else if (v == aToZBtn) {

			generateListViewForAToZ();

			resetButtonBackgroundColor(v);
			tabIdentity = 3;

		} else if (v == distanceBtn) {

			generateListViewForDistance();

			resetButtonBackgroundColor(v);
			tabIdentity = 5;

		}

		/*
		 * Search Related
		 */
		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			//isSearchEnabled = true;
			doSearch();

		} else if (v == btnClearSearch) {
			//isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();

		}

	}

	private void resetButtonBackgroundColor(View v) {
		// TODO Auto-generated method stub
		circleBtn.setBackgroundColor(Color.TRANSPARENT);
		aToZBtn.setBackgroundColor(Color.TRANSPARENT);
		distanceBtn.setBackgroundColor(Color.TRANSPARENT);

		v.setBackgroundColor(Color.GRAY);

	}

	private void generateListViewForAToZ() {

		listContainer.removeAllViews();

		tempFriendList = sortDataAlphabetically(tempFriendList);

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

	private boolean isHeaderCircle(String startingChar, String firstName) {

		return !(firstName.equalsIgnoreCase(startingChar));

	}

	private boolean isHeaderDistance(String startingDistance, String firstName) {

		return !(firstName.equalsIgnoreCase(startingDistance));

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

		// tempFriendList = sortDataAlphabetically(originalFriendList);

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
	private void getFriendsOfFriendsFromServer() {
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

			try {

				JSONObject jsonObject = new JSONObject(response);

				if (!jsonObject.isNull("friends")) {

					JSONArray jArrayFriends = jsonObject
							.getJSONArray("friends");

					originalFriendList = ServerResponseParser
							.parsePeoples(jArrayFriends);
					
					tempFriendList=originalFriendList;

					generateListViewForAToZ();

				}

				if (!jsonObject.isNull("circles")) {

					JSONArray jArrayCircles = jsonObject
							.getJSONArray("circles");

					circleList = ServerResponseParser
							.getCircleList(jArrayCircles);

				}

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

	private void generateListViewForCircles() {

		listContainer.removeAllViews();

		if (circleList.size() > 0) {

			for (int i = 0; i < circleList.size(); i++) {

				List<People> circleFriendList = circleList.get(i)
						.getFriendList();

				if (circleFriendList.size() > 0) {

					String startingCircleName = "";

					LinearLayout itemRow = getAFreshRow();

					int counter = 0;
					for (int j = 0; j < circleFriendList.size(); j++) {

						People people = Utility.getPeopleById(circleFriendList
								.get(j).getId(), originalFriendList);

						if (people != null) {
							if (isHeaderCircle(startingCircleName, circleList
									.get(i).getName())) {
								if (j > 0) {
									addAlreadyCreatedRow(itemRow);

								}
								counter = 0;
								itemRow = getAFreshRow();
								startingCircleName = circleList.get(i)
										.getName() + "";
								addHeader(startingCircleName);

							}
							if (counter % 4 == 0 && j > 0) {
								addAlreadyCreatedRow(itemRow);
								counter = 0;
								itemRow = getAFreshRow();
							}

							selectedPhoto.put(circleFriendList.get(j).getId(),
									false);

							// itemRow.addView(getItemViewFriend(circleFriendList
							// .get(j)));

							itemRow.addView(getItemViewFriend(people));

							counter++;
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

		//tempFriendList = originalFriendList;

		if (originalFriendList.size() > 0) {
			String startingDistance = "";

			LinearLayout itemRow = getAFreshRow();

			int counter = 0;
			for (int i = 0; i < originalFriendList.size(); i++) {

				People people = originalFriendList.get(i);

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

				selectedPhoto.put(originalFriendList.get(i).getId(), false);

				itemRow.addView(getItemViewFriend(originalFriendList.get(i)));
				counter++;

			}
			addAlreadyCreatedRow(itemRow);
		}
	}

	private String distanceLabel(double distances) {

		String distanceLabel = "";

		if (distances >= 0 && distances <= 500) {

			distanceLabel = "0 to 500 m";

		} else if (distances > 500 && distances <= 1000) {
			distanceLabel = "500 m to 1 km";
		} else if (distances > 1000) {

			distanceLabel = "1+ km";

		}

		return distanceLabel;
	}

	private void sortMasterListDistance() {
		Collections.sort(this.originalFriendList, new ListComparator());
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

		if (tabIdentity == 3) {

			// It is for A to Z filtaring
			List<Object> dataList = new ArrayList<Object>();
			dataList.addAll(originalFriendList);

			List<Object> list = Utility.getSearchResult(dataList,
					etSearchField.getText().toString().trim());

			tempFriendList.clear();

			for (Object obj : list) {
				tempFriendList.add((People) obj);
			}

			generateListViewForAToZ();

		} else if (tabIdentity == 5) {

		} else if (tabIdentity == 7) {

		}

		// updateDisplayList(listContent);

		// List<Object> list=tempFriendList;

		// List<Object> list = (Utility.getSearchResult(tempFriendList,
		// etSearchField.getText().toString().trim()));
		//
		// listContent.clear();
		// listContent.addAll(list);
		//
		// updateDisplayList(listContent);

		// tempFriendList,originalFriendList,circleList
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

}
