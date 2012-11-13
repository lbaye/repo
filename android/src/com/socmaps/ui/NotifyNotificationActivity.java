package com.socmaps.ui;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;

public class NotifyNotificationActivity extends Activity {

	ButtonActionListener buttonActionListener;

	LinearLayout notificationListContainer;
	private LayoutInflater inflater;
	private Context context;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notify_notification_activity);

		initialize();

	}

	public void initialize() {
		buttonActionListener = new ButtonActionListener();
		context = NotifyNotificationActivity.this;
		notificationListContainer = (LinearLayout) findViewById(R.id.notification_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();

		// initialize
		// initialize();

	}

	@Override
	protected void onResume() {
		super.onResume();

		/*
		 * notificationListContainer.removeAllViews(); for(int i=0;i<5;i++) {
		 * if(i%2==0) { View
		 * v=inflater.inflate(R.layout.row_notification_without_image, null);
		 * notificationListContainer.addView(v); } else { View
		 * v=inflater.inflate(R.layout.row_notification_with_image, null);
		 * notificationListContainer.addView(v); } }
		 */
	}

	@Override
	protected void onPause() {
		super.onPause();

	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			// finish();
			/*
			 * AlertDialog.Builder adb = new AlertDialog.Builder(this); //
			 * adb.setTitle("Set Title here");
			 * adb.setMessage("Are you sure you want to exit from this application?"
			 * ); adb.setPositiveButton("Yes", new
			 * DialogInterface.OnClickListener() { public void
			 * onClick(DialogInterface dialog, int id) { finish(); } });
			 * adb.setNegativeButton("No", new DialogInterface.OnClickListener()
			 * { public void onClick(DialogInterface dialog, int id) {
			 * dialog.cancel(); } }); adb.show();
			 */

		}
		return false;

	}

	private class ButtonActionListener implements OnClickListener {

		/*
		 * (non-Javadoc)
		 * 
		 * @see android.view.View.OnClickListener#onClick(android.view.View)
		 */
		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub

		}

	}

}
