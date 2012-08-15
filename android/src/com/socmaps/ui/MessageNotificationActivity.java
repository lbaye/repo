package com.socmaps.ui;

import com.socmaps.widget.ExpandablePanel;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.TabHost.TabContentFactory;
import android.widget.TabHost.TabSpec;

public class MessageNotificationActivity extends Activity {
	
	ButtonActionListener buttonActionListener;
	LinearLayout messageListContainer;
	private LayoutInflater inflater;
	private Context context;

	

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.message_notification_activity);
		
		initialize();
		
		

	}
	
	
	
	public void initialize()
	{
		context=MessageNotificationActivity.this;
		buttonActionListener = new ButtonActionListener();
		messageListContainer=(LinearLayout)findViewById(R.id.message_list_container);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);		
	}
	
	
	
	ExpandablePanel.OnExpandListener colapseExpand() {
		return new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                Button btn = (Button)handle;
                btn.setBackgroundResource(R.drawable.icon_more);
            }
            public void onExpand(View handle, View content) {
                Button btn = (Button)handle;
                btn.setBackgroundResource(R.drawable.btn_collapse);
            }
        };
	}
	

	@Override
	public void onContentChanged() {
		super.onContentChanged();

		// initialize
		//initialize();

	}

	@Override
	protected void onResume() {
		super.onResume();
		messageListContainer.removeAllViews();
		for(int i=0;i<5;i++)
		{
			View v=inflater.inflate(R.layout.row_message_list, null);
			ExpandablePanel panel = (ExpandablePanel)v.findViewById(R.id.foo);
			panel.setOnExpandListener(colapseExpand());
			messageListContainer.addView(v);
		}
	}

	@Override
	protected void onPause() {
		super.onPause();

	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			//finish();
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
	
	private class ButtonActionListener implements OnClickListener
	{

		/* (non-Javadoc)
		 * @see android.view.View.OnClickListener#onClick(android.view.View)
		 */
		public void onClick(View v) {
			// TODO Auto-generated method stub
			
		}
		
	}

}
