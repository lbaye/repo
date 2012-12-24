package com.socmaps.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Event;
import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.PeoplePicker;
import com.socmaps.widget.PeoplePickerListener;

/**
 * EventDetailsActivity class for generating event details view and some user interaction.
 *
 */
public class EventDetailsActivity extends Activity implements OnClickListener {

	private TextView eventNameText, eventDateTimeText, shortSummaryText,
			venueText, distanceText, descriptionText;
	private ImageView eventImage, showOnMapImage;
	private RadioGroup rsvpRadioGroup;
	private Button inviteMoreFriendBtn, deleteBtn, editBtn, backBtn;
	private LinearLayout rsvpPanel;
	private Context context;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	private LinearLayout guestListContainer;
	private RelativeLayout inviteFrndPanel;
	private LayoutInflater inflater;
	private boolean radioflag = true;
	private LinearLayout deleteEditPanel;

	private ProgressDialog m_ProgressDialog;

	String myResponse = Constant.MY_RESPONSE_MAYBE;

	String pickerInviteMore = "pickerInviteMore";

	List<String> inviteMoreSelectedFriendList;
	List<String> inviteMoreSelectedCircleList;
	List<String> inviteMoreSelectedFriendListAll;
	List<String> invitedGuestList;

	private Event selectedEvent;

	ImageDownloader imageDownloader;

