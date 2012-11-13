package com.socmaps.notificationBroadcast;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class NotificationCountBroadcastReciever extends BroadcastReceiver {

	private static BroadcastListener listener;
	private static NotificationCountBroadcastReciever instances = null;

	public static NotificationCountBroadcastReciever getInstance() {
		if (instances == null)
			instances = new NotificationCountBroadcastReciever();
		return instances;
	}

	public void setCallback(BroadcastListener temp) {
		NotificationCountBroadcastReciever.listener = temp;
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		listener.updateNotificationCountBuble(intent);
	}

}
