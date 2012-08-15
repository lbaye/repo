package com.socmaps.ui;

import java.util.HashMap;

import com.socmaps.util.Constant;
import com.socmaps.util.Data;
import com.socmaps.entity.Response;
import com.socmaps.util.Utility;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class ChangePasswordActivity extends Activity 
{
	EditText etOldPassword, etNewPassword, etConfirmNewPassword;
	Button btnSave;
	private ProgressDialog pd;
	
	String tempURLString,responseString;
	Response responseObject;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.change_password);
		
		initialize();
		
	}

	private void initialize() 
	{
		etOldPassword=(EditText) findViewById(R.id.etOldPassword);
		etNewPassword = (EditText) findViewById(R.id.etNewPassword);
		etConfirmNewPassword = (EditText) findViewById(R.id.etConfirmNewPassword);
		
		btnSave=(Button) findViewById(R.id.btnSave);
		btnSave.setOnClickListener(new ButtonActionListener());
	}
	
	public void validateInput()
	{
		boolean flag=true;
		
		String oldPassword = etOldPassword.getText().toString();
		String newPassword = etNewPassword.getText().toString();
		String confirmPassword = etConfirmNewPassword.getText().toString();
		
		
		if(oldPassword.equalsIgnoreCase(""))
		{
			flag=false;
			etOldPassword.setError( "Invalid old password.");					
		} else if(newPassword.equalsIgnoreCase(""))
		{
			flag=false;
			etNewPassword.setError( "Invalid new password.");					
		}
		else if(!newPassword.equals(confirmPassword))
		{
			flag=false;
			etConfirmNewPassword.setError( "Password does not match.");					
		}
		
		if(flag)
		{
			if(Utility.isConnectionAvailble(getApplicationContext()))
			{	
				tempURLString=Constant.changePassUrl;
				
				HashMap<String,String> hashMapString=new HashMap<String, String>();
				hashMapString.put("oldPassword", oldPassword);	
				hashMapString.put("newPassword", newPassword);

				tempURLString=Data.createUrl(tempURLString, hashMapString, "?");
				
				pd = ProgressDialog.show(ChangePasswordActivity.this, "Change password", "Please wait...", true, false);
				
				new Thread()
				{
					public void run() 
					{
						responseString=Data.getServerResponse(tempURLString);
						Log.d("response", responseString);								
						responseObject=Data.parseResponse(responseString);
						Log.d("responseMessage", responseObject.getMessage());								
																
						handler.sendEmptyMessage(0);							
						
					}
					
				}.start();						

			}
			else
			{
				Toast.makeText(getApplicationContext(), "Internet Connection Unavailable", Toast.LENGTH_SHORT).show();
			}
		}	
	}
	
	private Handler handler = new Handler()
	{
        @Override
        public void handleMessage(Message msg) 
        {
        	if(responseObject.getStatus().equals("1"))
        	{
    			pd.dismiss();
    			AlertDialog.Builder builder = new AlertDialog.Builder(ChangePasswordActivity.this);
    			builder.setTitle("Password change");
    			builder.setMessage("Password changed successfully.");
    			builder.setCancelable(false).setPositiveButton("OK", new DialogInterface.OnClickListener() 
    			{
    		           public void onClick(DialogInterface dialog, int id) 
    		           {
							finish();				
    		           }
    		    });

    			AlertDialog alert = builder.create();
    			alert.show();        		
        	}
        	else
        	{
        		pd.dismiss();
    			AlertDialog.Builder builder = new AlertDialog.Builder(ChangePasswordActivity.this);
    			builder.setTitle("Password change");
    			builder.setMessage("Password change failed.");
    			AlertDialog alert = builder.create();
    			alert.show();        		
        	}   
        }
	};
	
	private class ButtonActionListener implements OnClickListener
	{

		public void onClick(View v) {
			// TODO Auto-generated method stub
			if(v==btnSave)
			{
				validateInput();
			}
		}
		
	}


}
