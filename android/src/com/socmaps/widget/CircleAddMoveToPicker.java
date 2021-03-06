/**
 * 
 */
package com.socmaps.widget;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Dialog;
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
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * CircleAddMoveToPicker generates a custom dialog to display circle list item.
 *
 */
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
	String circleName;
	CircleAddMoveToAdapter nearByPlacesAdapter;

	private ArrayList<String> selectedArrayList = new ArrayList<String>();

	private People people;
	private RelativeLayout mainLayout;

	/**
	 * Generates a Circle list item.
	 * 
	 * @param context
	 *            Current active Context
	 * @param circleAddMoveToPickerListener
	 *            which is used for a specific action when button is clicked
	 * @param pickerName
	 *            is the Dialog Title
	 * @param circleList
	 *            List of Circle object
	 * @param selectedCircleList
	 *            List of String which are selected item (id) of circle list
	 * @param people
	 *            People object
	 * @see Context
	 */
	public CircleAddMoveToPicker(Context context,
			CircleAddMoveToPickerListener circleAddMoveToPickerListener,
			String pickerName, List<Circle> circleList,
			List<String> selectedCircleList, People people) {
		super(context);
		this.circleAddMoveToPickerListener = circleAddMoveToPickerListener;
		this.context = context;
		this.pickerName = pickerName;
		this.circleList = circleList;
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

					@Override
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

		Utility.hideKeyboardContext(context);

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

			moveSelectedPersonToParticularCircleAPICall();

			// Dialog cancel
			dismiss();

		}

		if (v == btnAddCircle) {

			circleName = editTextCircleName.getText().toString().trim();

			if (!circleName.equals("")) {

				// sendCircleNameToServer();
				addNewCircleAPICall();

			} else {
				Toast.makeText(context, "Please Enter Circle Name",
						Toast.LENGTH_SHORT).show();
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

			listView.setOnItemClickListener(this);
		}

	}

	private void addNewCircleAPICall() {

		String url = Constant.smCircleUrl;

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		params.add(new BasicNameValuePair("name", circleName));

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.ADD, true, context.getResources().getString(
						R.string.please_wait_text), context.getResources()
						.getString(R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.POST);

	}

	private void moveSelectedPersonToParticularCircleAPICall() {

		String id = people.getId();

		Log.w("Request Url  >>", Constant.smCircleUrl + "/friend/" + id);

		String url = Constant.smCircleUrl + "/friend/" + id;

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		for (String ids : selectedArrayList) {
			params.add(new BasicNameValuePair("circles[]", ids));
		}

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.MOVE, true, context.getResources().getString(
						R.string.please_wait_text), context.getResources()
						.getString(R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.PUT);

	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String response, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :",
					status + ":" + response);
			switch (status) {
			case Constant.STATUS_SUCCESS:

				Toast.makeText(context, "Moved selected circles successfully.",
						Toast.LENGTH_SHORT).show();

				try {
					JSONArray jArray = new JSONArray(response);

					List<Circle> circles = ServerResponseParser
							.getCircleListWithDetails(jArray);

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

			case Constant.STATUS_CREATED:

				Toast.makeText(context, "Successfully added new circle.",
						Toast.LENGTH_SHORT).show();

				try {
					JSONArray jArray = new JSONArray(response);
					List<Circle> circles = ServerResponseParser
							.getCircleListWithDetails(jArray);
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
			case Constant.STATUS_SUCCESS_NODATA:
				Toast.makeText(context, "No place found.", Toast.LENGTH_SHORT)
						.show();
				break;
			default:
				Toast.makeText(context,
						"An unknown error occured. Please try again!!",
						Toast.LENGTH_SHORT).show();
				break;

			}

		}

	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int index, long arg3) {

		hideKeybord();
	}

	/*
	 * Hide Keybord
	 */

	private void hideKeybord() {

		InputMethodManager mgr = (InputMethodManager) context
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(editTextCircleName.getWindowToken(), 0);
	}

}