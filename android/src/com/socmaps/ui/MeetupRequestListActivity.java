package com.socmaps.ui;

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
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class MeetupRequestListActivity extends Activity {

	ButtonActionListener buttonActionListener;
	LinearLayout meetupRequestListContainer;
	private LayoutInflater inflater;
	private Context context;

	ProgressDialog m_ProgressDialog;
	String meetupRequestResponse = "";
	int meetupRequestStatus = 0;

	String requestId;
	View requestItemView;
	String requestMyResponse;
	int requestStatus = 0;
	String requestResponse = "";

	int requestCount = 0;

	ImageLoader imageLoader;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.meetup_request_list_activity);

		initialize();

		getMeetupRequest();

	}

	public void initialize() {
		context = MeetupRequestListActivity.this;

		imageLoader = new ImageLoader(context);

		buttonActionListener = new ButtonActionListener();
		meetupRequestListContainer = (LinearLayout) findViewById(R.id.meetup_request_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

	}

	public void getMeetupRequest() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, meetupRequestThread,
					"Start get meetup request");
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

	private Runnable meetupRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMeetupUrl
					+ "/invited");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			meetupRequestResponse = restClient.getResponse();
			meetupRequestStatus = restClient.getResponseCode();

			runOnUiThread(meetupRequestReturnResponse);
		}
	};

	private Runnable meetupRequestReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseMeetupRequest(meetupRequestStatus,
					meetupRequestResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseMeetupRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("MEETUP REQ RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {
			// Log.e("Meetup List", response);
			try {
				meetupRequestListContainer.removeAllViews();

				List<MeetupRequest> meetupRequests = ServerResponseParser
						.parseMeetupRequestList(response);

				if (meetupRequests != null) {

					for (int i = 0; i < meetupRequests.size(); i++) {

						MeetupRequest meetupRequest = meetupRequests.get(i);

						if (meetupRequest != null) {
							meetupRequestListContainer
									.addView(getItemView(meetupRequest));
						}
					}
				}

			} catch (Exception e) {
				// Log.e("Parse response", e.getMessage());
				// TODO: handle exception
			}
		}

	}

	public View getItemView(final MeetupRequest meetupRequest) {
		final View itemView = inflater.inflate(R.layout.row_meetup_request,
				null);

		final String requestId = meetupRequest.getId();

		ImageView profilePic = (ImageView) itemView
				.findViewById(R.id.profilePic);
		TextView tvSenderName = (TextView) itemView
				.findViewById(R.id.senderName);
		TextView tvSentTime = (TextView) itemView.findViewById(R.id.sentTime);

		TextView tvGreetings = (TextView) itemView
				.findViewById(R.id.tvGreetings);
		TextView tvAddress = (TextView) itemView.findViewById(R.id.tvAddress);
		TextView tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);

		Button btnAcceptRequest = (Button) itemView
				.findViewById(R.id.btnAcceptRequest);
		Button btnDeclineRequest = (Button) itemView
				.findViewById(R.id.btnDeclineRequest);
		Button btnIgnoreRequest = (Button) itemView
				.findViewById(R.id.btnIgnoreRequest);

		TextView tvAcceptedRequest = (TextView) itemView
				.findViewById(R.id.tvAcceptedRequest);
		TextView tvDeclinedRequest = (TextView) itemView
				.findViewById(R.id.tvDeclinedRequest);
		TextView tvIgnoredRequest = (TextView) itemView
				.findViewById(R.id.tvIgnoredRequest);

		String avatarUrl = meetupRequest.getOwnerAvatar();
		if (avatarUrl != null && !avatarUrl.equals("")) {

			/*
			 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource
			 * ( getResources(), R.drawable.user_default));
			 * BitmapManager.INSTANCE.loadBitmap(avatarUrl, profilePic, 40, 40);
			 */

			imageLoader.DisplayImage(avatarUrl, profilePic,
					R.drawable.user_default);
		}

		String senderName = "";
		if (meetupRequest.getOwnerFirstName() != null) {
			senderName = meetupRequest.getOwnerFirstName();
		} else if (meetupRequest.getOwnerLastName() != null) {
			senderName = meetupRequest.getOwnerLastName();
		}
		tvSenderName.setText(senderName);

		String sentTime = "";
		if (meetupRequest.getTime() != null) {
			sentTime = Utility.getFormattedDisplayDate(meetupRequest.getTime());
		}
		tvSentTime.setText(sentTime);

		String recieverFirstName = StaticValues.myInfo.getFirstName();
		if (recieverFirstName == null) {
			recieverFirstName = "";
		}
		String greetings = "Hi " + recieverFirstName + ", " + senderName
				+ " has invited you to meet-up at";
		tvGreetings.setText(greetings);

		String address = meetupRequest.getAddress();
		if (address == null) {
			address = "Unknown location";
		}
		tvAddress.setText(address);

		String message = "";
		if (meetupRequest.getMessage() != null) {
			if (!meetupRequest.getMessage().equalsIgnoreCase("")) {
				message = "\"" + meetupRequest.getMessage() + "\"";
				tvMessage.setText(message);
			}

		}

		String myResponse = meetupRequest.getMyResponse();
		if (myResponse != null) {
			if (myResponse.equalsIgnoreCase(Constant.MY_RESPONSE_YES)) {
				btnAcceptRequest.setVisibility(View.GONE);
				tvAcceptedRequest.setVisibility(View.VISIBLE);
			} else if (myResponse.equalsIgnoreCase(Constant.MY_RESPONSE_NO)) {
				btnDeclineRequest.setVisibility(View.GONE);
				tvDeclinedRequest.setVisibility(View.VISIBLE);
			} else if (myResponse.equalsIgnoreCase(Constant.MY_RESPONSE_MAYBE)) {
				btnIgnoreRequest.setVisibility(View.GONE);
				tvIgnoredRequest.setVisibility(View.VISIBLE);
			}
		}

		btnAcceptRequest.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				responseToRequest(itemView, requestId, Constant.MY_RESPONSE_YES);
			}
		});
		btnDeclineRequest.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				final AlertDialog.Builder aBuilder = new AlertDialog.Builder(
						context);
				aBuilder.setTitle("Decline request");
				aBuilder.setIcon(R.drawable.icon_alert);
				aBuilder.setMessage("Are you sure you want to decline this Meet-up request?");

				aBuilder.setPositiveButton(getString(R.string.yesLabel),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(final DialogInterface dialog,
									final int which) {

								responseToRequest(itemView, requestId,
										Constant.MY_RESPONSE_NO);
								dialog.dismiss();
							}

						});

				aBuilder.setNegativeButton(getString(R.string.noLabel),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(final DialogInterface dialog,
									final int which) {
								dialog.dismiss();

							}

						});

				aBuilder.show();

			}
		});
		btnIgnoreRequest.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				responseToRequest(itemView, requestId,
						Constant.MY_RESPONSE_MAYBE);

			}
		});

		tvAddress.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				/*StaticValues.selectedMeetupRequest = meetupRequest;
				Intent intent = new Intent(context, ShowItemOnMap.class);
				intent.putExtra("FLAG", Constant.FLAG_MEETUP);
				startActivity(intent);*/
				
				Intent intent = new Intent(context, DirectionActivity.class);
				intent.putExtra("destLat", meetupRequest.getLat());
				intent.putExtra("destLng", meetupRequest.getLng());
				intent.putExtra("destAddress", meetupRequest.getAddress());
				startActivity(intent);
			}
		});

		return itemView;
	}

	// ///////////////////////////////////////////////////////////////////////////////////////////

	public void responseToRequest(View itemView, String itemId, String response) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Log.e("ResponseToRequest", itemId + ":" + response);

			requestId = itemId;
			requestItemView = itemView;
			requestMyResponse = response;

			Thread thread = new Thread(null, responseToRequestThread,
					"Start response request");
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

	private Runnable responseToRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMeetupUrl + "/"
					+ requestId + "/rsvp");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("response", requestMyResponse);

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			requestResponse = restClient.getResponse();
			requestStatus = restClient.getResponseCode();

			runOnUiThread(responseToReturnResponse);
		}
	};

	private Runnable responseToReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseToRequest(requestStatus, requestResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseToRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Accept Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);

			updateButtonStatus();

			String messageText = "";
			if (requestMyResponse.equalsIgnoreCase(Constant.MY_RESPONSE_YES)) {
				messageText = "Request accepted successfully";

			} else if (requestMyResponse
					.equalsIgnoreCase(Constant.MY_RESPONSE_NO)) {
				messageText = "Request declined successfully";
				requestItemView.setVisibility(View.GONE);
			} else if (requestMyResponse
					.equalsIgnoreCase(Constant.MY_RESPONSE_MAYBE)) {
				messageText = "Request ignored successfully";

			}

			Toast.makeText(context, messageText, Toast.LENGTH_SHORT).show();
			break;

		default:
			Toast.makeText(context,
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}

	public void updateButtonStatus() {
		Button btnAcceptRequest = (Button) requestItemView
				.findViewById(R.id.btnAcceptRequest);
		Button btnDeclineRequest = (Button) requestItemView
				.findViewById(R.id.btnDeclineRequest);
		Button btnIgnoreRequest = (Button) requestItemView
				.findViewById(R.id.btnIgnoreRequest);

		TextView tvAcceptedRequest = (TextView) requestItemView
				.findViewById(R.id.tvAcceptedRequest);
		TextView tvDeclinedRequest = (TextView) requestItemView
				.findViewById(R.id.tvDeclinedRequest);
		TextView tvIgnoredRequest = (TextView) requestItemView
				.findViewById(R.id.tvIgnoredRequest);

		btnAcceptRequest.setVisibility(View.VISIBLE);
		tvAcceptedRequest.setVisibility(View.GONE);

		btnDeclineRequest.setVisibility(View.VISIBLE);
		tvDeclinedRequest.setVisibility(View.GONE);

		btnIgnoreRequest.setVisibility(View.VISIBLE);
		tvIgnoredRequest.setVisibility(View.GONE);

		if (requestMyResponse.equalsIgnoreCase(Constant.MY_RESPONSE_YES)) {
			btnAcceptRequest.setVisibility(View.GONE);
			tvAcceptedRequest.setVisibility(View.VISIBLE);

		} else if (requestMyResponse.equalsIgnoreCase(Constant.MY_RESPONSE_NO)) {
			btnDeclineRequest.setVisibility(View.GONE);
			tvDeclinedRequest.setVisibility(View.VISIBLE);
		} else if (requestMyResponse
				.equalsIgnoreCase(Constant.MY_RESPONSE_MAYBE)) {
			btnIgnoreRequest.setVisibility(View.GONE);
			tvIgnoredRequest.setVisibility(View.VISIBLE);
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
