package com.socmaps.ui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.MessageEntity;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
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

	ImageLoader imageLoader;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.message_list_activity);

		initialize();

		// listIntent.putExtra("messageStatus", status);
		// listIntent.putExtra("messageResponse", response);

		int responseStatus = getIntent().getIntExtra("messageStatus", 404);
		String responseText = getIntent().getStringExtra("messageResponse");
		handleResponseMessage(responseStatus, responseText);
		// getMessages();

	}

	/*
	 * public void getMessages() { if
	 * (Utility.isConnectionAvailble(getApplicationContext())) {
	 * 
	 * Thread thread = new Thread(null, messagesThread, "Start get messages");
	 * thread.start();
	 * 
	 * // show progress dialog if needed m_ProgressDialog =
	 * ProgressDialog.show(this, getResources()
	 * .getString(R.string.please_wait_text), getResources()
	 * .getString(R.string.sending_request_text), true);
	 * 
	 * } else {
	 * 
	 * DialogsAndToasts
	 * .showNoInternetConnectionDialog(getApplicationContext()); } }
	 * 
	 * private Runnable messagesThread = new Runnable() {
	 * 
	 * @Override public void run() { // TODO Auto-generated method stub
	 * RestClient restClient = new RestClient(Constant.smMessagesUrl +
	 * "/inbox"); restClient.AddHeader(Constant.authTokenParam,
	 * Utility.getAuthToken(context));
	 * 
	 * try { restClient.Execute(RestClient.RequestMethod.GET); } catch
	 * (Exception e) { e.printStackTrace(); }
	 * 
	 * messageResponse = restClient.getResponse(); messageStatus =
	 * restClient.getResponseCode();
	 * 
	 * runOnUiThread(messageReturnResponse); } };
	 * 
	 * private Runnable messageReturnResponse = new Runnable() {
	 * 
	 * @Override public void run() { // TODO Auto-generated method stub
	 * handleResponseMessage(messageStatus, messageResponse);
	 * 
	 * // dismiss progress dialog if needed m_ProgressDialog.dismiss(); } };
	 */

	public void handleResponseMessage(int status, String response) {
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
							
							
							if(messageEntity.getStatus().equalsIgnoreCase(Constant.STATUS_MESSAGE_UNREAD))
							{
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

							/*
							 * if (messages[i].getCreateDate() != null) {
							 * sentTime.setText(messages[i].getCreateDate()); }
							 */
							if (messageEntity.getUpdateTimeEntity() != null) {
								sentTime.setText(Utility
										.getFormattedDisplayDate(messageEntity
												.getUpdateTimeEntity()));
							}

							if (messageEntity.getContent() != null) {
								String messageText = messageEntity.getContent();
								/*
								 * if (messageText.length() > 60) { messageText
								 * = messageText.substring(0, 60) + "..."; }
								 */

								senderMessage.setText(messageText);
							}

							final ImageView profilePic = (ImageView) v
									.findViewById(R.id.profilePic);

							String avatarUrl = messageInfoMap.get("avatar");

							if (avatarUrl != null && !avatarUrl.equals("")) {

								// BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource(getResources(),R.drawable.user_default));
								// BitmapManager.INSTANCE.loadBitmap(avatarUrl,profilePic,
								// 55, 55);
								// Log.e("ImageLoader", avatarUrl);
								imageLoader.DisplayImage(avatarUrl, profilePic,
										R.drawable.user_default);
							}

							listItemParent
									.setOnClickListener(new OnClickListener() {

										@Override
										public void onClick(View arg0) {
											// TODO Auto-generated method stub
											boolean isUnread = false;
											if(messageEntity.getStatus().equalsIgnoreCase(Constant.STATUS_MESSAGE_UNREAD))
											{
												isUnread = true;
												/*v.setBackgroundResource(R.drawable.list_item_selector);
												if(StaticValues.myInfo!=null)
												{
													StaticValues.myInfo.getNotificationCount().setMessageCount(StaticValues.myInfo.getNotificationCount().getMessageCount()-1);
													StaticValues.myInfo.getNotificationCount().setTotalCount(StaticValues.myInfo.getNotificationCount().getTotalCount()-1);
													
													Utility.updateNotificationBubbleCounter(MessageActivity.btnNotification);
													
												}*/
											}
											
											v.setBackgroundResource(R.drawable.list_item_selector);
											Intent i = new Intent(context, MessageConversationFromNotificationActivity.class);
											i.putExtra("itemThreadId", threadId);
											i.putExtra("itemMessageId", messageId);
											i.putExtra("status", isUnread);
											startActivity(i);
											
											//getMessageDetails(messageId, threadId);
										}
									});

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

	public void initialize() {
		context = MessageListActivity.this;
		buttonActionListener = new ButtonActionListener();

		imageLoader = new ImageLoader(context);

		btnNewMessage = (Button) findViewById(R.id.btnNewMessage);
		btnNewMessage.setOnClickListener(buttonActionListener);

		messageListContainer = (LinearLayout) findViewById(R.id.message_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}

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
			finish();
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

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnNewMessage) {
				// have initialize new message here
				initateNewMessage();
			}
		}

	}

	public void initateNewMessage() {
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

	public void getMessageDetails(String messageId, String threadId) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			itemMessageId = messageId;
			itemThreadId = threadId;

			if (itemMessageId != null && !itemMessageId.equalsIgnoreCase("")) {
				Thread thread = new Thread(null, messagesThread,
						"Start get message details");
				thread.start();

				// show progress dialog if needed
				m_ProgressDialog = ProgressDialog
						.show(MessageGroupActivity.group,
								getResources().getString(
										R.string.please_wait_text),
								getResources().getString(
										R.string.sending_request_text), true,true);
			} else {
				Toast.makeText(context, "Message ID not found.",
						Toast.LENGTH_SHORT).show();
			}

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable messagesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
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

			runOnUiThread(messageReturnResponse);
		}
	};

	private Runnable messageReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleMessageDetailsResponse(messageStatus, messageResponse);

			// dismiss progress dialog if needed
			
			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();
			}
			
		}

	};

	private void handleMessageDetailsResponse(int status, String response) {

		Log.e("Message Details", response);
		// TODO Auto-generated method stub
		Intent i = new Intent(context, MessageConversationActivity.class);
		i.putExtra("messageStatus", status);
		i.putExtra("messageResponse", response);

		// Create the view using FirstGroup's LocalActivityManager
		View view = MessageGroupActivity.group
				.getLocalActivityManager()
				.startActivity("Conversation",
						i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP))
				.getDecorView();

		// Again, replace the view
		MessageGroupActivity.group.replaceView(view);

	}

}
