package com.socmaps.ui;

import java.util.ArrayList;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Toast;
import com.socmaps.entity.People;
import com.socmaps.images.ImageFetcher;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.widget.NewsFeedPhotoZoomDialogPicker;

/**
 * NewsFeedActivity is used to show the activities of a particular user(user
 * himself or other user).
 */

public class NewsFeedActivity extends FragmentActivity implements OnClickListener {

	private Context context;
	private WebView webViewNewsFeed;
	private ProgressBar progressBar;
	private Button btnBack, btnNotification;

	private ImageFetcher imageFetcher;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.newsfeed_layout);

		initUI();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		Utility.updateNotificationBubbleCounter(btnNotification);

		imageFetcher.setExitTasksEarly(false);
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();

		imageFetcher.setExitTasksEarly(true);
		imageFetcher.flushCache();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();

		imageFetcher.closeCache();
	}

	private void initUI() {
		// TODO Auto-generated method stub
		context = this;

		imageFetcher = new ImageFetcher(context);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		progressBar = (ProgressBar) findViewById(R.id.progressBar);
		webViewNewsFeed = (WebView) findViewById(R.id.webViewNewsFeed);

		webViewNewsFeed.setBackgroundColor(Color.parseColor("#00000000"));

		WebSettings webSettings = webViewNewsFeed.getSettings();
		webSettings.setJavaScriptEnabled(true);
		webSettings.setPluginsEnabled(false);
		webSettings.setJavaScriptCanOpenWindowsAutomatically(false);

		webSettings.setSupportMultipleWindows(false);

		webViewNewsFeed.getSettings().setSupportZoom(false);
		webViewNewsFeed.setVerticalScrollBarEnabled(true);
		webViewNewsFeed.setHorizontalScrollBarEnabled(false);
		webViewNewsFeed.getSettings().setBuiltInZoomControls(false);

		webViewNewsFeed.loadUrl(Constant.smServerUrl + "/me/network/newsfeed.html?authToken=" + StaticValues.myInfo.getAuthToken());

		webViewNewsFeed.setWebViewClient(new MyWebViewClient());

		webViewNewsFeed.setWebChromeClient(new WebChromeClient() {

			@Override
			public void onProgressChanged(WebView view, int progress) {

				progressBar.setVisibility(View.VISIBLE);

				if (progress == 100)
					progressBar.setVisibility(View.INVISIBLE);
			}

		});

	}

	private class MyWebViewClient extends WebViewClient {
		@Override
		public void onPageFinished(final WebView view, final String url) {

		}

		@Override
		public void onPageStarted(final WebView view, final String url, final Bitmap favicon) {

		}

		@Override
		public boolean shouldOverrideUrlLoading(final WebView view, final String url) {

			Log.i("URL URL URL ", url);

			String subURL = url.substring(6);
			if (subURL.startsWith("profile")) {
				String id = subURL.substring(8);
				Log.d("URL", id);
				if (id.equalsIgnoreCase(StaticValues.myInfo.getId())) {
					Intent intent = new Intent(context, ProfileActivity.class);
					startActivity(intent);
				} else {

					People p = new People();
					p.setId(id);

					Intent intent = new Intent(context, ProfileActivity2.class);

					intent.putExtra("otherUser", p);
					startActivity(intent);

				}
			} else if (subURL.startsWith("image")) {
				String imageURL = subURL.substring(6);
				Log.d("URL", imageURL);

				NewsFeedPhotoZoomDialogPicker photoZoomPicker = new NewsFeedPhotoZoomDialogPicker(context, imageURL, imageFetcher);
				photoZoomPicker.getWindow().setLayout(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
				photoZoomPicker.show();
			} else if (subURL.startsWith("geotag")) {
			} else if (subURL.startsWith("report")) {

				final String[] typeId = subURL.split(":");

				 if(typeId.length>2){
					 
					 

					 AlertDialog.Builder adb = new AlertDialog.Builder(context);
						adb.setTitle("Report");
						// adb.setIcon(R.drawable.icon_alert);
						adb.setMessage("Do you want to report this post?");
						adb.setPositiveButton("Report", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								// server call
								dialog.dismiss();
								reportToServer(typeId[1], typeId[2]);
								

							}
						});
						adb.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								dialog.dismiss();
							}
						});
						adb.show();

				 
				 }

				
			}

			return true;
		}

	}

	
	private void reportToServer(String type, String id) {

		String url = Constant.smServerUrl + "/report";

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("objectType", type));
		params.add(new BasicNameValuePair("objectId", id));

		BackProcess backProcess = new BackProcess(context, params, url, REQUEST_TYPE.REPORT, false, null, null, new BackProcessCallBackListener(), false);

		backProcess.execute(RestClient.RequestMethod.POST);
	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String result, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :", status + ":" + result);
			switch (status) {
			case Constant.STATUS_SUCCESS:

				Toast.makeText(getApplicationContext(), "Report sent successfully.", Toast.LENGTH_SHORT).show();
				break;

			default:
				Toast.makeText(getApplicationContext(), "An unknown error occured. Please try again!!", Toast.LENGTH_SHORT).show();

				break;

			}

		}

	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		if (v == btnBack) {

			finish();
		} else if (v == btnNotification) {
			Intent intent = new Intent(context, NotificationActivity.class);
			startActivity(intent);
		}

	}

}
