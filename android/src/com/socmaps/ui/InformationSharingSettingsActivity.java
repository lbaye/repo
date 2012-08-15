package com.socmaps.ui;

import com.socmaps.entity.Information;
import com.socmaps.widget.ExpandablePanel;

import android.app.Activity;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class InformationSharingSettingsActivity extends Activity  implements OnClickListener
{
    //ListView lvInformationSharing; For Customized ListView
	Button btnSave;
	
	Button btnBack,btnNotification;
	
	CheckBox chkFirstName,chkLastName,chkUserName,chkEmail,chkProfilePicture,chkDateOfBirth,chkBiography,chkStreetAddres,
	chkCity,chkZIPCode,chkCountry,chkService,chkRelationshipStatus;
	
	int firstName=0,lastName=0,userName=0,email=0,profilePicture=0,dateOfBirth=0,biography=0,streetAddres=0,
	city=0,zIPCode=0,country=0,service=0,relationshipStatus=0;
	
	
	ExpandablePanel newsFeedPanel,profilePicPanel,emailPanel,namePanel,userNamePanel,genderPanel,dobPanel,biographyPanel,interestPanel,
	addressPanel,servicePanel,relationShipStatusPanel;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.information_sharing);
		initialize();
		setViewOnClickListener();
		setExpandListener();
		
	}

	
	public void onAttachedToWindow() {
	    super.onAttachedToWindow();
	    Window window = getWindow();
	    // Eliminates color banding
	    window.setFormat(PixelFormat.RGBA_8888);
	  }
	
	private void initialize()
	{		
		btnBack = (Button)findViewById(R.id.btnBack);		
		btnNotification = (Button)findViewById(R.id.btnNotification);
	
		
		newsFeedPanel=(ExpandablePanel)findViewById(R.id.newsFeedContainer);
		profilePicPanel=(ExpandablePanel)findViewById(R.id.profilePicContainer);
		emailPanel=(ExpandablePanel)findViewById(R.id.emailContainer);
		namePanel=(ExpandablePanel)findViewById(R.id.nameContainer);
		userNamePanel=(ExpandablePanel)findViewById(R.id.userNameContainer);
		genderPanel=(ExpandablePanel)findViewById(R.id.genderContainer);
		dobPanel=(ExpandablePanel)findViewById(R.id.dobContainer);
		biographyPanel=(ExpandablePanel)findViewById(R.id.biographyContainer);
		interestPanel=(ExpandablePanel)findViewById(R.id.interestsContainer);
		addressPanel=(ExpandablePanel)findViewById(R.id.addressContainer);
		servicePanel=(ExpandablePanel)findViewById(R.id.serviceContainer);
		relationShipStatusPanel=(ExpandablePanel)findViewById(R.id.relationshipStatusContainer);
		
	}
	
	private void setViewOnClickListener() {
		// TODO Auto-generated method stub
		
		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if(v == btnBack)
		{
			finish();	
		}
		else if(v == btnNotification)
		{
			Intent notificationIntent = new Intent(getApplicationContext(), NotificationActivity.class);
			startActivity(notificationIntent);	
		}
	}
	
	
	private void setExpandListener() {
		// TODO Auto-generated method stub
		newsFeedPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconNewsfeed);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextNewsfeed);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconNewsfeed);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextNewsfeed);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		profilePicPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconProfilePic);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextProfilePic);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconProfilePic);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextProfilePic);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		emailPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconEmail);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextEmail);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconEmail);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextEmail);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		namePanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconName);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextName);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconName);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextName);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		userNamePanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconUserName);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextUserName);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconUserName);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextUserName);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		genderPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconGender);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextGender);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconGender);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextGender);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		dobPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconDob);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextDob);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconDob);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextDob);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		biographyPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconBiography);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextBiography);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconBiography);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextBiography);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		interestPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconInterests);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextInterests);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconInterests);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextInterests);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		addressPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconAddress);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextAddress);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconAddress);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextAddress);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		servicePanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconService);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextService);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconService);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextService);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });
		
		relationShipStatusPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
            public void onCollapse(View handle, View content) {
                ImageView button=(ImageView)handle.findViewById(R.id.toggleIconRelationshipStatus);
                button.setImageResource(R.drawable.icon_arrow_down);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextRelationshipStatus);
            	text.setTypeface(null,Typeface.NORMAL);
            }
            public void onExpand(View handle, View content) {
            	ImageView button=(ImageView)handle.findViewById(R.id.toggleIconRelationshipStatus);
                button.setImageResource(R.drawable.icon_arrow_up);
                
            	LinearLayout container=(LinearLayout)content;
            	TextView text=(TextView)container.findViewById(R.id.toptextRelationshipStatus);
            	text.setTypeface(null,Typeface.BOLD);
            }
        });


	}
	

}
