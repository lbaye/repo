package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
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
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
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
import com.socmaps.listrow.PeopleRowFactory2;
import com.socmaps.listrow.RowType;
import com.socmaps.listrow.SecondDegreePeopleRowFactory2;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.MultiDirectionSlidingDrawer;

public class PeopleListActivity extends Activity implements OnClickListener,
		ListItemClickListener, OnCheckedChangeListener {

	private Button btnBack, btnPeopleInvite, btnCirclePeople,
			btnBlockUnblockPeople, btnPeopleByDistance;
	private Button topCloseButton;

	ListView contentListView;

	private Context context;
	ArrayList<People> userList;
	private SearchResult searchResult;
	private SearchResult peoplesAndPlacesEntity;
	private ContentListAdapter contentAdapter;

	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;

	boolean isSearchEnabled = false;
	MultiDirectionSlidingDrawer topDrawer;
	TopDrawerListener topDrawerListener;
	private CheckBox socialmapsCheckBox, facebookCheckBox;

	private boolean checkBoxFlag = false;
	private Dialog msgDialog;
	String sendMessageFriendId = "";
	String sendMessageSubject = "";
	String sendMessageContent = "";
	String sendMessageResponse = "";
	int sendMessageStatus = 0;
	private ProgressDialog m_ProgressDialog;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	private EditText etSearchField;
	private RelativeLayout searchPanel;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.people_list_layout);

		initialize();
		getIntentData();
		setListParameters();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		setCheckBoxSelection();
		populateMasterList();

		updateContentList(listMasterContent);
		updateDisplayList(listContent);
	}

	/*
	 * All initialize
	 */
	private void initialize() {

		context = PeopleListActivity.this;

		userList = new ArrayList<People>();
		// searchResult = new SearchResult();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnPeopleByDistance = (Button) findViewById(R.id.btnPeopleByDistance);
		btnPeopleByDistance.setOnClickListener(this);
		btnPeopleByDistance.setBackgroundColor(Color.LTGRAY);

		btnPeopleInvite = (Button) findViewById(R.id.btnPeopleInvite);
		btnPeopleInvite.setOnClickListener(this);

		btnCirclePeople = (Button) findViewById(R.id.btnPeopleCircle);
		btnCirclePeople.setOnClickListener(this);

		btnBlockUnblockPeople = (Button) findViewById(R.id.btnPeopleBlockUnblock);
		btnBlockUnblockPeople.setOnClickListener(this);

		contentListView = (ListView) findViewById(R.id.people_list);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

		topDrawerListener = new TopDrawerListener();
		topDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.topDrawer);
		topDrawer.setOnDrawerOpenListener(topDrawerListener);
		topDrawer.setOnDrawerCloseListener(topDrawerListener);
		topCloseButton = (Button) topDrawer.findViewById(R.id.topHandle);

		View v = topDrawer.findViewById(R.id.topSliderContent);
		socialmapsCheckBox = (CheckBox) v
				.findViewById(R.id.chkMenuItemSocialMaps);
		facebookCheckBox = (CheckBox) v.findViewById(R.id.chkMenuItemFacebook);

		setOnCheckChangeListener();

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

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
			doSearch();
			hideKeybord();
		} else if (v == btnPeopleInvite) {

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
			Intent blickUnblockiIntent = new Intent(getApplicationContext(),
					PeopleBlockUnblockActivity.class);
			blickUnblockiIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(blickUnblockiIntent);
			finish();
		} else if (v == btnBack) {
			finish();

		}

	}

	private void getIntentData() {

		peoplesAndPlacesEntity = StaticValues.searchResult;

		// Log.e("List Page:", "People count:" +
		// peoplesAndPlacesEntity.getPeoples().size());
		// Log.e("List Page:", "Place count:" +
		// peoplesAndPlacesEntity.getPlaces().size());
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
		// private ImageLoader imageLoader;
		private ImageDownloader imageDownloader;

		public ContentListAdapter(Context context, List<Object> itemsList) {

			this.items = itemsList;
			// imageLoader = new ImageLoader(context);

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
			if (items.get(position) instanceof People) {

				return RowType.PEOPLE.ordinal();
			} /*
			 * else if (items.get(position) instanceof Place) {
			 * 
			 * return RowType.PLACE.ordinal(); }
			 */else if (items.get(position) instanceof SecondDegreePeople) {

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
				return PeopleRowFactory2.getView(LayoutInflater.from(context),
						items.get(position), context, PeopleListActivity.this,
						convertView, imageDownloader, new PeopleItemListener());
			}

			// if (getItemViewType(position) == RowType.PEOPLE.ordinal()) {
			// return PeopleRowFactory2.getView(LayoutInflater.from(context),
			// items.get(position), context, PeopleListActivity.this,
			// convertView, imageLoader, new PeopleItemListener());
			// }

			if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal()) {
				return SecondDegreePeopleRowFactory2.getView(
						LayoutInflater.from(context), items.get(position),
						context, PeopleListActivity.this, convertView,
						imageDownloader, new SecondDegreePeopleItemListener());
			}

			// if (getItemViewType(position) == RowType.SECOND_DEGREE.ordinal())
			// {
			// return SecondDegreePeopleRowFactory2.getView(
			// LayoutInflater.from(context), items.get(position),
			// context, PeopleListActivity.this, convertView,
			// imageDownloader, new SecondDegreePeopleItemListener());
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

			/*
			 * else if (item instanceof Place &&
			 * SharedPreferencesHelper.getInstance(context).getBoolean(
			 * Constant.PLACE, true)) { listDisplayableContent.add(item);
			 * displayedItemCounter++; }
			 */

		}

		// update the list view
		updateListView();

		if (isSearchEnabled && displayedItemCounter == 0) {
			Toast.makeText(context, "No search result found.",
					Toast.LENGTH_SHORT).show();
		}
	}

	private void setCheckBoxSelection() {

		socialmapsCheckBox.setChecked(SharedPreferencesHelper.getInstance(
				context).getBoolean(Constant.PEOPLE_SOCIALMAPS, true));
		// placeCheckBox.setChecked(SharedPreferencesHelper.getInstance(context)
		// .getBoolean(Constant.PLACE, true));
		facebookCheckBox.setChecked(SharedPreferencesHelper
				.getInstance(context)
				.getBoolean(Constant.PEOPLE_FACEBOOK, true));

	}

	private void setOnCheckChangeListener() {
		// TODO Auto-generated method stub
		checkBoxFlag = true;
		socialmapsCheckBox.setOnCheckedChangeListener(this);
		// placeCheckBox.setOnCheckedChangeListener(this);
		facebookCheckBox.setOnCheckedChangeListener(this);

		checkBoxFlag = false;
	}

	private void populateMasterList() {

		listMasterContent.clear();

		// SharedPreferences appSharedPrefs = PreferenceManager
		// .getDefaultSharedPreferences(this.getApplicationContext());
		// Gson gson = new Gson();
		// String json = appSharedPrefs.getString("SearchResult", "");
		//
		// SearchResult obj = gson.fromJson(json, SearchResult.class);
		//
		// for (int i = 0; i < obj.getPlaces().size(); i++) {
		// listMasterContent.add(obj.getPlaces().get(i));
		// }
		//
		// for (int i = 0; i < obj.getPeoples().size(); i++) {
		// listMasterContent.add(obj.getPeoples().get(i));
		// }
		//
		// for (int i = 0; i < obj.getSecondDegreePeoples().size(); i++) {
		// listMasterContent.add(obj.getSecondDegreePeoples().get(i));
		// }

		addPeoplesToMasterList();
		addSecondDegreePeoplesToMasterList();

		sortMasterListData();
	}

	private void addPeoplesToMasterList() {

		if (peoplesAndPlacesEntity != null) {

			if (peoplesAndPlacesEntity.getPeoples() != null) {
				for (int i = 0; i < peoplesAndPlacesEntity.getPeoples().size(); i++) {
					listMasterContent.add(peoplesAndPlacesEntity.getPeoples()
							.get(i));
				}
			}

		}
	}

	private void addSecondDegreePeoplesToMasterList() {
		if (peoplesAndPlacesEntity != null) {

			if (peoplesAndPlacesEntity.getSecondDegreePeoples() != null) {

				for (int i = 0; i < peoplesAndPlacesEntity
						.getSecondDegreePeoples().size(); i++) {
					listMasterContent.add(peoplesAndPlacesEntity
							.getSecondDegreePeoples().get(i));
				}
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
			else if (object instanceof SecondDegreePeople)
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
			//showMessageDialog(people);
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

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);
		}

		@Override
		public void onSendMessageButtonClick(
				SecondDegreePeople secondDegreePeople) {
			// TODO Auto-generated method stub

			//showMessageDialog(secondDegreePeople);

		}

		@Override
		public void onMeetupButtonClick(SecondDegreePeople people) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onCheckChange(String itemId, boolean isChecked) {
			// TODO Auto-generated method stub

		}

	}

	private class TopDrawerListener implements
			MultiDirectionSlidingDrawer.OnDrawerOpenListener,
			MultiDirectionSlidingDrawer.OnDrawerCloseListener {

		@Override
		public void onDrawerClosed() {
			// TODO Auto-generated method stub
			Drawable openIcon = getResources().getDrawable(
					R.drawable.btn_slider_open);
			topCloseButton.setBackgroundDrawable(openIcon);
		}

		@Override
		public void onDrawerOpened() {
			// TODO Auto-generated method stub

			// if (bottomDrawer.isOpened()) {
			// bottomDrawer.animateClose();
			// }

			Drawable closeIcon = getResources().getDrawable(
					R.drawable.btn_slider_close);
			topCloseButton.setBackgroundDrawable(closeIcon);
		}

	}

	@Override
	public void onMapButtonClick(int flag) {
		// TODO Auto-generated method stub
		Intent intent = new Intent(context, ShowItemOnMap.class);
		intent.putExtra("FLAG", flag);
		startActivity(intent);
	}

	@Override
	public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		// TODO Auto-generated method stub
		if (!checkBoxFlag) {
			if (buttonView == socialmapsCheckBox) {
				SharedPreferencesHelper.getInstance(context).setBoolean(
						Constant.PEOPLE_SOCIALMAPS, isChecked);

			}

			if (buttonView == facebookCheckBox) {

				SharedPreferencesHelper.getInstance(context).setBoolean(
						Constant.PEOPLE_FACEBOOK, isChecked);

			}

			updateDisplayList(listContent);
		}
	}

	// private OnClickListener messageBtnListener = new OnClickListener() {
	//
	// @Override
	// public void onClick(View v) {
	//
	// People p = (People) v.getTag();
	//
	// if (v.getId() == R.id.btnMessagePeopleSocialMaps) {
	// Toast.makeText(context,
	// "Message Button Click ok: " + p.getFirstName(), 1000)
	// .show();
	// showMessageDialog(p);
	//
	// }
	//
	// }
	// };

	/*
	 * Send Message to individual Person
	 */
