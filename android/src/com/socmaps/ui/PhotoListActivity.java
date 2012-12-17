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
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.People;
import com.socmaps.entity.Photo;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.Utility;
import com.socmaps.widget.PhotoZoomDialogPicker;

public class PhotoListActivity extends Activity implements OnClickListener {

	private Context context;
	private Button btnSearch, btnNotification, btnBack, btnUploadNewPhoto,
			btnDeletePhotos, btnMyPhotos;

	private ImageView ivSeperator;
	private TextView tvPhotos;

	ProgressDialog mProgressDialog;

	private LinearLayout listContainer;
	private List<Photo> photoList;
	LinearLayout buttonContainerBottom, buttonContainerTop;
	private LayoutInflater inflater;

	HashMap<String, Boolean> selectedPhoto;

	String responseString = "";
	int responseStatus = 0;

	ImageDownloader imageDownloader;
	String userID = null;
	private People people;

	static boolean isUploadNewPhoto = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.photo_list_layout);

		Object obj = getIntent().getSerializableExtra("user");
		if (obj != null) {
			people = (People) (obj);
			obj = null;
			userID = people.getId();
			Log.d("CHECK VALUE", "ID: " + people.getId() + "~" + userID);
		}

		initialize();

		getPhotos();

		Log.d("onCreate", "PhotoListActivity");

	}

	@Override
	protected void onResume() {
		super.onResume();

		// Log.d("onResume PhotoListActivity",
		// getIntent().getIntExtra("IS_UPLOAD_NEW_PHOTO", 0) + " ");

		Utility.updateNotificationBubbleCounter(btnNotification);

		if (isUploadNewPhoto) {

			getPhotos();
			Log.d("PhotoListActivity onResume", "get New Photo ");
		}

		Log.d("onResume", "PhotoListActivity");

	}

	private void initialize() {

		context = PhotoListActivity.this;

		isUploadNewPhoto = false;

		btnSearch = (Button) findViewById(R.id.btnSearch);
		btnSearch.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnMyPhotos = (Button) findViewById(R.id.btnMyPhotos);

		btnUploadNewPhoto = (Button) findViewById(R.id.btnUploadNewPhoto);
		btnUploadNewPhoto.setOnClickListener(this);

		btnDeletePhotos = (Button) findViewById(R.id.btnDeletePhotos);
		btnDeletePhotos.setOnClickListener(this);

		ivSeperator = (ImageView) findViewById(R.id.ivSeparator);
		tvPhotos = (TextView) findViewById(R.id.tvPhotos);

		listContainer = (LinearLayout) findViewById(R.id.listContainer);
		buttonContainerTop = (LinearLayout) findViewById(R.id.buttonContainerTop);
		buttonContainerBottom = (LinearLayout) findViewById(R.id.buttonContainerBottom);
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		selectedPhoto = new HashMap<String, Boolean>();

		// imageDownloader = new ImageDownloader();
		// imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
		imageDownloader = ImageDownloader.getInstance();

		if (userID != null) {
			btnUploadNewPhoto.setVisibility(View.GONE);
			btnDeletePhotos.setVisibility(View.GONE);
			ivSeperator.setVisibility(View.GONE);
			buttonContainerTop.setGravity(Gravity.LEFT);
			btnMyPhotos.setText(people.getFirstName() + "'s" + " " + "photos");
		}

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnBack) {
			finish();
		} else if (v == btnUploadNewPhoto) {

			Intent uploadPhotoIntent = new Intent(context,
					PhotoUploadNewPhotoActivity.class);
			startActivity(uploadPhotoIntent);
			// finish();

		} else if (v == btnDeletePhotos) {
			initiateDeletePhotos();
		}
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

	private View getItemView(final Photo photo) {

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

				if (userID != null) {

				} else {
					if (selectedPhoto.get(id)) {
						photoContainer
								.setBackgroundResource(R.color.transparent);
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

			}
		});

		btnZoom.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				PhotoZoomDialogPicker photoZoomPicker = new PhotoZoomDialogPicker(
						context, "CIRCLE LIST", photoList, imageDownloader,
						photoList.indexOf(photo));
				photoZoomPicker.getWindow().setLayout(LayoutParams.FILL_PARENT,
						LayoutParams.FILL_PARENT);
				photoZoomPicker.show();

				// String[] URLS = new String[photoList.size()];
				//
				// for (int i = 0; i < photoList.size(); i++) {
				// URLS[i] = photoList.get(i).getImageLarge();
				//
				// }
				//
				// Intent zoomIntent = new Intent(context,
				// PhotoZoomActivity.class);
				// zoomIntent.putExtra("PHOTO_ZOOM_POSITION",
				// photoList.indexOf(photo));
				// zoomIntent.putExtra("PHOTO_URLS", URLS);
				// startActivity(zoomIntent);

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

	private void getPhotos() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, getList, "MagentoBackground");
			thread.start();
			mProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.photos),
					getResources().getString(R.string.fetching_data_text),
					true, true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable getList = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub

			RestClient restClient;
			if (userID == null) {
				restClient = new RestClient(Constant.smPhotoUrl);
			} else {
				restClient = new RestClient(Constant.smServerUrl + "/photos"
						+ "/users" + "/" + userID);
			}

			// RestClient restClient = new RestClient(Constant.smPhotoUrl);
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

			if (mProgressDialog != null) {
				mProgressDialog.dismiss();
			}

			handleGetPhotosResponse(responseStatus, responseString);

		}

	};

	private void handleGetPhotosResponse(int status, String response) {
		Log.d("Photos", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:

			photoList = ServerResponseParser.parsePhotos(response);
			// generate list

			if (photoList != null) {
				generateView();
			}
			break;

		case Constant.STATUS_SUCCESS_NODATA:
			Toast.makeText(context, "No photo found.", Toast.LENGTH_SHORT)
					.show();
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
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
		isUploadNewPhoto = false;
		Log.w("onPause()", "PhotoListActivity");
	}

	private void initiateDeletePhotos() {
		if (Utility.isConnectionAvailble(context)) {
			Thread thread = new Thread(null, deletePhotos, "MagentoBackground");
			thread.start();
			mProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.deletePhotoLabel), getResources()
					.getString(R.string.please_wait_text), true, true);
		} else
			DialogsAndToasts.showNoInternetConnectionDialog(context);
	}

	private Runnable deletePhotos = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smPhotoUrl
					+ "/deletephotos");
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			for (Map.Entry<String, Boolean> entry : selectedPhoto.entrySet()) {
				String key = entry.getKey();
				boolean value = entry.getValue();
				if (value) {
					restClient.AddParam("photoIds[]", key);
				}
			}

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
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

			if (mProgressDialog != null) {
				mProgressDialog.dismiss();
			}
			handleDeletePhotosResponse(responseStatus, responseString);

		}

	};

	private void handleDeletePhotosResponse(int status, String response) {
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

			Toast.makeText(getApplicationContext(),
					"Photo deleted successfully.", Toast.LENGTH_LONG).show();
			generateView();

			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.getJSONStringFromServerResponse(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;

		}
	}

}
