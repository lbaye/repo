package com.socmaps.ui;

import com.socmaps.util.Constant;
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
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

public class MessageActivity extends TabActivity {

	ButtonActionListener buttonActionListener;

	Button btnBack;
	
	static Button btnNotification;

	private TabHost mTabHost; 
	Context context;

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
		setContentView(R.layout.message_activity);

		initialize();
		
		

		setupTabHost();

		mTabHost.getTabWidget().setDividerDrawable(R.drawable.seperator);

		Drawable messageTabIcon = getResources().getDrawable(
				R.drawable.tab_item_message);
		Drawable meetupRequestTabIcon = getResources().getDrawable(
				R.drawable.tab_item_meetup);
		/*
		 * // Tab for message TabSpec messageSpec =
		 * mTabHost.newTabSpec("Message"); // setting Title and Icon for the Tab
		 * //messageSpec.setIndicator("Message",
		 * getResources().getDrawable(R.drawable.icon_message_tab)); Intent
		 * messageIntent = new Intent(getApplicationContext(),
		 * MessageNotificationActivity.class);
		 * messageSpec.setContent(messageIntent);
		 */

		/*
		 * Intent messageListIntent = new Intent(MessageActivity.this,
		 * MessageListActivity.class);
		 */
		Intent messageGroupIntent = new Intent().setClass(this,
				MessageGroupActivity.class);
		Intent meetupListIntent = new Intent(MessageActivity.this,
				MeetupRequestListActivity.class);

		setupTab(messageGroupIntent, messageTabIcon, getText(R.string.messages)
				.toString());
		setupTab(meetupListIntent, meetupRequestTabIcon,
				getText(R.string.meetuprequests).toString());
		
		if(getIntent().getStringExtra("selectedTab")!=null)
		{
			Log.i("Message:selectedTab", getIntent().getStringExtra("selectedTab"));
			if(getIntent().getStringExtra("selectedTab").equals(Constant.PUSH_NOTIFICATION_MEETUP))
			{
				mTabHost.setCurrentTab(1);
			}
		}

	}

	private TabHost getMyTabHost() {
		return mTabHost;
	}

	private void initialize() { 
		
		context = MessageActivity.this;
		
		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

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
		// Log.i("TabHost", mTabHost.getChildCount()+"");

	}

	private static View createTabView(final Context context, Drawable tabIcon,
			final String text) {
		View view = LayoutInflater.from(context).inflate(
				R.layout.tabs_bg_message, null);

		ImageView tabItemIcon = (ImageView) view.findViewById(R.id.tabIcon);

		tabItemIcon.setImageDrawable(tabIcon);

		return view;
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
			if (v == btnBack) {
				finish(); 
				Utility.hideKeyboardContext(context);
			}
			if (v == btnNotification) {
				Intent i = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(i);
			}

		}

	}

}
