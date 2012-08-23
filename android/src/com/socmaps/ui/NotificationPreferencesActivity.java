package com.socmaps.ui;

import java.io.ByteArrayOutputStream;

import com.socmaps.entity.LayersEntity;
import com.socmaps.entity.NotificationsEntity;
import com.socmaps.util.AppStaticStorages;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;
import com.socmaps.widget.ExpandablePanel;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

public class NotificationPreferencesActivity extends Activity implements OnClickListener
{
	
	RadioGroup radioGroupFrndRequest,radioGroupPost,radioGroupComments,radioGroupMesages,radioGroupRecommendations,radioGroupOfflineNotificstions;
	Button btnSave;
	Button btnBack,btnNotification;
	Context context;
	private ImageView leftArrowImage, rightArrowImage;
	private TextView proximityValueText;
	private ExpandablePanel proximityPanel;
	private final static int proximityLowerRange=0;
	private final static int proximityHigherRange=10;
	private static int proximityCurrentValue;
	private ProgressDialog m_ProgressDialog;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	
	public void onAttachedToWindow() {
		    super.onAttachedToWindow();
		    Window window = getWindow();
		    // Eliminates color banding
		    window.setFormat(PixelFormat.RGBA_8888);
		  }
	 
	@Override
	protected void onResume()
	{
		super.onResume();
		if(AppStaticStorages.notificationsEntity==null)
		{
			startDialogAndBgThread();
		}
		else
		{
			setFieldValues(AppStaticStorages.notificationsEntity);
		}
	}
	
