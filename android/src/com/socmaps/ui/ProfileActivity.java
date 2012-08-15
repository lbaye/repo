package com.socmaps.ui;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import org.json.JSONException;
import org.json.JSONObject;

import com.socmaps.util.Constant;
import com.socmaps.util.Data;
import com.socmaps.entity.ProfileInfo;
import com.socmaps.entity.Response;
import com.socmaps.util.Utility;

import android.app.Activity;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

public class ProfileActivity extends Activity 
{
	TextView tvName,tvAge,tvLivesIn,tvWork;
	ImageView ivProfilePicture,ivRegistationMedium;	
	
	String tempURLString,responseString,responseDataString;
	Response responseObject;
	ProfileInfo profileInfoObject=null;
	Uri imageUri;
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.profilepages);
		
		initialize();
		
		onLoad();
		
	}
	
	private void onLoad() 
	{
		if(Utility.isConnectionAvailble(getApplicationContext()))
		{	
			tempURLString=Constant.profileInfoUrl;
			responseString=Data.getServerResponse(tempURLString);
			Log.d("response", responseString);								
			responseObject=Data.parseResponse(responseString);			
			responseDataString=responseObject.getData();
			Log.d("responseData", responseDataString);
			
			try
			{
				JSONObject jsonObject = new JSONObject(responseDataString);
				profileInfoObject=new ProfileInfo();
				profileInfoObject.setBio( jsonObject.getString("bio"));
				profileInfoObject.setCity(jsonObject.getString("city"));
				profileInfoObject.setCountry(jsonObject.getString("country"));
				profileInfoObject.setDateOfBirth(jsonObject.getString("dob"));
				profileInfoObject.setEmail(jsonObject.getString("email"));
				profileInfoObject.setFirstName(jsonObject.getString("first_name"));
				profileInfoObject.setLastName(jsonObject.getString("last_name"));
				profileInfoObject.setPostCode(jsonObject.getString("post_code"));
				profileInfoObject.setProfilePic(jsonObject.getString("profile_pic"));
				profileInfoObject.setRegMedia(jsonObject.getString("reg_media"));
				profileInfoObject.setRelationshipStatus(jsonObject.getString("relationship_status"));
				profileInfoObject.setService(jsonObject.getString("service"));
				profileInfoObject.setSmID(jsonObject.getInt("sm_id"));
				profileInfoObject.setStreetAddress(jsonObject.getString("street_address"));
				
				tvName.setText(profileInfoObject.getFirstName().concat("".concat(profileInfoObject.getLastName())));
				tvAge.setText(Integer.toString(Utility.calculateAge(profileInfoObject.getDateOfBirth())));
				tvLivesIn.setText(profileInfoObject.getCity().concat(", ".concat(profileInfoObject.getCountry())));
				tvWork.setText(profileInfoObject.getService());
				try 
				{
					ivProfilePicture.setImageBitmap(BitmapFactory.decodeStream((InputStream)new URL(profileInfoObject.getProfilePic()).getContent()));
				}
				catch (MalformedURLException e)
				{
					e.printStackTrace();
				} 
				catch (IOException e) 
				{
					e.printStackTrace();
				}
				
				if(profileInfoObject.getRegMedia().equals("fb"))
				{
					ivRegistationMedium.setImageResource(R.drawable.facebookicon);
				}
				else
				{
					ivRegistationMedium.setImageResource(R.drawable.ic_launcher);
				}
			} 
			catch (JSONException e)
			{
				e.printStackTrace();
			}		
		}
		else
		{
			Toast.makeText(getApplicationContext(), "Internet Connection Unavailable", Toast.LENGTH_SHORT).show();
		}
	}	
	
	private void initialize() 
	{
		tvName=(TextView) findViewById(R.id.tvName);
		tvAge=(TextView) findViewById(R.id.tvAge);
		tvLivesIn=(TextView) findViewById(R.id.tvLivesIn);
		tvWork=(TextView) findViewById(R.id.tvWork);

		
		ivProfilePicture=(ImageView) findViewById(R.id.ivProfilePicture);
		ivRegistationMedium=(ImageView) findViewById(R.id.ivRegistationMedium);
	}

}
