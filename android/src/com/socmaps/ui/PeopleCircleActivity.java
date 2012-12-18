package com.socmaps.ui;

import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Circle;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.StaticValues;
import com.socmaps.widget.PeopleCirclePrefaranceItemView;

public class PeopleCircleActivity extends Activity implements OnClickListener {

	// private LinearLayout meetupRequestListContainer;

	private Context context;

	//ProgressDialog m_ProgressDialog;

	View requestItemView;

	// ImageLoader imageLoader;
	private boolean isSearchEnabled = false;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;

	private Button btnBack, btnInvitePeople, btnCirclePeople,
			btnBlockUnblockPeople, btnPeopleByDistance;

	private EditText etSearchField;
	private RelativeLayout searchPanel;
	// private int selectedBtnColor;

	private LinearLayout llCircleList;
	private LinearLayout circleItemView;

	private static boolean isRefreshCircleList = false;

	private static PeopleCircleActivity ins = null; 
	
	/** 
	 * This method holds an object which is static. 
	 * 
	 * @return PeopleCircleActivity
	 */

	public static PeopleCircleActivity getIns() {
		return ins;
	}

	ImageDownloader imageDownloader;

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

	}

	private void initialize() {

		ins = PeopleCircleActivity.this;
		context = PeopleCircleActivity.this;
		// imageLoader = new ImageLoader(context);
		imageDownloader = new ImageDownloader();
		imageDownloader.setMode(ImageDownloader.Mode.CORRECT);

		// selectedBtnColor = getResources().getColor(R.color.gray_light);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);
		btnToggleSearchPanel.setVisibility(View.GONE);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

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

		// circleItemViewList = new ArrayList<LinearLayout>();
		llCircleList = (LinearLayout) findViewById(R.id.llCircleList);

	}

	@Override
	public void onClick(View v) {

		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			isSearchEnabled = true;
			doSearch();
			// toggleSearchPanel();
		} else if (v == btnClearSearch) {
			isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();
		} else if (v == btnPeopleByDistance) {

			Intent circleIntent = new Intent(getApplicationContext(),
					PeopleListActivity.class);
			circleIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(circleIntent);
			finish();

		} else if (v == btnInvitePeople) {

			Intent inviteIntent = new Intent(getApplicationContext(),
					PeopleInvityActivity.class);

			inviteIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(inviteIntent);

			finish();

		} else if (v == btnCirclePeople) {

			// Intent circleIntent = new Intent(getApplicationContext(),
			// PeopleCircleActivity.class);
			// circleIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			// startActivity(circleIntent);
			// finish();

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
							context, circle, imageDownloader));
				}
			}
		}

	}

	/*
	 * Search portion
	 */
	private void doSearch() {

		// List<Object> list = (Utility.getSearchResult(listMasterContent,
		// etSearchField.getText().toString().trim()));
		//
		// listContent.clear();
		// listContent.addAll(list);
		//
		// updateDisplayList(listContent);
	}

	private void toggleSearchPanel() {
		if (!searchPanel.isShown())
			searchPanel.setVisibility(View.VISIBLE);
		else
			searchPanel.setVisibility(View.GONE);
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
