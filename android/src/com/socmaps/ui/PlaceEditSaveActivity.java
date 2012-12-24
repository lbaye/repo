package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.Utility;

/**
 * PlaceEditSaveActivity class is used to update or delete a particular saved place. 
 * If the update operation is performed, then the updated info is sent to the server. 
 * Delete operation will remove the place from the list & update the list.
 */

public class PlaceEditSaveActivity extends Activity implements OnClickListener {
	private Context context;
	private Button btnBack, btnPlaceNameEdit, btnPlaceDisEdit,
			btnPlaceCategory, btnPlaceAddPhoto, btnPeopleDeletePhoto,
			btnPeopleDelete, btnPeopleCancel, btnPeopleUpdate;

	private TextView txtPlaceAddress, titlePlaceEditSave;
	private ImageView ivPlace, separatorDeleteCancel;
	private int requestCode;
	private Bitmap placeIcon;
	private boolean isHome;

	private String placeName = "";
	private String placeDiscription = "";
	private String categoryItem = "";
	private String strAddress;
	private String photoUrl;
	private Place place;

	private double lat = 0.0;
	private double lng = 0.0;

	private ImageDownloader imageDownloader;
	private int catagoryPosition = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.place_edit_save_layout);

		initialize();

		updateUI();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

	}

	private void initialize() {

		context = PlaceEditSaveActivity.this;
		imageDownloader = ImageDownloader.getInstance();

		isHome = getIntent().getBooleanExtra("ISHOME", false);
		place = (Place) getIntent().getSerializableExtra("PLACE_OBJECT");

		txtPlaceAddress = (TextView) findViewById(R.id.txtPlaceAddress);
		titlePlaceEditSave = (TextView) findViewById(R.id.titlePlaceEditSave);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnPlaceNameEdit = (Button) findViewById(R.id.btnPlaceNameEdit);
		btnPlaceNameEdit.setOnClickListener(this);

		btnPlaceDisEdit = (Button) findViewById(R.id.btnPlaceDisEdit);
		btnPlaceDisEdit.setOnClickListener(this);

		btnPlaceCategory = (Button) findViewById(R.id.btnPlaceCategory);
		btnPlaceCategory.setOnClickListener(this);

		btnPlaceAddPhoto = (Button) findViewById(R.id.btnPlaceAddPhoto);
		btnPlaceAddPhoto.setOnClickListener(this);

		btnPeopleDeletePhoto = (Button) findViewById(R.id.btnPeopleDeletePhoto);
		btnPeopleDeletePhoto.setOnClickListener(this);

		btnPeopleDelete = (Button) findViewById(R.id.btnPeopleDelete);
		btnPeopleDelete.setOnClickListener(this);

		btnPeopleCancel = (Button) findViewById(R.id.btnPeopleCancel);
		btnPeopleCancel.setOnClickListener(this);

		btnPeopleUpdate = (Button) findViewById(R.id.btnPeopleUpdate);
		btnPeopleUpdate.setOnClickListener(this);

		ivPlace = (ImageView) findViewById(R.id.ivPlace);
		separatorDeleteCancel = (ImageView) findViewById(R.id.ivSeparatorDeleteCancel);

		if (isHome) {

			btnPeopleDelete.setVisibility(View.GONE);
			separatorDeleteCancel.setVisibility(View.GONE);

			btnPeopleUpdate.setText(getString(R.string.saveLabel));
			titlePlaceEditSave.setText(getString(R.string.savePlaceLabel));
		}

	}

	private void updateUI() {
		// TODO Auto-generated method stub
		if (place != null) {

			if (place.getName() != null) {
				placeName = place.getName();
			}
			if (place.getDescription() != null) {
				placeDiscription = place.getDescription();
			}

			if (place.getCategory() != null) {
				categoryItem = place.getCategory();
			}
			if (place.getCategory() != null && place.getCategory() != "") {
				catagoryPosition = getCategoryPosition(place.getCategory());
			}

			if (place.getVicinity() != null) {
				strAddress = place.getVicinity();
				txtPlaceAddress.setText(strAddress);
			}

			lat = place.getLatitude();
			lng = place.getLongitude();

			if (place.getStreetViewImage() != null
					&& !place.getStreetViewImage().equals("")) {
				photoUrl = place.getStreetViewImage();
				ivPlace.setImageResource(R.drawable.img_blank);
				imageDownloader.download(photoUrl, ivPlace);
				placeIcon = getBitmapFromURL(place.getStreetViewImage());
			}

		}

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {

		case R.id.btnBack:
			finish();
			break;

		case R.id.btnPlaceNameEdit:

			showTextInputDialog(R.id.btnPlaceNameEdit, placeName,
					place.getName());
			break;

		case R.id.btnPlaceDisEdit:
			showTextInputDialog(R.id.btnPlaceDisEdit, placeDiscription,
					place.getDescription());
			break;

		case R.id.btnPlaceCategory:
			selectCategory();
			break;

		case R.id.btnPlaceAddPhoto:

			uploadIconFromGalaryOrCamara();
			break;

		case R.id.btnPeopleDeletePhoto:

			deletePhotp();

			break;

		case R.id.btnPeopleDelete:
			deleteConfirmDialog();

			break;

		case R.id.btnPeopleCancel:
			finish();
			break;

		case R.id.btnPeopleUpdate:
			if (isHome) {
				savePlace();

			} else {

				updatePlace();
			}
			break;

		default:
			break;
		}
	}

	private Bitmap getBitmapFromURL(String src) {
		try {
			URL url = new URL(src);
			HttpURLConnection connection = (HttpURLConnection) url
					.openConnection();
			connection.setDoInput(true);
			connection.connect();
			InputStream input = connection.getInputStream();
			Bitmap myBitmap = BitmapFactory.decodeStream(input);
			return myBitmap;
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		} catch (Exception e) {

			e.printStackTrace();
			return null;
		}
	}

	// Save a new place
	private void savePlace() {
		String url = Constant.smCreatePlaces;

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("title", placeName));
		params.add(new BasicNameValuePair("lat", lat + ""));
		params.add(new BasicNameValuePair("lng", lng + ""));
		params.add(new BasicNameValuePair("description", placeDiscription));
		params.add(new BasicNameValuePair("category", categoryItem));
		params.add(new BasicNameValuePair("address", strAddress));

		if (placeIcon != null) {

			String photoString = "";
			ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

			placeIcon.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

			byte[] full_bytes = full_stream.toByteArray();
			photoString = Base64.encodeToString(full_bytes, Base64.DEFAULT);
			params.add(new BasicNameValuePair("photo", photoString));

		}

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.SAVE, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.POST);

	}

	// Update an existing place
	private void updatePlace() {

		if (!placeName.trim().equals("") && placeName != null) {

			String url = Constant.smCreatePlaces + "/" + place.getId();

			ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

			params.add(new BasicNameValuePair("title", placeName));
			params.add(new BasicNameValuePair("address", strAddress));
			params.add(new BasicNameValuePair("description", placeDiscription));
			params.add(new BasicNameValuePair("category", categoryItem));

			if (placeIcon != null) {

				String photoString = "";
				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				placeIcon.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				photoString = Base64.encodeToString(full_bytes, Base64.DEFAULT);
				params.add(new BasicNameValuePair("photo", photoString));

			}

			BackProcess backProcess = new BackProcess(context, params, url,
					REQUEST_TYPE.UPDATE, true, getResources().getString(
							R.string.please_wait_text), getResources()
							.getString(R.string.sending_request_text),
					new BackProcessCallBackListener(), true);

			backProcess.execute(RestClient.RequestMethod.PUT);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}

	}

	// Delete an existing place
	private void deletePlace() {

		String url = Constant.smCreatePlaces + "/" + place.getId();

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.DELETE, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.DELETE);
	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String result, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :",
					status + ":" + result);
			switch (status) {
			case Constant.STATUS_SUCCESS:

				if (type == REQUEST_TYPE.DELETE.ordinal()) {
					Toast.makeText(context, "Place deleted successfully.",
							Toast.LENGTH_SHORT).show();

				} else if (type == REQUEST_TYPE.UPDATE.ordinal()) {
					Toast.makeText(context, "Place updated successfully.",
							Toast.LENGTH_SHORT).show();

				}

				finish();
				break;
			case Constant.STATUS_SUCCESS_NODATA:
				Toast.makeText(getApplicationContext(), "No place found.",
						Toast.LENGTH_SHORT).show();
				break;

			case Constant.STATUS_CREATED:
				Toast.makeText(context, "Place saved successfully.",
						Toast.LENGTH_SHORT).show();

				finish();

				break;
			default:
				Toast.makeText(getApplicationContext(),
						"An unknown error occured. Please try again!!",
						Toast.LENGTH_SHORT).show();

				finish();
				break;

			}

		}

	}

	/*
	 * Place picture from gallery or camera
	 */
	private void uploadIconFromGalaryOrCamara() {
		// TODO Auto-generated method stub
		final CharSequence[] items = { "Gallery", "Camera" };
		AlertDialog.Builder builder = new AlertDialog.Builder(
				PlaceEditSaveActivity.this);
		builder.setTitle("Select");
		builder.setItems(items, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int item) {
				Toast.makeText(getApplicationContext(), items[item],
						Toast.LENGTH_SHORT).show();
				if (items[item].equals("Gallery")) {
					requestCode = Constant.REQUEST_CODE_GALLERY;
				} else {
					requestCode = Constant.REQUEST_CODE_CAMERA;
				}
				onOptionItemSelected(requestCode);
			}

		});
		AlertDialog alert = builder.create();
		alert.show();
	}

	private boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case Constant.REQUEST_CODE_GALLERY:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(
					Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case Constant.REQUEST_CODE_CAMERA:
			Intent cameraIntent = new Intent(
					android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(cameraIntent, requestCode);
			break;
		}
		return true;
	}

	private void deleteConfirmDialog() {
		// TODO Auto-generated method stub
		AlertDialog.Builder deleteDialog = new AlertDialog.Builder(context);
		deleteDialog.setMessage("Are you sure to delete this place");
		deleteDialog.setPositiveButton("Yes",
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int id) {

						deletePlace();

						dialog.cancel();
					}
				});

		deleteDialog.setNegativeButton("No",
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int id) {

						dialog.cancel();
					}
				});

		AlertDialog alert = deleteDialog.create();

		alert.show();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == Constant.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {

				if (placeIcon != null) {

				}

				placeIcon = Utility.resizeBitmap(
						(Bitmap) data.getExtras().get("data"),
						Constant.profileCoverWidth, 0, true);

				ivPlace.setImageBitmap(placeIcon);

			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == Constant.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {

				try {

					if (placeIcon != null) {

					}
					placeIcon = Utility.resizeBitmap(
							MediaStore.Images.Media.getBitmap(
									this.getContentResolver(), data.getData()),
							Constant.profileCoverWidth, 0, true);
					ivPlace.setImageBitmap(placeIcon);

				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (OutOfMemoryError e) {

					Log.e("Gallery image", "OutOfMemoryError");
					Toast.makeText(context,
							getString(R.string.errorMessageGallery),
							Toast.LENGTH_SHORT).show();
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}

			}
		}
	}

	private void deletePhotp() {
		// TODO Auto-generated method stub
		ivPlace.setImageBitmap(null);
	}

	// TODO Auto-generated method stub
	private void showTextInputDialog(final int id, final String text,
			String hint) {

		Log.w("showTextInputDialog into", "id: " + id + " text:" + text);

		final Dialog dialog = new Dialog(context, R.style.CustomDialogTheme);
		dialog.setContentView(R.layout.input_text_dialog_layout);

		dialog.setOnDismissListener(new OnDismissListener() {

			@Override
			public void onDismiss(DialogInterface dialog) {
				// TODO Auto-generated method stub
				Utility.hideKeyboard(PlaceEditSaveActivity.this);
			}
		});

		final EditText etInputText = (EditText) dialog
				.findViewById(R.id.etInputText);

		if (text != null && !text.trim().equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		Button btnCancel = (Button) dialog.findViewById(R.id.btnCancel);
		// if button is clicked, close the custom dialog
		btnCancel.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				dialog.dismiss();

			}
		});

		Button btnOk = (Button) dialog.findViewById(R.id.btnOk);
		// if button is clicked, close the custom dialog
		btnOk.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				String inputText = etInputText.getText().toString().trim();

				Log.w("showTextInputDialog into", "btnOk: " + inputText);

				switch (id) {

				case R.id.btnPlaceNameEdit:
					placeName = inputText;
					break;

				case R.id.btnPlaceDisEdit:
					placeDiscription = inputText;
					break;

				default:
					break;
				}

				dialog.dismiss();

			}
		});

		dialog.show();
	}

	private void selectCategory() {
		AlertDialog dialog;

		final String categoryArray[] = getResources().getStringArray(
				R.array.geoTagListOption);

		AlertDialog.Builder builder = new AlertDialog.Builder(this);

		builder.setSingleChoiceItems(categoryArray, catagoryPosition,
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int position) {

						categoryItem = categoryArray[position].trim()
								.toLowerCase().replace(" ", "_");
						catagoryPosition = position;

						dialog.dismiss();
					}

				});

		dialog = builder.create();
		dialog.show();
	}

	private int getCategoryPosition(String category) {
		// TODO Auto-generated method stub

		int position = 0;

		final String categoryArray[] = getResources().getStringArray(
				R.array.geoTagListOption);

		for (int i = 0; i < categoryArray.length; i++) {

			if (category.trim().replace("_", " ")
					.equalsIgnoreCase(categoryArray[i].toLowerCase().trim())) {

				position = i;

			}
		}

		return position;
	}

	protected void hideMessageDialogKeybord(EditText msgEditText) {
		// TODO Auto-generated method stub

		InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(msgEditText.getWindowToken(), 0);

	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStart();
		if (placeIcon != null) {
			placeIcon.recycle();
		}
		System.gc();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
	}

}
