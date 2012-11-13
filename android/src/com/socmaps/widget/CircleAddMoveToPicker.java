/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;
import android.util.SparseBooleanArray;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.ui.PeopleCircleActivity;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class CircleAddMoveToPicker extends Dialog implements
		OnItemClickListener, View.OnClickListener {

	CircleAddMoveToPickerListener circleAddMoveToPickerListener;
	Context context;
	private String pickerName;
	private Button btnCancel, btnOk, btnAddCircle;
	private List<Circle> circleList;
	private List<String> selectedCircleList;
	private Circle selectedCircle;
	private ListView listView;

	private EditText editTextCircleName;
	private ProgressDialog m_ProgressDialog;

	private String createCircleResponse = "";
	private int createCircleStatus = 0;

	private String moveToSelectedCirclesResponse = "";
	private int moveToSelectedCirclesStatus = 0;

	String circleName;
	CircleAddMoveToAdapter nearByPlacesAdapter;
	private String id;
	private ArrayList<String> selectedArrayList = new ArrayList<String>();

	private People people;
	private RelativeLayout mainLayout;

	public CircleAddMoveToPicker(Context context,
			CircleAddMoveToPickerListener circleAddMoveToPickerListener,
			String pickerName, List<Circle> circleList,
			List<String> selectedCircleList, People people) {
		super(context);
		this.circleAddMoveToPickerListener = circleAddMoveToPickerListener;
		this.context = context;
		this.pickerName = pickerName;
		this.circleList = circleList;
		// this.selectedPlace = selectedPlace;
		this.selectedCircleList = selectedCircleList;
		this.people = people;

		/** It will hide the title */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.create_circle_picker_dialog);

		initialize();
		generateList();

	}

	private void initialize() {

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

		btnOk = (Button) findViewById(R.id.btnOk);
		btnOk.setOnClickListener(this);

		btnAddCircle = (Button) findViewById(R.id.btnAddCircle);
		btnAddCircle.setOnClickListener(this);

		editTextCircleName = (EditText) findViewById(R.id.editTextCircleName);

		listView = (ListView) findViewById(R.id.addMoveCircleList);

		mainLayout = (RelativeLayout) findViewById(R.id.mainLayoutPeopleCirclePicker);

		editTextCircleName
				.setOnFocusChangeListener(new View.OnFocusChangeListener() {

					public void onFocusChange(View v, boolean flag) {
						if (flag == false) {
							InputMethodManager inputMethodManager = (InputMethodManager) context
									.getSystemService(Context.INPUT_METHOD_SERVICE);
							inputMethodManager.hideSoftInputFromWindow(
									v.getWindowToken(), 0);
						}
					}
				});

	}

	@Override
	public void onClick(View v) {
		if (v == btnCancel) {
			dismiss();

			// Refresh Circle list
			if (PeopleCircleActivity.getIns() != null) {

				PeopleCircleActivity.getIns().generateCircleView();
			}
		}
		if (v == btnOk) {

			circleAddMoveToPickerListener.onCircleSelect(pickerName,
					selectedCircle);

			int len = listView.getCount();
			SparseBooleanArray checked = listView.getCheckedItemPositions();

			// clear selected Array list
			selectedArrayList.clear();

			// get selected items
			for (int i = 0; i < len; i++)
				if (checked.get(i)) {

					Circle circle = circleList.get(i);

					Log.w("Checked Circle Name in CircleAddMoveToPicker???",
							circle.getName() + " Id: " + circle.getId());

					// Add selected item to a selected Array list
					selectedArrayList.add(circle.getId());

				}

			// Api calling
			moveToSelectedCircle();

			// Dialog cancel
			dismiss();

		}

		if (v == btnAddCircle) {

			circleName = editTextCircleName.getText().toString().trim();

			if (!circleName.equals("")) {

				sendCircleNameToServer();

			} else {
				Toast.makeText(context, "Please Enter Circle Name", 1000)
						.show();
			}
			hideKeybord();
			dismiss();
		}

		// Hide keybord
		if (v == mainLayout) {

			hideKeybord();

		}

	}

	/*
	 * Generate Circle List
	 */
	private void generateList() {

		if (circleList != null) {

			nearByPlacesAdapter = new CircleAddMoveToAdapter(context,
					android.R.layout.simple_list_item_multiple_choice,
					circleList, selectedCircleList);
			listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
			listView.setAdapter(nearByPlacesAdapter);

			for (int i = 0; i < circleList.size(); i++) {

				if (selectedCircleList.contains(circleList.get(i).getId())) {

					listView.setItemChecked(i, true);

				}

			}

			// nearByPlacesAdapter = new CircleAddMoveToAdapter(context,
			// R.layout.row_list_item_multiple_select, circleList,
			// selectedCircleList);
			//
			// listView.setAdapter(nearByPlacesAdapter);

			listView.setOnItemClickListener(this);
		}

	}

	// Refresh circle list
	private void refreshCircleList() {

		circleList = StaticValues.myInfo.getCircleList();

		if (circleList != null) {

			nearByPlacesAdapter = new CircleAddMoveToAdapter(context,
					android.R.layout.simple_list_item_multiple_choice,
					circleList, selectedCircleList);
			listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
			listView.setAdapter(nearByPlacesAdapter);

			for (int i = 0; i < circleList.size(); i++) {

				if (selectedCircleList.contains(circleList.get(i).getId())) {

					listView.setItemChecked(i, true);

				}

			}

			nearByPlacesAdapter.notifyDataSetChanged();

		}

	}

	/*
	 * Add Circle to server
	 */
	private void sendCircleNameToServer() {
		// TODO Auto-generated method stub

		if (Utility.isConnectionAvailble(context)) {

			Thread thread = new Thread(null, sendCircleNameThread,
					"Start add circle");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog
					.show(context,
							context.getResources().getString(
									R.string.please_wait_text),
							context.getResources().getString(
									R.string.sending_request_text), true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	private Runnable sendCircleNameThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smCircleUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("name", circleName);

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			createCircleResponse = restClient.getResponse();
			createCircleStatus = restClient.getResponseCode();

			((Activity) context).runOnUiThread(sendCircleNameReturnResponse);

			// handleResponseSendMessage(createCircleStatus,
			// createCircleResponse);

			// dismiss progress dialog if needed
			// m_ProgressDialog.dismiss();
		}
	};

	private Runnable sendCircleNameReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseCircleName(createCircleStatus, createCircleResponse);

			// dismiss progress dialog if needed

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	public void handleResponseCircleName(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("New Circle Add ", status + ":" + response);

		switch (status) {
		case Constant.STATUS_CREATED:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Successfully added new circle.",
					Toast.LENGTH_SHORT).show();

			try {
				JSONArray jArray = new JSONArray(response);
				List<Circle> circles = ServerResponseParser
						.getCircleList(jArray);
				if (circles.size() > 0) {
					StaticValues.myInfo.setCircleList(circles);
				}

			} catch (Exception e) {
				// TODO: handle exception
			}

			// Refresh Circle list
			if (PeopleCircleActivity.getIns() != null) {
				PeopleCircleActivity.getIns().generateCircleView();
			}

			break;

		default:
			Toast.makeText(context,
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	// End *******************************************************

	/*
	 * Move a particular friend to selected Circles
	 */
	private void moveToSelectedCircle() {
		// TODO Auto-generated method stub

		if (Utility.isConnectionAvailble(context)) {

			Thread thread = new Thread(null, moveToSelectedCirclesThread,
					"Start move to selected circles");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog
					.show(context,
							context.getResources().getString(
									R.string.please_wait_text),
							context.getResources().getString(
									R.string.sending_request_text), true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	private Runnable moveToSelectedCirclesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub

			String id = people.getId();

			RestClient restClient = new RestClient(Constant.smCircleUrl
					+ "/friend/" + id);

			Log.w("Request Url  >>", Constant.smCircleUrl + "/friend/" + id);

			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			for (String ids : selectedArrayList) {
				restClient.AddParam("circles[]", ids);
			}

			try {
				restClient.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			moveToSelectedCirclesResponse = restClient.getResponse();
			moveToSelectedCirclesStatus = restClient.getResponseCode();

			((Activity) context)
					.runOnUiThread(moveToSelectedCirclesResponseRunable);

		}
	};

	private Runnable moveToSelectedCirclesResponseRunable = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponsemoveToSelectedCircles(moveToSelectedCirclesStatus,
					moveToSelectedCirclesResponse);

			// dismiss progress dialog if needed

			if (m_ProgressDialog != null) {
				m_ProgressDialog.dismiss();
			}
		}
	};

	public void handleResponsemoveToSelectedCircles(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("Move to selected circles", status + ":" + response);

		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Moved selected circles successfully.",
					Toast.LENGTH_SHORT).show();

			try {
				JSONArray jArray = new JSONArray(response);
				List<Circle> circles = ServerResponseParser
						.getCircleList(jArray);
				if (circles.size() > 0) {
					StaticValues.myInfo.setCircleList(circles);
				}

			} catch (JSONException e) {
				// TODO: handle exception
			}

			// Refresh Circle list
			if (PeopleCircleActivity.getIns() != null) {

				PeopleCircleActivity.getIns().generateCircleView();
			}

			break;

		default:
			Toast.makeText(context,
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	// End ********************************

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int index, long arg3) {

		// if (index == 1) {
		// listView.setItemChecked(1, false);
		// }

		// selectedCircle = circleList.get(index);
		//
		// circleAddMoveToPickerListener
		// .onCircleSelect(pickerName, selectedCircle);
		
		hideKeybord();
	}

	/*
	 * Hide Keybord
	 */

	public void hideKeybord() {

		// etSearchField
		// .setOnFocusChangeListener(new View.OnFocusChangeListener() {
		//
		// public void onFocusChange(View v, boolean flag) {
		// if (flag == false) {
		// InputMethodManager inputMethodManager = (InputMethodManager)
		// getSystemService(Context.INPUT_METHOD_SERVICE);
		// inputMethodManager.hideSoftInputFromWindow(
		// v.getWindowToken(), 0);
		// }
		// }
		// });

		InputMethodManager mgr = (InputMethodManager) context
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(editTextCircleName.getWindowToken(), 0);
	}

}