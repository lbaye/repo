package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.Bundle;
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
import com.socmaps.entity.SearchResult;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.ListItemClickListener;
import com.socmaps.listrow.ListItemClickListenerPlace;
import com.socmaps.listrow.PlaceRowFactory;
import com.socmaps.listrow.RowType;
import com.socmaps.util.Constant;
import com.socmaps.util.SharedPreferencesHelper;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PlacesNearToMe extends Activity implements OnClickListener,
		ListItemClickListener {

	Button btnNotification;
	Button topCloseButton, bottomCloseButton, btnMyPlaces, btnBack;

	private Context context;
	private ListView contentListView;
	private ContentListAdapter contentAdapter;
	private SearchResult peoplesAndPlacesEntity;
	private Button  btnToggleSearchPanel, btnDoSearch,
			btnClearSearch;

	private EditText etSearchField;
	private RelativeLayout searchPanel;

	private List<Object> listMasterContent;
	private List<Object> listContent;
	private List<Object> listDisplayableContent;

	boolean isSearchEnabled = false;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.places_near_tome_layout);

		initialize();
		getIntentData();
		setListParameters();

	}

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();

		Utility.updateNotificationBubbleCounter(btnNotification);
		populateMasterList();

		updateContentList(listMasterContent);
		updateDisplayList(listContent);

	}

	private void initialize() {

		context = PlacesNearToMe.this;

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnMyPlaces = (Button) findViewById(R.id.btnMyPlaces);
		btnMyPlaces.setOnClickListener(this);

		contentListView = (ListView) findViewById(R.id.places_list_neartoMe);
		listMasterContent = new ArrayList<Object>();
		listContent = new ArrayList<Object>();
		listDisplayableContent = new ArrayList<Object>();
		contentAdapter = new ContentListAdapter(context, listDisplayableContent);

		btnToggleSearchPanel = (Button) findViewById(R.id.btnSearch);
		btnToggleSearchPanel.setOnClickListener(this);

		searchPanel = (RelativeLayout) findViewById(R.id.searchPanel);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnDoSearch.setOnClickListener(this);
		btnClearSearch = (Button) findViewById(R.id.btnClearSearch);
		btnClearSearch.setOnClickListener(this);

		etSearchField = (EditText) findViewById(R.id.etSearchField);

	}

	@Override
	public void onClick(View v) {

		Utility.hideKeyboardContext(context);

		 if (v == btnNotification) {
			Intent i = new Intent(context, NotificationActivity.class);
			startActivity(i);
		} else if (v == btnToggleSearchPanel) {
			toggleSearchPanel();
		} else if (v == btnDoSearch) {
			isSearchEnabled = true;
			doSearch();
			// toggleSearchPanel();
		} else if (v == btnClearSearch) {
			isSearchEnabled = false;
			etSearchField.setText("");
			doSearch();
		} else if (v == btnMyPlaces) {

//			Intent intentToGoPlace = new Intent(context,
//					PlacesListActivity.class);
//			startActivity(intentToGoPlace);
			
			finish();

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

	private void getIntentData() {
		peoplesAndPlacesEntity = StaticValues.searchResult;
	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();
	}

	private void updateContentList(List<Object> list) {
		listContent.clear();
		listContent.addAll(list);

	}

	private void updateDisplayList(List<Object> list) {

		int displayedItemCounter = 0;

		listDisplayableContent.clear();
		for (int i = 0; i < list.size(); i++) {

			Object item = list.get(i);
			if (item instanceof Place
					&& SharedPreferencesHelper.getInstance(context).getBoolean(
							Constant.PLACE, false)) {
				listDisplayableContent.add(item);
				displayedItemCounter++;
			}

		}

		// update the list view
		updateListView();

		if (isSearchEnabled && displayedItemCounter == 0) {
			Toast.makeText(context, "No search result found.",
					Toast.LENGTH_SHORT).show();
		}
	}

	private void updateListView() {
		contentAdapter.notifyDataSetChanged();
	}

	private void populateMasterList() {
		listMasterContent.clear();

		if (peoplesAndPlacesEntity != null) {
			addPlacesToMasterList();
			sortMasterListData();
		}
	}

	private void sortMasterListData() {
		Collections.sort(this.listMasterContent, new ListComparator());
	}

	class ListComparator implements Comparator<Object> {

		@Override
		public int compare(Object first, Object last) {
			double firstDistance = getDistance(first);
			double lastDistance = getDistance(last);

			if (firstDistance > lastDistance)
				return 1;
			else if (firstDistance == lastDistance)
				return 0;
			else
				return -1;
		}

		private double getDistance(Object object) {
			if (object instanceof Place)
				return ((Place) object).getDistance();

			else
				return 0;
		}

	}

	private void addPlacesToMasterList() {

		if (peoplesAndPlacesEntity.getPlaces() != null) {
			for (int i = 0; i < peoplesAndPlacesEntity.getPlaces().size(); i++) {
				listMasterContent
						.add(peoplesAndPlacesEntity.getPlaces().get(i));
			}
		}
	}

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();

	}

	private class ContentListAdapter extends BaseAdapter {

		private List<Object> items;
		private ImageDownloader imageDownloader;
		public ContentListAdapter(Context context, List<Object> itemsList) {

			this.items = itemsList;		
			imageDownloader = ImageDownloader.getInstance();

		}

		@Override
		public int getViewTypeCount() {
			return RowType.values().length;
		}

		@Override
		public int getItemViewType(int position) {
			if (items.get(position) instanceof Place) {

				return RowType.PLACE.ordinal();
			} else {
				return -1;
			}
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
				return PlaceRowFactory.getView(LayoutInflater.from(context),
						items.get(position), context, PlacesNearToMe.this,
						convertView, imageDownloader, new PlaceItemListener());
			} else {
				return null;
			}
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

		}

		@Override
		public void onShowOnMapButtonClick(Place place) {
			// TODO Auto-generated method stub
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = place;
			finish();
		}

	}



	@Override
	public void onMapButtonClick(int flag) {
		Intent intent = new Intent(context, ShowItemOnMap.class);
		intent.putExtra("FLAG", flag);
		startActivity(intent);
	}

	private void doSearch() {
		//
		List<Object> list = (Utility.getSearchResult(listMasterContent,
				etSearchField.getText().toString().trim()));

		listContent.clear();
		listContent.addAll(list);

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
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}


}
