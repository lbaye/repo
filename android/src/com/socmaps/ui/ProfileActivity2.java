package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.NewsFeedPhotoZoomDialogPicker;

public class ProfileActivity2 extends Activity implements OnClickListener {

	Context context;

	Button btnBack, btnNotification;

	ImageView ivProfilePic, ivCoverPic, ivRegMedia, ivOnline;
	ImageView btnEditProfilePic, btnEditCoverPic, btnEditStatus,
			btnNavigateToMap, btnEvent;
	ImageView photos_icon_image, friends_icon_image, places_icon_image,
			interest_icon_image, plan_icon_image;

	TextView tvName, tvStatusMessage, tvAddress, tvTime, tvDistance, tvAge,
			tvCity, tvCompany, tvRelationshipStatus;

	LinearLayout age_layout, relationship_layout, living_in_layout,
			work_at_layout;
	LinearLayout layEditProfilePic;
	LinearLayout lenearLayoutFirstMeetUp, linearLayoutFirstPlan;

	int responseStatus = 0;
	String responseString = "";

	ImageDownloader imageDownloader;

	private ProgressDialog m_ProgressDialog = null;
	int requestCode;
	Bitmap avatar;
	String dob = "";
	Calendar now = Calendar.getInstance();

	String strRelationshipStatus;

	private People people;
	private People peopleUpdate;
	private String peopleId;

	String getAvater, getCoverPhoto, getRegMedia, getFirstName, getLastName,
			userName, getStatusMsg, getStreetAdd, getLastLog, getAge,
			getRelationshipStatus, getCity, getWorkInfo;

	RelativeLayout relativeLayoutFriendshipStatus, relativeLayoutFriend,
			relativeLayoutMeetUp, relativeLayoutMessage,
			relativeLayoutDirection;
	TextView tvFriendshipStatus, tvFriendshipCheck;

	private Dialog msgDialog, frndRequestDialog;

	String friendRequestFriendId = "";
	String friendRequestMessage = "";
	String friendRequestResponse = "";
	int friendRequestStatus = 0;

	private List<String> friendRequestSentList = new ArrayList<String>();

	String sendMessageFriendId = "";
	String sendMessageSubject = "";
	String sendMessageContent = "";
	String sendMessageResponse = "";
	int sendMessageStatus = 0;
	private WebView webViewNewsFeed;
	private ProgressBar progressBar;

