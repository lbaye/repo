package com.socmaps.ui;


import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.TabHost.TabContentFactory;
import android.widget.TabHost.TabSpec;

public class FriendRequestNotificationActivity extends Activity {
	
	ButtonActionListener buttonActionListener;
	LinearLayout friendRequestListContainer;
	private LayoutInflater inflater;
	private Context context;
	

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friend_request_notification_activity);
		
		initialize();
		
		

	}
	
	
	
	public void initialize()
	{
		context=FriendRequestNotificationActivity.this;
		buttonActionListener = new ButtonActionListener();
		friendRequestListContainer=(LinearLayout)findViewById(R.id.friend_request_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				
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
		
		friendRequestListContainer.removeAllViews();
		for(int i=0;i<5;i++)
		{
			View v=inflater.inflate(R.layout.row_friend_request, null);
			friendRequestListContainer.addView(v);
		}
	}

	@Override
	protected void onPause() {
		super.onPause();

	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			//finish();
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
			
		}
		
	}

}
