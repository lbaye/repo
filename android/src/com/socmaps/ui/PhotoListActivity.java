package com.socmaps.ui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.socmaps.entity.Photo;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;

public class PhotoListActivity extends Activity implements OnClickListener {

	private Context context;
	private Button btnSearch, btnNotification, btnBack, btnUploadNewPhoto,
			btnDeletePhotos;

	ProgressDialog mProgressDialog;

	private LinearLayout listContainer;
	private List<Photo> photoList;
	LinearLayout buttonContainerBottom;
	private LayoutInflater inflater;

	HashMap<String, Boolean> selectedPhoto;

	String responseString = "";
	int responseStatus = 0;

	ImageDownloader imageDownloader;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.photo_list_layout);
		initialize();

	}

	private void initialize() {

		context = PhotoListActivity.this;

		btnSearch = (Button) findViewById(R.id.btnSearch);
		btnSearch.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnUploadNewPhoto = (Button) findViewById(R.id.btnUploadNewPhoto);
		btnUploadNewPhoto.setOnClickListener(this);

		btnDeletePhotos = (Button) findViewById(R.id.btnDeletePhotos);
		btnDeletePhotos.setOnClickListener(this);

		listContainer = (LinearLayout) findViewById(R.id.listContainer);
		buttonContainerBottom = (LinearLayout) findViewById(R.id.buttonContainerBottom);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		selectedPhoto = new HashMap<String, Boolean>();

		imageDownloader = new ImageDownloader();
		imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
	}

	private void generateView() {

		listContainer.removeAllViews();
		selectedPhoto.clear();
		
		buttonContainerBottom.setVisibility(View.GONE);

		if (photoList.size() > 0) {

			LinearLayout itemRow = getAFreshRow();

			int counter = 0;
			for (int i = 0; i < photoList.size(); i++) {

				if (counter % 4 == 0 && i > 0) {
					addAlreadyCreatedRow(itemRow);
					counter = 0;
					itemRow = getAFreshRow();
				}

				selectedPhoto.put(photoList.get(i).getId(), false);

				itemRow.addView(getItemView(photoList.get(i)));
				counter++;

			}
			addAlreadyCreatedRow(itemRow);
		}
	}

	public View getItemView(Photo photo) {

		View v = inflater.inflate(R.layout.photo_item, null);

		final ImageView ivPhoto = (ImageView) v.findViewById(R.id.ivPhoto);
		final Button btnZoom = (Button) v.findViewById(R.id.btnZoom);

		final LinearLayout photoContainer = (LinearLayout) v
				.findViewById(R.id.photoContainer);

		Display display = getWindowManager().getDefaultDisplay();

		int width = display.getWidth();

		v.setLayoutParams(new LinearLayout.LayoutParams(width / 4,
				LayoutParams.WRAP_CONTENT));

		final String id = photo.getId();

		if (photo.getImageThumb() != null && photo.getImageThumb() != "") {
			imageDownloader.download(photo.getImageThumb(), ivPhoto);
		}

		ivPhoto.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (selectedPhoto.get(id)) {
					photoContainer.setBackgroundResource(R.color.transparent);
					selectedPhoto.put(id, false);
				} else {
					photoContainer
							.setBackgroundResource(R.color.highlightGreen);
					selectedPhoto.put(id, true);
				}

				if (getSelectedPhotoNumber() > 0) {
					buttonContainerBottom.setVisibility(View.VISIBLE);
				} else {
					buttonContainerBottom.setVisibility(View.GONE);
				}

			}
		});

		btnZoom.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

			}
		});

		return v;
	}

	private LinearLayout getAFreshRow() {

		LinearLayout row = (LinearLayout) inflater.inflate(
				R.layout.photo_list_row, null);

		return row;
	}

	private void addAlreadyCreatedRow(LinearLayout row) {
		if (row.getChildCount() > 0)
			listContainer.addView(row);

	}

	private int getSelectedPhotoNumber() {
		int counter = 0;

		for (Map.Entry<String, Boolean> entry : selectedPhoto.entrySet()) {
			String key = entry.getKey();
			boolean value = entry.getValue();
			if (value) {
				counter++;
			}
		}

		return counter;
	}

	public void getPhotos() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, getList, "MagentoBackground");
			thread.start();
			mProgressDialog = ProgressDialog
					.show(this,
							getResources().getString(R.string.photos),
							getResources().getString(
									R.string.fetching_data_text), true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable getList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smPhotoUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();

			responseStatus = restClient.getResponseCode();

			runOnUiThread(returnResGetPhotos);
		}
	};

	private Runnable returnResGetPhotos = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			mProgressDialog.dismiss();
			handleGetPhotosResponse(responseStatus, responseString);

		}

	};

	public void handleGetPhotosResponse(int status, String response) {
		Log.d("Photos", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			photoList = ServerResponseParser.parsePhotos(response);
			// generate list

			if (photoList != null) {
				generateView();
			}

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	protected void onResume() {
		super.onResume();

		getPhotos();

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnBack) {
			finish();
		} else if (v == btnUploadNewPhoto) {
			
			Intent uploadPhotoIntent=new Intent(context,PhotoUploadNewPhotoActivity.class);
			startActivity(uploadPhotoIntent);
			finish();

		} else if (v == btnDeletePhotos) {
			initiateDeletePhotos();
		}
	}

	public void initiateDeletePhotos() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, deletePhotos, "MagentoBackground");
			thread.start();
			mProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.deletePhotoLabel), getResources()
					.getString(R.string.please_wait_text), true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable deletePhotos = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smPhotoUrl+"/me");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			for (Map.Entry<String, Boolean> entry : selectedPhoto.entrySet()) {
				String key = entry.getKey();
				boolean value = entry.getValue();
				if (value) {
					restClient.AddParam("id[]", key);
				}
			}

			try {
				restClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();

			responseStatus = restClient.getResponseCode();

			runOnUiThread(returnResDeletePhotos);

		}
	};

	private Runnable returnResDeletePhotos = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			mProgressDialog.dismiss();
			handleDeletePhotosResponse(responseStatus, responseString);

		}

	};

	public void handleDeletePhotosResponse(int status, String response) {
		Log.d("Photos", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			
			
			List<Photo> tempPhotoList = new ArrayList<Photo>();
			
			for (Photo photo : photoList) {
				if (!selectedPhoto.get(photo.getId())) {
					tempPhotoList.add(photo);
				}
			}
			
			photoList.clear();
			photoList = tempPhotoList;

			generateView();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

}
