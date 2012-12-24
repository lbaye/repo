package com.socmaps.ui;

import com.socmaps.util.Utility;

import android.app.Activity;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.Button;

/**
 * SettingsActivity class is used to set up the application based on user's own preference. 
 * From the SettingsActivity users can set up Accounting, Information, Lacation Sharing, Notification, 
 * Platform, Layer. 
 *
 */

public class SettingsActivity extends Activity {

	Button btnBack, btnNotification, btnAccountSettings, btnInformationSharing,
			btnLocationSharing, btnNotifications, btnPlatforms, btnLayers;

	ButtonClickListener buttonClickListener;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.settings_layout);

		initialize();

	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		
		Utility.updateNotificationBubbleCounter(btnNotification);
	}

	private void initialize() {

		buttonClickListener = new ButtonClickListener();

		btnAccountSettings = (Button) findViewById(R.id.btnAccountSettings);
		btnAccountSettings.setOnClickListener(buttonClickListener);

		btnInformationSharing = (Button) findViewById(R.id.btnInformationSharing);
		btnInformationSharing.setOnClickListener(buttonClickListener);

		btnLocationSharing = (Button) findViewById(R.id.btnLocationSharing);
		btnLocationSharing.setOnClickListener(buttonClickListener);

		btnNotifications = (Button) findViewById(R.id.btnNotifications);
		btnNotifications.setOnClickListener(buttonClickListener);

		btnPlatforms = (Button) findViewById(R.id.btnPlatforms);
		btnPlatforms.setOnClickListener(buttonClickListener);

		btnLayers = (Button) findViewById(R.id.btnLayers);
		btnLayers.setOnClickListener(buttonClickListener);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonClickListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonClickListener);
	}

	private class ButtonClickListener implements View.OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnAccountSettings) {
				Intent accountSettingsIntent = new Intent(
						getApplicationContext(), AccountSettingsActivity.class);
				startActivity(accountSettingsIntent);
			} else if (v == btnInformationSharing) {
				Intent informationSharingSettingsIntent = new Intent(
						getApplicationContext(),
						InformationSharingSettingsActivity.class);
				startActivity(informationSharingSettingsIntent);
			} else if (v == btnLocationSharing) {
				Intent locationSharingSettingsIntent = new Intent(
						getApplicationContext(),
						LocationSharingSettingsActivity.class);
				startActivity(locationSharingSettingsIntent);
			} else if (v == btnNotifications) {
				Intent notificationsSettingsIntent = new Intent(
						getApplicationContext(),
						NotificationPreferencesActivity.class);
				startActivity(notificationsSettingsIntent);
			} else if (v == btnPlatforms) {
				Intent platformsSettingsIntent = new Intent(
						getApplicationContext(),
						PlatformPreferencesActivity.class);
				startActivity(platformsSettingsIntent);
			} else if (v == btnLayers) {
				Intent layersSettingsIntent = new Intent(
						getApplicationContext(), LayerPreferencesActivity.class);
				startActivity(layersSettingsIntent);
			}

			else if (v == btnBack) {
				finish();
			} else if (v == btnNotification) {
				Intent notificationIntent = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(notificationIntent);
			}
		}

	}

}
