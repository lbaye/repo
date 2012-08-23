package com.socmaps.ui;

import com.socmaps.util.Utility;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.ProgressBar;

public class SplashActivity extends Activity 
{
	ProgressBar pbSplash;
	int total=0;
	boolean isRunning=false;
	int splashDuration=2000; //millisecond
	String loopCountString;
	int loopCount;
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.splash);
		
		initialize();
		
	}

	private int getInt(String loopCountString) 
	{	
		int retrnValue=0;
		try
		{
			retrnValue = Integer.parseInt(loopCountString);
		} 
		catch (NumberFormatException e)
		{
			Log.d("Exception", e.toString());
		}
		return retrnValue;
	}

	private void initialize() 
	{
		pbSplash=(ProgressBar)findViewById(R.id.pbSplash);	
		
		
		loopCountString = getString(R.string.splashSliderLength) ;
		loopCount =	getInt(loopCountString);
	}

	@Override
	public void onStart() 
	{
		super.onStart();
		pbSplash.setProgress(0);
		isRunning=true;
		
		new Thread() 
		{
			public void run() 
			{
				try
				{
					for (int i = 1; i <= loopCount && isRunning; i++)
					{
						Thread.sleep(splashDuration/loopCount);
						splashHandler1.sendMessage(splashHandler.obtainMessage());
						
						if(i == loopCount)
						{
							splashHandler.sendEmptyMessage(0);//.sendEmptyMessageDelayed(0, 0);
						}
					}					
				}
				catch (Throwable t)
				{

				}
				//splashHandler.sendEmptyMessageDelayed(0, 0);
			}
		}.start();
	}
	
	private Handler splashHandler1=new Handler()
	{
		public void handleMessage(Message msg)
		{
			total=total+1;
			pbSplash.incrementProgressBy(1);
		};
	};

	private Handler splashHandler = new Handler() 
	{
		@SuppressLint("ParserError")
		@Override
		public void handleMessage(Message msg) 
		{		
			switch (msg.what) 
			{
			case 0:
				finish();
				if(Utility.isLoggedIn(getApplicationContext()))
				{
					//startActivity(new Intent(SplashActivity.this, HomeActivity.class));
					startActivity(new Intent(SplashActivity.this, LoginActivity.class));
				}
				else
				{
					startActivity(new Intent(SplashActivity.this, LoginActivity.class));
				}
				
				break;
			}
			super.handleMessage(msg);
		}
	};
}
