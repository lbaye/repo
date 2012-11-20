package com.socmaps.ui;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ProgressBar;

import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;

public class NewsFeedActivity extends Activity implements OnClickListener {

	private WebView webViewNewsFeed;
	private ProgressBar progressBar;
	private Button btnBack;

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
	}

	private void initUI() {
		// TODO Auto-generated method stub

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

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

		// Our application's main page will be loaded
		// http://ec2-46-51-157-204.eu-west-1.compute.amazonaws.com/prodtest/me/newsfeed.html?authToken=51a610291d73b70b022deaefd7f53e3aa4d746f7
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
			Log.d("web status", "onPageFinished");

			webViewNewsFeed
					.loadUrl("javascript:window.HTMLOUT.showHTML('<head>'+document.getElementsByTagName('html')[0].innerHTML+'</head>');");

		}

		@Override
		public void onPageStarted(final WebView view, final String url,
				final Bitmap favicon) {
			Log.d("web status", "onPageStarted");

		}

		@Override
		public boolean shouldOverrideUrlLoading(final WebView view,
				final String url) {

			// Log.d("clicked data is ", url);
			//
			// final Intent intent = new Intent(Intent.ACTION_VIEW,
			// Uri.parse(url));
			// startActivity(intent);

			view.loadUrl(url);
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
		}

	}

}
