package com.socmaps.ui;

import java.util.ArrayList;

import android.app.ActivityGroup;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.Utility;

public class MessageGroupActivity extends ActivityGroup {

	public static MessageGroupActivity group;
	private ArrayList<View> history;

	private Context context;

	ProgressDialog m_ProgressDialog;
	String messageResponse = "";
	int messageStatus = 0;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		if (this.history == null) {
			this.history = new ArrayList<View>();
		}
		group = this;

		context = MessageGroupActivity.this;

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

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable messagesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl
					+ "/inbox?show_last_reply=1");
			// RestClient restClient = new
			// RestClient(Constant.smMessagesUrl+"/inbox");
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
			navigateToList(messageStatus, messageResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void navigateToList(int status, String response) {
		// show proper message through Toast or Dialog

		// Start the root activity withing the group and get its view
		Intent listIntent = new Intent(context, MessageListActivity.class);
		listIntent.putExtra("messageStatus", status);
		listIntent.putExtra("messageResponse", response);

		View view = getLocalActivityManager().startActivity(
				getString(R.string.messages),
				listIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP))
				.getDecorView();

		// Replace the view of this ActivityGroup
		replaceView(view);

	}

	public void replaceView(View v) {
		// Adds the old one to history
		history.add(v);
		// Changes this Groups View to the new View.
		setContentView(v);
	}

	public void back() {
		if (history.size() > 1) {
			history.remove(history.size() - 1);
			setContentView(history.get(history.size() - 1));
		} else {
			finish();
		}
	}

	@Override
	public void onBackPressed() {
		MessageGroupActivity.group.back();
		return;
	}

}
