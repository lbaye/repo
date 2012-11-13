package com.socmaps.widget;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;

import com.socmaps.ui.R;

public class MapViewDialog extends Activity implements OnClickListener {

	private int flag = -1;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.show_item_on_map_layout);
		getIntentData();
	}

	private void getIntentData() {
		// TODO Auto-generated method stub
		flag = getIntent().getIntExtra("FLAG", -1);
	}

	@Override
	public void onClick(View arg0) {
		// TODO Auto-generated method stub

	}

}