	String source = "";
	String s = "";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.event_details_layout);

		source = getIntent().getStringExtra("source");
		Object selectedItem = getIntent().getSerializableExtra("selectedEvent");
		if (selectedItem != null) {
			selectedEvent = (Event) (selectedItem);
			selectedItem = null;
			Log.d("EVENT CHECK2",
					selectedEvent.getEventId() + " "
							+ selectedEvent.getEventTitle() + " "
							+ selectedEvent.getEvent_type() + " "
							+ selectedEvent.getMyResponse() + " URL: "
							+ selectedEvent.getEventImageUrl());
		}

		initialize();
		setOnclicklistenerToView();
		setInitialDataToView();
		startGuestFetchingThread();
	}

	private void setOnclicklistenerToView() {
		// TODO Auto-generated method stub
		showOnMapImage.setOnClickListener(this);
		deleteBtn.setOnClickListener(this);
		editBtn.setOnClickListener(this);
		inviteMoreFriendBtn.setOnClickListener(this);
		backBtn.setOnClickListener(this);
		rsvpRadioGroup.setOnCheckedChangeListener(t);
	}

	RadioGroup.OnCheckedChangeListener t = new RadioGroup.OnCheckedChangeListener() {

		@Override
		public void onCheckedChanged(RadioGroup group, int checkedId) {
			// TODO Auto-generated method stub
			if (radioflag) {
				switch (checkedId) {
				case R.id.yes_btn:
					myResponse = Constant.MY_RESPONSE_YES;
					break;
				case R.id.no_btn:
					myResponse = Constant.MY_RESPONSE_NO;
					break;
				case R.id.maybe_btn:
					myResponse = Constant.MY_RESPONSE_MAYBE;
					break;
				default:
					break;
				}
				responseToEvent();
			}
		}
	};

	private void startGuestFetchingThread() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, GetEventWithGuestList,
					"MagentoBackground");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true, true);
		} else {
			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable GetEventWithGuestList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient getAccountSettingsClient = new RestClient(
					Constant.smGetEventUrl + "/" + selectedEvent.getEventId());
			getAccountSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();

			responseStatus = getAccountSettingsClient.getResponseCode();

			runOnUiThread(returnResGetEventWithGuestList);
		}
	};

	private Runnable returnResGetEventWithGuestList = new Runnable() {

		@Override
		public void run() {

			handleEventWithGuestResponse(responseStatus, responseString);
			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}

		}

	};

	private void handleEventWithGuestResponse(int status, String response) {
		Log.d("Events", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			selectedEvent = ServerResponseParser
					.parseGetEventDetailsResult(response);
			addContentsInGuestList();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void addContentsInGuestList() {
		// TODO Auto-generated method stub
		guestListContainer.removeAllViews();
		invitedGuestList = new ArrayList<String>();
		Log.e("Guests invited", selectedEvent.getGuestList().size() + "");
		List<People> guests = selectedEvent.getGuestList();
		if (guests != null) {

			for (int i = 0; i < guests.size(); i++) {
				People friendEntity = guests.get(i);
				invitedGuestList.add(friendEntity.getId());
				View v = getItemViewFriend(friendEntity);
				guestListContainer.addView(v);
			}
		}
	}

	private void setInitialDataToView() {
		// TODO Auto-generated method stub
		if (selectedEvent != null) {

			// invite panel hide show
			if ("my_event".equalsIgnoreCase(selectedEvent.getEvent_type())) {
				inviteFrndPanel.setVisibility(View.VISIBLE);
			} else if (selectedEvent.isGuestCanInvite()
					&& selectedEvent.isInvited()) {
				inviteFrndPanel.setVisibility(View.VISIBLE);
			} else
				inviteFrndPanel.setVisibility(View.GONE);
			// delete edit panel show hide
			if (selectedEvent.getEvent_type() == null) {
				deleteEditPanel.setVisibility(View.GONE);
			} else if (selectedEvent.getEvent_type().equalsIgnoreCase(
					"my_event")) {
				deleteEditPanel.setVisibility(View.VISIBLE);
			} else
				deleteEditPanel.setVisibility(View.GONE);

			// set Title text

			if (selectedEvent.getEventTitle() != null) {
				if (!selectedEvent.getEventTitle().equals("")) {
					eventNameText.setText(selectedEvent.getEventTitle());
					eventNameText.setVisibility(View.VISIBLE);
				} else
					eventNameText.setVisibility(View.GONE);
			} else
				eventNameText.setVisibility(View.GONE);

			// set short summary text
			if (selectedEvent.getShortSummary() != null) {
				if (!selectedEvent.getShortSummary().equals("")) {
					shortSummaryText.setText(selectedEvent.getShortSummary());
					shortSummaryText.setVisibility(View.VISIBLE);
				} else
					shortSummaryText.setVisibility(View.GONE);
			} else
				shortSummaryText.setVisibility(View.GONE);

			// set address
			if (selectedEvent.getAddress() != null) {
				if (!selectedEvent.getAddress().equals("")) {
					venueText.setText(selectedEvent.getAddress());
					venueText.setVisibility(View.VISIBLE);
				} else
					venueText.setVisibility(View.GONE);
			} else
				venueText.setVisibility(View.GONE);

			// set Date
			if (selectedEvent.getEventTime() != null) {

				eventDateTimeText.setText(Utility
						.getFormattedDisplayDateEventList(selectedEvent
								.getEventTime()));
				eventDateTimeText.setVisibility(View.VISIBLE);

			} else
				eventDateTimeText.setVisibility(View.GONE);

			if (selectedEvent.getEventImageUrl() != null) {

				if (!selectedEvent.getEventImageUrl().equalsIgnoreCase("")) {
					imageDownloader.download(selectedEvent.getEventImageUrl(),
							eventImage);
				}

			} else {
			}

			// Rsvp Panel show hide
			if (selectedEvent.isInvited()
					&& !("my_event").equalsIgnoreCase(selectedEvent
							.getEvent_type())) {
				rsvpPanel.setVisibility(View.VISIBLE);
				radioflag = false;
				setRadioGroupValue(rsvpRadioGroup,
						selectedEvent.getMyResponse());
				radioflag = true;

			} else
				rsvpPanel.setVisibility(View.GONE);

			// set distance
			distanceText
					.setText(Utility.getFormatedDistance(selectedEvent
							.getDistance(), StaticValues.myInfo.getSettings()
							.getUnit()));
			// set description
			if (selectedEvent.getDescription() != null)
				descriptionText.setText(selectedEvent.getDescription());
			else
				descriptionText.setText("");

		}
	}

	private View getItemViewFriend(People people) {

		View v = inflater.inflate(R.layout.people_item, null);

		TextView nameView = (TextView) v.findViewById(R.id.name);
		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);

		final LinearLayout proficPicContainer = (LinearLayout) v
				.findViewById(R.id.proficPicContainer);

		String firstName = people.getFirstName();
		String lastName = people.getLastName();
		final String id = people.getId();
		String avatarUrl = people.getAvatar();

		String name = "";

		if (firstName != null) {
			name = firstName + " ";
		}
		if (lastName != null) {
			name += lastName;
		}

		nameView.setText(name);

		if (avatarUrl != null && !avatarUrl.equals("")) {

			imageDownloader.download(avatarUrl, profilePic);

		} else {

			profilePic.setImageResource(R.drawable.user_default);
		}

		proficPicContainer.setBackgroundResource(R.color.highlightGreen);

		return v;
	}

	private void setRadioGroupValue(RadioGroup rG, String status) {
		if ("yes".equalsIgnoreCase(status)) {
			((RadioButton) rG.findViewById(R.id.yes_btn)).setChecked(true);
		} else if ("no".equalsIgnoreCase(status)) {
			((RadioButton) rG.findViewById(R.id.no_btn)).setChecked(true);
		} else {
			((RadioButton) rG.findViewById(R.id.maybe_btn)).setChecked(true);
		}

	}

	private void initialize() {
		// TODO Auto-generated method stub
		context = EventDetailsActivity.this;
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		imageDownloader = ImageDownloader.getInstance();

		eventNameText = (TextView) findViewById(R.id.event_name_text);
		eventDateTimeText = (TextView) findViewById(R.id.event_date_text);

		shortSummaryText = (TextView) findViewById(R.id.short_summary_text);
		venueText = (TextView) findViewById(R.id.address_text);
		distanceText = (TextView) findViewById(R.id.distance_text);
		descriptionText = (TextView) findViewById(R.id.description_text);
		eventImage = (ImageView) findViewById(R.id.cover_image_view);
		showOnMapImage = (ImageView) findViewById(R.id.map_image_btn);
		rsvpRadioGroup = (RadioGroup) findViewById(R.id.rgRSVPSelector);
		inviteMoreFriendBtn = (Button) findViewById(R.id.inviteMorePeopleBtn);
		deleteBtn = (Button) findViewById(R.id.deleteEventBtn);
		editBtn = (Button) findViewById(R.id.editEventBtn);
		rsvpPanel = (LinearLayout) findViewById(R.id.rsvp_panel);
		guestListContainer = (LinearLayout) findViewById(R.id.guestListContainer);
		inviteFrndPanel = (RelativeLayout) findViewById(R.id.invite_frnd_panel);
		deleteEditPanel = (LinearLayout) findViewById(R.id.delete_edit_panel);
		backBtn = (Button) findViewById(R.id.btnBack);

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (source != null) {
				if (source.equalsIgnoreCase("map")) {

					StaticValues.isHighlightAnnotation = true;
					StaticValues.highlightAnnotationItem = selectedEvent;

					Intent intent = new Intent(context, HomeActivity.class);
					intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(intent);
				} else {
					finish();
				}
			} else {
				finish();
			}

		}
		return false;

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == deleteBtn) {
			initiateDeleteEvent();
		} else if (v == editBtn) {
			Intent intent = new Intent(context, EventEditActivity.class);
			intent.putExtra("selectedEvent", selectedEvent);
			finish();
			startActivity(intent);
		} else if (v == showOnMapImage) {

			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = selectedEvent;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);

		} else if (v == inviteMoreFriendBtn) {
			showPeoplePicker(pickerInviteMore);
		} else if (v == backBtn) {
			finish();
		}
	}

	private void initiateDeleteEvent() {
		AlertDialog.Builder adb = new AlertDialog.Builder(this);
		adb.setTitle("Delete event");
		adb.setMessage("Are you sure you want to delete this event?");
		adb.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int id) {
				deleteEvent();
				dialog.cancel();
			}
		});
		adb.setNegativeButton("No", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int id) {
				dialog.cancel();
			}
		});
		adb.show();
	}

	private void deleteEvent() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, deleteEventThread,
					"Start delete event");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable deleteEventThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smEventUrl + "/"
					+ selectedEvent.getEventId());
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.DELETE);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(deleteEventResponseThread);
		}
	};

	private Runnable deleteEventResponseThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
			handleResponseDeleteEvent(responseStatus, responseString);

		}
	};

	private void handleResponseDeleteEvent(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("DELETE EVENT RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {

			Toast.makeText(context, "Event deleted successfully.",
					Toast.LENGTH_SHORT).show();
			Intent intent = new Intent(context, EventListActivity.class);
			finish();
			startActivity(intent);

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

	private void responseToEvent() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, responseEventThread,
					"Start response event");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable responseEventThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smEventUrl + "/"
					+ selectedEvent.getEventId() + "/rsvp");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("response", myResponse);

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(responseEventResponseThread);
		}
	};

	private Runnable responseEventResponseThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}

			handleResponseEvent(responseStatus, responseString);

		}
	};

	private void handleResponseEvent(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("rsvp response", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();

		}

	}

	private void showPeoplePicker(String pickerName) {
		// custom dialog

		// initialize picker
		PeoplePicker peoplePicker = new PeoplePicker(context,
				new InviteMorePeopleListener(), pickerName,
				inviteMoreSelectedFriendList, inviteMoreSelectedCircleList,
				invitedGuestList, null);
		peoplePicker.setButtonLabels("Invite", "Cancel");

		peoplePicker.show();
	}

	private class InviteMorePeopleListener implements PeoplePickerListener {

		@Override
		public void onSelect(String pickerName,
				List<String> selectedFriendList,
				List<String> selectedCircleList,
				List<String> selectedCircleFriendList,
				List<String> selectedFriendListAll) {
			
			if (pickerName.equalsIgnoreCase(pickerInviteMore)) {
				inviteMoreSelectedFriendList = selectedFriendList;
				inviteMoreSelectedCircleList = selectedCircleList;
				inviteMoreSelectedFriendListAll = selectedFriendListAll;

				if (inviteMoreSelectedFriendListAll.size() > 0) {
					// send invitation
					initiateSendInvitation();
				} else {
					Toast.makeText(context, "No friend selected to invite.",
							Toast.LENGTH_SHORT).show();
				}

			}

		}

	}

	private void resetSelectedList() {
		// reset selected list
		inviteMoreSelectedFriendList = null;
		inviteMoreSelectedCircleList = null;
		inviteMoreSelectedFriendListAll = null;
	}

	private void initiateSendInvitation() {
		Thread thread = new Thread(null, sendInvitationDataThread,
				"Start send messages");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.sending_request_text), true, true);
	}

	private Runnable sendInvitationDataThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smGetEventUrl + "/"
					+ selectedEvent.getEventId() + "/guests");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			for (int i = 0; i < inviteMoreSelectedFriendListAll.size(); i++) {
				restClient.AddParam("guests[]",
						inviteMoreSelectedFriendListAll.get(i));
			}
			// end of invited people

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(sendEventDataResponse);
		}
	};

	private Runnable sendEventDataResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}

			handleEventWithGuestResponse(responseStatus, responseString);
			resetSelectedList();
		}
	};

}