//	private void showMessageDialog(final Object people) {
//		// TODO Auto-generated method stub
//		msgDialog = DialogsAndToasts.showSendMessage(context);
//		final EditText msgEditText = (EditText) msgDialog
//				.findViewById(R.id.message_body_text);
//		Button send = (Button) msgDialog.findViewById(R.id.btnSend);
//		Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);
//
//		// final People p = (People) people;
//
//		send.setOnClickListener(new OnClickListener() {
//
//			@Override
//			public void onClick(View arg0) {
//				// TODO Auto-generated method stub
//
//				People p = null;
//				SecondDegreePeople secondDegreePeople = null;
//
//				if (people instanceof People) {
//
//					p = (People) people;
//					if (!msgEditText.getText().toString().trim().equals("")) {
//						sendMessage(p.getId(), "Message", msgEditText.getText()
//								.toString().trim());
//					} else {
//						msgEditText.setError("Please enter your message!!");
//					}
//
//				} else if (people instanceof SecondDegreePeople) {
//					secondDegreePeople = (SecondDegreePeople) people;
//
//					if (!msgEditText.getText().toString().trim().equals("")) {
//						sendMessage(secondDegreePeople.getRefId(), "Message",
//								msgEditText.getText().toString().trim());
//					} else {
//						msgEditText.setError("Please enter your message!!");
//					}
//
//				}
//
//				hideMessageDialogKeybord(msgEditText);
//
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
//					.getString(R.string.sending_request_text), true,true);
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
//			if(m_ProgressDialog!=null){
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
	 * Search portion
	 */

	private void doSearch() {
		//
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
}
