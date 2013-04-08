package com.socmaps.util;

import java.util.ArrayList;

import org.apache.http.NameValuePair;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.socmaps.util.RestClient.RequestMethod;

/**
 * BackProcess class for generating a server request as a separate thread.
 *
 */
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
		GET_SERVER_DATA, UPDATE, DELETE, SAVE, RENAME, ADD, MOVE, REPORT
	}

	int requestType;
	String progressTitle = "";
	String progressMessage = "";

	

	/**
	 * Initiates a server request as a separate thread.
	 * 
	 * @param context Current active Context.
	 * @param param ArrayList of NameValuePair for the request
	 * @param url Server URL for the request
	 * @param type Type of the request
	 * @param isShowProgressBar true if ProgressDialog needed, false otherwise.
	 * @param title Title text of the ProgressDialog
	 * @param message Message text of the ProgressDialog
	 * @param callback Listener to fire appropriate event after end of the request
	 * @param isProgressDialogCancelable true if the ProgressDialog is cancellable during middle of the process, false otherwise
	 */
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

	private void showProgressDialog(String title, String message) {

		if (showLoading) {

			m_ProgressDialog = ProgressDialog.show(context, title, message,
					true, isProgressDialogCancelable);
		}
	}

}
