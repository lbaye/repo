package com.socmaps.ui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageFetcher;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * RecommendationActivity is used to recommend someone about a particular location. 
 * Basically one user recommends other user and when recommends the recipient user can see the 
 * direction of that location from his current location. 
 *
 */

public class RecommendationActivity extends FragmentActivity {

	Context context;

	Button btnBack, btnNotification;
	Button btnCancel, btnSend;

	EditText etMessage;
	String requestMessage = "", requestAddress = "";

	ProgressDialog m_ProgressDialog;

	int requestCode;

	String responseString;
	int responseStatus = 0;

	ButtonActionListener buttonActionListener;

	private LayoutInflater inflater;
	private Button btnFriendSelect, btnSelectAll, btnUnselectAll,
			btnCancleSearch;
	EditText etFriendSearch;
	LinearLayout friendListContainer;
	ScrollView scrollViewFriends;
	HashMap<String, Boolean> selectedFriends = new HashMap<String, Boolean>();

	ImageFetcher imageFetcher;
	private Place place;

	HashMap<String, Boolean> backupSelectedFriends = new HashMap<String, Boolean>();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.recommanded_layout);

		Object obj = getIntent().getSerializableExtra("place");
		if (obj != null) {
			place = (Place) (obj);
			obj = null;
		}

		Log.d("Place ID",
				place.getId() + " " + place.getName() + " "
						+ place.getVicinity());

		requestAddress = place.getVicinity();

		initialize();
		generateFriendList();
		showFriendList();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		Utility.updateNotificationBubbleCounter(btnNotification);
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

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void initialize() {

		context = RecommendationActivity.this;

		imageFetcher = new ImageFetcher(context);

		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

		btnSend = (Button) findViewById(R.id.btnSend);
		btnSend.setOnClickListener(buttonActionListener);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener);

		btnCancleSearch = (Button) findViewById(R.id.btnCancleSearch);
		btnCancleSearch.setOnClickListener(buttonActionListener);

		etMessage = (EditText) findViewById(R.id.etMessage);

		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		btnFriendSelect = (Button) findViewById(R.id.btnFriendSelect);
		btnFriendSelect.setOnClickListener(buttonActionListener);
		btnSelectAll = (Button) findViewById(R.id.btnSelectAll);
		btnSelectAll.setOnClickListener(buttonActionListener);
		btnUnselectAll = (Button) findViewById(R.id.btnUnselectAll);
		btnUnselectAll.setOnClickListener(buttonActionListener);

		etFriendSearch = (EditText) findViewById(R.id.etFriendSearch);
		friendListContainer = (LinearLayout) findViewById(R.id.friendListContainer);
		scrollViewFriends = (ScrollView) findViewById(R.id.scrollViewFriends);

		etFriendSearch.addTextChangedListener(filterTextWatcher);
	}

	private TextWatcher filterTextWatcher = new TextWatcher() {

		@Override
		public void afterTextChanged(Editable s) {
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
		}

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
			// contentAdapter.getFilter().filter(s);
			Log.d("Do Search", "Do Search Method Called  "
					+ etFriendSearch.getText().toString().trim());
			doSearch();
		}

	};

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnBack) {
				finish();
			} else if (v == btnNotification) {
				Intent notificationIntent = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(notificationIntent);
			} else if (v == btnSend) {
				validateRequest();
			}

			else if (v == btnCancel) {
				finish();
			}

			else if (v == btnCancleSearch) {
				hideKeyBoard();
				etFriendSearch.setText("");
			}

			else if (v == btnFriendSelect) {
				showFriendList();
			} else if (v == btnSelectAll) {
				selectAll();
			} else if (v == btnUnselectAll) {
				unselectAll();
			}

		}
	}

	private void hideKeyBoard() {
		InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(etFriendSearch.getWindowToken(), 0);
	}

	private void generateFriendList() {

		friendListContainer.removeAllViews();
		List<People> friends = StaticValues.myInfo.getFriendList();

		if (friends != null) {

			for (int i = 0; i < friends.size(); i++) {
				View v = getItemViewFriend(friends.get(i));
				friendListContainer.addView(v);
			}
		}
	}

	private View getItemViewFriend(People fEntity) {

		View v = inflater.inflate(R.layout.people_item, null);

		TextView nameView = (TextView) v.findViewById(R.id.name);
		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);

		final LinearLayout proficPicContainer = (LinearLayout) v
				.findViewById(R.id.proficPicContainer);

		final String id = fEntity.getId();
		String avatarUrl = fEntity.getAvatar();

		String name = "";
		name = Utility.getItemTitle(fEntity);
		nameView.setText(name);

		selectedFriends.put(id, false);

		if (avatarUrl != null && !avatarUrl.equals("")) {
			imageFetcher.loadImage(avatarUrl, profilePic);
		}

		if (backupSelectedFriends.containsKey(id)) {
			boolean preValue = backupSelectedFriends.get(id);

			if (preValue) {
				proficPicContainer
						.setBackgroundResource(R.color.highlightGreen);
				selectedFriends.put(id, preValue);
			}
		}

		profilePic.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				boolean isSelected = selectedFriends.get(id);
				if (isSelected) {
					proficPicContainer
							.setBackgroundResource(R.color.transparent);
				} else {
					proficPicContainer
							.setBackgroundResource(R.color.highlightGreen);
				}
				selectedFriends.put(id, !isSelected);

			}
		});

		return v;
	}

	private void showFriendList() {

		btnFriendSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);
		scrollViewFriends.setVisibility(View.VISIBLE);
	}

	private void selectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(true);
		}
	}

	private void unselectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(false);
		}
	}

	private void selectionFriends(boolean isSelect) {
		int selectionColor;
		if (isSelect) {
			selectionColor = R.color.highlightGreen;
		} else {
			selectionColor = R.color.transparent;
		}

		int totalChild = friendListContainer.getChildCount();
		for (int i = 0; i < totalChild; i++) {
			View v = friendListContainer.getChildAt(i);
			LinearLayout proficPicContainer = (LinearLayout) v
					.findViewById(R.id.proficPicContainer);
			proficPicContainer.setBackgroundResource(selectionColor);
		}

		Set set = selectedFriends.entrySet();
		Iterator iterator = set.iterator();
		while (iterator.hasNext()) {
			Map.Entry me = (Map.Entry) iterator.next();

			String key = (String) me.getKey();
			selectedFriends.put(key, isSelect);
		}
	}

	private void validateRequest() {
		// TODO Auto-generated method stub
		boolean validated = true;
		String messageText = "";

		List<String> invitedPeopleList = Utility
				.getListFromHashMap(selectedFriends);

		if (invitedPeopleList.size() == 0) {
			validated = false;
			messageText = "No friend is selected to be invited.";
		}

		if (validated) {
			initiateSendData();
		} else {
			Toast.makeText(context, messageText, Toast.LENGTH_SHORT).show();
		}
	}

	private void initiateSendData() {
		Thread thread = new Thread(null, sendRequestThread,
				"Start send request");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.sending_request_text), true, true);
	}

	private Runnable sendRequestThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smServerUrl
					+ "/recommend/venue/" + place.getId());
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			requestMessage = etMessage.getText().toString().trim();
			Log.d("Message to Sent", requestMessage);

			restClient.AddParam("metaTitle", place.getName());
			restClient.AddParam("metaContent[note]", requestMessage);
			restClient.AddParam("metaContent[address]", place.getVicinity());
			restClient.AddParam("metaContent[lat]", place.getLatitude() + "");
			restClient.AddParam("metaContent[lng]", place.getLongitude() + "");

			List<String> invitedPeopleList = Utility
					.getListFromHashMap(selectedFriends);
			for (int i = 0; i < invitedPeopleList.size(); i++) {
				restClient.AddParam("recipients[]", invitedPeopleList.get(i));
			}

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(sendRequestResponse);
		}
	};

	private Runnable sendRequestResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}

			handleResponseRequest(responseStatus, responseString);

		}
	};

	private void handleResponseRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("RECOMMANDATION REQUEST RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_CREATED) {
			Toast.makeText(context,
					"Recommandation request sent successfully.",
					Toast.LENGTH_SHORT).show();

			finish();

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

	private void doSearch() {

		List<Object> dataList = new ArrayList<Object>();
		dataList.addAll(StaticValues.myInfo.getFriendList());

		List<Object> list = (Utility.getSearchResult(dataList, etFriendSearch
				.getText().toString().trim()));
		friendListContainer.removeAllViews();

		backupSelectedFriends = new HashMap<String, Boolean>(selectedFriends);
		selectedFriends.clear();
		for (int i = 0; i < list.size(); i++) {
			View v = getItemViewFriend((People) list.get(i));
			friendListContainer.addView(v);
		}

	}

}
