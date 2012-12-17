package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
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
import com.socmaps.listrow.ListItemClickListenerSecondDegreePeople;
import com.socmaps.listrow.PeopleRowFactoryBlockUnblock;
import com.socmaps.listrow.RowType;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PeopleBlockUnblockActivity extends Activity implements
		OnClickListener, ListItemClickListener {

	private Context context;
	private ProgressDialog m_ProgressDialog;
	View requestItemView;

	private boolean isSearchEnabled = false;
	private Button btnMapView, btnListView, btnCircle, btnToggleSearchPanel,
			btnDoSearch, btnClearSearch, btnSeleceUnselectAllUser,
			btnCancelInvite, topCloseButton, btnBack, btnInvitePeople,
			btnCirclePeople, btnBlockUnblockPeople, btnSelectedFriends,
			btnPeopleByDistance;

	private EditText etSearchField;
	private RelativeLayout searchPanel;

	// private int colorButtonSelected;
	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;
	private ListView contentListView;
	private ContentListAdapter contentAdapter;
	private SearchResult peoplesAndPlacesEntity;

	private Dialog msgDialog;
	private String sendMessageFriendId = "";
	private String sendMessageSubject = "";
	private String sendMessageContent = "";
	private String sendMessageResponse = "";
	private int sendMessageStatus = 0;

	private boolean isAllSelect = false;

	private HashMap<String, Boolean> selectedArrayList;

	private String blockUnblockResponse;
	private int blockUnblockStatus;
	private String unblockId;
	private String blockId;

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
		// colorButtonSelected = getResources().getColor(R.color.gray_light);

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

		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			isSearchEnabled = true;
			doSearch();
			hideKeybord();
			// toggleSearchPanel();
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

			// Intent blickUnblockiIntent = new Intent(getApplicationContext(),
			// PeopleBlockUnblockActivity.class);
			// blickUnblockiIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			// startActivity(blickUnblockiIntent);
			// finish();

		} else if (v == btnSeleceUnselectAllUser) {

			isAllSelect = !isAllSelect;

			String unit = "";
			if (isAllSelect) {
				// StaticValues.PEOPLE_SELECT_ALL_USERS = false;
				btnSeleceUnselectAllUser
						.setText(getString(R.string.unselectAllLabel));
				unit = getString(R.string.unselectAllLabel);
			} else {
				// StaticValues.PEOPLE_SELECT_ALL_USERS = true;

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

				// Log.w("key ", key);

				boolean value = selectedArrayList.get(key);

				if (value) {
					// Log.i("People Id: " + key, "isChecked: " + value);
					checkCounter++;
				}

			}
			Log.i("Total Checked:", "" + checkCounter);

			//sendSelectedPeopleToServer();
			blockOrUnblockSelectedUsers();
			
		} else if (v == btnBack) {

			finish();

		}

	}

	/*
	 * Do Individual UnBlock
	 */
//	private void sendUnBlockToServer() {
//		// TODO Auto-generated method stub
//		if (Utility.isConnectionAvailble(getApplicationContext())) {
//
//			Thread thread = new Thread(null, unBlockThread,
//					"Start send block  to server");
//			thread.start();
//
//			// show progress dialog if needed
//			m_ProgressDialog = ProgressDialog.show(context, getResources()
//					.getString(R.string.please_wait_text), getResources()
//					.getString(R.string.sending_request_text), true, true);
//
//		} else {
//
//			DialogsAndToasts
//					.showNoInternetConnectionDialog(getApplicationContext());
//		}
//	}
//
//	private Runnable unBlockThread = new Runnable() {
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			RestClient restClient = new RestClient(Constant.smUnBlockUrl);
//			restClient.AddHeader(Constant.authTokenParam,
//					Utility.getAuthToken(context));
//
//			if (unblockId != null) {
//				restClient.AddParam("users[]", unblockId);
//			}
//
//			try {
//				restClient.Execute(RestClient.RequestMethod.PUT);
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//
//			blockUnblockResponse = restClient.getResponse();
//			blockUnblockStatus = restClient.getResponseCode();
//
//			runOnUiThread(unblockReturnResponse);
//		}
//	};
//
//	private Runnable unblockReturnResponse = new Runnable() {
//
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			handleResponseUnBlock(blockUnblockStatus, blockUnblockResponse);
//
//			// dismiss progress dialog if needed
//
//			if (m_ProgressDialog != null) {
//				m_ProgressDialog.dismiss();
//			}
//
//		}
//	};
//
//	public void handleResponseUnBlock(int status, String response) {
//		// show proper message through Toast or Dialog
//		Log.w("Send Unblock  Return Response", status + ":" + response);
//		switch (status) {
//		case Constant.STATUS_SUCCESS:
//			// Log.d("Login", status+":"+response);
//			Toast.makeText(context, "Unblocked successfully.",
//					Toast.LENGTH_SHORT).show();
//
//			for (int i = 0; i < StaticValues.searchResult.getPeoples().size(); i++) {
//
//				People p = StaticValues.searchResult.getPeoples().get(i);
//				if (unblockId.equals(p.getId())) {
//					StaticValues.searchResult.getPeoples().get(i)
//							.setBlocked(false);
//					break;
//				}
//
//			}
//
//			populateListData();
//
//			break;
//
//		default:
//			Toast.makeText(getApplicationContext(),
//					"An unknown error occured. Please try again!!",
//					Toast.LENGTH_SHORT).show();
//			break;
//
//		}
//
//	}

	/*
	 * Do Individual Block
	 */