	private String friendsResponse;
	private int friendsStatus;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.other_layout);

		Object obj = getIntent().getSerializableExtra("otherUser");
		peopleId = getIntent().getStringExtra("peopleId");
		if (obj != null) {
			people = (People) (obj);
			peopleId = people.getId();
			obj = null;
		}

		initialize();

		if (peopleId != null) {
			getFriendInfo();
		}

	}

	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);
	}

	private void initialize() {
		context = ProfileActivity2.this;
		imageDownloader = ImageDownloader.getInstance();

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

		photos_icon_image = (ImageView) findViewById(R.id.photos_icon_image);
		photos_icon_image.setOnClickListener(this);

		friends_icon_image = (ImageView) findViewById(R.id.friends_icon_image);
		friends_icon_image.setOnClickListener(this);

		places_icon_image = (ImageView) findViewById(R.id.places_icon_image);
		places_icon_image.setOnClickListener(this);

		interest_icon_image = (ImageView) findViewById(R.id.interest_icon_image);
		interest_icon_image.setOnClickListener(this);

		plan_icon_image = (ImageView) findViewById(R.id.plan_icon_image);
		plan_icon_image.setOnClickListener(this);

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
		linearLayoutFirstPlan = (LinearLayout) findViewById(R.id.linearLayoutFirstPlan);

		tvFriendshipStatus = (TextView) findViewById(R.id.tvFriendshipStatus);

		layEditProfilePic = (LinearLayout) findViewById(R.id.layEditProfilePic);
		tvFriendshipCheck = (TextView) findViewById(R.id.tvFriendshipCheck);

		ivOnline = (ImageView) findViewById(R.id.ivOnline);

		progressBar = (ProgressBar) findViewById(R.id.progressBar);
		webViewNewsFeed = (WebView) findViewById(R.id.webViewNewsFeed);

		webViewNewsFeed.setBackgroundColor(Color.parseColor("#00000000"));

		WebSettings webSettings = webViewNewsFeed.getSettings();
		webSettings.setJavaScriptEnabled(true);
		webSettings.setPluginsEnabled(false);
		webSettings.setJavaScriptCanOpenWindowsAutomatically(false);

		webSettings.setSupportMultipleWindows(false);

		webViewNewsFeed.getSettings().setSupportZoom(false);
		webViewNewsFeed.setVerticalScrollBarEnabled(true);
		webViewNewsFeed.setHorizontalScrollBarEnabled(false);
		webViewNewsFeed.getSettings().setBuiltInZoomControls(false);

		webViewNewsFeed.loadUrl(Constant.smServerUrl + "/" + peopleId
				+ "/newsfeed.html?authToken="
				+ StaticValues.myInfo.getAuthToken());

		Log.d("Friend NF URL",
				Constant.smServerUrl + "/" + peopleId
						+ "/newsfeed.html?authToken="
						+ StaticValues.myInfo.getAuthToken());

		webViewNewsFeed.setWebViewClient(new MyWebViewClient());

		webViewNewsFeed.setWebChromeClient(new WebChromeClient() {

			@Override
			public void onProgressChanged(WebView view, int progress) {

				progressBar.setVisibility(View.VISIBLE);

				if (progress == 100)
					progressBar.setVisibility(View.INVISIBLE);
			}

		});

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnNavigateToMap) {
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = peopleUpdate;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);

		} else if (v == btnEvent) {
			Intent i = new Intent(context, EventListActivityOther.class);
			i.putExtra("user", peopleUpdate);
			startActivity(i);
		} else if (v == btnBack) {
			finish();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(context,
					NotificationActivity.class);
			startActivity(notificationIntent);
		} else if (v == photos_icon_image) {
			showOtherPeoplePhoto();
		} else if (v == friends_icon_image) {

			Intent friendIntent = new Intent(getApplicationContext(),
					FriendListActivity.class);
			friendIntent.putExtra("PERSON_ID", peopleUpdate.getId());
			startActivity(friendIntent);
		} else if (v == places_icon_image) {
			goToShowPlaces();
		} else if (v == interest_icon_image) {
			goToMeetUp();
		} else if (v == relativeLayoutFriend) {
			showFrndRequestDialog(peopleUpdate);
		} else if (v == relativeLayoutMeetUp) {
			goToMeetUp();
		} else if (v == relativeLayoutMessage) {
			showMessageDialog(peopleUpdate);
		} else if (v == relativeLayoutDirection) {
			goToDirection();
		} else if (v == plan_icon_image) {
			goToShowPlanList();
		}

	}

	private void goToShowPlanList() {
		Intent intent = new Intent(context, PlanListActivity.class);
		intent.putExtra("personID", peopleUpdate.getId());
		intent.putExtra("firstName", peopleUpdate.getFirstName());
		intent.putExtra("lastName", peopleUpdate.getLastName());
		Log.d("Person Id", peopleUpdate.getId());
		startActivity(intent);
	}

	private void showOtherPeoplePhoto() {
		Intent intent = new Intent(getApplicationContext(),
				PhotoListActivity.class);
		intent.putExtra("user", peopleUpdate);
		startActivity(intent);
	}

	private void goToShowPlaces() {
		Intent intentToGoPlace = new Intent(context, PlacesListActivity.class);
		Log.d("People Name & ID", peopleUpdate.getFirstName() + " "
				+ peopleUpdate.getId());
		intentToGoPlace.putExtra("personID", peopleUpdate.getId());
		intentToGoPlace.putExtra("PERSON_NAME", peopleUpdate.getFirstName());
		startActivity(intentToGoPlace);
	}

	private void goToMeetUp() {
		Log.d("LAT LNG Meetup People",
				String.valueOf(peopleUpdate.getCurrentLat()) + " "
						+ String.valueOf(peopleUpdate.getCurrentLng()));

		Intent intentToShowMeetUp = new Intent(context,
				MeetupRequestNewActivity.class);
		intentToShowMeetUp.putExtra("selectedPeople", peopleUpdate);
		startActivity(intentToShowMeetUp);
	}

	private void goToDirection() {

		Intent intentToGoDirection = new Intent(context,
				DirectionActivity.class);
		intentToGoDirection.putExtra("destLat", peopleUpdate.getCurrentLat());
		intentToGoDirection.putExtra("destLng", peopleUpdate.getCurrentLng());
		intentToGoDirection.putExtra("destAddress",
				peopleUpdate.getCurrentAddress());

		startActivity(intentToGoDirection);
	}

	private void setButtonForDisplay() {
		String userId = peopleUpdate.getId();
		String friendshipStatus = peopleUpdate.getFriendshipStatus();
		Log.d("User ID & Friendship Status Check", userId + " "
				+ friendshipStatus);

		if (friendRequestSentList.contains(userId)) {
			tvFriendshipStatus.setText("Pending");
		} else {

			if (friendshipStatus != null) {

				if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_NONE)) {

					relativeLayoutMeetUp.setVisibility(View.GONE);
					relativeLayoutFriendshipStatus.setVisibility(View.GONE);
					relativeLayoutFriend.setVisibility(View.VISIBLE);

				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {

					relativeLayoutFriend.setVisibility(View.GONE);
					relativeLayoutFriendshipStatus.setVisibility(View.GONE);

					relativeLayoutMeetUp.setVisibility(View.VISIBLE);
				} else {
					relativeLayoutFriendshipStatus.setVisibility(View.VISIBLE);
					relativeLayoutFriend.setVisibility(View.GONE);
					relativeLayoutMeetUp.setVisibility(View.GONE);

					String status = "";
					if (friendshipStatus
							.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {
						status = getString(R.string.status_friend_request_friend);
						relativeLayoutMeetUp.setVisibility(View.VISIBLE);

						relativeLayoutFriend.setVisibility(View.GONE);
						relativeLayoutFriendshipStatus.setVisibility(View.GONE);
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

	private void sendFriendRequest(String friendId, String message) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendRequestFriendId = friendId;
			friendRequestMessage = message;

			Thread thread = new Thread(null, friendRequestThread,
					"Start send message");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);

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
			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}
		}
	};

	private void handleResponseFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Send Frnd Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
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

	private void handleSuccssfulFriendRequest() {
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

	private void sendMessage(String friendId, String subject, String content) {
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
					.getString(R.string.sending_request_text), true, true);

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
			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}
		}
	};

	private void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog
		Log.d("Send Message", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
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

	private class MyWebViewClient extends WebViewClient {
		@Override
		public void onPageFinished(final WebView view, final String url) {
			Log.d("web status", "onPageFinished");

			webViewNewsFeed
					.loadUrl("javascript:window.HTMLOUT.showHTML('<head>'+document.getElementsByTagName('html')[0].innerHTML+'</head>');");

		}

		@Override
		public void onPageStarted(final WebView view, final String url,
				final Bitmap favicon) {
			Log.d("web status", "onPageStarted");

		}

		@Override
		public boolean shouldOverrideUrlLoading(final WebView view,
				final String url) {

			Log.i("URL URL URL ", url);

			String subURL = url.substring(6);
			if (subURL.startsWith("profile")) {
				String id = subURL.substring(8);
				Log.d("URL", id);
				if (id.equalsIgnoreCase(peopleId)) {

				} else {

					People p = new People();
					p.setId(id);

					Intent intent = new Intent(context, ProfileActivity2.class);

					intent.putExtra("otherUser", p);
					startActivity(intent);

				}
			} else if (subURL.startsWith("image")) {
				String imageURL = subURL.substring(6);
				Log.d("URL", imageURL);

				NewsFeedPhotoZoomDialogPicker photoZoomPicker = new NewsFeedPhotoZoomDialogPicker(

				context, imageURL, imageDownloader);
				photoZoomPicker.getWindow().setLayout(LayoutParams.FILL_PARENT,
						LayoutParams.FILL_PARENT);
				photoZoomPicker.show();
			} else if (subURL.startsWith("geotag")) {
			}

			return true;
		}

	}

	private void getFriendInfo() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {
			Thread thread = new Thread(null, friendsThread,
					"Start get friend's info from server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true, true);
		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable friendsThread = new Runnable() {
		@Override
		public void run() {
			RestClient restClient;
			Log.d("sending people id", peopleId);
			restClient = new RestClient(Constant.smServerUrl + "/users/"
					+ peopleId);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

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
			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}
		}
	};

	private void handleResponseFriends(int status, String response) {

		Log.w("Got friends response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			try {

				JSONObject jsonObject = new JSONObject(response);

				if (jsonObject != null) {
					peopleUpdate = ServerResponseParser.parsePeople(jsonObject);

					if (peopleUpdate != null) {
						Log.d("Update People", peopleUpdate.getFirstName()
								+ " " + peopleUpdate.getLastName() + " id: "
								+ peopleUpdate.getId());

						setDefaultValues();
						setButtonForDisplay();
					} else {
						Log.d("People Update Response", "Null Received");
					}

				}

			} catch (JSONException e) {

			}
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;
		}
	}

	private void setDefaultValues() {

		if (peopleUpdate.getFriendshipStatus() != null) {
			if (peopleUpdate.getFriendshipStatus().equalsIgnoreCase(
					Constant.STATUS_FRIENDSHIP_FRIEND)) {
				layEditProfilePic.setVisibility(View.VISIBLE);
				lenearLayoutFirstMeetUp.setVisibility(View.VISIBLE);
			}
		}

		if (peopleUpdate.getAvatar() != null) {
			ivProfilePic.setImageResource(R.drawable.thumb);
			imageDownloader.download(peopleUpdate.getAvatar(), ivProfilePic);

		}

		if (peopleUpdate.getCoverPhoto() != null) {

			Log.i("CoverPic", peopleUpdate.getCoverPhoto());
			ivCoverPic.setImageResource(R.drawable.img_blank);
			imageDownloader.download(peopleUpdate.getCoverPhoto(), ivCoverPic);
		}
		if (peopleUpdate.getRegMedia() != null) {
			if (peopleUpdate.getRegMedia().equals("fb")) {
				ivRegMedia.setVisibility(View.VISIBLE);
			}
		}

		String name = "";
		if (peopleUpdate.getFirstName() != null) {
			name = peopleUpdate.getFirstName() + " ";
		}
		if (peopleUpdate.getLastName() != null) {
			name += peopleUpdate.getLastName();
		}
		tvName.setText(name);

		if (peopleUpdate.getStatusMsg() != null) {
			if (peopleUpdate.getStatusMsg().equalsIgnoreCase("status"))
				tvStatusMessage.setVisibility(View.GONE);
			else
				tvStatusMessage.setText(peopleUpdate.getStatusMsg());
		} else {
			tvStatusMessage.setVisibility(View.GONE);
		}

		if (peopleUpdate.getStreetAddress() != null) {
			tvAddress.setText(peopleUpdate.getCurrentAddress());
		}

		if (peopleUpdate.getStreetAddress() == null) {
			tvAddress.setVisibility(View.INVISIBLE);
		}

		if (Utility.getFormatedDistance(peopleUpdate.getDistance()) != null) {
			tvDistance.setText(Utility.getFormatedDistance(Utility
					.calculateDistance(StaticValues.myPoint, new GeoPoint(
							(int) (peopleUpdate.getCurrentLat() * 1E6),
							(int) (peopleUpdate.getCurrentLng() * 1E6))),
					StaticValues.myInfo.getSettings().getUnit()));
		}

		if (peopleUpdate.getLastLogIn() != null) {
			tvTime.setText(Utility.getFormattedDisplayDate(peopleUpdate
					.getLastLogIn()));
		}

		if (peopleUpdate.getAge() > 0) {
			tvAge.setText(peopleUpdate.getAge() + " years");
		}
		if (peopleUpdate.getAge() == 0) {
			tvAge.setText(" ");
		}

		if (peopleUpdate.getRelationshipStatus() != null) {
			tvRelationshipStatus.setText(peopleUpdate.getRelationshipStatus());
		}

		if (peopleUpdate.getCity() != null) {
			tvCity.setText(peopleUpdate.getCity());
		}

		if (peopleUpdate.getWorkStatus() != null) {
			tvCompany.setText(peopleUpdate.getWorkStatus());
		}

		if (peopleUpdate.isOnline()) {
			ivOnline.setImageResource(R.drawable.online);
		}
	}

}
