package com.socmaps.ui;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;

public class PeopleActivity extends Activity 
{
	Button btnNetworks,btnFriends,btnFilters,btnProximityAlerts,btnLocationSharing,btnMessages;
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.people);
		
		initialize();
	}

	private void initialize() 
	{
		btnNetworks=(Button) findViewById(R.id.btnNetworks);
		btnFriends=(Button) findViewById(R.id.btnFriends);
		btnFilters=(Button) findViewById(R.id.btnFilters);
		btnProximityAlerts=(Button) findViewById(R.id.btnProximityAlerts);
		btnLocationSharing=(Button) findViewById(R.id.btnLocationSharing);
		btnMessages=(Button) findViewById(R.id.btnMessages);
	}
}
