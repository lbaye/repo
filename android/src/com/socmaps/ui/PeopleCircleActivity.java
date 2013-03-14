package com.socmaps.ui;

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.socmaps.entity.Circle;
import com.socmaps.images.ImageFetcher;
import com.socmaps.util.StaticValues;
import com.socmaps.widget.PeopleCirclePrefaranceItemView;

/**
 * PeopleCircleActivity class is used to create new circle & 
 * put people into it or put people from one circle to another or rename a circle. 
 * It also shows the persons of a particular circle. 
 */

public class PeopleCircleActivity extends FragmentActivity implements OnClickListener {

	private Context context;

	View requestItemView;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;

	private Button btnBack, btnInvitePeople, btnCirclePeople,btnBlockUnblockPeople, btnPeopleByDistance;
	private RelativeLayout searchPanel;

	private LinearLayout llCircleList;
	private static PeopleCircleActivity ins = null;

	/**
	 * This method holds an object which is static.
	 * 
	 * @return PeopleCircleActivity
	 */

	public static PeopleCircleActivity getIns() {
		return ins;
	}

	ImageFetcher imageFetcher;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.people_circle_tab_layout);

		initialize();

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		generateCircleView();
		
		imageFetcher.setExitTasksEarly(false);

	}
	
	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		imageFetcher.setExitTasksEarly(true);
	    imageFetcher.flushCache();
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		imageFetcher.closeCache();
	}

	private void initialize() {

		ins = PeopleCircleActivity.this;
		context = PeopleCircleActivity.this;

		imageFetcher = new ImageFetcher(context);
		

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);
		btnToggleSearchPanel.setVisibility(View.GONE);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnPeopleByDistance = (Button) findViewById(R.id.btnPeopleByDistance);
		btnPeopleByDistance.setOnClickListener(this);

		btnInvitePeople = (Button) findViewById(R.id.btnInvitePeople);
		btnInvitePeople.setOnClickListener(this);

		btnCirclePeople = (Button) findViewById(R.id.btnCirclePeople);
		btnCirclePeople.setOnClickListener(this);
		btnCirclePeople.setBackgroundColor(Color.LTGRAY);

		btnBlockUnblockPeople = (Button) findViewById(R.id.btnBlockUnblockPeople);
		btnBlockUnblockPeople.setOnClickListener(this);

		llCircleList = (LinearLayout) findViewById(R.id.llCircleList);

	}
	
	

	@Override
	public void onClick(View v) {

		if (v == btnToggleSearchPanel) {

		} else if (v == btnDoSearch) {

		} else if (v == btnClearSearch) {

		} else if (v == btnPeopleByDistance) {

			Intent circleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			circleIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(circleIntent);
			finish();

		} else if (v == btnInvitePeople) {

			Intent inviteIntent = new Intent(getApplicationContext(),
					PeopleInviteActivity.class);

			inviteIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(inviteIntent);

			finish();

		} else if (v == btnCirclePeople) {

		} else if (v == btnBlockUnblockPeople) {
			Intent blickUnblockiIntent = new Intent(getApplicationContext(),
					PeopleBlockUnblockActivity.class);
			blickUnblockiIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(blickUnblockiIntent);
			finish();
		} else if (v == btnBack) {

			finish();

		}

	}

	/**
	 * This method generates Circle list of a person.
	 * 
	 */

	public void generateCircleView() {

		List<Circle> circleList = StaticValues.myInfo.getCircleList();
		llCircleList.removeAllViews();
		if (circleList != null) {
			for (int i = 0; i < circleList.size(); i++) {
				Circle circle = circleList.get(i);

				if (circle != null) {
					llCircleList.addView(new PeopleCirclePrefaranceItemView(
							context, circle, imageFetcher));
				}
			}
		}

	}

	private void showSearchPanel(boolean display) {
		if (display) {
			searchPanel.setVisibility(View.VISIBLE);

		} else {
			searchPanel.setVisibility(View.GONE);
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (searchPanel.isShown()) {
				showSearchPanel(false);
			} else {
				finish();
			}

		}
		return false;

	}

}
