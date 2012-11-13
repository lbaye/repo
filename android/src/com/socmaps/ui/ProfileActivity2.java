package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.People;
import com.socmaps.entity.SearchResult;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class ProfileActivity2 extends Activity implements OnClickListener {
	Context context;

	Button btnBack, btnNotification;

	ImageView ivProfilePic, ivCoverPic, ivRegMedia;
	ImageView btnEditProfilePic, btnEditCoverPic, btnEditStatus,
			btnNavigateToMap, btnEvent;
	ImageView photos_icon_image, friends_icon_image, places_icon_image;

	/* Meet Up(Interest) ImageView : along side Photos, Friends, Places & Events */
	ImageView interest_icon_image;
	/* finish */

	TextView tvName, tvStatusMessage, tvAddress, tvTime, tvDistance, tvAge,
			tvCity, tvCompany, tvRelationshipStatus;

	LinearLayout age_layout, relationship_layout, living_in_layout,
			work_at_layout;

	int responseStatus = 0;
	String responseString = "";

	ImageLoader imageLoader;
	private String flag = ""; // UNIT or INFO
	private ProgressDialog m_ProgressDialog = null;
	public final static int REQUEST_CODE_CAMERA = 700;
	public final static int REQUEST_CODE_GALLERY = 701;
	int requestCode;
	Bitmap avatar;
	String dob = "";
	Calendar now = Calendar.getInstance();

	String strRelationshipStatus;

	public People people;

	String getAvater, getCoverPhoto, getRegMedia, getFirstName, getLastName,
			userName, getStatusMsg, getStreetAdd, getLastLog, getAge,
			getRelationshipStatus, getCity, getWorkInfo;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.other_user_profile);

		Object obj = getIntent().getSerializableExtra("otherUser");
		if (obj != null) {
			people = (People) (obj);
			obj = null;
			Log.d("CHECK VALUE", "Address: " + people.getStreetAddress());
		}

		initialize();
		setDefaultValues();

	}

	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void initialize() {
		context = ProfileActivity2.this;

		imageLoader = new ImageLoader(context);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		ivProfilePic = (ImageView) findViewById(R.id.ivProfilePic);
		ivCoverPic = (ImageView) findViewById(R.id.ivCoverPic);
		ivRegMedia = (ImageView) findViewById(R.id.ivRegMedia);

		/*
		 * btnEditProfilePic = (ImageView) findViewById(R.id.btnEditProfilePic);
		 * btnEditProfilePic.setOnClickListener(this);
		 * btnEditProfilePic.setVisibility(View.INVISIBLE);
		 * 
		 * btnEditCoverPic = (ImageView) findViewById(R.id.btnEditCoverPic);
		 * btnEditCoverPic.setOnClickListener(this);
		 * btnEditCoverPic.setVisibility(View.INVISIBLE);
		 * 
		 * btnEditStatus = (ImageView) findViewById(R.id.btnEditStatus);
		 * btnEditStatus.setOnClickListener(this);
		 * btnEditStatus.setVisibility(View.INVISIBLE);
		 */

		btnNavigateToMap = (ImageView) findViewById(R.id.btnNavigateToMap);
		btnNavigateToMap.setOnClickListener(this);

		btnEvent = (ImageView) findViewById(R.id.btnEvent);
		btnEvent.setOnClickListener(this);

		// ----- for last part ------ //

		photos_icon_image = (ImageView) findViewById(R.id.photos_icon_image);
		photos_icon_image.setOnClickListener(this);

		friends_icon_image = (ImageView) findViewById(R.id.friends_icon_image);
		friends_icon_image.setOnClickListener(this);

		places_icon_image = (ImageView) findViewById(R.id.places_icon_image);
		places_icon_image.setOnClickListener(this);

		interest_icon_image = (ImageView) findViewById(R.id.interest_icon_image);
		interest_icon_image.setOnClickListener(this);

		// ------------ for last part end ---------- //

		tvName = (TextView) findViewById(R.id.tvName);
		tvStatusMessage = (TextView) findViewById(R.id.tvStatusMessage);
		tvAddress = (TextView) findViewById(R.id.tvAddress);
		tvTime = (TextView) findViewById(R.id.tvTime);
		tvDistance = (TextView) findViewById(R.id.tvDistance);
		tvAge = (TextView) findViewById(R.id.tvAge);

		tvCity = (TextView) findViewById(R.id.tvCity);
		tvCompany = (TextView) findViewById(R.id.tvCompany);

		age_layout = (LinearLayout) findViewById(R.id.age_layout);
		relationship_layout = (LinearLayout) findViewById(R.id.relationship_layout);
		living_in_layout = (LinearLayout) findViewById(R.id.living_in_layout);
		work_at_layout = (LinearLayout) findViewById(R.id.work_at_layout);

		/*
		 * age_layout.setOnClickListener(this);
		 * relationship_layout.setOnClickListener(this);
		 * living_in_layout.setOnClickListener(this);
		 * work_at_layout.setOnClickListener(this);
		 */

		tvRelationshipStatus = (TextView) findViewById(R.id.tvRelationshipStatus);

	}

	public void setDefaultValues() {

		imageLoader.clearCache();

		if (people.getAvatar() != null) {
			imageLoader.DisplayImage(people.getAvatar(), ivProfilePic,
					R.drawable.thumb);
		}

		if (people.getCoverPhoto() != null) {
			imageLoader.DisplayImage(people.getCoverPhoto(), ivCoverPic,
					R.drawable.cover_pic_default);
		}
		if (people.getRegMedia() != null) {
			if (people.getRegMedia().equals("fb")) {
				ivRegMedia.setVisibility(View.VISIBLE);
			}
		}

		String name = "";
		if (people.getFirstName() != null) {
			name = people.getFirstName() + " ";
		}
		if (people.getLastName() != null) {
			name += people.getLastName();
		}
		tvName.setText(name);

		if (people.getStatusMsg() != null) {
			tvStatusMessage.setText(people.getStatusMsg());
		} else {
			tvStatusMessage.setVisibility(View.GONE);
		}

		if (people.getStreetAddress() != null) {
			// tvAddress.setText(people.getStreetAddress());
			tvAddress.setText(people.getCurrentAddress()); /*
															 * use
															 * getCurrentAddress
															 * to show
															 * OtherProfile
															 * "my address"
															 * field
															 */
		}

		/* extra work : may be discard later on */
		if (people.getStreetAddress() == null) {
			tvAddress.setVisibility(View.INVISIBLE);
		}
		/* finished */

		if (people.getLastLogIn() != null) {
			tvTime.setText(Utility.getFormattedDisplayDate(people
					.getLastLogIn()));
		}

		if (people.getAge() > 0) {
			tvAge.setText(people.getAge() + " years");
		}
		// --- extra work : may be discard later on --- //
		if (people.getAge() == 0) {
			tvAge.setText(" ");
		}
		// ---- finish --- //

		if (people.getRelationshipStatus() != null) {
			tvRelationshipStatus.setText(people.getRelationshipStatus());
		}

		if (people.getCity() != null) {
			tvCity.setText(people.getCity());
		}

		if (people.getWorkStatus() != null) {
			tvCompany.setText(people.getWorkStatus());
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnNavigateToMap) {
		} else if (v == btnEvent) {
			Intent i = new Intent(context, EventListActivity.class);
			startActivity(i);
		} else if (v == btnBack) {
			finish();
			// showDialogToUpdateInfo();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(context,
					NotificationActivity.class);
			startActivity(notificationIntent);
		} else if (v == photos_icon_image) {
			Toast.makeText(
					getApplicationContext(),
					people.getFirstName() + "'s"
							+ " photos will be shown later on",
					Toast.LENGTH_SHORT).show();
		} else if (v == friends_icon_image) {
			Toast.makeText(
					getApplicationContext(),
					people.getFirstName() + "'s"
							+ " friends will be shown later on",
					Toast.LENGTH_SHORT).show();
		} else if (v == places_icon_image) {
			Toast.makeText(
					getApplicationContext(),
					people.getFirstName() + "'s"
							+ " places list will be shown later on",
					Toast.LENGTH_SHORT).show();
		} else if (v == interest_icon_image) {
			Toast.makeText(
					getApplicationContext(),
					people.getFirstName() + "'s"
							+ " interest list will be shown later on",
					Toast.LENGTH_SHORT).show();
		}

	}

	/*
	 * @Override protected void onActivityResult(int requestCode, int
	 * resultCode, Intent data) { super.onActivityResult(requestCode,
	 * resultCode, data); if (requestCode ==
	 * ProfileActivity2.REQUEST_CODE_CAMERA) { if (resultCode == RESULT_OK) {
	 * 
	 * if (avatar != null) { avatar.recycle(); }
	 * 
	 * // avatar = (Bitmap) data.getExtras().get("data"); avatar =
	 * Utility.resizeBitmap( (Bitmap) data.getExtras().get("data"),
	 * Constant.thumbWidth, Constant.thumbHeight);
	 * btnEditProfilePic.setImageBitmap(avatar); }
	 * 
	 * if (resultCode == RESULT_CANCELED) { return; }
	 * 
	 * } else if (requestCode == ProfileActivity2.REQUEST_CODE_GALLERY) { if
	 * (resultCode == RESULT_OK) { // imageUri = data.getData(); try { // avatar
	 * = // MediaStore.Images.Media.getBitmap(this.getContentResolver(), //
	 * data.getData()); if (avatar != null) { avatar.recycle(); } avatar =
	 * Utility.resizeBitmap( MediaStore.Images.Media.getBitmap(
	 * this.getContentResolver(), data.getData()), Constant.thumbWidth,
	 * Constant.thumbHeight); btnEditProfilePic.setImageBitmap(avatar); } catch
	 * (FileNotFoundException e) { // TODO Auto-generated catch block
	 * e.printStackTrace(); } catch (IOException e) { // TODO Auto-generated
	 * catch block e.printStackTrace(); } catch (Exception e) { // TODO: handle
	 * exception e.printStackTrace(); } //
	 * ivProfilePicture.setImageURI(imageUri); } } }
	 */
}
