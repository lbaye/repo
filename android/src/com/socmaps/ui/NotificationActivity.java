package com.socmaps.ui;

import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;
import android.widget.TextView;

/** 
 * NotificationActivity class is used to notify user about the messages that has received or pending friendship request or 
 * other notification. It also shows some exact digit to figure out. 
 */

public class NotificationActivity extends TabActivity {

	ButtonActionListener buttonActionListener;

	Button btnBack, btnSearch, btnNotification;

	private TabHost mTabHost;

	static TextView tabView1, tabView2, tabView3;
	static int tabCounter = 0;

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notification_activity);

		initialize();

		setupTabHost();

		mTabHost.getTabWidget().setDividerDrawable(R.drawable.seperator);

		Drawable messageTabIcon = getResources().getDrawable(
				R.drawable.tab_item_notification_message);
		Drawable friendRequestTabIcon = getResources().getDrawable(
				R.drawable.tab_item_notification_friend_request);
		Drawable notifyTabIcon = getResources().getDrawable(
				R.drawable.tab_item_notification_notification);

		Intent messageIntent = new Intent(NotificationActivity.this,
				MessageNotificationActivity.class);
		Intent frIntent = new Intent(NotificationActivity.this,
				FriendRequestNotificationActivity.class);
		Intent notifyIntent = new Intent(NotificationActivity.this,
				NotifyNotificationActivity.class);

		String messageCount = "0";
		String friendRequestCount = "0";
		String notificationCount = "0";
		if (StaticValues.myInfo != null) {
			messageCount = ""
					+ StaticValues.myInfo.getNotificationCount()
							.getMessageCount();
			friendRequestCount = ""
					+ StaticValues.myInfo.getNotificationCount()
							.getFriendRequestCount();
			notificationCount = ""
					+ StaticValues.myInfo.getNotificationCount()
							.getNotificationCount();
		}

		setupTab(messageIntent, messageTabIcon, messageCount);
		setupTab(frIntent, friendRequestTabIcon, friendRequestCount);
		setupTab(notifyIntent, notifyTabIcon, notificationCount);

		if (getIntent().getStringExtra("selectedTab") != null) {
			if (getIntent().getStringExtra("selectedTab").equals(
					Constant.PUSH_NOTIFICATION_FRIEND_REQUEST)) {
				mTabHost.setCurrentTab(1);
			}
		}

	}

	/**
	 * This method is used to get the Tab Host.
	 * 
	 * @return TabHost
	 * @see TabHost
	 */

	public TabHost getMyTabHost() {
		return mTabHost;
	}

	private void initialize() {
		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnSearch = (Button) findViewById(R.id.btnSearch);
		btnSearch.setOnClickListener(buttonActionListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

	}

	private void setupTabHost() {
		mTabHost = (TabHost) findViewById(android.R.id.tabhost);
		mTabHost.setup();
	}

	private void setupTab(final Intent intent, final Drawable tabIcon,
			final String tag) {
		View tabview = createTabView(mTabHost.getContext(), tabIcon, tag);

		TabSpec setContent = mTabHost.newTabSpec(tag).setIndicator(tabview)
				.setContent(intent);
		mTabHost.addTab(setContent);
		Log.i("TabHost", mTabHost.getChildCount() + "");

	}

	private static View createTabView(final Context context, Drawable tabIcon,
			final String text) {
		View view = LayoutInflater.from(context).inflate(
				R.layout.tabs_bg_notification, null);

		RelativeLayout tabItemLayout = (RelativeLayout) view
				.findViewById(R.id.tabItemLayout);

		tabItemLayout.setBackgroundDrawable(tabIcon);

		TextView tvItemCountDisplay = (TextView) tabItemLayout
				.findViewById(R.id.tvItemCountDisplay);
		tvItemCountDisplay.setText(text);

		if (tabCounter == 0) {
			tabView1 = tvItemCountDisplay;
		} else if (tabCounter == 1) {
			tabView2 = tvItemCountDisplay;
		} else if (tabCounter == 2) {
			tabView3 = tvItemCountDisplay;
		}
		tabCounter++;

		return view;
	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();
	}

	@Override
	protected void onResume() {
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);
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

		/*
		 * (non-Javadoc)
		 * 
		 * @see android.view.View.OnClickListener#onClick(android.view.View)
		 */
		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnBack) {
				finish();
			}
		}
	}
}
