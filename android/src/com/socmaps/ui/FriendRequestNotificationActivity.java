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

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.CirclesAndFriends;
import com.socmaps.entity.FriendRequest;
import com.socmaps.entity.MyInfo;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

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

	public void initialize() {
		context = FriendRequestNotificationActivity.this;
		buttonActionListener = new ButtonActionListener();
		friendRequestListContainer = (LinearLayout) findViewById(R.id.friend_request_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

	}

	public void getFriendRequest() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, friendRequestThread,
					"Start get frnd request");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(this, getResources()
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
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("FR REQ RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {
			try {
				friendRequestListContainer.removeAllViews();

				FriendRequest[] friendRequests = ServerResponseParser
						.parseFriendRequest(response);

				if (friendRequests != null) {
					/*
					 * NotificationActivity ta = (NotificationActivity)
					 * this.getParent(); TabHost th = ta.getMyTabHost(); View
					 * tab = th.getChildAt(1); TextView tabLabel =
					 * (TextView)tab.findViewById(R.id.tvItemCountDisplay);
					 * tabLabel.setText(""+friendRequests.length);
					 */

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

							// accept_friend_request_btn
							// decline_friend_request_btn
							// ignore_friend_request_btn

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
				// Log.e("Parse response", e.getMessage());
				// TODO: handle exception
			}
		}

	}

	// ///////////////////////////////////////////////////////////////////////////////////////////

	public void acceptFriendRequest(String senderId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendId = senderId;

			Thread thread = new Thread(null, acceptFriendRequestThread,
					"Start accept request");
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
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseAcceptFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Accept Friend Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			if(selectedView!=null)
			{
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

	// //////////////////////////////////////////////////////////////////////////////////

	public void declineFriendRequest(String senderId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendId = senderId;

			Thread thread = new Thread(null, declineFriendRequestThread,
					"Start decline request");
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
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseDeclineFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Decline Friend Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Friend request declined.",
					Toast.LENGTH_SHORT).show();
			if(selectedView!=null)
			{
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

	// //////////////////////////////////////////////////////////////////////////////////////////////

	public void ignoreFriendRequest(String senderId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendId = senderId;

			Thread thread = new Thread(null, ignoreFriendRequestThread,
					"Start ignore request");
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
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseIgnoreFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Ignore Friend Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
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

	// //////////////////////////////////////////////////////////////////////////////////////////////

	@Override
	public void onContentChanged() {
		super.onContentChanged();

		// initialize
		// initialize();

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
			// finish();
			/*
			 * AlertDialog.Builder adb = new AlertDialog.Builder(this); //
			 * adb.setTitle("Set Title here");
			 * adb.setMessage("Are you sure you want to exit from this application?"
			 * ); adb.setPositiveButton("Yes", new
			 * DialogInterface.OnClickListener() { public void
			 * onClick(DialogInterface dialog, int id) { finish(); } });
			 * adb.setNegativeButton("No", new DialogInterface.OnClickListener()
			 * { public void onClick(DialogInterface dialog, int id) {
			 * dialog.cancel(); } }); adb.show();
			 */

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
