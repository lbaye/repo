package com.socmaps.ui;


import android.app.Activity;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.TabHost.TabContentFactory;
import android.widget.TabHost.TabSpec;

public class NotificationActivity extends TabActivity {
	
	ButtonActionListener buttonActionListener;
	
	Button btnBack, btnSearch, btnNotification;
	
	private TabHost mTabHost;

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
		
		mTabHost.getTabWidget().setDividerDrawable(R.drawable.sp2);

		Drawable messageTabIcon = getResources().getDrawable( R.drawable.icon_message_notification );
		Drawable friendRequestTabIcon = getResources().getDrawable( R.drawable.icon_friend_request );
		Drawable notifyTabIcon = getResources().getDrawable( R.drawable.icon_notify );
		
		
		/*// Tab for message
        TabSpec messageSpec = mTabHost.newTabSpec("Message");
        // setting Title and Icon for the Tab
        //messageSpec.setIndicator("Message", getResources().getDrawable(R.drawable.icon_message_tab));
        Intent messageIntent = new Intent(getApplicationContext(), MessageNotificationActivity.class);
        messageSpec.setContent(messageIntent);*/

		Intent messageIntent = new Intent(NotificationActivity.this, MessageNotificationActivity.class);
		Intent frIntent = new Intent(NotificationActivity.this, FriendRequestNotificationActivity.class);
		Intent notifyIntent = new Intent(NotificationActivity.this, NotifyNotificationActivity.class);
		
		setupTab(messageIntent,messageTabIcon, "1");
		setupTab(frIntent,friendRequestTabIcon, "4");
		setupTab(notifyIntent,notifyTabIcon, "3");

	}
	
	
	
	public void initialize()
	{
		buttonActionListener = new ButtonActionListener();
		
		btnBack = (Button)findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);
		
		btnSearch = (Button)findViewById(R.id.btnSearch);
		btnSearch.setOnClickListener(buttonActionListener);
		
		btnNotification = (Button)findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);	
				
	}
	
	
	private void setupTabHost() {
		mTabHost = (TabHost) findViewById(android.R.id.tabhost);
		mTabHost.setup();
	}
	
	private void setupTab(final Intent intent,final Drawable tabIcon, final String tag) {
		View tabview = createTabView(mTabHost.getContext(),tabIcon, tag);

		TabSpec setContent = mTabHost.newTabSpec(tag).setIndicator(tabview).setContent(intent);
		mTabHost.addTab(setContent);

	}

	private static View createTabView(final Context context, Drawable tabIcon, final String text) {
		View view = LayoutInflater.from(context).inflate(R.layout.tabs_bg_notification, null);
		
		
		RelativeLayout tabItemLayout = (RelativeLayout) view.findViewById(R.id.tabItemLayout);
		
		tabItemLayout.setBackgroundDrawable(tabIcon);
		
		TextView tvItemCountDisplay = (TextView)tabItemLayout.findViewById(R.id.tvItemCountDisplay);
		tvItemCountDisplay.setText(text);
		
		
		return view;
	}
	
	

	@Override
	public void onContentChanged() {
		super.onContentChanged();

		// initialize
		//initialize();

	}

	@Override
	protected void onResume() {
		super.onResume();

	}

	@Override
	protected void onPause() {
		super.onPause();

	}

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
	
	private class ButtonActionListener implements OnClickListener
	{

		/* (non-Javadoc)
		 * @see android.view.View.OnClickListener#onClick(android.view.View)
		 */
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if(v == btnBack)
			{
				finish();
			}
			
		}
		
	}

}
