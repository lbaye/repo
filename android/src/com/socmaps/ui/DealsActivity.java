package com.socmaps.ui;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;

public class DealsActivity extends Activity 
{
	Button btnApparel,btnTech,btnMeals,btnAccomodation,btnSports,btnDeals,btnMyProducts,btnReviews,btnInterests;
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.deal);
		
		initialize();
	}
	
	private void initialize() 
	{
		btnApparel=(Button) findViewById(R.id.btnApparel);
		btnTech=(Button) findViewById(R.id.btnTech);
		btnMeals=(Button) findViewById(R.id.btnMeals);
		btnAccomodation=(Button) findViewById(R.id.btnAccomodation);
		btnSports=(Button) findViewById(R.id.btnSports);
		btnDeals=(Button) findViewById(R.id.btnDeals);
		btnMyProducts=(Button) findViewById(R.id.btnMyProducts);
		btnReviews=(Button) findViewById(R.id.btnReviews);
		btnInterests=(Button) findViewById(R.id.btnInterests);
	}

}
