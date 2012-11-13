package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.DialogInterface.OnDismissListener;
import android.graphics.Bitmap;
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
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.Utility;

public class PlaceEditSaveActivity extends Activity implements OnClickListener {
	private Context context;
	private Button btnBack, btnPlaceNameEdit, btnPlaceDisEdit,
			btnPlaceCategory, btnPlaceAddPhoto, btnPeopleDeletePhoto,
			btnPeopleDelete, btnPeopleCancel, btnPeopleUpdate;

	private TextView txtPlaceAddress;

	private Dialog msgDialog;

	private ImageView ivPlace, separatorDeleteCancel;
	private final static int REQUEST_CODE_CAMERA = 705;
	private final static int REQUEST_CODE_GALLERY = 707;
	private int requestCode;
	private Bitmap placeIcon;
	private boolean isHome;
	private ProgressDialog m_ProgressDialog;
	private String savePlacesResponse;
	private int savePlacesStatus;
	private static String placeName = "";
	private static String placeDiscription = "";
	private String categoryItem = "";
	private String strAddress = "";
	private String photoUrl = "";
	private Place place;

	private boolean isUpdate;
	private double lat = 0.0;
	private double lng = 0.0;

	private ImageDownloader il;
	private int catagoryPosition = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.place_edit_save_layout);

		initialize();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		updateUI();

	}

	public void initialize() {

		context = PlaceEditSaveActivity.this;

		il = new ImageDownloader();
		il.setMode(ImageDownloader.Mode.CORRECT);

		isHome = getIntent().getBooleanExtra("ISHOME", false);
		place = (Place) getIntent().getSerializableExtra("PLACE_OBJECT");

		txtPlaceAddress = (TextView) findViewById(R.id.txtPlaceAddress);

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
			if (place.getAddress() != null) {
				strAddress = place.getAddress();
			}

			lat = place.getLatitude();
			lng = place.getLongitude();

			if (place.getStreetViewImage() != null) {
				photoUrl = place.getStreetViewImage();
			}

			if (place.getCategory() != null && place.getCategory() != "") {
				catagoryPosition = getCategoryPosition(place.getCategory());
			}

			Log.i("Save Place Data PlaceEditSaveActivity>>>",
					"Name: " + place.getName() + " Phopt: "
							+ place.getStreetViewImage() + " Address:"
							+ place.getAddress() + " Category:"
							+ place.getCategory() + " lat:"
							+ place.getLatitude() + " Lon:"
							+ place.getLongitude());
		}

		txtPlaceAddress.setText(strAddress);

		if (photoUrl != null) {

			ivPlace.setImageResource(R.drawable.img_blank);
			il.download(photoUrl, ivPlace);
		} else {
			ivPlace.setImageResource(R.drawable.img_blank);
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
			// showPlaceNameDiscriptionEditDialog(context, false);

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

			isUpdate = false;

			updateOrDeletePlace();
			break;

		case R.id.btnPeopleCancel:
			finish();
			break;

		case R.id.btnPeopleUpdate:

			isUpdate = true;

			if (isHome) {
				savePlaceToServer();
			} else {
				updateOrDeletePlace();
			}
			break;

		default:
			break;
		}
	}

	/*
	 * Update and Delete an existing place
	 */
	private void updateOrDeletePlace() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, updatePlacesThread,
					"Start update place to server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable updatePlacesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smCreatePlaces
					+ "/" + place.getId());
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			try {

				if (isUpdate) {

					restClient.AddParam("title", placeName);
					restClient.AddParam("address", strAddress);
					restClient.AddParam("description", placeDiscription);
					restClient.AddParam("category", categoryItem);

					if (placeIcon != null) {

						String photoString = "";
						ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

						placeIcon.compress(Bitmap.CompressFormat.PNG, 60,
								full_stream);

						byte[] full_bytes = full_stream.toByteArray();
						photoString = Base64.encodeToString(full_bytes,
								Base64.DEFAULT);
						restClient.AddParam("photo", photoString);

					}

					restClient.Execute(RestClient.RequestMethod.PUT);

				} else {
					restClient.Execute(RestClient.RequestMethod.DELETE);
				}

			} catch (Exception e) {
				e.printStackTrace();
			}

			savePlacesResponse = restClient.getResponse();
			savePlacesStatus = restClient.getResponseCode();

			runOnUiThread(updatePlacesResponseFromServer);
		}
	};

	private Runnable updatePlacesResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseUpdatePlaces(savePlacesStatus, savePlacesResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseUpdatePlaces(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("Places Update response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Places update successful.",
					Toast.LENGTH_SHORT).show();

			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	/*
	 * Places create/save to server
	 */
	private void savePlaceToServer() {
		// TODO Auto-generated method stub
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			Thread thread = new Thread(null, savePlacesThread,
					"Start save place to server");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable savePlacesThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smCreatePlaces);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			Log.w("PlaceEditSaveActivity Save a new Place", "title:"
					+ placeName + " lat:" + lat + " long:" + lng);

			restClient.AddParam("title", placeName);
			restClient.AddParam("lat", lat + "");
			restClient.AddParam("lng", lng + "");
			restClient.AddParam("description", placeDiscription);
			restClient.AddParam("category", categoryItem);
			restClient.AddParam("address", strAddress);

			if (placeIcon != null) {

				String photoString = "";
				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				placeIcon.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				photoString = Base64.encodeToString(full_bytes, Base64.DEFAULT);
				restClient.AddParam("photo", photoString);

			}

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			savePlacesResponse = restClient.getResponse();
			savePlacesStatus = restClient.getResponseCode();

			runOnUiThread(savePlacesResponseFromServer);
		}
	};

	private Runnable savePlacesResponseFromServer = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponsesavePlaces(savePlacesStatus, savePlacesResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponsesavePlaces(int status, String response) {
		// show proper message through Toast or Dialog
		Log.w("Places saved response from server", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Places saved successful.",
					Toast.LENGTH_SHORT).show();

			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

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
					requestCode = PlaceEditSaveActivity.REQUEST_CODE_GALLERY;
				} else {
					requestCode = PlaceEditSaveActivity.REQUEST_CODE_CAMERA;
				}
				onOptionItemSelected(requestCode);
			}

		});
		AlertDialog alert = builder.create();
		alert.show();
	}

	public boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case PlaceEditSaveActivity.REQUEST_CODE_GALLERY:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(
					Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case PlaceEditSaveActivity.REQUEST_CODE_CAMERA:
			Intent cameraIntent = new Intent(
					android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(cameraIntent, requestCode);
			break;
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == PlaceEditSaveActivity.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {

				if (placeIcon != null) {
					placeIcon.recycle();
				}

				// avatar = (Bitmap) data.getExtras().get("data");
				placeIcon = Utility
						.resizeBitmap((Bitmap) data.getExtras().get("data"),
								Constant.profileCoverWidth,
								Constant.profileCoverHeight);

				ivPlace.setImageBitmap(placeIcon);

			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == PlaceEditSaveActivity.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {
				// imageUri = data.getData();
				try {

					// avatar =
					// MediaStore.Images.Media.getBitmap(this.getContentResolver(),
					// data.getData());
					if (placeIcon != null) {
						placeIcon.recycle();
					}
					placeIcon = Utility.resizeBitmap(
							MediaStore.Images.Media.getBitmap(
									this.getContentResolver(), data.getData()),
							Constant.profileCoverWidth,
							Constant.profileCoverHeight);
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
				// ivProfilePicture.setImageURI(imageUri);
			}
		}
	}

	private void deletePhotp() {
		// TODO Auto-generated method stub
		ivPlace.setImageBitmap(null);
	}

	/*
	 * 
	 */

	// TODO Auto-generated method stub
	public void showTextInputDialog(final int id, final String text, String hint) {

		Log.w("showTextInputDialog into", "id: " + id + " text:" + text);

		// custom dialog
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

		if (hint != null) {
			etInputText.setHint(hint);
		}

		if (text != null && !text.trim().equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		// TextView tvTitle = (TextView) dialog.findViewById(R.id.tvTitle);

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

				if (!inputText.equalsIgnoreCase("")) {

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

			}
		});

		dialog.show();
	}

	// private void showPlaceNameDiscriptionEditDialog(Context context,
	// final boolean isName) {
	// // TODO Auto-generated method stub
	// msgDialog = DialogsAndToasts.showSendMessage(context);
	//
	// final TextView title = (TextView) msgDialog
	// .findViewById(R.id.dialogTitale);
	//
	// title.setVisibility(View.INVISIBLE);
	//
	// final EditText msgEditText = (EditText) msgDialog
	// .findViewById(R.id.message_body_text);
	//
	// if (isName) {
	//
	// msgEditText.setHint(placeName);
	//
	// } else {
	// msgEditText.setHint(placeDiscription);
	//
	// }
	//
	// Button send = (Button) msgDialog.findViewById(R.id.btnSend);
	// Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);
	// send.setOnClickListener(new OnClickListener() {
	//
	// @Override
	// public void onClick(View arg0) {
	// // TODO Auto-generated method stub
	//
	// String inputStr = msgEditText.getText().toString().trim();
	//
	// if (isName) {
	// if (!inputStr.equals("")) {
	// placeName = inputStr;
	// }
	// } else {
	// if (!inputStr.equals("")) {
	// placeDiscription = inputStr;
	// }
	//
	// }
	//
	// msgDialog.dismiss();
	//
	// // if (!msgEditText.getText().toString().trim().equals("")) {
	// //
	// // // Do something here
	// //
	// // } else {
	// // msgEditText.setError("Please enter your message!!");
	// // }
	//
	// hideMessageDialogKeybord(msgEditText);
	// }
	// });
	// cancel.setOnClickListener(new OnClickListener() {
	//
	// @Override
	// public void onClick(View v) {
	// // TODO Auto-generated method stub
	//
	// hideMessageDialogKeybord(msgEditText);
	// msgDialog.dismiss();
	//
	// }
	// });
	// msgDialog.show();
	// }

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

						Toast.makeText(getApplicationContext(), categoryItem,
								Toast.LENGTH_SHORT).show();
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
