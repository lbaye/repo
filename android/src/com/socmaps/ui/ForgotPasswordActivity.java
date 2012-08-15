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

public class ForgotPasswordActivity extends Activity 
{
	EditText etEmail;
	Button btnSendTest;
	private ProgressDialog pd;
	
	String tempURLString,responseString;
	Response responseObject;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.forgotpassword);
		
		initialize();
		
		btnSendTest.setOnClickListener(new OnClickListener()
		{
			public void onClick(View v) 
			{
				boolean flag=true;
				
				if( !Utility.isValidEmailID(etEmail.getText().toString()))
				{
					flag=false;
					etEmail.setError( "Invalid Email Id");					
				}
				
				if(flag)
				{
					if(Utility.isConnectionAvailble(getApplicationContext()))
					{	
						tempURLString=Constant.forgotPassUrl;
						
						HashMap<String,String> hashMapString=new HashMap<String, String>();
						hashMapString.put("email", etEmail.getText().toString());						

						tempURLString=Data.createUrl(tempURLString, hashMapString, "?");
						
						pd = ProgressDialog.show(ForgotPasswordActivity.this, "Waiting..", null, true, false);
						
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
		});
	
		
	}

	private void initialize() 
	{
		etEmail=(EditText) findViewById(R.id.etEmail);
		btnSendTest=(Button) findViewById(R.id.btnSendTest);
	}
	
	private Handler handler = new Handler()
	{
        @Override
        public void handleMessage(Message msg) 
        {
        	if(responseObject.getStatus().equals("1"))
        	{
    			pd.dismiss();
    			AlertDialog.Builder builder = new AlertDialog.Builder(ForgotPasswordActivity.this);
    			builder.setTitle("Mail Sent !");
    			builder.setCancelable(false).setPositiveButton("OK", new DialogInterface.OnClickListener() 
    			{
    		           public void onClick(DialogInterface dialog, int id) 
    		           {
							Intent myIntent = new Intent(getApplicationContext(), LoginActivity.class);
							startActivity(myIntent);				
    		           }
    		    });

    			AlertDialog alert = builder.create();
    			alert.show();        		
        	}
        	else
        	{
        		pd.dismiss();
    			AlertDialog.Builder builder = new AlertDialog.Builder(ForgotPasswordActivity.this);
    			builder.setTitle("Email cannot be sent !");
    			AlertDialog alert = builder.create();
    			alert.show();        		
        	}   
        }
	};


}
