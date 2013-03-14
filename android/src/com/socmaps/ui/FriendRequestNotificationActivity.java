package com.socmaps.ui;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.CirclesAndFriends;
import com.socmaps.entity.FriendRequest;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * FriendRequestNotificationActivity class for generating friend request notification view and some user interaction.
 *
 */
public class FriendRequestNotificationActivity extends Activity {

	ButtonActionListener buttonActionListener;
	LinearLayout friendRequestListContainer;
	private LayoutInflater inflater;
	private Context context;

	ProgressDialog m_ProgressDialog;
	String friendRequestResponse = "";
	int friendRequestStatus = 0;

	String friendId;
	int requestStatus = 0;
	String requestResponse = "";

	int requestCount = 0;
	
	View selectedView;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_request_notification_activity);

		initialize();

		getFriendRequest();

	}

	private void initialize() {
		context = FriendRequestNotificationActivity.this;
		buttonActionListener = new ButtonActionListener();
		friendRequestListContainer = (LinearLayout) findViewById(R.id.friend_request_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

	}

	private void getFriendRequest() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, friendRequestThread,
					"Start get frnd request");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true,true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable friendRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendRequestUrl
					+ "/unaccepted");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
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
			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			
			}
		}
	};

	private void handleResponseFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("FR REQ RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {
			try {
				friendRequestListContainer.removeAllViews();

				FriendRequest[] friendRequests = ServerResponseParser
						.parseFriendRequest(response);

				if (friendRequests != null) {

					for (int i = 0; i < friendRequests.length; i++) {
						if (friendRequests[i] != null) {
							final View itemView = inflater.inflate(
									R.layout.row_friend_request, null);

							TextView senderName = (TextView) itemView
									.findViewById(R.id.sender_name_text_view);
							TextView sentTime = (TextView) itemView
									.findViewById(R.id.sentTime);
							TextView senderMessage = (TextView) itemView
									.findViewById(R.id.senderMessage);

							final String senderId = friendRequests[i]
									.getSenderId();

							if (friendRequests[i].getSenderName() != null) {
								senderName.setText(friendRequests[i]
										.getSenderName());
							}
							if (friendRequests[i].getSentTime() != null) {

								sentTime.setText(Utility
										.getFormattedDisplayDate(friendRequests[i]
												.getSentTime()));
							}
							if (friendRequests[i].getMessage() != null) {
								if (!friendRequests[i].getMessage().equals("")) {
									senderMessage.setText("\""
											+ friendRequests[i].getMessage()
											+ "\"");
								}
							}

							Button acceptButton = (Button) itemView
									.findViewById(R.id.btnAcceptRequest);
							acceptButton
									.setOnClickListener(new OnClickListener() {

										@Override
										public void onClick(View v) {
											// TODO Auto-generated method stub
											acceptFriendRequest(senderId);
											selectedView = itemView;
										}

									});

							Button declineButton = (Button) itemView
									.findViewById(R.id.btnDeclineRequest);
							declineButton
									.setOnClickListener(new OnClickListener() {

										@Override
										public void onClick(View v) {
											// TODO Auto-generated method stub
											declineFriendRequest(senderId);
											selectedView = itemView;
										}

									});

							Button ignoreButton = (Button) itemView
									.findViewById(R.id.btnIgnoreRequest);
							ignoreButton
									.setOnClickListener(new OnClickListener() {

										@Override
										public void onClick(View v) {
											// TODO Auto-generated method stub
											// ignoreFriendRequest(senderId);
											selectedView = itemView;
											selectedView.setVisibility(View.GONE);
										}

									});

							friendRequestListContainer.addView(itemView);
						}
					}
				}

			} catch (Exception e) {
				
				// TODO: handle exception
			}
		}
	}

	private void acceptFriendRequest(String senderId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendId = senderId;

			Thread thread = new Thread(null, acceptFriendRequestThread,
					"Start accept request");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true,true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable acceptFriendRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendRequestUrl
					+ "/" + friendId + "/accept");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			requestResponse = restClient.getResponse();
			requestStatus = restClient.getResponseCode();

			runOnUiThread(acceptFriendRequestReturnResponse);
		}
	};

	private Runnable acceptFriendRequestReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseAcceptFriendRequest(requestStatus, requestResponse);

			// dismiss progress dialog if needed
			
			if(m_ProgressDialog!=null){
			m_ProgressDialog.dismiss();
			}
		}
	};

	private void handleResponseAcceptFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Accept Friend Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			if(selectedView!=null)
			{
				if(StaticValues.myInfo!=null)
				{
					StaticValues.myInfo.getNotificationCount().setFriendRequestCount(StaticValues.myInfo.getNotificationCount().getFriendRequestCount()-1);
					StaticValues.myInfo.getNotificationCount().setTotalCount(StaticValues.myInfo.getNotificationCount().getTotalCount()-1);
					
					NotificationActivity.tabView2.setText("" + StaticValues.myInfo.getNotificationCount().getFriendRequestCount());
				}
				selectedView.setVisibility(View.GONE);
			}
			
			
			Toast.makeText(context, "Friend request accepted.",
					Toast.LENGTH_SHORT).show();
			if (response != null && !response.equals("")) {
				CirclesAndFriends circlesAndFriends = ServerResponseParser
						.parseCircleAndFriends(response);

				if (circlesAndFriends != null) {
					StaticValues.myInfo.setCircleList(circlesAndFriends.getCircles());
					StaticValues.myInfo.setFriendList(circlesAndFriends.getFriends());
				}

			}

			break;

		default:
			Toast.makeText(context,
					"An unknown error occured. Please try again!!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}

	private void declineFriendRequest(String senderId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendId = senderId;

			Thread thread = new Thread(null, declineFriendRequestThread,
					"Start decline request");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true,true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable declineFriendRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendRequestUrl
					+ "/" + friendId + "/decline");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			requestResponse = restClient.getResponse();
			requestStatus = restClient.getResponseCode();

			runOnUiThread(declineFriendRequestReturnResponse);
		}
	};

	private Runnable declineFriendRequestReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseDeclineFriendRequest(requestStatus, requestResponse);

			// dismiss progress dialog if needed
			
			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}
		}
	};

	private void handleResponseDeclineFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Decline Friend Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			Toast.makeText(context, "Friend request declined.",
					Toast.LENGTH_SHORT).show();
			if(selectedView!=null)
			{
				if(StaticValues.myInfo!=null)
				{
					StaticValues.myInfo.getNotificationCount().setFriendRequestCount(StaticValues.myInfo.getNotificationCount().getFriendRequestCount()-1);
					StaticValues.myInfo.getNotificationCount().setTotalCount(StaticValues.myInfo.getNotificationCount().getTotalCount()-1);
					
					NotificationActivity.tabView2.setText("" + StaticValues.myInfo.getNotificationCount().getFriendRequestCount());
				}
				
				selectedView.setVisibility(View.GONE);
			}
			
			break;

		default:
			Toast.makeText(context,
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}


	private void ignoreFriendRequest(String senderId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendId = senderId;

			Thread thread = new Thread(null, ignoreFriendRequestThread,
					"Start ignore request");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true,true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable ignoreFriendRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendRequestUrl
					+ "/" + friendId + "/ignore");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			requestResponse = restClient.getResponse();
			requestStatus = restClient.getResponseCode();

			runOnUiThread(ignoreFriendRequestReturnResponse);
		}
	};

	private Runnable ignoreFriendRequestReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseIgnoreFriendRequest(requestStatus, requestResponse);

			// dismiss progress dialog if needed
			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}
		}
	};

	private void handleResponseIgnoreFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Ignore Friend Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			Toast.makeText(context, "Friend request ignored.",
					Toast.LENGTH_SHORT).show();
			break;

		default:
			Toast.makeText(context,
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}


	@Override
	public void onContentChanged() {
		super.onContentChanged();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
		}
		return false;

	}

	private class ButtonActionListener implements OnClickListener {

		/*
		 * (non-Javadoc)
		 * 
		 * @see android.view.View.OnClickListener#onClick(android.view.View)
		 */
		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub

		}

	}

}
