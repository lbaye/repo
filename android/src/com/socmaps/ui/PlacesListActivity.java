package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.apache.http.NameValuePair;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.ListItemClickListener;
import com.socmaps.listrow.ListItemClickListenerPlace;
import com.socmaps.listrow.PlaceRowFactoryForSavedPlace;
import com.socmaps.listrow.RowType;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PlacesListActivity extends Activity implements OnClickListener,
		ListItemClickListener {

	private Button btnBack, btnNearToMe;
	private ListView contentListView;
	private ImageView ivSeparator;

	private Context context;
	private ContentListAdapter contentAdapter;

	private List<Place> listMasterContent;
	private List<Place> listContent;
	private List<Place> listDisplayableContent;

	private boolean isSearchEnabled = false;
	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	private EditText etSearchField;
	private RelativeLayout searchPanel;
	private String personID = null;
	private LinearLayout buttonContainerTop;

	private String personName = "";
	private TextView titlePlaceEditSave;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.places_list_layout);

		personID = getIntent().getStringExtra("personID");
		if (personID != null)
			Log.d("Person ID", personID);

		personName = getIntent().getStringExtra("PERSON_NAME");

		initialize();

	}

	@Override
	protected void onResume() {

		super.onResume();
		callAPI();
		setListParameters();

		Log.w("PlacesListActivity ", "onResume()");

	}

	/*
	 * All initialize
	 */
	private void initialize() {

		context = PlacesListActivity.this;

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		contentListView = (ListView) findViewById(R.id.places_list);

		listMasterContent = new ArrayList<Place>();
		listContent = new ArrayList<Place>();
		listDisplayableContent = new ArrayList<Place>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);
		etSearchField = (EditText) findViewById(R.id.etSearchField);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		buttonContainerTop = (LinearLayout) findViewById(R.id.buttonContainerTop);
		btnNearToMe = (Button) findViewById(R.id.btnNearToMe);
		btnNearToMe.setOnClickListener(this);
		ivSeparator = (ImageView) findViewById(R.id.ivSeparator);

		if (personID != null) {
			btnNearToMe.setVisibility(View.INVISIBLE);
			ivSeparator.setVisibility(View.INVISIBLE);
			buttonContainerTop.setVisibility(View.GONE);
		}

		titlePlaceEditSave = (TextView) findViewById(R.id.titlePlaceEditSave);

		if (personName != null && !personName.equals("")) {
			titlePlaceEditSave.setText(personName + "'s" + " Places");
		}

	}

	@Override
	public void onClick(View v) {

		Utility.hideKeyboardContext(context);

		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			isSearchEnabled = true;
			doSearch();
		} else if (v == btnClearSearch) {
			isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();
		}

		else if (v == btnNearToMe) {
			Intent intentToGoPlace = new Intent(context, PlacesNearToMe.class);
			startActivity(intentToGoPlace);
		} else if (v == btnBack) {

			finish();
		}

	}

	private void setListParameters() {

		View footerView = new View(context);
		footerView.setBackgroundColor(Color.TRANSPARENT);
		footerView.setMinimumHeight(50);

		contentListView.addFooterView(footerView);

		contentListView.setAdapter(contentAdapter);

		int[] colors = { 0xFFFFFFFF, 0xFFFFFFFF };
		contentListView.setDivider(new GradientDrawable(Orientation.TOP_BOTTOM,
				colors));
		contentListView.setDividerHeight(2);

	}

	private void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Place> items;
		private ImageDownloader imageDownloader;

		public ContentListAdapter(Context context, List<Place> itemsList) {

			this.items = itemsList;
			imageDownloader = ImageDownloader.getInstance();
		}

		@Override
		public int getViewTypeCount() {
			return RowType.values().length;
		}

		@Override
		public int getItemViewType(int position) {

			return RowType.PLACE.ordinal();

		}

		@Override
		public int getCount() {
			return items.size();
		}

		@Override
		public Object getItem(int position) {
			return items.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {

			if (getItemViewType(position) == RowType.PLACE.ordinal()) {

				if (personID == null) {
					return PlaceRowFactoryForSavedPlace.getView(
							LayoutInflater.from(context), items.get(position),
							context, PlacesListActivity.this, convertView,
							imageDownloader, new PlaceItemListener(), 1);
				} else if (personID != null) {
					return PlaceRowFactoryForSavedPlace.getView(
							LayoutInflater.from(context), items.get(position),
							context, PlacesListActivity.this, convertView,
							imageDownloader, new PlaceItemListener(), 2);
				} else {
					return null;
				}
			} else {
				return null;
			}
		}

	}

	private void updateContentList(List<Place> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	private void updateDisplayList(List<Place> list) {

		int displayedItemCounter = 0;

		listDisplayableContent.clear();
		for (int i = 0; i < list.size(); i++) {

			listDisplayableContent.add(list.get(i));
			displayedItemCounter++;

		}

		// update the list view
		updateListView();

		if (isSearchEnabled && displayedItemCounter == 0) {
			Toast.makeText(context, "No search result found.",
					Toast.LENGTH_SHORT).show();
		}
	}

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, new ListComparator());
	}

	private class ListComparator implements Comparator<Place> {

		@Override
		public int compare(Place first, Place last) {
			double firstDistance = getDistance(first);
			double lastDistance = getDistance(last);

			if (firstDistance > lastDistance)
				return 1;
			else if (firstDistance == lastDistance)
				return 0;
			else
				return -1;
		}

		private double getDistance(Place object) {

			return object.getDistance();

		}

	}

	private class PlaceItemListener implements ListItemClickListenerPlace {

		@Override
		public void onItemClick(Place place) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onArrowButtonClick(Place place) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onReviewButtonClick(Place place) {
			// TODO Auto-generated method stub

			Intent peopleIntent = new Intent(context,
					PlaceEditSaveActivity.class);
			peopleIntent.putExtra("ISHOME", false);
			peopleIntent.putExtra("PLACE_OBJECT", place);

			startActivity(peopleIntent);

		}

		@Override
		public void onShowOnMapButtonClick(Place place) {
			// TODO Auto-generated method stub
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = place;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);

			// finish();
		}

	}

	@Override
	public void onMapButtonClick(int flag) {
		// TODO Auto-generated method stub
		Intent intent = new Intent(context, ShowItemOnMap.class);
		intent.putExtra("FLAG", flag);
		startActivity(intent);
	}

	private void callAPI() {

		String url;
		if (personID == null) {
			url = Constant.smPlaces;
		} else {
			url = Constant.smServerUrl + "/users" + "/" + personID + "/places";
			Log.i("PlaceList URL", Constant.smServerUrl + "/users" + "/"
					+ personID + "/places");
		}

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.GET_SERVER_DATA, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.GET);
	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String result, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :",
					status + ":" + result);
			switch (status) {
			case Constant.STATUS_SUCCESS:

				listMasterContent.clear();
				listMasterContent = ServerResponseParser
						.parseSavedPlaces(result);

				sortMasterListData();

				updateContentList(listMasterContent);
				updateDisplayList(listContent);

				break;
			case Constant.STATUS_SUCCESS_NODATA:
				Toast.makeText(getApplicationContext(), "No place found.",
						Toast.LENGTH_SHORT).show();
				break;
			default:
				Toast.makeText(getApplicationContext(),
						"An unknown error occured. Please try again!!",
						Toast.LENGTH_SHORT).show();
				break;

			}

		}

	}

	/*
	 * Search portion
	 */

	private void doSearch() {

		List<Object> dataList = new ArrayList<Object>();
		dataList.addAll(listMasterContent);

		List<Object> list = (Utility.getSearchResult(dataList, etSearchField
				.getText().toString().trim()));

		listContent.clear();

		for (Object obj : list) {
			listContent.add((Place) obj);
		}

		updateDisplayList(listContent);
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
