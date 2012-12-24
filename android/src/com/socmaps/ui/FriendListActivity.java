package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import org.apache.http.NameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
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
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * FriendListActivity class for generating friend list (by distance,circle and a to z) view and some user interaction.
 *
 */
public class FriendListActivity extends Activity implements OnClickListener {

	private enum SelectedTab {
		ATOZ, DISTANCE, CIRCLES
	}

	private Context context;
	private Button btnBack, aToZBtn, distanceBtn, circleBtn, btnNotification;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;

	private EditText etSearchField;
	private RelativeLayout searchPanel;
	private LinearLayout listContainer;

	private List<People> originalFriendList;
	private List<People> tempFriendList;

	private List<People> tempFriendListDistance;

	private LayoutInflater inflater;
	private int selectedTab;

	private HashMap<String, Boolean> selectedPhoto;

	private ImageDownloader imageDownloader;

	private String personID = null;

	private List<Circle> mainCircleList;

	private List<Circle> tempCircleList;

	private int colorButtonSelected;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_list_layout);

		initialize();
		personID = getIntent().getStringExtra("PERSON_ID");

		if (personID == null) {
			if (StaticValues.myInfo != null) {
				personID = StaticValues.myInfo.getId();
			}
		}

		if (personID != null) {

			callAPI();

			Log.w("FriendListActivity onCreate", "personID not null");

		}

	}

	@Override
	protected void onResume() {
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);

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

			doSearch();

		} else if (v == btnClearSearch) {
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

		sortDataAlphabetically();

		if (tempFriendList != null) {

			Log.i("generateListViewForAToZ() a to z", tempFriendList.size()
					+ "After sort size of tempFriendList");

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

	private View getItemViewFriend(final People people) {

		View v = inflater.inflate(R.layout.friend_item, null);

		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);
		final TextView name = (TextView) v.findViewById(R.id.txtFriendName);

		Display display = getWindowManager().getDefaultDisplay();

		int width = display.getWidth();

		v.setLayoutParams(new LinearLayout.LayoutParams(width / 4,
				LayoutParams.WRAP_CONTENT));

		if (people.getAvatar() != null && people.getAvatar() != "") {
			imageDownloader.download(people.getAvatar(), profilePic);
		}

		name.setText(Utility.getFieldText(people));

		profilePic.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

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

	private LinearLayout getAFreshRow() {
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

	private void updateContentList(List<People> list) {

		if (list != null) {

			tempFriendList.clear();
			tempFriendList.addAll(list);

			tempFriendListDistance.clear();
			tempFriendListDistance.addAll(list);
		}

	}

	private void updateCircleContentList(List<Circle> list) {

		if (list != null) {

			tempCircleList.clear();
			tempCircleList.addAll(list);

		}

	}

	private void callAPI() {

		String url = Constant.smServerUrl + "/" + personID + "/friends";

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.GET_SERVER_DATA, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.GET);
	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String response, int type) {

			// TODO Auto-generated method stub
			Log.w("Got friends response from server", status + ":" + response);
			switch (status) {
			case Constant.STATUS_SUCCESS:

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

					if (StaticValues.myInfo != null) {
						if (originalFriendList != null
								&& mainCircleList != null
								&& personID.equals(StaticValues.myInfo.getId())) {
							StaticValues.myInfo
									.setFriendList(originalFriendList);
							StaticValues.myInfo.setCircleList(mainCircleList);
						}
					}

					updateContentList(originalFriendList);
					updateCircleContentList(mainCircleList);

					generateListViewForAToZ();

				} catch (JSONException e) {
					// TODO: handle exception
				}

				break;

			case Constant.STATUS_SUCCESS_NODATA:
				Toast.makeText(getApplicationContext(), "No data found.",
						Toast.LENGTH_SHORT).show();
				break;

			default:
				Toast.makeText(getApplicationContext(),
						"An unknown error occured. Please try again!!",
						Toast.LENGTH_SHORT).show();
				break;

			}

		}

	}

	private class ListComparatorName implements Comparator<People> {

		@Override
		public int compare(People first, People last) {
			String firstString = first.getFirstName();
			String secondString = last.getFirstName();
			return firstString.compareToIgnoreCase(secondString);
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

								itemRow.addView(getItemViewFriend(people));

								counter++;
							}

						}

					}
					addAlreadyCreatedRow(itemRow);
				}

			}

		}
	}

	private void generateListViewForDistance() {

		listContainer.removeAllViews();

		sortMasterListDistance();

		if (tempFriendListDistance != null) {
			String startingDistance = "";

			LinearLayout itemRow = getAFreshRow();

			int counter = 0;
			for (int i = 0; i < tempFriendListDistance.size(); i++) {

				People people = tempFriendListDistance.get(i);

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

			List<Circle> list = Utility.getSearchResultFromCircle(
					mainCircleList, originalFriendList, etSearchField.getText()
							.toString().trim());

			tempCircleList.clear();

			Log.w("doSearch() circle", list.size() + " size of list");

			tempCircleList.addAll(list);

			generateListViewForCircles();

		}

	}

	@Override
	protected void onPause() {
		super.onPause();
	}

}
