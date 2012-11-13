package com.socmaps.ui;

import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MessageEntity;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;
import com.socmaps.widget.ExpandablePanel;

public class MessageNotificationActivity extends Activity {

	ButtonActionListener buttonActionListener;
	LinearLayout messageListContainer;
	private LayoutInflater inflater;
	private Context context;

	ProgressDialog m_ProgressDialog;
	String messageResponse = "";
	int messageStatus = 0;

	public String itemMessageId;
	public String itemThreadId;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.message_notification_activity);

		initialize();

		getMessages();

	}

	public void getMessages() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, messagesThread,
					"Start get messages");
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

	private Runnable messagesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl
					+ "/inbox");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			messageResponse = restClient.getResponse();
			messageStatus = restClient.getResponseCode();

			runOnUiThread(messageReturnResponse);
		}
	};

	private Runnable messageReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseMessage(messageStatus, messageResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseMessage(int status, String response) {

		Log.i("MESSAGE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {
			try {

				messageListContainer.removeAllViews();

				List<MessageEntity> messages = ServerResponseParser
						.parseMessages(response);

				if (messages != null) {

					NotificationActivity ta = (NotificationActivity) this
							.getParent();
					TabHost th = ta.getMyTabHost();
					View tab = th.getChildAt(0);
					TextView tabLabel = (TextView) tab
							.findViewById(R.id.tvItemCountDisplay);
					tabLabel.setText(""
							+ Utility.getMessageCount(messages,
									Constant.STATUS_MESSAGE_UNREAD));

					for (int i = 0; i < messages.size(); i++) {

						MessageEntity messageEntity = messages.get(i);
						if (messageEntity != null) {
							if (messageEntity.getStatus() != null) {
								if (messageEntity.getStatus().equalsIgnoreCase(
										Constant.STATUS_MESSAGE_UNREAD)) {
									View v = inflater.inflate(
											R.layout.row_message_list, null);
									ExpandablePanel panel = (ExpandablePanel) v
											.findViewById(R.id.foo);
									panel.setOnExpandListener(colapseExpand());

									final String messageId = messageEntity
											.getMessageId();
									final String threadId = messageEntity
											.getThread();

									TextView senderName = (TextView) v
											.findViewById(R.id.sender_name_text_view);
									TextView sentTime = (TextView) v
											.findViewById(R.id.sentTime);
									TextView senderMessage = (TextView) v
											.findViewById(R.id.senderMessage);

									String name = "";
									if (messageEntity.getSenderFirstName() != null) {
										name = messageEntity
												.getSenderFirstName() + " ";

									}
									if (messageEntity.getSenderLastName() != null) {
										name += messageEntity
												.getSenderLastName();

									}

									senderName.setText(name);

									if (messageEntity.getUpdateTimeEntity() != null) {
										sentTime.setText(Utility
												.getFormattedDisplayDate(messageEntity
														.getUpdateTimeEntity()));
									}

									if (messageEntity.getContent() != null) {
										senderMessage.setText(messageEntity
												.getContent());
									}

									v.setOnClickListener(new OnClickListener() {

										@Override
										public void onClick(View arg0) {
											getMessageDetails(messageId,
													threadId);
										}
									});

									messageListContainer.addView(v);
								}
							}

						}
					}
				}

			} catch (Exception e) {
				Log.e("Parse response", e.getMessage());
			}
		}

	}

	public void initialize() {
		context = MessageNotificationActivity.this;
		buttonActionListener = new ButtonActionListener();
		messageListContainer = (LinearLayout) findViewById(R.id.message_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}

	ExpandablePanel.OnExpandListener colapseExpand() {
		return new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				Button btn = (Button) handle;
				btn.setBackgroundResource(R.drawable.icon_more);
			}

			@Override
			public void onExpand(View handle, View content) {
				Button btn = (Button) handle;
				btn.setBackgroundResource(R.drawable.btn_collapse);
			}
		};
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

		@Override
		public void onClick(View v) {
		}

	}

	public void getMessageDetails(String messageId, String threadId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			itemMessageId = messageId;
			itemThreadId = threadId;

			if (itemMessageId != null && !itemMessageId.equalsIgnoreCase("")) {
				Thread thread = new Thread(null, messagesDetailsThread,
						"Start get message details");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog.show(context, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.sending_request_text), true);
			} else {
				Toast.makeText(context, "Message ID not found.",
						Toast.LENGTH_SHORT).show();
			}

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
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
			handleMessageDetailsResponse(messageStatus, messageResponse);
			m_ProgressDialog.dismiss();
		}

	};

	private void handleMessageDetailsResponse(int status, String response) {

		Log.e("Message Details", response);
		Intent i = new Intent(context,
				MessageConversationFromNotificationActivity.class);
		i.putExtra("messageStatus", status);
		i.putExtra("messageResponse", response);

		startActivity(i);

	}

}