	private void startDialogAndBgThread()
	{
		if (Utility.isConnectionAvailble(getApplicationContext()))
		{
			Thread thread = new Thread(null, getNotificationSettingsInfo,"Start update password");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true);
		} 
		else 
		{
			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}
	}
	
	private Runnable getNotificationSettingsInfo=new Runnable()
	{
		@Override
		public void run()
		{
			RestClient getAccountSettingsClient=new RestClient(Constant.smNotificationSettingsUrl);
			getAccountSettingsClient.AddHeader(Constant.authTokenParam,Utility.getAuthToken(context));
			try 
			{
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			}
			catch (Exception e)
			{
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();
			responseStatus = getAccountSettingsClient.getResponseCode();
			runOnUiThread(returnResGetNotificationSettings);				
		}
	};
	
	private Runnable returnResGetNotificationSettings=new Runnable()
	{
		@Override
		public void run()
		{
			m_ProgressDialog.dismiss();
			handleNotificationSettingsResponse(responseStatus, responseString);
		}
	};

	public void handleNotificationSettingsResponse(int status, String response)
	{
		Log.d("Registration", status + ":" + response);
		switch (status) 
		{
			case Constant.STATUS_SUCCESS:
				NotificationsEntity notificationsEntity=ServerResponseParser.parseNotificationSettings(response);
				setFieldValues(notificationsEntity);
				AppStaticStorages.notificationsEntity=notificationsEntity;
				break;

			case Constant.STATUS_BADREQUEST:
				Toast.makeText(getApplicationContext(),	Utility.parseResponseString(response), Toast.LENGTH_LONG).show();
				break;

			case Constant.STATUS_NOTFOUND:
				Toast.makeText(getApplicationContext(),	Utility.parseResponseString(response), Toast.LENGTH_LONG).show();
			
				break;
			default:
				Toast.makeText(getApplicationContext(),	"An unknown error occured.", Toast.LENGTH_LONG).show();
				break;
		}
	}

	
	private void setFieldValues(NotificationsEntity notificationsEntity)
	{
		setRadioGroupValue(radioGroupFrndRequest,notificationsEntity.isFriendRequests());		
		setRadioGroupValue(radioGroupPost,notificationsEntity.isPostsByFriends());		
		setRadioGroupValue(radioGroupComments,notificationsEntity.isComments());		
		setRadioGroupValue(radioGroupMesages,notificationsEntity.isMessages());		
		setRadioGroupValue(radioGroupRecommendations,notificationsEntity.isRecommendations());		
		setRadioGroupValue(radioGroupOfflineNotificstions,notificationsEntity.isOfflineNotifications());	
		if(notificationsEntity.getProximityRadius()>0)
		{
			proximityValueText.setText(notificationsEntity.getProximityRadius()+"");
		}
		else
		{
			proximityValueText.setText("0");
		}
	}
	
	private void setRadioGroupValue(RadioGroup rG,boolean status)
	{
		if(status)
		{
			((RadioButton)rG.findViewById(R.id.on_radio)).setChecked(status);
		}
		else
		{
			((RadioButton)rG.findViewById(R.id.off_radio)).setChecked(true);
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notification_preferences);
		
		initialize();
		setExpandListener();
		
		updateUI();
		
		setViewOnclickListener();
	}
	
	

	
   private int getRadioStatus(RadioGroup rG)
   {	  	   
	   if(((RadioButton)rG.findViewById(R.id.off_radio)).isChecked())
	   {
		   return 0;
	   }
	   else
	   {
		   return 1;
	   }
   }
   
	private void updateUI()
	{
		updateProximityTextView(proximityCurrentValue);
	}

	private void initialize()
	{
		/*chkFriendRequest=(CheckBox) findViewById(R.id.chkFriendRequest);
		chkPostsByFriends=(CheckBox) findViewById(R.id.chkPostsByFriends);
		chkComments=(CheckBox) findViewById(R.id.chkComments);
		chkMessages=(CheckBox) findViewById(R.id.chkMessages);
		chkRecommendations=(CheckBox) findViewById(R.id.chkRecommendations);
		chkOfflineNotifications=(CheckBox) findViewById(R.id.chkOfflineNotifications);
		chkRadius=(CheckBox) findViewById(R.id.chkRadius);
		etRadius=(EditText) findViewById(R.id.etRadius);
		btnSave=(Button) findViewById(R.id.btnSave);
	*/
		context=NotificationPreferencesActivity.this;
		radioGroupFrndRequest=(RadioGroup)findViewById(R.id.radioFriendRequestGroup);
		radioGroupPost=(RadioGroup)findViewById(R.id.radioPostGroup);
		radioGroupComments=(RadioGroup)findViewById(R.id.radioCommentsGroup);
		radioGroupMesages=(RadioGroup)findViewById(R.id.radioMessageGroup);
		radioGroupRecommendations=(RadioGroup)findViewById(R.id.radioRecommendationGroup);
		radioGroupOfflineNotificstions=(RadioGroup)findViewById(R.id.radioOfflineNotificationGroup);
		
		
		btnBack = (Button)findViewById(R.id.btnBack);		
		btnNotification = (Button)findViewById(R.id.btnNotification);
		btnSave= (Button)findViewById(R.id.btnSave);
		proximityCurrentValue=0;
		leftArrowImage=(ImageView)findViewById(R.id.left_arrow);
		rightArrowImage=(ImageView)findViewById(R.id.right_arrow);
		proximityValueText=(TextView)findViewById(R.id.proximity_value_text);
		proximityPanel=(ExpandablePanel)findViewById(R.id.proximityContainer);
	
	}
	
	private void setViewOnclickListener() {
		// TODO Auto-generated method stub
		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		
		leftArrowImage.setOnClickListener(this);
		rightArrowImage.setOnClickListener(this);
		btnSave.setOnClickListener(this);
		
	}
		

	private void setExpandListener() {
		// TODO Auto-generated method stub
		proximityPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.arrowImageProximity);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptext);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.arrowImageProximity);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptext);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if(v==leftArrowImage)
		{
			if(proximityCurrentValue>proximityLowerRange)
			{
				proximityCurrentValue--;
				updateProximityTextView(proximityCurrentValue);
			}
		}
		else if(v==rightArrowImage)
		{
			if(proximityCurrentValue<proximityHigherRange)
			{
				proximityCurrentValue++;
				updateProximityTextView(proximityCurrentValue);
			}
		}
		
		else if(v == btnBack)
		{
			finish();	
		}
		else if(v == btnNotification)
		{
			Intent notificationIntent = new Intent(getApplicationContext(), NotificationActivity.class);
			startActivity(notificationIntent);	
		}
		else if(v==btnSave)
		{
			updateAllValues();
		}
	}
	
	private Runnable updateNotificationValuesThread=new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendDataToServer();
		}
	};
	
	private void sendDataToServer()
	{
		RestClient client = new RestClient(Constant.smNotificationSettingsUrl);

		// client.AddHeader("GData-Version", "2");
		client.AddHeader(Constant.authTokenParam,
				Utility.getAuthToken(context));
		client.AddParam("friend_requests_sm",getRadioStatus(radioGroupFrndRequest)+"");
		client.AddParam("posts_by_friends_sm",getRadioStatus(radioGroupPost)+"");
		client.AddParam("comments_sm",getRadioStatus(radioGroupComments)+"");
		client.AddParam("messages_sm",getRadioStatus(radioGroupMesages)+"");
		client.AddParam("recommendations_sm",getRadioStatus(radioGroupRecommendations)+"");		
		if(Integer.parseInt(proximityValueText.getText().toString())==0)
		{
			client.AddParam("proximity_alerts_sm",0+"");
		}
		else 
		{
			client.AddParam("proximity_alerts_sm",1+"");			
		}
		client.AddParam("offline_notifications_sm",getRadioStatus(radioGroupOfflineNotificstions)+"");
		client.AddParam("proximity_radius",proximityValueText.getText().toString());			

		try {
			client.Execute(RestClient.RequestMethod.PUT);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();

		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);
	}
	
	
	private Runnable returnRes=new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponse(responseStatus, responseString);
			m_ProgressDialog.dismiss();
			
		}
	};
	
	
	public void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(getApplicationContext(),
					"Information saved successfully!!", Toast.LENGTH_SHORT)
					.show();
					
			AppStaticStorages.notificationsEntity=ServerResponseParser.parseNotificationSettings(response);
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();
			
			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
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
		
		Thread thread = new Thread(null, updateNotificationValuesThread,
				"Start update notification");
		thread.start();
		
		m_ProgressDialog=ProgressDialog.show(this, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.updating_data_text), true);
		m_ProgressDialog.show();
	}

	private void updateProximityTextView(int Value) {
		// TODO Auto-generated method stub
		proximityValueText.setText(""+Value);
	}

	/*private boolean isValidMove(int currentValue)
	{
		if(currentValue>proximityLowerRange && currentValue < proximityHigherRange)
			return true;
		else 
			return false;
	}*/
}
