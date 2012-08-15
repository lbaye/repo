package com.socmaps.ui;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;

public class VenueActivity extends Activity 
{
	Button btnRestaurants,btnShops,btnBars,btnHotels,btnMuseums,btnBusinesses,btnMyPlaces,
	btnReviews,btnLayers,btnEvents,btnInterests,btnTips;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.venues);
		
		initialize();
	}

	private void initialize() 
	{
		btnRestaurants=(Button) findViewById(R.id.btnRestaurants);
		btnShops=(Button) findViewById(R.id.btnShops);
		btnBars=(Button) findViewById(R.id.btnBars);
		btnHotels=(Button) findViewById(R.id.btnHotels);
		btnMuseums=(Button) findViewById(R.id.btnMuseums);
		btnBusinesses=(Button) findViewById(R.id.btnBusinesses);
		btnMyPlaces=(Button) findViewById(R.id.btnMyPlaces);
		btnReviews=(Button) findViewById(R.id.btnReviews);
		btnLayers=(Button) findViewById(R.id.btnLayers);
		btnEvents=(Button) findViewById(R.id.btnEvents);
		btnInterests=(Button) findViewById(R.id.btnInterests);
		btnTips=(Button) findViewById(R.id.btnTips);
	}

}
