package com.socmaps.ui;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;

import com.socmaps.entity.LayersPreferences;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * LayerPreferencesActivity class for generating layer preference view and some user interaction.
 *
 */
public class LayerPreferencesActivity extends Activity implements
		OnClickListener {

	CheckBox chkWikipedia, chkTripAdvisor, chkFoodspotting;
	Button btnSave;
	Button btnBack, btnNotification;
	Context context;
	RadioGroup radioGroupWiki, radioGroupTripad, radioGroupFoodSpoting;
	ProgressDialog m_ProgressDialog;
	int requestCode;
	String responseString;
	int responseStatus = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.layer_preferences_layout);

		initialize();
		setViewOnClickListener();
	}
	
	

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		if (StaticValues.layersPreferences == null) {
			startDialogAndBgThread();
		} else {
			setFieldValues(StaticValues.layersPreferences);
		}
		
		Utility.updateNotificationBubbleCounter(btnNotification);
	}

	private void setFieldValues(LayersPreferences layersPreferences) {
		// TODO Auto-generated method stub

		setRadioGroupValue(radioGroupWiki, layersPreferences.getWikipedia());
		setRadioGroupValue(radioGroupTripad, layersPreferences.getTripadvisor());
		setRadioGroupValue(radioGroupFoodSpoting,
				layersPreferences.getFoodspotting());

	}

	private void setRadioGroupValue(RadioGroup rG, boolean status) {
		// TODO Auto-generated method stub
		if (status) {
			((RadioButton) rG.findViewById(R.id.on_radio)).setChecked(status);
		} else
			((RadioButton) rG.findViewById(R.id.off_radio)).setChecked(true);
	}

	private void handleLayerSettingsResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			LayersPreferences layersPreferences = ServerResponseParser
					.parseLayerSettings(response);
			setFieldValues(layersPreferences);
			StaticValues.layersPreferences = layersPreferences;
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private Runnable returnResGetLayerSettings = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}
			handleLayerSettingsResponse(responseStatus, responseString);
		}

	};

	private Runnable getLayerSettingsInfo = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient getAccountSettingsClient = new RestClient(
					Constant.layersSettingsUrl);
			getAccountSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();

			responseStatus = getAccountSettingsClient.getResponseCode();

			runOnUiThread(returnResGetLayerSettings);

		}
	};

	private void startDialogAndBgThread() {

		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, getLayerSettingsInfo,
					"Start update password");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true,true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}

	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void initialize() {

		context = LayerPreferencesActivity.this;
		radioGroupWiki = (RadioGroup) findViewById(R.id.radioGroupWiki);
		radioGroupTripad = (RadioGroup) findViewById(R.id.radioGroupTripAdvisor);
		radioGroupFoodSpoting = (RadioGroup) findViewById(R.id.radioGroupFoodSpotting);
		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);

		btnSave = (Button) findViewById(R.id.btnSaveLayers);

	}

	private void setViewOnClickListener() {
		// TODO Auto-generated method stub

		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		btnSave.setOnClickListener(this);
	}

	private Runnable updateLayersValuesThread = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendDataToServer();
		}
	};

	private int getRadioStatus(RadioGroup rG) {
		int checkedRadioButton = rG.getCheckedRadioButtonId();

		if (((RadioButton) rG.findViewById(R.id.off_radio)).isChecked()) {
			return 0;
		} else {
			return 1;
		}
		/*
		 * switch (checkedRadioButton) { case R.id.off_radio :
		 * radioButtonSelected = 0; break; case R.id.on_radio :
		 * radioButtonSelected = 1; break;
		 * 
		 * }
		 */

	}

	private void sendDataToServer() {
		RestClient client = new RestClient(Constant.layersSettingsUrl);

		// client.AddHeader("GData-Version", "2");
		client.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));
		client.AddParam("wikipedia", getRadioStatus(radioGroupWiki) + "");
		client.AddParam("tripadvisor", getRadioStatus(radioGroupTripad) + "");
		client.AddParam("foodspotting", getRadioStatus(radioGroupFoodSpoting)
				+ "");

		try {
			client.Execute(RestClient.RequestMethod.PUT);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();

		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);
	}

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponse(responseStatus, responseString);
			if(m_ProgressDialog!=null){
				m_ProgressDialog.dismiss();
			}

		}
	};

	private void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			Toast.makeText(getApplicationContext(),
					"Information saved successfully!!", Toast.LENGTH_SHORT)
					.show();
			StaticValues.layersPreferences = ServerResponseParser
					.parseLayerSettings(response);
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();
			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	private void updateAllValues() {
		// TODO Auto-generated method stub

		Thread thread = new Thread(null, updateLayersValuesThread,
				"Start update platforms");
		thread.start();

		m_ProgressDialog = ProgressDialog.show(this,
				getResources().getString(R.string.please_wait_text),
				getResources().getString(R.string.updating_data_text), true,true);
		m_ProgressDialog.show();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnBack) {
			finish();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(getApplicationContext(),
					NotificationActivity.class);
			startActivity(notificationIntent);
		} else if (v == btnSave) {
			updateAllValues();
		}

	}

}
