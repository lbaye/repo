package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

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
import com.socmaps.listrow.ListItemClickListenerPeople;
import com.socmaps.listrow.ListItemClickListenerSecondDegreePeople;
import com.socmaps.listrow.RowType;
import com.socmaps.listrow.SecondDegreePeopleRowFactoryPeopleInvite;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PeopleInvityActivity extends Activity implements OnClickListener,
		ListItemClickListener {

	private Context context;
	private ProgressDialog m_ProgressDialog;
	View requestItemView;

	private boolean isSearchEnabled = false;
	private Button btnMapView, btnListView, btnCircle, btnToggleSearchPanel,
			btnDoSearch, btnClearSearch, btnSeleceUnselectAllUser,
			btnCancelInvite, topCloseButton, btnBack, btnInvitePeople,
			btnCirclePeople, btnBlockUnblockPeople, btnPeopleByDistance,
			btnInviteSelectedUsers;

	private EditText etSearchField;
	private RelativeLayout searchPanel;

	// private int colorButtonSelected;
	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;
	private ListView contentListView;
	private ContentListAdapter contentAdapter;
	private SearchResult peoplesAndPlacesEntity;

	public Dialog msgDialog;
	private String sendMessageFriendId = "";
	private String sendMessageSubject = "";
	private String sendMessageContent = "";
	private String sendMessageResponse = "";
	private int sendMessageStatus = 0;

	private boolean isAllSelect = false;
	private HashMap<String, Boolean> selectedArrayList;

	private String invitePeopleServerResponse;
	private int invitePeopleStatus;

	FbAPIsAuthListener fbAPIsAuthListener;
	FbAPIsLogoutListener fbAPIsLogoutListener;
	
	List<String> idList= new ArrayList<String>();

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

	public void populateListData() {
		populateMasterList();
		updateContentList(listMasterContent);
		updateDisplayList(listContent);
	}

	public void initialize() {
		context = PeopleInvityActivity.this;
		// colorButtonSelected = getResources().getColor(R.color.gray_light);

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

		// StaticValues.PEOPLE_IS_DISPLAY_CHECKBOX = true;

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

			// isAllSelect = !isAllSelect;
			//
			// String unit = "";
			// if (isAllSelect) {
			// // StaticValues.PEOPLE_SELECT_ALL_USERS = false;
			// btnSeleceUnselectAllUser
			// .setText(getString(R.string.unselectAllLabel));
			// unit = getString(R.string.unselectAllLabel);
			// } else {
			// // StaticValues.PEOPLE_SELECT_ALL_USERS = true;
			//
			// btnSeleceUnselectAllUser
			// .setText(getString(R.string.selectAllLabel));
			// unit = getString(R.string.selectAllLabel);
			// }
			//
			// for (int i = 0; i < listDisplayableContent.size(); i++) {
			//
			// ((People) listDisplayableContent.get(i)).setUnit(unit);
			//
			// }
			//
			// updateListView();
			//
			// for (int i = 0; i < listDisplayableContent.size(); i++) {
			//
			// selectedArrayList.put(
			// ((People) listDisplayableContent.get(i)).getId(),
			// isAllSelect);
			//
			// }

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
					// Log.i("People Id: " + key, "isChecked: " + value);
					checkCounter++;
					idList.add(key);
				}

			}
			Log.i("Total Checked:", "" + checkCounter);

			// sendSelectedPeopleToServer();
			if(checkCounter == 0)
			{
				Toast.makeText(context, "No friend is selected to invite.", Toast.LENGTH_SHORT).show();
			}
			else if(checkCounter>50)
			{
				Toast.makeText(context, "You can't invite more than 50 users at a time.", Toast.LENGTH_SHORT).show();
			}
			else
			{
				if (StaticValues.myInfo.getRegMedia().equalsIgnoreCase("fb") && FBUtility.mFacebook!=null) {
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

	public void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Object> items;
		private ImageDownloader imageDownloader;

		public ContentListAdapter(Context context, List<Object> itemsList) {

			this.items = itemsList;
			//imageDownloader = new ImageDownloader();
			//imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
			imageDownloader = ImageDownloader.getInstance();
		}

		@Override
		public int getViewTypeCount() {
			return RowType.values().length;
		}

		@Override
		public int getItemViewType(int position) {
			// if (items.get(position) instanceof People) {
			//
			// return RowType.PEOPLE.ordinal();
			// } else
			//

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

			// if (getItemViewType(position) == RowType.PEOPLE.ordinal()) {
			// return PeopleRowFactoryInvite.getView(
			// LayoutInflater.from(context), items.get(position),
			// context, PeopleInvityActivity.this, convertView,
			// imageDownloader, new PeopleItemListener());
			// }

			if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal()) {

				Log.e("Test Test getView regenerate>>",
						selectedArrayList.get(((SecondDegreePeople) items
								.get(position)).getRefId()) + "");

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

	public void updateContentList(List<Object> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	public void updateDisplayList(List<Object> list) {

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

				selectedArrayList.put(((SecondDegreePeople) item).getRefId(),false);

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
		// addPeoplesToMasterList();

		if (peoplesAndPlacesEntity != null) {

			addSecondDegreePeoplesToMasterList();

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
				return ((Place) object).getDistance();
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

			Toast.makeText(context, "Comming soon", 1000).show();
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
			showMessageDialog(people);
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
			Toast.makeText(context, "Comming soon", 1000).show();

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
	private void showMessageDialog(final People people) {
		// TODO Auto-generated method stub
		msgDialog = DialogsAndToasts.showSendMessage(context);
		final EditText msgEditText = (EditText) msgDialog
				.findViewById(R.id.message_body_text);
		Button send = (Button) msgDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if (!msgEditText.getText().toString().trim().equals("")) {
					sendMessage(people.getId(), "Message", msgEditText
							.getText().toString().trim());
				} else {
					msgEditText.setError("Please enter your message!!");
				}

				hideMessageDialogKeybord(msgEditText);
			}
		});
		cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				hideMessageDialogKeybord(msgEditText);
				msgDialog.dismiss();

			}
		});
		msgDialog.show();
	}

	public void sendMessage(String friendId, String subject, String content) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			sendMessageFriendId = friendId;
			sendMessageSubject = subject;
			sendMessageContent = content;

			Thread thread = new Thread(null, sendMessageThread,
					"Start send message");
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

	private Runnable sendMessageThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("recipients[]", sendMessageFriendId);
			restClient.AddParam("subject", sendMessageSubject);
			restClient.AddParam("content", sendMessageContent);

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			sendMessageResponse = restClient.getResponse();
			sendMessageStatus = restClient.getResponseCode();

			runOnUiThread(sendMessageReturnResponse);
		}
	};

	private Runnable sendMessageReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseSendMessage(sendMessageStatus, sendMessageResponse);

			// dismiss progress dialog if needed

			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}

		}
	};

	public void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog
		Log.d("Send Message", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Message sent successfully.",
					Toast.LENGTH_SHORT).show();
			msgDialog.dismiss();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"Message not delivered,please try again!!",
					Toast.LENGTH_SHORT).show();

			break;

		}

	}

	/*
	 * Invite Selected users
	 */
	private void sendSelectedPeopleToServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, invitePeopleThread,
					"Start send block unblock list to server");
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

	private Runnable invitePeopleThread = new Runnable() {
		@Override
		public void run() {

			RestClient restClient = new RestClient(Constant.smBlockUnblockUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			for (String key : selectedArrayList.keySet()) {

				boolean value = selectedArrayList.get(key);

				if (value) {

					restClient.AddParam("users[]", key);
				}

			}

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			invitePeopleServerResponse = restClient.getResponse();
			invitePeopleStatus = restClient.getResponseCode();

			runOnUiThread(invitePeopleResponse);
		}
	};

	private Runnable invitePeopleResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseInvitePeople(invitePeopleStatus,
					invitePeopleServerResponse);

			// dismiss progress dialog if needed

			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}
			
		}
	};

	public void handleResponseInvitePeople(int status, String response) {
		// show proper message through Toast or Dialog
		Log.d("Send Block Unblock Return Response", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Request sent successfully.",
					Toast.LENGTH_SHORT).show();

			for (int i = 0; i < StaticValues.searchResult
					.getSecondDegreePeoples().size(); i++) {

				SecondDegreePeople p = StaticValues.searchResult
						.getSecondDegreePeoples().get(i);

				// StaticValues.searchResult.getSecondDegreePeoples().get(i)
				// .setBlocked(selectedArrayList.get(p.getId()));

			}
			//
			// populateListData();

			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

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

	public class FbAPIsAuthListener implements AuthListener {

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
	public class FbAPIsLogoutListener implements LogoutListener {
		// @Override
		@Override
		public void onLogoutBegin() {
			Log.e("PeopleInviteActivity", "Logging out...");
		}

		// @Override
		@Override
		public void onLogoutFinish() {
			Log.e("PeopleInviteActivity", "You have logged out! ");

			// mahadi:start login again
			// btnFBLogin.setVisibility(View.GONE);
			// btnFBLogin2.setVisibility(View.VISIBLE);
			Utility.setFacebookImage(context, null);
			// ivFacebookProfile.setImageDrawable(getResources().getDrawable(
			// R.drawable.icon_facebook));

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

	public void initInviteFriends() {
		Log.d("PeopleInviteActivity Facebook", "Have to invite");

		if (Utility.isConnectionAvailble(context)) {

			showInvitationDialog();

		} else {
			Toast.makeText(getApplicationContext(),
					"Internet Connection Unavailable", Toast.LENGTH_SHORT)
					.show();
		}
	}

	public void showInvitationDialog() {
		
		String idString = "";
		if(idList!=null)
		{
			for(int i=0;i<idList.size();i++)
			{
				idString += idList.get(i)+",";
			}
		}
		if(idString.length()>1)
		{
			idString = idString.substring(0, idString.length()-1);
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
	public class AppRequestsListener extends BaseDialogListener {
		// @Override
		@Override
		public void onComplete(Bundle values) {
			/*
			 * Toast toast = Toast.makeText(getApplicationContext(),
			 * "App request sent", Toast.LENGTH_SHORT); toast.show();
			 */
		}

		@Override
		public void onFacebookError(FacebookError error) {
			/*
			 * Toast.makeText(getApplicationContext(), "Facebook Error: " +
			 * error.getMessage(), Toast.LENGTH_SHORT) .show();
			 */
		}

		@Override
		public void onCancel() {
			/*
			 * Toast toast = Toast.makeText(getApplicationContext(),
			 * "App request cancelled", Toast.LENGTH_SHORT); toast.show();
			 */
		}
	}

	/*
	 * Hide Keybord
	 */

	public void hideKeybord() {

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

	public void showSearchPanel(boolean display) {
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

		Log.w("PeopleInvityActivity", "onStop");
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
