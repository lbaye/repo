package com.socmaps.ui;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socmaps.entity.People;
import com.socmaps.util.StaticValues;

public class FriendListActivity extends Activity {

	private enum Audio {
		ATOZ, DISTANCE, CIRCLES
	}

	private class Users {
		private List<People> friendList;
		private HashMap<String, List<String>> circles;
		private HashMap<String, People> friendMap;
	}

	private Context context;
	private Button searchBtn, doSearchBtn, aToZBtn, distanceBtn, circleBtn;
	private EditText searchQueryEditText;
	private RelativeLayout searchPanel;
	private LinearLayout listContainer;
	private List<People> originalFriendList;
	private List<People> tempFriendList;
	private LayoutInflater inflater;
	private int selectedTab = Audio.ATOZ.ordinal();
	
	HashMap<String, Boolean> selectedPhoto;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_list_layout);
		initialize();
		populateUsers();
		getFriendList();
		showHideSearchPanel(true);
		tempFriendList = sortDataAlphabetically(originalFriendList);
		generateListViewForAToZ();
	}

	private void populateUsers() {
		// TODO Auto-generated method stub

	}

	private void updateTabHostButtonView(int selection) {

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

	public View getItemViewFriend(People fEntity) {

		View v = inflater.inflate(R.layout.friend_item, null);
		
		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);

		final LinearLayout proficPicContainer = (LinearLayout) v
				.findViewById(R.id.proficPicContainer);
		
		Display display = getWindowManager().getDefaultDisplay();

		int width =display.getWidth();
		
		v.setLayoutParams(new LinearLayout.LayoutParams(width/4, LayoutParams.WRAP_CONTENT));

		final String id = fEntity.getId();

		


		

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
				if(selectedPhoto.get(id))
				{
					proficPicContainer.setBackgroundResource(R.color.transparent);
					selectedPhoto.put(id, false);
				}
				else
				{
					proficPicContainer.setBackgroundResource(R.color.highlightGreen);
					selectedPhoto.put(id, true);
				}
				
			}
		}); 
		
		
		

		return v;
	}

	private LinearLayout getAFreshRow() {

		/*LinearLayout row = new LinearLayout(this);
		row.setOrientation(LinearLayout.HORIZONTAL);
		row.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.WRAP_CONTENT));
		row.setPadding(10, 10, 10, 0);*/
		
		LinearLayout row =(LinearLayout) inflater.inflate(R.layout.friend_list_row, null);

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

		// for testing
		for (int i = 0; i < 10; i++) {
			People frnd = new People();
			frnd.setFirstName("Name");
			frnd.setId("a"+i);
			originalFriendList.add(frnd);
		}
		for (int i = 0; i < 10; i++) {
			People frnd = new People();
			frnd.setFirstName("Name");
			frnd.setId("b"+i);
			originalFriendList.add(frnd);
		}
		for (int i = 0; i < 10; i++) {
			People frnd = new People();
			frnd.setFirstName("Name");
			frnd.setId("c"+i);
			originalFriendList.add(frnd);
		}
		// for testing
	}

	private void initialize() {

		context = FriendListActivity.this;
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
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	protected void onResume() {
		super.onResume();

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

}