//	private void sendBlockToServer() {
//		// TODO Auto-generated method stub
//		if (Utility.isConnectionAvailble(getApplicationContext())) {
//
//			Thread thread = new Thread(null, blockThread,
//					"Start send block  to server");
//			thread.start();
//
//			// show progress dialog if needed
//			m_ProgressDialog = ProgressDialog.show(context, getResources()
//					.getString(R.string.please_wait_text), getResources()
//					.getString(R.string.sending_request_text), true, true);
//
//		} else {
//
//			DialogsAndToasts
//					.showNoInternetConnectionDialog(getApplicationContext());
//		}
//	}
//
//	private Runnable blockThread = new Runnable() {
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			RestClient restClient = new RestClient(Constant.smBlockUrl);
//			restClient.AddHeader(Constant.authTokenParam,
//					Utility.getAuthToken(context));
//
//			if (blockId != null) {
//				restClient.AddParam("users[]", blockId);
//			}
//
//			try {
//				restClient.Execute(RestClient.RequestMethod.PUT);
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//
//			blockUnblockResponse = restClient.getResponse();
//			blockUnblockStatus = restClient.getResponseCode();
//
//			runOnUiThread(blockReturnResponse);
//		}
//	};
//
//	private Runnable blockReturnResponse = new Runnable() {
//
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			handleResponseBlock(blockUnblockStatus, blockUnblockResponse);
//
//			// dismiss progress dialog if needed
//
//			if (m_ProgressDialog != null) {
//				m_ProgressDialog.dismiss();
//			}
//		}
//	};
//
//	public void handleResponseBlock(int status, String response) {
//		// show proper message through Toast or Dialog
//		Log.d("Send Block  Return Response", status + ":" + response);
//		switch (status) {
//		case Constant.STATUS_SUCCESS:
//			// Log.d("Login", status+":"+response);
//			Toast.makeText(context, "Blocked successfully.", Toast.LENGTH_SHORT)
//					.show();
//
//			for (int i = 0; i < StaticValues.searchResult.getPeoples().size(); i++) {
//
//				People p = StaticValues.searchResult.getPeoples().get(i);
//				if (blockId.equals(p.getId())) {
//					StaticValues.searchResult.getPeoples().get(i)
//							.setBlocked(true);
//					break;
//				}
//
//			}
//			populateListData();
//
//			break;
//
//		default:
//			Toast.makeText(getApplicationContext(),
//					"An unknown error occured. Please try again!!",
//					Toast.LENGTH_SHORT).show();
//			break;
//
//		}
//
//	}

	/*
	 * Do Block or Unblock Selected users
	 */
