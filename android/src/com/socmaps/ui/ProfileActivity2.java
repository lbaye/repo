package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
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
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class ProfileActivity2 extends Activity implements OnClickListener {
	Context context;

	Button btnBack, btnNotification;

	ImageView ivProfilePic, ivCoverPic, ivRegMedia;
	ImageView btnEditProfilePic, btnEditCoverPic, btnEditStatus,
			btnNavigateToMap, btnEvent;
	ImageView photos_icon_image, friends_icon_image, places_icon_image,
			interest_icon_image;

	TextView tvName, tvStatusMessage, tvAddress, tvTime, tvDistance, tvAge,
			tvCity, tvCompany, tvRelationshipStatus;

	LinearLayout age_layout, relationship_layout, living_in_layout,
			work_at_layout;
	LinearLayout layEditProfilePic;
	LinearLayout lenearLayoutFirstMeetUp;

	int responseStatus = 0;
	String responseString = "";

	ImageDownloader imageDownloader;

	private ProgressDialog m_ProgressDialog = null;
	public final static int REQUEST_CODE_CAMERA = 700;
	public final static int REQUEST_CODE_GALLERY = 701;
	int requestCode;
	Bitmap avatar;
	String dob = "";
	Calendar now = Calendar.getInstance();

	String strRelationshipStatus;

	public People people;

	String getAvater, getCoverPhoto, getRegMedia, getFirstName, getLastName,
			userName, getStatusMsg, getStreetAdd, getLastLog, getAge,
			getRelationshipStatus, getCity, getWorkInfo;

	RelativeLayout relativeLayoutFriendshipStatus, relativeLayoutFriend,
			relativeLayoutMeetUp, relativeLayoutMessage,
			relativeLayoutDirection;
	TextView tvFriendshipStatus, tvFriendshipCheck;

	public Dialog msgDialog, frndRequestDialog;
	// public Dialog currentBubbleDialog;

	String friendRequestFriendId = "";
	String friendRequestMessage = "";
	String friendRequestResponse = "";
	int friendRequestStatus = 0;

	public List<String> friendRequestSentList = new ArrayList<String>();

	String sendMessageFriendId = "";
	String sendMessageSubject = "";
	String sendMessageContent = "";
	String sendMessageResponse = "";
	int sendMessageStatus = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// setContentView(R.layout.other_user_profile);
		setContentView(R.layout.other_layout);

		Object obj = getIntent().getSerializableExtra("otherUser");
		if (obj != null) {
			people = (People) (obj);
			obj = null;
			Log.d("CHECK VALUE", "Address: " + people.getStreetAddress());
		}

		initialize();
		setDefaultValues();
		setButtonForDisplay();

	}

	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void initialize() {
		context = ProfileActivity2.this;

		imageDownloader = new ImageDownloader();
		imageDownloader.setMode(ImageDownloader.Mode.CORRECT);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		ivProfilePic = (ImageView) findViewById(R.id.ivProfilePic);
		ivCoverPic = (ImageView) findViewById(R.id.ivCoverPic);
		ivRegMedia = (ImageView) findViewById(R.id.ivRegMedia);

		btnNavigateToMap = (ImageView) findViewById(R.id.btnNavigateToMap);
		btnNavigateToMap.setOnClickListener(this);

		btnEvent = (ImageView) findViewById(R.id.btnEvent);
		btnEvent.setOnClickListener(this);

		// ----- for last part ------ //

		photos_icon_image = (ImageView) findViewById(R.id.photos_icon_image);
		photos_icon_image.setOnClickListener(this);

		friends_icon_image = (ImageView) findViewById(R.id.friends_icon_image);
		friends_icon_image.setOnClickListener(this);

		places_icon_image = (ImageView) findViewById(R.id.places_icon_image);
		places_icon_image.setOnClickListener(this);

		interest_icon_image = (ImageView) findViewById(R.id.interest_icon_image);
		interest_icon_image.setOnClickListener(this);

		// ------------ for last part end ---------- //

		tvName = (TextView) findViewById(R.id.tvName);
		tvStatusMessage = (TextView) findViewById(R.id.tvStatusMessage);
		tvAddress = (TextView) findViewById(R.id.tvAddress);
		tvTime = (TextView) findViewById(R.id.tvTime);
		tvDistance = (TextView) findViewById(R.id.tvDistance);
		tvAge = (TextView) findViewById(R.id.tvAge);

		tvCity = (TextView) findViewById(R.id.tvCity);
		tvCompany = (TextView) findViewById(R.id.tvCompany);

		age_layout = (LinearLayout) findViewById(R.id.age_layout);
		relationship_layout = (LinearLayout) findViewById(R.id.relationship_layout);
		living_in_layout = (LinearLayout) findViewById(R.id.living_in_layout);
		work_at_layout = (LinearLayout) findViewById(R.id.work_at_layout);

		tvRelationshipStatus = (TextView) findViewById(R.id.tvRelationshipStatus);

		relativeLayoutFriendshipStatus = (RelativeLayout) findViewById(R.id.relativeLayoutFriendshipStatus);

		relativeLayoutFriend = (RelativeLayout) findViewById(R.id.relativeLayoutFriend);
		relativeLayoutFriend.setOnClickListener(this);

		relativeLayoutMeetUp = (RelativeLayout) findViewById(R.id.relativeLayoutMeetUp);
		relativeLayoutMeetUp.setOnClickListener(this);

		relativeLayoutMessage = (RelativeLayout) findViewById(R.id.relativeLayoutMessage);
		relativeLayoutMessage.setOnClickListener(this);

		relativeLayoutDirection = (RelativeLayout) findViewById(R.id.relativeLayoutDirection);
		relativeLayoutDirection.setOnClickListener(this);

		lenearLayoutFirstMeetUp = (LinearLayout) findViewById(R.id.linearLayoutFirstMeetUp);

		tvFriendshipStatus = (TextView) findViewById(R.id.tvFriendshipStatus);

		layEditProfilePic = (LinearLayout) findViewById(R.id.layEditProfilePic);
		tvFriendshipCheck = (TextView) findViewById(R.id.tvFriendshipCheck);

		if (people.getFriendshipStatus().equalsIgnoreCase(
				Constant.STATUS_FRIENDSHIP_FRIEND)) {
			layEditProfilePic.setVisibility(View.VISIBLE);
			lenearLayoutFirstMeetUp.setVisibility(View.VISIBLE);
		}

	}

	public void setDefaultValues() {

		imageDownloader.clearCache();

		if (people.getAvatar() != null) {

			ivProfilePic.setImageResource(R.drawable.thumb);
			imageDownloader.download(people.getAvatar(), ivProfilePic);
		}

		if (people.getCoverPhoto() != null) {

			ivCoverPic.setImageResource(R.drawable.img_blank);
			imageDownloader.download(people.getCoverPhoto(), ivCoverPic);
		}
		if (people.getRegMedia() != null) {
			if (people.getRegMedia().equals("fb")) {
				ivRegMedia.setVisibility(View.VISIBLE);
			}
		}

		String name = "";
		if (people.getFirstName() != null) {
			name = people.getFirstName() + " ";
		}
		if (people.getLastName() != null) {
			name += people.getLastName();
		}
		tvName.setText(name);

		if (people.getStatusMsg() != null) {
			if (people.getStatusMsg().equalsIgnoreCase("status"))
				tvStatusMessage.setVisibility(View.GONE);
			else
				tvStatusMessage.setText(people.getStatusMsg());
		} else {
			tvStatusMessage.setVisibility(View.GONE);
		}

		if (people.getStreetAddress() != null) {
			// tvAddress.setText(people.getStreetAddress());
			tvAddress.setText(people.getCurrentAddress()); /*
															 * use
															 * getCurrentAddress
															 * to show
															 * OtherProfile
															 * "my address"
															 * field
															 */
		}

		/* extra work : may be discard later on */
		if (people.getStreetAddress() == null) {
			tvAddress.setVisibility(View.INVISIBLE);
		}
		/* finished */

		if (Utility.getFormatedDistance(people.getDistance()) != null) {
			// tvDistance.setText(Utility.getFormatedDistance(people.getDistance()));
			tvDistance.setText(Utility.getFormatedDistance(
					people.getDistance(), StaticValues.myInfo.getSettings()
							.getUnit()));
		}

		if (people.getLastLogIn() != null) {
			tvTime.setText(Utility.getFormattedDisplayDate(people
					.getLastLogIn()));
		}

		if (people.getAge() > 0) {
			tvAge.setText(people.getAge() + " years");
		}
		if (people.getAge() == 0) {
			tvAge.setText(" ");
		}

		if (people.getRelationshipStatus() != null) {
			tvRelationshipStatus.setText(people.getRelationshipStatus());
		}

		if (people.getCity() != null) {
			tvCity.setText(people.getCity());
		}

		if (people.getWorkStatus() != null) {
			tvCompany.setText(people.getWorkStatus());
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnNavigateToMap) {
//			Toast.makeText(context, "Will Go To Map", Toast.LENGTH_SHORT)
//					.show(); 
			
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people; 
			
			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);

		} else if (v == btnEvent) {
			Intent i = new Intent(context, EventListActivity.class);
			startActivity(i);
		} else if (v == btnBack) {
			finish();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(context,
					NotificationActivity.class);
			startActivity(notificationIntent);
		} else if (v == photos_icon_image) {
			Toast.makeText(
					getApplicationContext(),
					people.getFirstName() + "'s"
							+ " photos will be shown later on",
					Toast.LENGTH_SHORT).show();
		} else if (v == friends_icon_image) {
			Toast.makeText(
					getApplicationContext(),
					people.getFirstName() + "'s"
							+ " friends will be shown later on",
					Toast.LENGTH_SHORT).show();
		} else if (v == places_icon_image) {
			goToShowPlaces();
		} else if (v == interest_icon_image) {
			goToMeetUp();
		} else if (v == relativeLayoutFriend) {
			showFrndRequestDialog(people);
		} else if (v == relativeLayoutMeetUp) {
			goToMeetUp();
		} else if (v == relativeLayoutMessage) {
			showMessageDialog(people);
		} else if (v == relativeLayoutDirection) {
			goToDirection();
		}

	} 

	private void goToShowPlaces() {
		// Toast.makeText(context, "will be added very soon",
		// Toast.LENGTH_SHORT).show();
		Intent intentToGoPlace = new Intent(context, PlacesListActivity.class);
		Log.d("People Name & ID", people.getFirstName() + " " + people.getId());
		intentToGoPlace.putExtra("personID", people.getId());
		startActivity(intentToGoPlace);
		finish();
	}

	private void goToMeetUp() {
		// Toast.makeText(context, "Not This Time", Toast.LENGTH_SHORT).show();

		Log.d("LAT LNG Meetup People", String.valueOf(people.getCurrentLat())+" "+String.valueOf(people.getCurrentLng()));
		
		Intent intentToShowMeetUp = new Intent(context,
				MeetupRequestNewActivity.class); 
		intentToShowMeetUp.putExtra("destLat", people.getCurrentLat());
		intentToShowMeetUp.putExtra("destLng", people.getCurrentLng()); 
		intentToShowMeetUp.putExtra("destAddress", people.getCurrentAddress());
		startActivity(intentToShowMeetUp);
	}

	private void goToDirection() {
		// Toast.makeText(context, "A dialog will open to send message",
		// Toast.LENGTH_SHORT).show();

		Intent intentToGoDirection = new Intent(context,
				DirectionActivity.class);
		intentToGoDirection.putExtra("destLat", people.getCurrentLat());
		intentToGoDirection.putExtra("destLng", people.getCurrentLng());
		intentToGoDirection.putExtra("destAddress", people.getCurrentAddress());

		startActivity(intentToGoDirection);
	}

	private void setButtonForDisplay() {
		String userId = people.getId();
		String friendshipStatus = people.getFriendshipStatus();
		Log.d("User ID & Friendship Status Check", userId + " "
				+ friendshipStatus);

		if (friendRequestSentList.contains(userId)) {
			tvFriendshipStatus.setText("Pending");
		} else {
			if (friendshipStatus
					.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_NONE)) {
				// tvFriendshipStatus.setVisibility(View.GONE);
				// relativeLayoutFriendshipStatus.setVisibility(View.VISIBLE);
				// tvFriendshipStatus.setText("No Friendship");

				relativeLayoutMeetUp.setVisibility(View.GONE); // --- extra ---
																// //
				relativeLayoutFriendshipStatus.setVisibility(View.INVISIBLE); // ---
																				// extra
																				// ---
																				// //

				relativeLayoutFriend.setVisibility(View.VISIBLE);

			} else if (friendshipStatus
					.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {
				// tvFriendshipStatus.setVisibility(View.GONE);
				// tvFriendshipStatus.setText("Friend");

				relativeLayoutFriend.setVisibility(View.GONE); // --- extra ---
																// //
				relativeLayoutFriendshipStatus.setVisibility(View.INVISIBLE); // ---
																				// extra
																				// ---
																				// //

				relativeLayoutMeetUp.setVisibility(View.VISIBLE);
			} else {
				// tvFriendshipStatus.setVisibility(View.VISIBLE);
				// relativeLayoutFriend.setVisibility(View.GONE);
				relativeLayoutFriendshipStatus.setVisibility(View.VISIBLE);

				relativeLayoutFriend.setVisibility(View.INVISIBLE);

				relativeLayoutMeetUp.setVisibility(View.GONE); // --- extra ---
																// //

				String status = "";
				if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {
					status = getString(R.string.status_friend_request_friend);
					relativeLayoutMeetUp.setVisibility(View.VISIBLE);

					relativeLayoutFriend.setVisibility(View.GONE); // --- extra
																	// --- //
					relativeLayoutFriendshipStatus
							.setVisibility(View.INVISIBLE); // --- extra --- //
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_PENDING)) {
					status = getString(R.string.status_friend_request_pending);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REQUESTED)) {
					status = getString(R.string.status_friend_request_sent);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REJECTED_BY_ME)) {
					status = getString(R.string.status_friend_request_declined_by_me);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REJECTED_BY_HIM)) {
					status = getString(R.string.status_friend_request_declined_by_him);
				}
				tvFriendshipStatus.setText(status);
			}
		}
	}

	private void showFrndRequestDialog(final People people) {
		// TODO Auto-generated method stub
		frndRequestDialog = DialogsAndToasts.showAddFrnd(context);
		final EditText msgEditText = (EditText) frndRequestDialog
				.findViewById(R.id.message_body_text);

		Button send = (Button) frndRequestDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) frndRequestDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				/*
				 * sendFriendRequest(item.getUser().getId(),
				 * msgEditText.getText() .toString().trim());
				 */

				sendFriendRequest(people.getId(), msgEditText.getText()
						.toString().trim());

			}
		});
		cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				frndRequestDialog.dismiss();
			}
		});
		frndRequestDialog.show();
	}

	public void sendFriendRequest(String friendId, String message) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendRequestFriendId = friendId;
			friendRequestMessage = message;

			Thread thread = new Thread(null, friendRequestThread,
					"Start send message");
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

	private Runnable friendRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendRequestUrl
					+ "/" + friendRequestFriendId);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("message", friendRequestMessage);

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			friendRequestResponse = restClient.getResponse();
			friendRequestStatus = restClient.getResponseCode();

			runOnUiThread(friendRequestReturnResponse);
		}
	};

	private Runnable friendRequestReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseFriendRequest(friendRequestStatus,
					friendRequestResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Send Frnd Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);

			handleSuccssfulFriendRequest();

			Toast.makeText(context, "Request sent successfully.",
					Toast.LENGTH_SHORT).show();
			frndRequestDialog.dismiss();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(context,
					"Friend request already sent to this user.",
					Toast.LENGTH_SHORT).show();
			frndRequestDialog.dismiss();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}

	public void handleSuccssfulFriendRequest() {
		// currentBubbleDialog.dismiss();
		if (!friendRequestSentList.contains(friendRequestFriendId)) {
			friendRequestSentList.add(friendRequestFriendId);
		}

		ArrayList<People> peopleList = StaticValues.searchResult.getPeoples();

		for (int i = 0; i < peopleList.size(); i++) {
			String userId = peopleList.get(i).getId();
			if (friendRequestSentList.contains(userId)) {
				peopleList.get(i).setFriendshipStatus(
						Constant.STATUS_FRIENDSHIP_PENDING);
			}
		}
		StaticValues.searchResult.setPeoples(peopleList);
		// updateMap();
	}

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
			}
		});
		cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
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
					.getString(R.string.sending_request_text), true);

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
			m_ProgressDialog.dismiss();
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
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}
}
