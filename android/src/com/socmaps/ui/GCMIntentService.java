/*
 * Copyright 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.socmaps.ui;

import static com.socmaps.pushNotification.CommonUtilities.SENDER_ID;
import static com.socmaps.pushNotification.CommonUtilities.displayMessage;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.google.android.gcm.GCMBaseIntentService;
import com.google.android.gcm.GCMRegistrar;
import com.socmaps.entity.PushData;
import com.socmaps.pushNotification.CommonUtilities;
import com.socmaps.pushNotification.ServerUtilities;

/**
 * IntentService responsible for handling GCM messages.
 */
public class GCMIntentService extends GCMBaseIntentService {

	Intent intent = new Intent(CommonUtilities.DISPLAY_MESSAGE_ACTION);
	int counter = 0;

	@SuppressWarnings("hiding")
	private static final String TAG = "GCMIntentService";

	/**
	 * This constructor refers SENDER_ID;
	 * 
	 */
	public GCMIntentService() {
		super(SENDER_ID);
	}

	@Override
	protected void onRegistered(Context context, String registrationId) {
		Log.i(TAG, "Device registered: regId = " + registrationId);
		displayMessage(context, getString(R.string.gcm_registered));
		ServerUtilities.register(context, registrationId);
	}

	@Override
	protected void onUnregistered(Context context, String registrationId) {
		Log.i(TAG, "Device unregistered");
		displayMessage(context, getString(R.string.gcm_unregistered));
		if (GCMRegistrar.isRegisteredOnServer(context)) {
			ServerUtilities.unregister(context, registrationId);
		} else {
			// This callback results from the call to unregister made on
			// ServerUtilities when the registration to the server failed.
			Log.i(TAG, "Ignoring unregister callback");
		}
	}

	@Override
	protected void onMessage(Context context, Intent intent) {

		String action = intent.getAction();

		if ("com.google.android.c2dm.intent.RECEIVE".equals(action)) {
			Log.w("C2DM", "Received message");

			PushData pushData = new PushData();

			if (intent.getStringExtra("objectId") != null) {
				pushData.setObjectId(intent.getStringExtra("objectId"));
			}
			if (intent.getStringExtra("objectType") != null) {
				pushData.setObjectType(intent.getStringExtra("objectType"));
			}
			if (intent.getStringExtra("title") != null) {
				pushData.setTitle(intent.getStringExtra("title"));
			}
			if (intent.getStringExtra("message") != null) {
				pushData.setMessage(intent.getStringExtra("message"));
				Log.i("message", intent.getStringExtra("message"));
			}
			if (intent.getStringExtra("badge") != null) {
				pushData.setBadge(Integer.parseInt(intent
						.getStringExtra("badge")));
				Log.i("badge", intent.getStringExtra("badge"));
			}
			if (intent.getStringExtra("tabCounts") != null) {
				pushData.setTabCounts(intent.getStringExtra("tabCounts"));
				Log.i("tabCounts", intent.getStringExtra("tabCounts"));
			}

			Log.d("GCM: onMessage", "Type: " + pushData.getObjectType());

			Intent intent2 = new Intent(CommonUtilities.DISPLAY_MESSAGE_ACTION);
			intent2.putExtra("pushData", pushData);
			sendBroadcast(intent2);

			generateNotification(context, pushData);
		}
	}

	@Override
	protected void onDeletedMessages(Context context, int total) {
		Log.i(TAG, "Received deleted messages notification");
		String message = getString(R.string.gcm_deleted, total);
		displayMessage(context, message);

		PushData pushData = new PushData();
		pushData.setMessage(message);
		// notifies user
		generateNotification(context, pushData);
	}

	@Override
	public void onError(Context context, String errorId) {
		Log.i(TAG, "Received error: " + errorId);
		displayMessage(context, getString(R.string.gcm_error, errorId));
	}

	@Override
	protected boolean onRecoverableError(Context context, String errorId) {
		// log message
		Log.i(TAG, "Received recoverable error: " + errorId);
		displayMessage(context,
				getString(R.string.gcm_recoverable_error, errorId));
		return super.onRecoverableError(context, errorId);
	}

	/**
	 * Issues a notification to inform the user that server has sent a message.
	 */
	private static void generateNotification(Context context, PushData pushData) {
		int icon = R.drawable.icon;
		long when = System.currentTimeMillis();
		NotificationManager notificationManager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		Notification notification = new Notification(icon,
				pushData.getMessage(), when);
		String title = context.getString(R.string.app_name);
		Intent notificationIntent = new Intent(context, HomeActivity.class);
		// set intent so it does not start a new activity
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);

		notificationIntent.putExtra("pushData", pushData);

		PendingIntent intent = PendingIntent.getActivity(context, 0,
				notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
		notification.setLatestEventInfo(context, title, pushData.getMessage(),
				intent);
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notificationManager.notify(0, notification);

		Log.i("generateNotification: Type", pushData.getObjectType());

	}

}