//	private void sendSelectedPeopleToServer() {
//		// TODO Auto-generated method stub
//		if (Utility.isConnectionAvailble(getApplicationContext())) {
//
//			Thread thread = new Thread(null, blockOrUnblockThread,
//					"Start send block unblock list to server");
//			thread.start();
//
//			// show progress dialog if needed
//			m_ProgressDialog = ProgressDialog.show(context, getResources()
//					.getString(R.string.please_wait_text), getResources()
//					.getString(R.string.sending_request_text), true, true);
//
//		} else {
//
//			DialogsAndToasts
//					.showNoInternetConnectionDialog(getApplicationContext());
//		}
//	}
//
//	private Runnable blockOrUnblockThread = new Runnable() {
//		@Override
//		public void run() {
//
//			RestClient restClient = new RestClient(Constant.smBlockUnblockUrl);
//			restClient.AddHeader(Constant.authTokenParam,
//					Utility.getAuthToken(context));
//
//			for (String key : selectedArrayList.keySet()) {
//
//				boolean value = selectedArrayList.get(key);
//
//				if (value) {
//
//					restClient.AddParam("users[]", key);
//				}
//
//			}
//
//			try {
//				restClient.Execute(RestClient.RequestMethod.PUT);
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//
//			blockUnblockResponse = restClient.getResponse();
//			blockUnblockStatus = restClient.getResponseCode();
//
//			runOnUiThread(blockUnblockReturnResponse);
//		}
//	};
//
//	private Runnable blockUnblockReturnResponse = new Runnable() {
//
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			handleResponseBlockUnblock(blockUnblockStatus, blockUnblockResponse);
//
//			// dismiss progress dialog if needed
//
//			if (m_ProgressDialog != null) {
//				m_ProgressDialog.dismiss();
//			}
//		}
//	};
//
//	public void handleResponseBlockUnblock(int status, String response) {
//		// show proper message through Toast or Dialog
//		Log.d("Send Block Unblock Return Response", status + ":" + response);
//		switch (status) {
//		case Constant.STATUS_SUCCESS:
//			// Log.d("Login", status+":"+response);
//			Toast.makeText(context, "Request sent successfully.",
//					Toast.LENGTH_SHORT).show();
//
//			for (int i = 0; i < StaticValues.searchResult.getPeoples().size(); i++) {
//
//				People p = StaticValues.searchResult.getPeoples().get(i);
//
//				StaticValues.searchResult.getPeoples().get(i)
//						.setBlocked(selectedArrayList.get(p.getId()));
//
//			}
//
//			populateListData();
//
//			break;
//
//		default:
//			Toast.makeText(getApplicationContext(),
//					"An unknown error occured. Please try again!!",
//					Toast.LENGTH_SHORT).show();
//			break;
//
//		}
//
//	}

	//Another way**************
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
					REQUEST_TYPE.GET_SERVER_DATA, true, getResources()
							.getString(R.string.please_wait_text),
					getResources().getString(R.string.sending_request_text),
					new BackProcessCallBackListener(),true);

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
				// Log.d("Login", status+":"+response);
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

	// **********************************

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
			// imageDownloader = new ImageDownloader();
			// imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
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
			}

			// if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal())
			// {
			// return SecondDegreePeopleRowFactoryBlockUnblock.getView(
			// LayoutInflater.from(context), items.get(position),
			// context, PeopleBlockUnblockActivity.this, convertView,
			// imageLoader, new SecondDegreePeopleItemListener());
			// }
			else {
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

	private void addSecondDegreePeoplesToMasterList() {
		for (int i = 0; i < peoplesAndPlacesEntity.getSecondDegreePeoples()
				.size(); i++) {
			listMasterContent.add(peoplesAndPlacesEntity
					.getSecondDegreePeoples().get(i));
		}
	}

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, new ListComparator());
	}

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

			Log.w("PeopleBlockUnblockActivity", "onBlockButtonClick");

			if (people.isBlocked()) {

				// Log.w("PeopleBlockUnblockActivity ",
				// "onBlockButtonClick if people.isBlocked(): "+people.isBlocked());

				unblockId = people.getId();
				//sendUnBlockToServer();
			} else {

				// Log.w("PeopleBlockUnblockActivity",
				// "onBlockButtonClick else  people.isBlocked(): "+people.isBlocked());

				blockId = people.getId();
				//sendBlockToServer();
			}

		}

		@Override
		public void onUnBlockButtonClick(People people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onShowOnMapButtonClick(People people) {
			// TODO Auto-generated method stub

			// StaticValues.isHighlightAnnotation = true;
			// StaticValues.highlightAnnotationItem = people;
			// finish();

			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);

		}

		@Override
		public void onSendMessageButtonClick(People people) {
			// TODO Auto-generated method stub
			//showMessageDialog(people);
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
	 * Send Message to individual Person
	 */
//	private void showMessageDialog(final People people) {
//		// TODO Auto-generated method stub
//		msgDialog = DialogsAndToasts.showSendMessage(context);
//		final EditText msgEditText = (EditText) msgDialog
//				.findViewById(R.id.message_body_text);
//		Button send = (Button) msgDialog.findViewById(R.id.btnSend);
//		Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);
//		send.setOnClickListener(new OnClickListener() {
//
//			@Override
//			public void onClick(View arg0) {
//				// TODO Auto-generated method stub
//				if (!msgEditText.getText().toString().trim().equals("")) {
//					sendMessage(people.getId(), "Message", msgEditText
//							.getText().toString().trim());
//				} else {
//					msgEditText.setError("Please enter your message!!");
//				}
//
//				hideMessageDialogKeybord(msgEditText);
//			}
//		});
//		cancel.setOnClickListener(new OnClickListener() {
//
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//
//				hideMessageDialogKeybord(msgEditText);
//				msgDialog.dismiss();
//
//			}
//		});
//		msgDialog.show();
//	}
//
//	public void sendMessage(String friendId, String subject, String content) {
//		if (Utility.isConnectionAvailble(getApplicationContext())) {
//
//			sendMessageFriendId = friendId;
//			sendMessageSubject = subject;
//			sendMessageContent = content;
//
//			Thread thread = new Thread(null, sendMessageThread,
//					"Start send message");
//			thread.start();
//
//			// show progress dialog if needed
//			m_ProgressDialog = ProgressDialog.show(context, getResources()
//					.getString(R.string.please_wait_text), getResources()
//					.getString(R.string.sending_request_text), true, true);
//
//		} else {
//
//			DialogsAndToasts
//					.showNoInternetConnectionDialog(getApplicationContext());
//		}
//	}
//
//	private Runnable sendMessageThread = new Runnable() {
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			RestClient restClient = new RestClient(Constant.smMessagesUrl);
//			restClient.AddHeader(Constant.authTokenParam,
//					Utility.getAuthToken(context));
//
//			restClient.AddParam("recipients[]", sendMessageFriendId);
//			restClient.AddParam("subject", sendMessageSubject);
//			restClient.AddParam("content", sendMessageContent);
//
//			try {
//				restClient.Execute(RestClient.RequestMethod.POST);
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//
//			sendMessageResponse = restClient.getResponse();
//			sendMessageStatus = restClient.getResponseCode();
//
//			runOnUiThread(sendMessageReturnResponse);
//		}
//	};
//
//	private Runnable sendMessageReturnResponse = new Runnable() {
//
//		@Override
//		public void run() {
//			// TODO Auto-generated method stub
//			handleResponseSendMessage(sendMessageStatus, sendMessageResponse);
//
//			// dismiss progress dialog if needed
//
//			if (m_ProgressDialog != null) {
//				m_ProgressDialog.dismiss();
//			}
//		}
//	};
//
//	public void handleResponseSendMessage(int status, String response) {
//		// show proper message through Toast or Dialog
//		Log.d("Send Message", status + ":" + response);
//		switch (status) {
//		case Constant.STATUS_CREATED:
//			// Log.d("Login", status+":"+response);
//			Toast.makeText(context, "Message sent successfully.",
//					Toast.LENGTH_SHORT).show();
//			msgDialog.dismiss();
//			break;
//
//		default:
//			Toast.makeText(getApplicationContext(),
//					"Message not delivered,please try again!!",
//					Toast.LENGTH_SHORT).show();
//			break;
//
//		}
//
//	}

	/*
	 * Hide Keybord
	 */

	private void hideKeybord() {

		// etSearchField
		// .setOnFocusChangeListener(new View.OnFocusChangeListener() {
		//
		// public void onFocusChange(View v, boolean flag) {
		// if (flag == false) {
		// InputMethodManager inputMethodManager = (InputMethodManager)
		// getSystemService(Context.INPUT_METHOD_SERVICE);
		// inputMethodManager.hideSoftInputFromWindow(
		// v.getWindowToken(), 0);
		// }
		// }
		// });

		InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(etSearchField.getWindowToken(), 0);
	}

	protected void hideMessageDialogKeybord(EditText msgEditText) {
		// TODO Auto-generated method stub

		InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(msgEditText.getWindowToken(), 0);

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
		// StaticValues.PEOPLE_SELECT_ALL_USERS = false;

		Log.w("PeopleBlockUnblockActivity", "onStop");

	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();

		for (int i = 0; i < StaticValues.searchResult.getPeoples().size(); i++) {

			People p = StaticValues.searchResult.getPeoples().get(i);

			StaticValues.searchResult.getPeoples().get(i).setUnit("");

		}

	}

}
