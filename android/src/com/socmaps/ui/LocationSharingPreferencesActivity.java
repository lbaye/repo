package com.socmaps.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;

public class LocationSharingPreferencesActivity extends Activity implements OnClickListener
{
	CheckBox chkFriends,chkStrangers;
	Button btnSave;
	
	Button btnBack,btnNotification;
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.locationsharing_preferences);
		
		initialize();
		setViewOnClickListener();
	}
	
	public void onAttachedToWindow() {
	    super.onAttachedToWindow();
	    Window window = getWindow();
	    // Eliminates color banding
	    window.setFormat(PixelFormat.RGBA_8888);
	  }
	
	private void initialize()
	{
		btnBack = (Button)findViewById(R.id.btnBack);		
		btnNotification = (Button)findViewById(R.id.btnNotification);
		
		chkFriends=(CheckBox) findViewById(R.id.chkFriends);
		chkStrangers=(CheckBox) findViewById(R.id.chkStrangers);
		btnSave=(Button) findViewById(R.id.btnSave);
	}
	
	private void setViewOnClickListener() {
		// TODO Auto-generated method stub
		
		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		
	}

	/* (non-Javadoc)
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if(v == btnBack)
		{
			finish();	
		}
		else if(v == btnNotification)
		{
			Intent notificationIntent = new Intent(getApplicationContext(), NotificationActivity.class);
			startActivity(notificationIntent);	
		}
		
	}
}
