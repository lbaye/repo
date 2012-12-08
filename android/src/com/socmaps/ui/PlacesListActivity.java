package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
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
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.ListItemClickListener;
import com.socmaps.listrow.ListItemClickListenerPlace;
import com.socmaps.listrow.PlaceRowFactoryForSavedPlace;
import com.socmaps.listrow.RowType;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PlacesListActivity extends Activity implements OnClickListener,
		ListItemClickListener {

	private Button btnBack;
	private ListView contentListView;

	public Context context;
	private ContentListAdapter contentAdapter;

	private List<Place> listMasterContent;
	private List<Place> listContent;
	private List<Place> listDisplayableContent;

	boolean isSearchEnabled = false;

	public Dialog msgDialog;

	private ProgressDialog m_ProgressDialog;

	private Button btnToggleSearchPanel, btnDoSearch, btnClearSearch;
	private EditText etSearchField;
	private RelativeLayout searchPanel;

	private String placesResponse;
	private int placesStatus;

	String personID = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.places_list_layout);

		personID = getIntent().getStringExtra("personID");
		if (personID != null)
			Log.d("Person ID", personID);

		initialize();

	}

	@Override
	protected void onResume() {

		super.onResume();

		getPlacesFromServer();
		setListParameters();

		Log.w("PlacesListActivity ", "onResume()");

	}

	/*
	 * All initialize
	 */
	public void initialize() {

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

	}

	@Override
	public void onClick(View v) {

		Utility.hideKeyboardContext(context);

		if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			isSearchEnabled = true;
			doSearch();
			// hideKeybord();
			// toggleSearchPanel();
		} else if (v == btnClearSearch) {
			isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();
			// hideKeybord();
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

	public void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Place> items;
		private ImageDownloader imageDownloader;

		public ContentListAdapter(Context context, List<Place> itemsList) {

			this.items = itemsList;
			//imageDownloader = new ImageDownloader();
			//imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
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

	public void updateContentList(List<Place> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	public void updateDisplayList(List<Place> list) {

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

	class ListComparator implements Comparator<Place> {

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

	/*
	 * Places places from server
	 */
	private void getPlacesFromServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, placesThread,
					"Start get places from server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true,true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable placesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient;
			if (personID == null) {
				restClient = new RestClient(Constant.smPlaces);
			} 
			else 
			{
				restClient = new RestClient(Constant.smServerUrl+"/users"+"/"+personID+"/places");
				Log.i("PlaceList URL", Constant.smServerUrl+"/users"+"/"+personID+"/places");
			}
				

			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			placesResponse = restClient.getResponse();
			placesStatus = restClient.getResponseCode();

			runOnUiThread(placesResponseFromServer);
		}
	};

	private Runnable placesResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponsePlaces(placesStatus, placesResponse);

			// dismiss progress dialog if needed

			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}
		}
	};

	public void handleResponsePlaces(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("Got places response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			// Toast.makeText(context, "Places response successful.",
			// Toast.LENGTH_SHORT).show();

			listMasterContent.clear();
			listMasterContent = ServerResponseParser.parseSavedPlaces(response);

			sortMasterListData();

			updateContentList(listMasterContent);
			updateDisplayList(listContent);

			break;
		case Constant.STATUS_SUCCESS_NODATA:
			Toast.makeText(getApplicationContext(),
					"No place found.",
					Toast.LENGTH_SHORT).show();
			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	/*
	 * Hide Keybord
	 */

	// public void hideKeybord() {
	//
	// // etSearchField
	// // .setOnFocusChangeListener(new View.OnFocusChangeListener() {
	// //
	// // public void onFocusChange(View v, boolean flag) {
	// // if (flag == false) {
	// // InputMethodManager inputMethodManager = (InputMethodManager)
	// // getSystemService(Context.INPUT_METHOD_SERVICE);
	// // inputMethodManager.hideSoftInputFromWindow(
	// // v.getWindowToken(), 0);
	// // }
	// // }
	// // });
	//
	// InputMethodManager mgr = (InputMethodManager)
	// getSystemService(Context.INPUT_METHOD_SERVICE);
	// mgr.hideSoftInputFromWindow(etSearchField.getWindowToken(), 0);
	// }

	// protected void hideMessageDialogKeybord(EditText msgEditText) {
	// // TODO Auto-generated method stub
	//
	// InputMethodManager mgr = (InputMethodManager)
	// getSystemService(Context.INPUT_METHOD_SERVICE);
	// mgr.hideSoftInputFromWindow(msgEditText.getWindowToken(), 0);
	//
	// }

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

	public void showSearchPanel(boolean display) {
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
