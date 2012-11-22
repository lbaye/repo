package com.socmaps.ui;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ListView;
import android.widget.Toast;

import com.socmaps.entity.Event;
import com.socmaps.images.ImageDownloader;
import com.socmaps.images.ImageLoader;
import com.socmaps.listrow.EventRowFactory;
import com.socmaps.listrow.ListItemClickListenerEvent;
import com.socmaps.notificationBroadcast.BroadcastListener;
import com.socmaps.notificationBroadcast.BroadcastService;
import com.socmaps.notificationBroadcast.NotificationCountBroadcastReciever;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class EventListActivity extends Activity implements OnClickListener,
		BroadcastListener {
	private Context context;
	private EditText searchEditText;
	private Button btnBack, btnSearch, btnNotification;

	private Button btnDoSearch, btnNewEvent, btnFilterByDate,
			btnFilterByDistance, btnFilterByFriendsEvent, btnFilterByMyEvent,
			btnFilterByPublicEvent;
	private ListView eventList;
	// private ContentListAdapter contentAdapter;
	private ListArrayAdapter contentAdapter;
	private List<Event> events;
	private List<Event> dateWiseSortedEvents;
	private ProgressDialog mProgressDialog;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	Event selctedEventForRSVP;
	String rsvpValue;
	// public static boolean isUpdateList = false;
	private NotificationCountBroadcastReciever broadcastReceiver;

	int colorButtonNormal, colorButtonSelected;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.event_list_layout);

		init();
		
		
		
		setListParameters();
		setViewOnClickListener();

		fetchDataForList();

	}
	


	private void setViewOnClickListener() {

		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		btnSearch.setOnClickListener(this);

		btnNewEvent.setOnClickListener(this);
		btnDoSearch.setOnClickListener(this);

		btnFilterByDate.setOnClickListener(this);
		btnFilterByDistance.setOnClickListener(this);
		btnFilterByFriendsEvent.setOnClickListener(this);
		btnFilterByMyEvent.setOnClickListener(this);
		btnFilterByPublicEvent.setOnClickListener(this);
	}

	private void init() {
		// TODO Auto-generated method stub
		context = EventListActivity.this;

		colorButtonNormal = getResources().getColor(R.color.transparent);
		colorButtonSelected = getResources().getColor(R.color.gray_light);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnSearch = (Button) findViewById(R.id.btnSearch);

		searchEditText = (EditText) findViewById(R.id.etFriendSearch);
		searchEditText.addTextChangedListener(filterTextWatcher);

		btnDoSearch = (Button) findViewById(R.id.btnDoSearch);
		btnNewEvent = (Button) findViewById(R.id.btnNewEvent);
		btnFilterByDate = (Button) findViewById(R.id.btnFilterByDate);
		btnFilterByDistance = (Button) findViewById(R.id.btnFilterByDistance);
		btnFilterByFriendsEvent = (Button) findViewById(R.id.btnFilterByFriendsEvent);
		btnFilterByMyEvent = (Button) findViewById(R.id.btnFilterByMyEvent);
		btnFilterByPublicEvent = (Button) findViewById(R.id.btnFilterByPublicEvent);

		eventList = (ListView) findViewById(R.id.event_list);
		events = new ArrayList<Event>();
		dateWiseSortedEvents = new ArrayList<Event>();
		// contentAdapter=new ContentListAdapter(context,events);
		contentAdapter = new ListArrayAdapter(context, R.layout.row_list_event,
				events);
		eventList.setTextFilterEnabled(true);
	}

	private void initializeNotificationCountBroadcast() {

		broadcastReceiver = NotificationCountBroadcastReciever.getInstance();
		broadcastReceiver.setCallback(this);
		registerReceiver(broadcastReceiver, new IntentFilter(
				BroadcastService.BROADCAST_ACTION));
	}

	private void setListParameters() {
		// TODO Auto-generated method stub

		eventList.setAdapter(contentAdapter);
		int[] colors = { 0xFFFFFFFF, 0xFFFFFFFF };
		eventList.setDivider(new GradientDrawable(Orientation.TOP_BOTTOM,
				colors));
		eventList.setDividerHeight(2);
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		unregisterReceiver(broadcastReceiver);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		initializeNotificationCountBroadcast();
		findViewById(R.id.mainLayout).requestFocus();
		
		Utility.updateNotificationBubbleCounter(btnNotification);
		
		/*
		 * if (isUpdateList) { isUpdateList = !isUpdateList; fetchDataForList();
		 * // resetFilterEditText();
		 * 
		 * }
		 */

		/*
		 * for(int i=0;i<10;i++) { EventEntity eventEntity=new EventEntity();
		 * events.add(eventEntity); } contentAdapter.notifyDataSetChanged();
		 */
	}

	private void resetFilterEditText() {
		// searchEditText.clearFocus();
		searchEditText.setText("");
		// searchEditText.setHint("Your search");
	}

	public void fetchDataForList() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, viewList, "MagentoBackground");
			thread.start();
			mProgressDialog = ProgressDialog
					.show(this,
							getResources().getString(R.string.eventsLabel),
							getResources().getString(
									R.string.fetching_data_text), true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private void filterEvents(String key) {

		if (key.equalsIgnoreCase("public_event")) {
			filterPublicEvents();
		} else {
			events.clear();
			for (int i = 0; i < dateWiseSortedEvents.size(); i++) {
				Event tempEvent = dateWiseSortedEvents.get(i);
				if (key.equalsIgnoreCase(tempEvent.getEvent_type()))
					events.add(tempEvent);
			}
		}

	}

	private void filterPublicEvents() {
		events.clear();
		String permission;
		for (int i = 0; i < dateWiseSortedEvents.size(); i++) {
			Event tempEvent = dateWiseSortedEvents.get(i);

			permission = tempEvent.getPermission();
			if (permission != null) {
				if (permission.equalsIgnoreCase("public")) {
					events.add(tempEvent);
				}

			}

		}
	}

	private void sortDataByDistance() {
		Collections.sort(this.events, new ListComparator());
	}

	class ListComparator implements Comparator<Event> {

		@Override
		public int compare(Event first, Event last) {
			double firstDistance = first.getDistance();
			double lastDistance = last.getDistance();

			if (firstDistance > lastDistance)
				return 1;
			else if (firstDistance == lastDistance)
				return 0;
			else
				return -1;
		}

		/*
		 * private double getDistance(EventEntity object) { if (object
		 * instanceof OtherUserEntity) return ((OtherUserEntity)
		 * object).getDistance(); else if (object instanceof PlaceEntity) return
		 * ((PlaceEntity) object).getDistance(); else return 0; }
		 */

	}

	private Runnable viewList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient getAccountSettingsClient = new RestClient(
					Constant.smGetEventUrl);
			getAccountSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();

			responseStatus = getAccountSettingsClient.getResponseCode();

			runOnUiThread(returnResGetEvents);
		}
	};

	private Runnable returnResGetEvents = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			mProgressDialog.dismiss();
			handleGetEventsResponse(responseStatus, responseString);

		}

	};

	public void handleGetEventsResponse(int status, String response) {
		Log.d("Events", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			dateWiseSortedEvents = ServerResponseParser
					.parseGetEventListResult(response);
			/*
			 * Log.e("Events size", dateWiseSortedEvents.size()+"");
			 * events.clear(); events.addAll(dateWiseSortedEvents);
			 */
			resetFilterEditText();
			this.resetAdapterItems();

			btnFilterByDate.setBackgroundColor(colorButtonSelected);
			contentAdapter.notifyDataSetChanged();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private TextWatcher filterTextWatcher = new TextWatcher() {

		@Override
		public void afterTextChanged(Editable s) {
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
		}

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
			contentAdapter.getFilter().filter(s);
		}

	};

	/*
	 * @Override public void onArrowButtonClick() { // TODO Auto-generated
	 * method stub
	 * 
	 * finish();
	 * 
	 * Intent eventDetailsIntent = new Intent(context,
	 * EventDetailsActivity.class); startActivity(eventDetailsIntent); }
	 */

	public void clearFilterButtonSelection() {
		btnFilterByDate.setBackgroundColor(colorButtonNormal);
		btnFilterByDistance.setBackgroundColor(colorButtonNormal);
		btnFilterByFriendsEvent.setBackgroundColor(colorButtonNormal);
		btnFilterByMyEvent.setBackgroundColor(colorButtonNormal);
		btnFilterByPublicEvent.setBackgroundColor(colorButtonNormal);
	}

	@Override
	public void onClick(View v) {
		if (v == btnFilterByDistance) {
			this.resetAdapterItems();
			sortDataByDistance();
			btnFilterByDistance.setBackgroundColor(colorButtonSelected);
			contentAdapter.notifyDataSetChanged();
		}
		if (v == btnFilterByDate) {
			this.resetAdapterItems();
			btnFilterByDate.setBackgroundColor(colorButtonSelected);
			contentAdapter.notifyDataSetChanged();
		}
		if (v == btnFilterByFriendsEvent) {
			this.resetAdapterItems();
			filterEvents("friends_event");
			btnFilterByFriendsEvent.setBackgroundColor(colorButtonSelected);
			contentAdapter.notifyDataSetChanged();
		}
		if (v == btnFilterByMyEvent) {
			this.resetAdapterItems();
			filterEvents("my_event");
			btnFilterByMyEvent.setBackgroundColor(colorButtonSelected);
			contentAdapter.notifyDataSetChanged();

		}
		if (v == btnFilterByPublicEvent) {
			this.resetAdapterItems();
			filterEvents("public_event");
			btnFilterByPublicEvent.setBackgroundColor(colorButtonSelected);
			contentAdapter.notifyDataSetChanged();

		}

		if (v == btnNewEvent) {
			Intent eventIntent = new Intent(getApplicationContext(),
					EventNewActivity.class);
			finish();
			startActivity(eventIntent);
		}
		if (v == btnBack) {
			finish();
		}
		if (v == btnDoSearch) {
			Log.e("Search button click", "Search button click");
			Utility.hideKeyboardContext(context);
		}
	}

	private void resetAdapterItems() {
		this.events.clear();
		clearFilterButtonSelection();
		this.events.addAll(this.dateWiseSortedEvents);
		contentAdapter.setObjects(this.events);
	}

	public class ListArrayAdapter extends BaseAdapter implements Filterable {

		private List<Event> mObjects;

		private final Object mLock = new Object();

		private int mResource;

		private int mDropDownResource;

		private int mFieldId = 0;

		private boolean mNotifyOnChange = true;

		private Context mContext;

		private List<Event> mOriginalValues;
		private ArrayFilter mFilter;

		private LayoutInflater mInflater;

		private ImageDownloader imageDownloader;

		public ListArrayAdapter(Context context, int textViewResourceId,
				List<Event> objects) {

			imageDownloader = new ImageDownloader();
			imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
			
			init(context, textViewResourceId, 0, objects);
			// BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource(context.getResources(),
			// R.drawable.event_item_bg));
		}

		@Override
		public void notifyDataSetChanged() {
			super.notifyDataSetChanged();
			mNotifyOnChange = true;
		}

		public void setNotifyOnChange(boolean notifyOnChange) {
			mNotifyOnChange = notifyOnChange;
		}

		private void init(Context context, int resource,
				int textViewResourceId, List<Event> objects) {
			mContext = context;
			mInflater = (LayoutInflater) context
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			mResource = mDropDownResource = resource;
			mObjects = objects;

			mFieldId = textViewResourceId;
		}

		public Context getContext() {
			return mContext;
		}

		@Override
		public int getCount() {
			return mObjects.size();
		}

		@Override
		public Event getItem(int position) {
			return mObjects.get(position);
		}

		public int getPosition(Event item) {
			return mObjects.indexOf(item);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		public void setObjects(List<Event> items) {
			this.mObjects = items;
			this.mOriginalValues = null;
		}

		public List<Event> getObjects() {
			return this.mObjects;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {

			return EventRowFactory.getView(LayoutInflater.from(context),
					mObjects.get(position), context, new ItemListener(),
					position, convertView, imageDownloader);
		}

		public void setDropDownViewResource(int resource) {
			this.mDropDownResource = resource;
		}

		@Override
		public Filter getFilter() {
			if (mFilter == null) {
				mFilter = new ArrayFilter();
			}
			return mFilter;
		}

		private class ArrayFilter extends Filter {
			@Override
			protected FilterResults performFiltering(CharSequence prefix) {
				FilterResults results = new FilterResults();

				if (mOriginalValues == null) {
					synchronized (mLock) {
						mOriginalValues = new ArrayList<Event>(mObjects);
					}
				}

				if (prefix == null || prefix.length() == 0) {
					ArrayList<Event> list;
					synchronized (mLock) {
						list = new ArrayList<Event>(mOriginalValues);
					}
					results.values = list;
					results.count = list.size();
				} else {
					String prefixString = prefix.toString().toLowerCase();

					ArrayList<Event> values;
					synchronized (mLock) {
						values = new ArrayList<Event>(mOriginalValues);
					}

					final int count = values.size();
					final ArrayList<Event> newValues = new ArrayList<Event>();

					for (int i = 0; i < count; i++) {
						final Event value = values.get(i);
						final String valueText = value.getEventTitle()
								.toString().toLowerCase();

						// First match against the whole, non-splitted value
						if (valueText.startsWith(prefixString)) {
							newValues.add(value);
						} else {
							final String[] words = valueText.split(" ");
							final int wordCount = words.length;

							// Start at index 0, in case valueText starts with
							// space(s)
							for (int k = 0; k < wordCount; k++) {
								if (words[k].startsWith(prefixString)) {
									newValues.add(value);
									break;
								}
							}
						}
					}

					results.values = newValues;
					results.count = newValues.size();
				}

				return results;
			}

			@Override
			protected void publishResults(CharSequence constraint,
					FilterResults results) {
				// noinspection unchecked
				mObjects = (ArrayList<Event>) results.values;
				if (results.count > 0) {
					notifyDataSetChanged();
				} else {
					notifyDataSetInvalidated();
				}
			}
		}
	}

	/*
	 * @Override public void onMapButtonClicked(Event event) { // TODO
	 * Auto-generated method stub // new MapViewDialog(ListOfEvents.this, //
	 * event.getEventLocation()).show(); StaticValues.selectedEvent = event;
	 * Intent intent = new Intent(context, ShowItemOnMap.class);
	 * intent.putExtra("FLAG", Constant.FLAG_EVENT); startActivity(intent); }
	 */

	/*
	 * @Override public void onRadioButtonChecked(String s, Event event) { if
	 * (!s.equalsIgnoreCase(event.getMyResponse())) { selctedEventForRSVP =
	 * event; rsvpValue = s; // Toast.makeText(context, s,
	 * Toast.LENGTH_SHORT).show();
	 * 
	 * String[] params = new String[2]; params[0] = s; params[1] =
	 * event.getEventId(); if (Utility.isConnectionAvailble(context)) new
	 * UpdateRSVPTask().execute(params); else
	 * DialogsAndToasts.showNoInternetConnectionDialog(context); } }
	 */

	private class UpdateRSVPTask extends AsyncTask<String, String, Long> {
		private ProgressDialog updateDialog;

		@Override
		protected void onPostExecute(Long result) {
			super.onPostExecute(result);
			updateDialog.dismiss();
			if (result == Constant.STATUS_SUCCESS) {
				// event.setMyResponse(s);
				selctedEventForRSVP.setMyResponse(rsvpValue);
			} else {
				Toast.makeText(context, "Error", Toast.LENGTH_SHORT).show();
			}
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			updateDialog = new ProgressDialog(context);
			updateDialog.setMessage("Loading...");
			updateDialog.show();

		}

		@Override
		protected Long doInBackground(String... params) {
			// TODO Auto-generated method stub
			RestClient updateRSVPClient = new RestClient(Constant.smEventUrl
					+ "/" + params[1] + "/rsvp");
			updateRSVPClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			updateRSVPClient.AddParam("response", params[0]);
			try {
				updateRSVPClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			// String response = updateRSVPClient.getResponse();

			int status = updateRSVPClient.getResponseCode();
			return (long) status;
		}

	}

	@Override
	public void updateNotificationCountBuble(Intent intent) {
		String counter = intent.getStringExtra("counter");
		// btnNotification.setText(counter);

	}

	private class ItemListener implements ListItemClickListenerEvent {

		@Override
		public void onItemClick(Event event) {
			// TODO Auto-generated method stub
			//finish();

			Intent eventDetailsIntent = new Intent(context,
					EventDetailsActivity.class);
			eventDetailsIntent.putExtra("selectedEvent", event);
			startActivity(eventDetailsIntent);
		}

		@Override
		public void onArrowButtonClick(Event event) {
			// TODO Auto-generated method stub
			//finish();

			Intent eventDetailsIntent = new Intent(context,
					EventDetailsActivity.class);
			eventDetailsIntent.putExtra("selectedEvent", event);
			startActivity(eventDetailsIntent);

		}

		@Override
		public void onRSVPSelection(Event event, String response) {
			// TODO Auto-generated method stub

			if (!response.equalsIgnoreCase(event.getMyResponse())) {
				selctedEventForRSVP = event;
				rsvpValue = response;
				// Toast.makeText(context, s, Toast.LENGTH_SHORT).show();

				String[] params = new String[2];
				params[0] = response;
				params[1] = event.getEventId();
				if (Utility.isConnectionAvailble(context))
					new UpdateRSVPTask().execute(params);
				else
					DialogsAndToasts.showNoInternetConnectionDialog(context);
			}

		}

		@Override
		public void onShowOnMapButtonClick(Event event) {
			// TODO Auto-generated method stub
			/*
			 * Intent intent = new Intent(context, ShowItemOnMap.class);
			 * intent.putExtra("FLAG", Constant.FLAG_EVENT);
			 * startActivity(intent);
			 */
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = event;
			finish();
		}

	}

}
