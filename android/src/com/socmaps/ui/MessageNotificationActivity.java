package com.socmaps.ui;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.FriendRequest;
import com.socmaps.entity.MessageEntity;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;
import com.socmaps.widget.ExpandablePanel;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
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
	
	ProgressDialog m_ProgressDialog;
	String messageResponse = "";
	int messageStatus = 0;

	

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.message_notification_activity);
		
		initialize();
		
		getMessages();

	}
	
	public void getMessages() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, messagesThread,
					"Start get messages");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}
	
	private Runnable messagesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl+"/inbox");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			messageResponse = restClient.getResponse();
			messageStatus = restClient.getResponseCode();

			runOnUiThread(messageReturnResponse);
		}
	};
	
	private Runnable messageReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseMessage(messageStatus,
					messageResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	
	public void handleResponseMessage(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("MESSAGE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_SUCCESS) {
			try {
				
				messageListContainer.removeAllViews();
				
				
				MessageEntity[] messages = ServerResponseParser.parseMessages(response);
				
				
				
				if(messages != null)
				{
					
					NotificationActivity ta = (NotificationActivity) this.getParent();
					TabHost th = ta.getMyTabHost();
					View tab = th.getChildAt(0);
					TextView tabLabel = (TextView)tab.findViewById(R.id.tvItemCountDisplay);
					tabLabel.setText(""+messages.length);
					
					for(int i=0;i<messages.length;i++)
					{
						if(messages[i] != null)
						{
							View v=inflater.inflate(R.layout.row_message_list, null);
							ExpandablePanel panel = (ExpandablePanel)v.findViewById(R.id.foo);
							panel.setOnExpandListener(colapseExpand());
							
							
							
							TextView senderName = (TextView)v.findViewById(R.id.sender_name_text_view);
							TextView sentTime = (TextView)v.findViewById(R.id.sentTime);
							TextView senderMessage = (TextView)v.findViewById(R.id.senderMessage);
							
							
							String name = "";
							if(messages[i].getSenderFirstName() != null)
							{
								name = messages[i].getSenderFirstName()+" ";
								
							}
							if(messages[i].getSenderLastName() != null)
							{
								name += messages[i].getSenderLastName();
								
							}
							
							senderName.setText(name);
							
							if(messages[i].getCreateDate() != null)
							{
								sentTime.setText(messages[i].getCreateDate());
							}
							if(messages[i].getContent() != null)
							{
								senderMessage.setText(messages[i].getContent());
							}
							
							
							messageListContainer.addView(v);
						}
					}
				}

				

			} catch (Exception e) {
				Log.e("Parse response", e.getMessage());
				// TODO: handle exception
			}
		}

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
