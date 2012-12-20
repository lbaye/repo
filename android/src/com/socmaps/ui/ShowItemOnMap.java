package com.socmaps.ui;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.Overlay;
import com.readystatesoftware.maps.OnSingleTapListener;
import com.readystatesoftware.maps.TapControlledMapView;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.customballons.BubleTapHandle;
import com.socmaps.customballons.CustomItemizedOverlay;
import com.socmaps.customballons.CustomOverlayItem;
import com.socmaps.entity.Event;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageDownloader;
import com.socmaps.listrow.RowType;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.MultiDirectionSlidingDrawer;

public class ShowItemOnMap extends MapActivity implements BubleTapHandle,
		OnClickListener {

	Button closeButton;
	// Button mOpenButton;
	MultiDirectionSlidingDrawer topDrawer, bottomDrawer;

	private static Context context;

	private TapControlledMapView mapView;

	private List<Overlay> mapOverlays;

	private MapController mapController;

	Drawable drawable, drawableSelf, drawablePlace;
	int requestCode;
	String responseString;
	int responseStatus = 0;
	CustomItemizedOverlay<CustomOverlayItem> itemizedOverlayItem;

	private static int flag = -1;

	private ImageView avatar, placeIconImage;
	private Dialog d, msgDialog, frndRequestDialog;

	private ProgressDialog m_ProgressDialog;

	String responseStringUpdateLocation = "";
	int responseStatusUpdateLocation = 0;

	String friendRequestFriendId = "";
	String friendRequestMessage = "";
	String friendRequestResponse = "";
	int friendRequestStatus = 0;

	String sendMessageFriendId = "";
	String sendMessageSubject = "";
	String sendMessageContent = "";
	String sendMessageResponse = "";
	int sendMessageStatus = 0;

	Object selectedItem;

	private List<String> friendRequestSentList = new ArrayList<String>();

	ImageDownloader imageDownloader;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.show_item_on_map_layout);

		getIntentData();
		initialize();

	}

	private void getIntentData() {
		// TODO Auto-generated method stub
		flag = getIntent().getIntExtra("FLAG", -1);
		selectedItem = getIntent().getSerializableExtra("selectedItem");
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
	}

	private void updateMap() {
		// TODO Auto-generated method stub

		if (flag == RowType.PEOPLE.ordinal())
			putPeopleOnMap();
		if (flag == RowType.PLACE.ordinal())
			putPlaceOnMap();
		if (flag == Constant.FLAG_EVENT)
			putEventOnMap();
		if (flag == Constant.FLAG_MEETUP)
			putMeetupOnMap();
		mapView.invalidate();
	}

	private void putEventOnMap() {
		// TODO Auto-generated method stub

		if (selectedItem != null) {
			Event selectedEvent = (Event) selectedItem;

			GeoPoint point = new GeoPoint(
					(int) (selectedEvent.getLatitude() * 1E6),
					(int) (selectedEvent.getLongitude() * 1E6));

			itemizedOverlayItem = new CustomItemizedOverlay<CustomOverlayItem>(
					drawablePlace, mapView, this, Constant.FLAG_EVENT,
					imageDownloader);
			CustomOverlayItem overlayItem = new CustomOverlayItem(point, "",
					"", selectedEvent);
			itemizedOverlayItem.addOverlay(overlayItem);
			itemizedOverlayItem.populateItemizedOverlay();
			mapOverlays.add(itemizedOverlayItem);
			mapController.animateTo(point);
		}

	}

	private void putMeetupOnMap() {
		// TODO Auto-generated method stub
		MeetupRequest meetupEntity = StaticValues.selectedMeetupRequest;
		if (meetupEntity != null) {
			if (meetupEntity.getLocation() != null) {
				itemizedOverlayItem = new CustomItemizedOverlay<CustomOverlayItem>(
						drawablePlace, mapView, this, Constant.FLAG_MEETUP,
						imageDownloader);
				CustomOverlayItem overlayItem = new CustomOverlayItem(
						meetupEntity.getLocation(), "", "", meetupEntity);
				itemizedOverlayItem.addOverlay(overlayItem);
				itemizedOverlayItem.populateItemizedOverlay();
				mapOverlays.add(itemizedOverlayItem);
				mapController.animateTo(meetupEntity.getLocation());
			}

		}

	}

	private void putPlaceOnMap() {
		// TODO Auto-generated method stub
		Place place = StaticValues.selectedPlace;
		itemizedOverlayItem = new CustomItemizedOverlay<CustomOverlayItem>(
				drawablePlace, mapView, this, Constant.FLAG_PLACE,
				imageDownloader);

		GeoPoint geoPoint = new GeoPoint((int) (place.getLatitude() * 1E6),
				(int) (place.getLongitude() * 1E6));

		CustomOverlayItem overlayItem = new CustomOverlayItem(geoPoint, "", "",
				place);
		itemizedOverlayItem.addOverlay(overlayItem);
		itemizedOverlayItem.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlayItem);
		mapController.animateTo(geoPoint);

	}

	private void putPeopleOnMap() {
		// TODO Auto-generated method stub

		People people = (People) selectedItem;

		GeoPoint point = new GeoPoint((int) (people.getCurrentLat() * 1E6),
				(int) (people.getCurrentLng() * 1E6));

		itemizedOverlayItem = new CustomItemizedOverlay<CustomOverlayItem>(
				drawable, mapView, this, Constant.FLAG_PEOPLE, imageDownloader);
		CustomOverlayItem overlayItem = new CustomOverlayItem(point, "", "",
				people);
		itemizedOverlayItem.addOverlay(overlayItem);
		itemizedOverlayItem.populateItemizedOverlay();
		mapOverlays.add(itemizedOverlayItem);
		mapController.animateTo(point);
	}

	private void initialize() {

		context = ShowItemOnMap.this;

		imageDownloader = ImageDownloader.getInstance();

		mapView = (TapControlledMapView) findViewById(R.id.myGMap);

		mapView.setBuiltInZoomControls(false);

		mapView.setOnSingleTapListener(new OnSingleTapListener() {

			@Override
			public boolean onSingleTap(MotionEvent e) {
				itemizedOverlayItem.hideAllBalloons();
				return true;
			}
		});
		mapController = mapView.getController();

		mapOverlays = mapView.getOverlays();
		mapOverlays.clear();

		drawablePlace = getResources().getDrawable(R.drawable.place_marker);
		drawable = getResources().getDrawable(R.drawable.user_marker);

		mapView.setSatellite(false);
		mapController.setZoom(16);

		closeButton = (Button) findViewById(R.id.btnCancel);
		closeButton.setOnClickListener(this);

	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}

	/** Register for the updates when Activity is in foreground */
	@Override
	protected void onResume() {
		super.onResume();
		updateMap();
	}

	/** Stop the updates when Activity is paused */
	@Override
	protected void onPause() {
		super.onPause();

	}

	private class FetchImageTask extends AsyncTask<String, Integer, Bitmap> {
		@Override
		protected Bitmap doInBackground(String... arg0) {
			Bitmap b = null;
			try {
				b = BitmapFactory.decodeStream((InputStream) new URL(arg0[0])
						.getContent());
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			return b;
		}
	}

	@Override
	public void catchBubleTap(CustomOverlayItem item, int typeFlag) {
		// TODO Auto-generated method stub

		if (typeFlag == Constant.FLAG_PEOPLE) {

			showPeoplePopUpDetails(item);
		}

		else if (typeFlag == Constant.FLAG_PLACE) {
			showPlacePopUpDetails(item);
		} else {
		}
	}

	private void showPlacePopUpDetails(CustomOverlayItem item) {
		// TODO Auto-generated method stub
		d = DialogsAndToasts.showExtendedInfoDialog(context,
				R.layout.dialog_on_map_place_extended);

		TextView titleText = (TextView) d.findViewById(R.id.title_text);
		String title = item.getPlace().getName();
		if (title != null && !title.equals("")) {
			titleText.setText(title);
		}

		TextView addressText = (TextView) d.findViewById(R.id.address_text);
		String address = item.getPlace().getVicinity();
		if (address != null && !address.equals("")) {
			addressText.setText(address);
		}

		TextView distance = (TextView) d.findViewById(R.id.distance_text);
		double distanceValue = item.getPlace().getDistance();
		String distanceString = String.format("%.2f", distanceValue);
		distance.setText(distanceString + " miles AWAY");

		ImageView closeBtn = (ImageView) d.findViewById(R.id.close_btn);
		closeBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				d.dismiss();
			}
		});

		placeIconImage = (ImageView) d.findViewById(R.id.place_icon_image);
		String iconUrl = item.getPlace().getIconUrl();
		if (iconUrl != null && !iconUrl.equals("")) {

			placeIconImage.setImageResource(R.drawable.icon);
			new FetchImageTask() {
				@Override
				protected void onPostExecute(Bitmap result) {
					if (result != null) {
						placeIconImage.setImageBitmap(result);
					}
				}
			}.execute(iconUrl);
		}

		d.show();
	}

	private void showPeoplePopUpDetails(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		d = DialogsAndToasts.showExtendedInfoDialog(context,
				R.layout.dialog_on_map_extended);

		String userId = item.getUser().getId();

		TextView firstName = (TextView) d.findViewById(R.id.first_name_text);
		String fName = Utility.getFieldText(item.getUser());

		firstName.setText(fName);

		TextView age = (TextView) d.findViewById(R.id.age_text);
		int ageValue = item.getUser().getAge();
		if (ageValue != 0) {
			age.setText("-Age:" + ageValue);
		} else
			age.setVisibility(View.GONE);

		TextView distance = (TextView) d.findViewById(R.id.distance_text);
		double distanceValue = item.getUser().getDistance();
		String distanceString = String.format("%.2f", distanceValue);
		distance.setText(distanceString + " miles AWAY");

		TextView street = (TextView) d.findViewById(R.id.street_text);
		String sName = item.getUser().getCurrentAddress();
		if (sName != null && !sName.equals("")) {
			street.setText(sName);
		}

		TextView gender = (TextView) d.findViewById(R.id.gender_text);
		String genderValue = item.getUser().getGender();
		if (genderValue != null && !genderValue.equals("")) {
			gender.setText(":" + genderValue);
		}

		TextView relationshipSatus = (TextView) d
				.findViewById(R.id.relationship_text);
		String relationshipValue = item.getUser().getRelationshipStatus();
		if (relationshipValue != null && !relationshipValue.equals("")) {
			relationshipSatus.setText(relationshipValue);
		}

		TextView city = (TextView) d.findViewById(R.id.city_text);
		String cityValue = item.getUser().getCity();
		if (cityValue != null && !cityValue.equals("")) {
			city.setText(cityValue);
		}

		TextView work = (TextView) d.findViewById(R.id.work_text);
		String workValue = item.getUser().getWorkStatus();
		if (workValue != null && !workValue.equals("")) {
			work.setText(workValue);
		}

		avatar = (ImageView) d.findViewById(R.id.avater_image);
		String avatarUrl = item.getUser().getAvatar();
		if (avatarUrl != null && !avatarUrl.equals("")) {

			avatar.setImageResource(R.drawable.icon);
			new FetchImageTask() {
				@Override
				protected void onPostExecute(Bitmap result) {
					if (result != null) {
						avatar.setImageBitmap(result);
					}
				}
			}.execute(item.getUser().getAvatar());
		}

		Button addFrndBtn = (Button) d.findViewById(R.id.add_frnd_btn);

		boolean isFrndValue = item.getUser().getIsFrnd();
		if (isFrndValue) {
			addFrndBtn.setVisibility(View.GONE);
		}
		Button sendMessageBtn = (Button) d.findViewById(R.id.message_btn);
		ImageView closeBtn = (ImageView) d.findViewById(R.id.close_btn);
		closeBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				d.dismiss();
			}
		});

		Button meetupBtn = (Button) d.findViewById(R.id.meet_up_btn);
		TextView tvFriendshipStatus = (TextView) d
				.findViewById(R.id.tvFriendshipStatus);

		String friendshipStatus = item.getUser().getFriendshipStatus();
		if (friendRequestSentList.contains(userId)) {
			tvFriendshipStatus.setText("Pending");
		} else {
			if (friendshipStatus
					.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_NONE)) {
				tvFriendshipStatus.setVisibility(View.GONE);
				addFrndBtn.setVisibility(View.VISIBLE);
			} else {
				tvFriendshipStatus.setVisibility(View.VISIBLE);
				addFrndBtn.setVisibility(View.GONE);

				String status = "";
				if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_FRIEND)) {
					status = getString(R.string.status_friend_request_friend);
					meetupBtn.setVisibility(View.VISIBLE);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_PENDING)) {
					status = getString(R.string.status_friend_request_pending);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REQUESTED)) {
					status = getString(R.string.status_friend_request_sent);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REJECTED_BY_ME)) {
					status = getString(R.string.status_friend_request_declined_by_me);
				} else if (friendshipStatus
						.equalsIgnoreCase(Constant.STATUS_FRIENDSHIP_REJECTED_BY_HIM)) {
					status = getString(R.string.status_friend_request_declined_by_him);
				}
				tvFriendshipStatus.setText(status);
			}
		}

		addFrndBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				showFrndRequestDialog(item);
			}
		});
		sendMessageBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				showMessageDialog(item);
			}

		});

		d.show();
	}

	private void showFrndRequestDialog(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		frndRequestDialog = DialogsAndToasts.showAddFrnd(context);
		final EditText msgEditText = (EditText) frndRequestDialog
				.findViewById(R.id.message_body_text);
		Button send = (Button) frndRequestDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) frndRequestDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				sendFriendRequest(item.getUser().getId(), msgEditText.getText()
						.toString().trim());

			}
		});
		cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				frndRequestDialog.dismiss();
			}
		});
		frndRequestDialog.show();
	}

	private void showMessageDialog(final CustomOverlayItem item) {
		// TODO Auto-generated method stub
		msgDialog = DialogsAndToasts.showSendMessage(context);
		final EditText msgEditText = (EditText) msgDialog
				.findViewById(R.id.message_body_text);
		Button send = (Button) msgDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);
		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if (!msgEditText.getText().toString().trim().equals("")) {
					sendMessage(item.getUser().getId(), "Message", msgEditText
							.getText().toString().trim());
				} else {
					msgEditText.setError("Please enter your message!!");
				}
			}
		});
		cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				msgDialog.dismiss();
			}
		});
		msgDialog.show();
	}

	private void sendFriendRequest(String friendId, String message) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			friendRequestFriendId = friendId;
			friendRequestMessage = message;

			Thread thread = new Thread(null, friendRequestThread,
					"Start send message");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable friendRequestThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smFriendRequestUrl
					+ "/" + friendRequestFriendId);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("message", friendRequestMessage);

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			friendRequestResponse = restClient.getResponse();
			friendRequestStatus = restClient.getResponseCode();

			runOnUiThread(friendRequestReturnResponse);
		}
	};

	private Runnable friendRequestReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseFriendRequest(friendRequestStatus,
					friendRequestResponse);

			// dismiss progress dialog if needed
			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}
		}
	};

	private void handleResponseFriendRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.d("Send Frnd Request", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			if (!friendRequestSentList.contains(friendRequestFriendId)) {
				friendRequestSentList.add(friendRequestFriendId);
			}

			ArrayList<People> peopleList = StaticValues.searchResult
					.getPeoples();

			for (int i = 0; i < peopleList.size(); i++) {
				String userId = peopleList.get(i).getId();
				if (friendRequestSentList.contains(userId)) {
					peopleList.get(i).setFriendshipStatus(
							Constant.STATUS_FRIENDSHIP_PENDING);
				}
			}

			StaticValues.searchResult.setPeoples(peopleList);

			Toast.makeText(context, "Request sent successfully.",
					Toast.LENGTH_SHORT).show();
			frndRequestDialog.dismiss();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}
	}

	private void sendMessage(String friendId, String subject, String content) {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			sendMessageFriendId = friendId;
			sendMessageSubject = subject;
			sendMessageContent = content;

			Thread thread = new Thread(null, sendMessageThread,
					"Start send message");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true, true);

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable sendMessageThread = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			restClient.AddParam("recipients[]", sendMessageFriendId);
			restClient.AddParam("subject", sendMessageSubject);
			restClient.AddParam("content", sendMessageContent);

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			sendMessageResponse = restClient.getResponse();
			sendMessageStatus = restClient.getResponseCode();

			runOnUiThread(sendMessageReturnResponse);
		}
	};

	private Runnable sendMessageReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseSendMessage(sendMessageStatus, sendMessageResponse);

			// dismiss progress dialog if needed
			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}
		}
	};

	private void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog
		Log.d("Send Message", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
			Toast.makeText(context, "Message sent successfully.",
					Toast.LENGTH_SHORT).show();
			msgDialog.dismiss();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured. Please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == closeButton) {
			finish();
		}
	}

}
