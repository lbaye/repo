package com.socmaps.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Plan;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.ListItemClickListenerPlan;
import com.socmaps.listrow.PlanRowFactory;
import com.socmaps.notificationBroadcast.BroadcastListener;
import com.socmaps.notificationBroadcast.BroadcastService;
import com.socmaps.notificationBroadcast.NotificationCountBroadcastReciever;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * PlanListActivity class is used to depict the list of plans of user's & others users. 
 * There is options of Edit & Delete if that is user's own Plan List. 
 * No chance for Edit or Delete is it shows other particular user's Plan List. 
 */

public class PlanListActivity extends Activity implements OnClickListener,
		BroadcastListener {

	private Context context;
	private Button btnBack, btnNotification;
	TextView tvtitle;
	LinearLayout separator;

	private ListView planList;
	private ListArrayAdapter contentAdapter;
	private List<Plan> plans;
	private List<Plan> dateWiseSortedPlans;
	private ProgressDialog mProgressDialog;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	private NotificationCountBroadcastReciever broadcastReceiver;

	int colorButtonNormal, colorButtonSelected;

	Plan seletedPlan;

	String personID = null;
	String personFirstName = "", personLastName = "";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.plan_list_layout);

		personID = getIntent().getStringExtra("personID");
		personFirstName = getIntent().getStringExtra("firstName");
		personLastName = getIntent().getStringExtra("lastName");
		if (personID != null)
			Log.d("Person ID", personID);

		init();
		setListParameters();
		setViewOnClickListener();
		fetchDataForList();
	}

	private void init() {
		// TODO Auto-generated method stub
		context = PlanListActivity.this;

		colorButtonNormal = getResources().getColor(R.color.transparent);
		colorButtonSelected = getResources().getColor(R.color.gray_light);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);

		tvtitle = (TextView) findViewById(R.id.tvtitle);

		separator = (LinearLayout) findViewById(R.id.separator);

		planList = (ListView) findViewById(R.id.event_list);
		plans = new ArrayList<Plan>();
		dateWiseSortedPlans = new ArrayList<Plan>();
		contentAdapter = new ListArrayAdapter(context, R.layout.row_list_plan,
				plans);
		planList.setTextFilterEnabled(true);

		if (personID == null) {
			tvtitle.setText("Plans");
		} else if (personID != null) {
			tvtitle.setText(personFirstName + " " + personLastName + "'s" + " "
					+ "Plans");
		}
	}

	private void initializeNotificationCountBroadcast() {

		broadcastReceiver = NotificationCountBroadcastReciever.getInstance();
		broadcastReceiver.setCallback(this);
		registerReceiver(broadcastReceiver, new IntentFilter(
				BroadcastService.BROADCAST_ACTION));
	}

	private void setListParameters() {
		// TODO Auto-generated method stub

		planList.setAdapter(contentAdapter);
		int[] colors = { 0xFFFFFFFF, 0xFFFFFFFF };
		planList.setDivider(new GradientDrawable(Orientation.TOP_BOTTOM, colors));
		planList.setDividerHeight(2);
	}

	private void setViewOnClickListener() {

		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
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
	}

	@Override
	public void updateNotificationCountBuble(Intent intent) {
		// TODO Auto-generated method stub
		String counter = intent.getStringExtra("counter");
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnBack)
			finish();
		else if (v == btnNotification) {
			Intent intent = new Intent(context, NotificationActivity.class);
			startActivity(intent);
		}
	}

	private void fetchDataForList() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, viewList, "MagentoBackground");
			thread.start();
			mProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.plan_label),
					getResources().getString(R.string.fetching_data_text),
					true, true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable viewList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			RestClient getAccountSettingsClient;
			if (personID == null) {
				getAccountSettingsClient = new RestClient(Constant.smServerUrl
						+ "/me/plans");
			} else {
				getAccountSettingsClient = new RestClient(Constant.smServerUrl
						+ "/users" + "/" + personID + "/plans");
			}

			getAccountSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();

			responseStatus = getAccountSettingsClient.getResponseCode();

			runOnUiThread(returnResGetplans);
		}
	};

	private Runnable returnResGetplans = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			if (mProgressDialog != null) {
				mProgressDialog.dismiss();
			}
			handleGetplansResponse(responseStatus, responseString);

		}

	};

	private void handleGetplansResponse(int status, String response) {
		Log.d("plans", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			dateWiseSortedPlans = ServerResponseParser
					.parseGetPlanListResult(response);

			this.resetAdapterItems();
			contentAdapter.notifyDataSetChanged();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response),
					Toast.LENGTH_LONG).show();

			break;

		case Constant.STATUS_SUCCESS_NODATA:
			Toast.makeText(getApplicationContext(), "No plan found.",
					Toast.LENGTH_SHORT).show();
			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response),
					Toast.LENGTH_LONG).show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void resetAdapterItems() {
		this.plans.clear();
		this.plans.addAll(this.dateWiseSortedPlans);
		contentAdapter.setObjects(this.plans);
	}

	private class ListArrayAdapter extends BaseAdapter implements Filterable {

		private List<Plan> mObjects;

		private final Object mLock = new Object();

		private int mResource;

		private int mDropDownResource;

		private int mFieldId = 0;

		private boolean mNotifyOnChange = true;

		private Context mContext;

		private List<Plan> mOriginalValues;
		private ArrayFilter mFilter;

		private LayoutInflater mInflater;

		private ImageDownloader imageDownloader;

		public ListArrayAdapter(Context context, int textViewResourceId,
				List<Plan> objects) {

			imageDownloader = ImageDownloader.getInstance();

			init(context, textViewResourceId, 0, objects);
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
				int textViewResourceId, List<Plan> objects) {
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

		public int getCount() {
			return mObjects.size();
		}

		public Plan getItem(int position) {
			return mObjects.get(position);
		}

		public int getPosition(Plan item) {
			return mObjects.indexOf(item);
		}

		public long getItemId(int position) {
			return position;
		}

		public void setObjects(List<Plan> items) {
			this.mObjects = items;
			this.mOriginalValues = null;
		}

		public List<Plan> getObjects() {
			return this.mObjects;
		}

		public View getView(int position, View convertView, ViewGroup parent) {

			if (personID == null) {
				return PlanRowFactory.getView(LayoutInflater.from(context),
						mObjects.get(position), context, new ItemListener(),
						position, convertView, imageDownloader, 1);
			} else if (personID != null) {
				return PlanRowFactory.getView(LayoutInflater.from(context),
						mObjects.get(position), context, new ItemListener(),
						position, convertView, imageDownloader, 2);
			} else
				return null;

		}

		private void setDropDownViewResource(int resource) {
			this.mDropDownResource = resource;
		}

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
						mOriginalValues = new ArrayList<Plan>(mObjects);
					}
				}

				if (prefix == null || prefix.length() == 0) {
					ArrayList<Plan> list;
					synchronized (mLock) {
						list = new ArrayList<Plan>(mOriginalValues);
					}
					results.values = list;
					results.count = list.size();
				} else {
					String prefixString = prefix.toString().toLowerCase();

					ArrayList<Plan> values;
					synchronized (mLock) {
						values = new ArrayList<Plan>(mOriginalValues);
					}

					final int count = values.size();
					final ArrayList<Plan> newValues = new ArrayList<Plan>();

					for (int i = 0; i < count; i++) {
						final Plan value = values.get(i);
						final String valueText = value.getPlanTitle()
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
				mObjects = (ArrayList<Plan>) results.values;
				if (results.count > 0) {
					notifyDataSetChanged();
				} else {
					notifyDataSetInvalidated();
				}
			}
		}
	}

	private class ItemListener implements ListItemClickListenerPlan {

		@Override
		public void onItemClick(Plan plan) {
			// TODO Auto-generated method stub
		}

		@Override
		public void onArrowButtonClick(Plan plan) {
			// TODO Auto-generated method stub
		}

		@Override
		public void onShowOnMapButtonClick(Plan plan) {
			// TODO Auto-generated method stub

			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = plan;

			Intent intent = new Intent(context, HomeActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);
		}

		@Override
		public void onShowEditButtonClick(Plan plan) {
			// TODO Auto-generated method stub

			if (plan != null) {
				seletedPlan = plan;
				Log.d("Check Plan", seletedPlan.getPlanId());

				Intent intent = new Intent(context, PlanEditActivity.class);
				intent.putExtra("selectedPlan", seletedPlan);
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
				startActivity(intent);
			}
		}

		@Override
		public void onShowDeleteButtonClick(Plan plan) {
			// TODO Auto-generated method stub

			if (plan != null) {
				seletedPlan = plan;
				Log.d("Check Plan", seletedPlan.getPlanId());
				initiateDeletePlan();
			}
		}

	}

	private void initiateDeletePlan() {
		AlertDialog.Builder adb = new AlertDialog.Builder(this);
		adb.setTitle("Delete plan");
		adb.setMessage("Are you sure you want to delete this plan?");
		adb.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int id) {
				deletePlan();
				dialog.cancel();
			}
		});
		adb.setNegativeButton("No", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int id) {
				dialog.cancel();
			}
		});
		adb.show();
	}

	private void deletePlan() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, deletePlanThread,
					"Start delete plan");
			thread.start();

			// show progress dialog if needed
			mProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable deletePlanThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smPlanUrl + "/"
					+ seletedPlan.getPlanId());
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.DELETE);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(deletePlanResponseThread);
		}
	};

	private Runnable deletePlanResponseThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (mProgressDialog != null) {

				mProgressDialog.dismiss();
			}

			handleResponseDeletePlan(responseStatus, responseString);

		}
	};

	private void handleResponseDeletePlan(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("DELETE Plan RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {

			Toast.makeText(context, "Plan deleted successfully.",
					Toast.LENGTH_SHORT).show();

			for (int i = 0; i < plans.size(); i++) {
				if (plans.get(i).getPlanId()
						.equalsIgnoreCase(seletedPlan.getPlanId())) {
					plans.remove(i);
				}
			}

			contentAdapter.notifyDataSetChanged();

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

}
