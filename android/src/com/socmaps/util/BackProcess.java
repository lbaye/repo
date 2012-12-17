package com.socmaps.util;

import java.util.ArrayList;

import org.apache.http.NameValuePair;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.socmaps.util.RestClient.RequestMethod;

public class BackProcess extends AsyncTask<RequestMethod, Void, String> {
	private Context context;

	private BackProcessCallback callback;
	private boolean showLoading;
	private ProgressDialog m_ProgressDialog;
	private String response;
	private int status;
	private RestClient restClient;
	private boolean isProgressDialogCancelable = true;

	public static enum REQUEST_TYPE {
		GET_SERVER_DATA, UPDATE, DELETE, SAVE, RENAME, ADD, MOVE
	}

	int requestType;
	String progressTitle = "";
	String progressMessage = "";

	// public BackProcess(Context context, ArrayList<NameValuePair> param,
	// String url, REQUEST_TYPE type, boolean isShowProgressBar,
	// BackProcessCallback callback) {
	// this.context = context;
	// this.callback = callback;
	// this.showLoading = isShowProgressBar;
	// requestType = type.ordinal();
	//
	// restClient = new RestClient(url);
	//
	// if (Utility.getAuthToken(context) != null) {
	// restClient.AddHeader(Constant.authTokenParam,
	// Utility.getAuthToken(context));
	// }
	//
	// restClient.AddParams(param);
	// }

	public BackProcess(Context context, ArrayList<NameValuePair> param,
			String url, REQUEST_TYPE type, boolean isShowProgressBar,
			String title, String message, BackProcessCallback callback,
			boolean isProgressDialogCancelable) {
		this.context = context;
		this.callback = callback;
		requestType = type.ordinal();

		this.showLoading = isShowProgressBar;
		this.progressTitle = title;
		this.progressMessage = message;
		this.isProgressDialogCancelable = isProgressDialogCancelable;

		restClient = new RestClient(url);

		if (Utility.getAuthToken(context) != null) {
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
		}

		restClient.AddParams(param);
	}

	@Override
	protected void onPreExecute() {
		// Debug.debug(getClass(), "onPreExecute");
		// if (showLoading) {
		// loadingDialog = new LoadingDialog(context,
		// android.R.style.Theme_Translucent_NoTitleBar);
		// loadingDialog.setCancelable(false);
		// try {
		// loadingDialog.show();
		// } catch (Exception e) {
		// Log.e("BackProcess", "error", e);
		// }
		// } else if (loadingView != null) {
		// loadingView.setVisibility(View.KEEP_SCREEN_ON);
		// }

		if (Utility.isConnectionAvailble(context.getApplicationContext())) {
			super.onPreExecute();
			showProgressDialog(progressTitle, progressMessage);
		} else {
			this.cancel(true);
			Log.i("onPreExecute", "cancel");
			DialogsAndToasts.showNoInternetConnectionDialog(context
					.getApplicationContext());
		}

	}

	@Override
	protected String doInBackground(RequestMethod... arg0) {
		// TODO Auto-generated method stub

		try {
			Log.i("doInBackground", "running");
			restClient.Execute(arg0[0]);
		} catch (Exception e) {
			e.printStackTrace();
		}

		response = restClient.getResponse();
		status = restClient.getResponseCode();

		return "";
	}

	@Override
	protected void onPostExecute(String result) {
		// TODO Auto-generated method stub
		super.onPostExecute(result);

		if (m_ProgressDialog != null) {
			m_ProgressDialog.dismiss();
		}

		callback.onFinish(status, response, requestType);

	}

	public void showProgressDialog(String title, String message) {

		if (showLoading) {

			m_ProgressDialog = ProgressDialog.show(context, title, message,
					true, isProgressDialogCancelable);
		}
	}

}
