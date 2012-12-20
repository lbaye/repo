package com.socmaps.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
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

import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.NewsFeedPhotoZoomDialogPicker;

public class NewsFeedActivity extends Activity implements OnClickListener {

	private Context context;
	private WebView webViewNewsFeed;
	private ProgressBar progressBar;
	private Button btnBack, btnNotification;

	private ImageDownloader imageDownloader;

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
	}

	private void initUI() {
		// TODO Auto-generated method stub
		context = this;

		imageDownloader = ImageDownloader.getInstance();

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

		webViewNewsFeed.loadUrl(Constant.smServerUrl
				+ "/me/newsfeed.html?authToken="
				+ StaticValues.myInfo.getAuthToken());

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
		public void onPageStarted(final WebView view, final String url,
				final Bitmap favicon) {
			

		}

		@Override
		public boolean shouldOverrideUrlLoading(final WebView view,
				final String url) {

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

				NewsFeedPhotoZoomDialogPicker photoZoomPicker = new NewsFeedPhotoZoomDialogPicker(
						context, imageURL, imageDownloader);
				photoZoomPicker.getWindow().setLayout(LayoutParams.FILL_PARENT,
						LayoutParams.FILL_PARENT);
				photoZoomPicker.show();
			} else if (subURL.startsWith("geotag")) {			
			}

			return true;
		}

	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
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
