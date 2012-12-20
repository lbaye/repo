package com.socmaps.ui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MessageEntity;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class MessageConversationFromNotificationActivity extends Activity {

	ButtonActionListener buttonActionListener;
	Button btnSend;
	Button btnBack;
	LinearLayout messageListContainer;
	private LayoutInflater inflater;
	private Context context;

	ScrollView scrollViewBody;

	EditText etNewMessage;
	String newMessage;

	ProgressDialog m_ProgressDialog;
	String messageResponse = "";
	int messageStatus = 0;

	String parentId;

	// Replies update related variables
	long lastUpdatedOn;
	long fetchNewRepliesAfter = 60 * 1000;

	String repliesResponse = "";
	int repliesStatus = 0;

	String messageTitle;

	HashMap<String, Boolean> displayedMessageList = new HashMap<String, Boolean>();

	ImageDownloader imageDownloader;

	String itemThreadId;
	String itemMessageId;
	boolean isUnread;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.message_conversation_from_notification_activity);

		initialize();

		itemThreadId = getIntent().getStringExtra("itemThreadId");
		itemMessageId = getIntent().getStringExtra("itemMessageId");
		isUnread = getIntent().getBooleanExtra("status", false);

		getMessageDetails();

	}

	private void getMessageDetails() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			if (itemMessageId != null && !itemMessageId.equalsIgnoreCase("")) {
				Thread thread = new Thread(null, messagesDetailsThread,
						"Start get message details");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog.show(context, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.sending_request_text), true, true);
			} else {
				Toast.makeText(context, "Message details not found.",
						Toast.LENGTH_SHORT).show();
				finish();
			}

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
			finish();
		}
	}

	private Runnable messagesDetailsThread = new Runnable() {
		@Override
		public void run() {
			RestClient restClient = new RestClient(Constant.smMessagesUrl + "/"
					+ itemMessageId);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			messageResponse = restClient.getResponse();
			messageStatus = restClient.getResponseCode();

			runOnUiThread(messageDetailsReturnResponse);
		}
	};

	private Runnable messageDetailsReturnResponse = new Runnable() {

		@Override
		public void run() {

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}

			handleResponseMessage(messageStatus, messageResponse);

		}

	};

	private void getRepliesPeriodically() {
		final int delay = 30;
		long period = fetchNewRepliesAfter;
		Timer timer = new Timer();

		timer.scheduleAtFixedRate(new TimerTask() {
			@Override
			public void run() {
				// Task here ...

				long currentTime = Utility.getUnixTimestamp();
				long timeDiff = currentTime - lastUpdatedOn;

				if (timeDiff > delay) {
					getReplies();
				}

			}
		}, delay * 1000, period);
	}

	private void getReplies() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, replyThread, "Start get replies");
			thread.start();

		} else {

			if (m_ProgressDialog != null) {
				if (m_ProgressDialog.isShowing()) {
					m_ProgressDialog.dismiss();
				}
			}
		}
	}

	private Runnable replyThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			Log.e("ReplyUrl", Constant.smMessagesUrl + "/" + parentId
					+ "/replies?since=" + lastUpdatedOn);

			RestClient restClient = new RestClient(Constant.smMessagesUrl + "/"
					+ parentId + "/replies?since=" + lastUpdatedOn);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			repliesResponse = restClient.getResponse();
			repliesStatus = restClient.getResponseCode();

			runOnUiThread(replyReturnResponse);
		}
	};

	private Runnable replyReturnResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			if (m_ProgressDialog != null) {
				if (m_ProgressDialog.isShowing()) {
					m_ProgressDialog.dismiss();
				}
			}

			handleResponseReplies(repliesStatus, repliesResponse);

			// dismiss progress dialog if needed m_ProgressDialog.dismiss();
		}
	};

	private void handleResponseReplies(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("REPLY RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {

			lastUpdatedOn = Utility.getUnixTimestamp();
			repliesResponse = "";
			repliesStatus = 0;

			try {
				List<MessageEntity> replies = ServerResponseParser
						.parseMessages(response);

				if (replies != null) {
					for (int i = 0; i < replies.size(); i++) {

						MessageEntity replyMessageEntity = replies.get(i);

						String messageId = replyMessageEntity.getMessageId();
						boolean isDisplayed = displayedMessageList
								.containsKey(messageId);
						if (!isDisplayed) {
							View rView = getListItem(replyMessageEntity);
							messageListContainer.addView(rView);
							displayedMessageList.put(messageId, true);
						}

					}
				}
				// end of replies

				etNewMessage.setText("");

				scrollToBottom();

			} catch (Exception e) {
				Log.e("Parse response", e.getMessage());
				// TODO: handle exception
			}
		}

	}

	private void handleResponseMessage(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("MESSAGE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {

			if (StaticValues.myInfo != null && isUnread) {
				StaticValues.myInfo.getNotificationCount().setMessageCount(
						StaticValues.myInfo.getNotificationCount()
								.getMessageCount() - 1);
				StaticValues.myInfo.getNotificationCount().setTotalCount(
						StaticValues.myInfo.getNotificationCount()
								.getTotalCount() - 1);

			}

			lastUpdatedOn = Utility.getUnixTimestamp();
			getRepliesPeriodically();

			try {

				messageListContainer.removeAllViews();

				try {
					JSONObject jObject = new JSONObject(response);
					MessageEntity messages = ServerResponseParser
							.parseMessageThread(jObject);

					if (messages != null) {

						parentId = messages.getMessageId();

						Map<String, String> messageInfoMap = buildViewableMessageInfo(messages);
						TextView tvThreadTitle = (TextView) findViewById(R.id.tvThreadTitle);
						tvThreadTitle.setText(messageInfoMap.get("title"));

						View v = getListItem(messages);

						messageListContainer.addView(v);

						// add replies here
						List<MessageEntity> meList = messages.getReplies();
						if (meList != null) {
							for (int j = 0; j < meList.size(); j++) {

								String messageId = meList.get(j).getMessageId();

								boolean isDisplayed = displayedMessageList
										.containsKey(messageId);
								if (!isDisplayed) {
									View rView = getListItem(meList.get(j));
									messageListContainer.addView(rView);
									displayedMessageList.put(messageId, true);
								}

							}
						}

						// end of replies

					}

				} catch (JSONException e) {
					// TODO: handle exception
				}

			} catch (Exception e) {
				Log.e("Parse response", e.getMessage());
				// TODO: handle exception
			}

		}

	}

	private View getListItem(final MessageEntity mEntity) {
		View v;

		String senderId = mEntity.getSenderId();
		String userId = Utility.getUserId(context);

		if (userId.equalsIgnoreCase(senderId)) {
			v = inflater.inflate(R.layout.message_conversation_item_left, null);
		} else {
			v = inflater
					.inflate(R.layout.message_conversation_item_right, null);
		}

		TextView senderName = (TextView) v.findViewById(R.id.senderName);
		TextView sentTime = (TextView) v.findViewById(R.id.sentTime);
		TextView senderMessage = (TextView) v.findViewById(R.id.senderMessage);

		String name = "";
		if (mEntity.getSenderFirstName() != null) {
			name = mEntity.getSenderFirstName() + " ";

		}
		if (mEntity.getSenderLastName() != null) {
			name += mEntity.getSenderLastName();

		}

		senderName.setText(name);

		/*
		 * if (mEntity.getCreateDate() != null) {
		 * sentTime.setText(mEntity.getCreateDate()); }
		 */

		if (mEntity.getUpdateTimeEntity() != null) {
			sentTime.setText(Utility.getFormattedDisplayDate(mEntity
					.getUpdateTimeEntity()));
		}

		if (mEntity.getContent() != null) {
			String messageText = mEntity.getContent();

			senderMessage.setText(messageText);
		}

		Button btnDirection = (Button) v.findViewById(R.id.btnDirection);

		if (mEntity.getMetaContent() != null) {
			if (mEntity.getMetaContent().getType()
					.equals(Constant.META_TYPE_VENUE)) {
				btnDirection.setVisibility(View.VISIBLE);
			}
		}

		btnDirection.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(context, DirectionActivity.class);
				intent.putExtra("destLat", mEntity.getMetaContent()
						.getLatitude());
				intent.putExtra("destLng", mEntity.getMetaContent()
						.getLongitude());
				intent.putExtra("destAddress", mEntity.getMetaContent()
						.getAddress());
				startActivity(intent);
			}
		});

		return v;
	}

	private void initialize() {
		context = MessageConversationFromNotificationActivity.this;
		buttonActionListener = new ButtonActionListener();

		imageDownloader = ImageDownloader.getInstance();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnSend = (Button) findViewById(R.id.btnSend);
		btnSend.setOnClickListener(buttonActionListener);

		scrollViewBody = (ScrollView) findViewById(R.id.scrollViewBody);

		etNewMessage = (EditText) findViewById(R.id.etNewMessage);

		messageListContainer = (LinearLayout) findViewById(R.id.message_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();
	}

	@Override
	protected void onResume() {
		super.onResume();
		scrollToBottom();
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			finish();
		}
		return false;

	}

	private void scrollToBottom() {
		final Handler handler = new Handler();
		new Thread(new Runnable() {
			@Override
			public void run() {
				handler.postDelayed(new Runnable() {
					@Override
					public void run() {
						scrollViewBody.scrollBy(View.FOCUS_LEFT,
								View.FOCUS_DOWN);
					}
				}, 500);
			}
		}).start();
	}

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnSend) {
				// have initialize new message here
				validateNewMessage();
			} else if (v == btnBack) {
				finish();
			}
		}

	}

	private void validateNewMessage() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			if (!etNewMessage.getText().toString().trim().equalsIgnoreCase("")
					&& parentId != null) {
				Thread thread = new Thread(null, sendMessagesThread,
						"Start send messages");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog.show(context, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.sending_request_text), true, true);
			}

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable sendMessagesThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("thread", parentId);
			restClient.AddParam("content", etNewMessage.getText().toString()
					.trim());

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			messageResponse = restClient.getResponse();
			messageStatus = restClient.getResponseCode();

			runOnUiThread(sendMessageReturnResponse);
		}
	};

	private Runnable sendMessageReturnResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			handleResponseSendMessage(messageStatus, messageResponse);

		}
	};

	private void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("MESSAGE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_CREATED) {

			Toast.makeText(context, "Message sent successfully.",
					Toast.LENGTH_SHORT).show();

			getReplies();

		} else {
			if (m_ProgressDialog != null) {
				if (m_ProgressDialog.isShowing()) {
					m_ProgressDialog.dismiss();
				}
			}
			Toast.makeText(context, "Sending failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

	private Map<String, String> buildViewableMessageInfo(MessageEntity message) {

		Map<String, String> info = new HashMap<String, String>();

		List<String> recipientNames = new ArrayList<String>();
		List<String> recipientAvatars = new ArrayList<String>();

		String userId = Utility.getUserId(context);

		for (Map<String, String> recipient : message.getRecipients()) {
			// Build message title
			String id = recipient.get("id");
			if (!id.equals(userId)) {
				recipientNames.add(recipient.get("firstName"));
				recipientAvatars.add(recipient.get("avatar"));
			}
		}

		// Build message title and set it over "title" key
		if (recipientNames.isEmpty()) {
			info.put("title", message.getSenderFirstName());
		} else {
			info.put("title", Utility.joinString(recipientNames, ", "));
		}

		// Set message avatar
		if (recipientAvatars.isEmpty()) {
			info.put("avatar", message.getSenderAvatar());
		} else {
			info.put("avatar", recipientAvatars.get(0));
		}
		return info;
	}

}
