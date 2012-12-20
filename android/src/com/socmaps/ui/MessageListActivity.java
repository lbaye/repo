package com.socmaps.ui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socmaps.entity.MessageEntity;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;

public class MessageListActivity extends Activity {

	ButtonActionListener buttonActionListener;
	Button btnNewMessage;
	LinearLayout messageListContainer;
	private LayoutInflater inflater;
	private Context context;

	ProgressDialog m_ProgressDialog;
	String messageResponse = "";
	int messageStatus = 0;

	String itemMessageId = "";
	String itemThreadId = "";

	ImageDownloader imageDownloader;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.message_list_activity);

		initialize();

		int responseStatus = getIntent().getIntExtra("messageStatus", 404);
		String responseText = getIntent().getStringExtra("messageResponse");
		handleResponseMessage(responseStatus, responseText);
	}

	private void handleResponseMessage(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("MESSAGE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {
			try {

				messageListContainer.removeAllViews();

				List<MessageEntity> messages = ServerResponseParser
						.parseMessages(response);

				if (messages != null) {

					for (int i = 0; i < messages.size(); i++) {

						final MessageEntity messageEntity = messages.get(i);
						if (messageEntity != null) {

							final String messageId = messageEntity
									.getMessageId();
							final String threadId = messageEntity.getThread();

							final View v = inflater.inflate(
									R.layout.message_list_item, null);
							RelativeLayout listItemParent = (RelativeLayout) v
									.findViewById(R.id.listItemParent);

							if (messageEntity.getStatus().equalsIgnoreCase(
									Constant.STATUS_MESSAGE_UNREAD)) {
								v.setBackgroundResource(R.drawable.list_item_selector_highlighted);

							}

							TextView senderName = (TextView) v
									.findViewById(R.id.senderName);
							TextView sentTime = (TextView) v
									.findViewById(R.id.sentTime);
							TextView senderMessage = (TextView) v
									.findViewById(R.id.senderMessage);

							Map<String, String> messageInfoMap = buildViewableMessageInfo(messageEntity);

							senderName.setText(messageInfoMap.get("title"));

							if (messageEntity.getUpdateTimeEntity() != null) {
								sentTime.setText(Utility
										.getFormattedDisplayDate(messageEntity
												.getUpdateTimeEntity()));
							}

							if (messageEntity.getContent() != null) {
								String messageText = messageEntity.getContent();

								senderMessage.setText(messageText);
							}

							final ImageView profilePic = (ImageView) v
									.findViewById(R.id.profilePic);

							String avatarUrl = messageInfoMap.get("avatar");

							if (avatarUrl != null && !avatarUrl.equals("")) {

								imageDownloader.download(avatarUrl, profilePic);
							}

							listItemParent
									.setOnClickListener(new OnClickListener() {

										@Override
										public void onClick(View arg0) {
											// TODO Auto-generated method stub
											boolean isUnread = false;
											if (messageEntity
													.getStatus()
													.equalsIgnoreCase(
															Constant.STATUS_MESSAGE_UNREAD)) {
												isUnread = true;
											}

											v.setBackgroundResource(R.drawable.list_item_selector);
											Intent i = new Intent(
													context,
													MessageConversationFromNotificationActivity.class);
											i.putExtra("itemThreadId", threadId);
											i.putExtra("itemMessageId",
													messageId);
											i.putExtra("status", isUnread);
											startActivity(i);

										}
									});

							if (messageEntity.getStatus().equalsIgnoreCase(
									"unread")) {

								senderMessage.setBackgroundColor(Color.GRAY);
							}

							messageListContainer.addView(v);
						}
					}
				}

			} catch (Exception e) {
				Log.e("Parse response", e.getMessage());
				// TODO: handle exception
			}
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

	private void initialize() {
		context = MessageListActivity.this;
		buttonActionListener = new ButtonActionListener();

		imageDownloader = ImageDownloader.getInstance();

		btnNewMessage = (Button) findViewById(R.id.btnNewMessage);
		btnNewMessage.setOnClickListener(buttonActionListener);

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

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnNewMessage) {
				// have initialize new message here
				initateNewMessage();
			}
		}

	}

	private void initateNewMessage() {
		// TODO Auto-generated method stub
		Intent i = new Intent(context, MessageComposeActivity.class);

		View view = MessageGroupActivity.group
				.getLocalActivityManager()
				.startActivity("Compose",
						i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP))
				.getDecorView();

		// Again, replace the view
		MessageGroupActivity.group.replaceView(view);

	}
}
