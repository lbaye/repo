package com.socmaps.widget;

import java.util.List;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.PeopleCircleActivity;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PeopleCircleFriendsPrefaranceItemView extends LinearLayout
		implements View.OnClickListener {

	private Context context;

	private String itemId;
	private LinearLayout llHeaderPanel;

	private View headerSeperator;
	private TextView first_name_text, address_text, distance_text;

	private ImageView map_image_btn, people_icon_image, cover_image_view;
	private LinearLayout llItemContents;

	private Button btnMessagePeopleCicleFriend, btnAddMoveToCircle;
	ImageView ivSource;

	private boolean isToggle = true;
	private boolean hideHeader = false;

	public boolean isExpanded = false;

	private People people;

	private ImageDownloader imageDownloader;
	private Dialog msgDialog;
	private String sendMessageFriendId = "";
	private String sendMessageSubject = "";
	private String sendMessageContent = "";
	private String sendMessageResponse = "";
	private int sendMessageStatus = 0;
	private ProgressDialog m_ProgressDialog;

	public PeopleCircleFriendsPrefaranceItemView(Context context,
			People people, ImageDownloader imageDownloader) {
		super(context, null);

		this.context = context;
		this.people = people;
		this.imageDownloader = imageDownloader;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.row_in_row_people_circle_preference_item,
				this, true);

		init();
		setDefaultValues();

	}

	private void init() {

		llHeaderPanel = (LinearLayout) findViewById(R.id.llHeaderPanel);
		llHeaderPanel.setOnClickListener(this);

		llItemContents = (LinearLayout) findViewById(R.id.llItemContents);
		headerSeperator = findViewById(R.id.headerSeperator);

		first_name_text = (TextView) findViewById(R.id.first_name_text);
		address_text = (TextView) findViewById(R.id.address_text);
		distance_text = (TextView) findViewById(R.id.distance_text);

		btnMessagePeopleCicleFriend = (Button) findViewById(R.id.btnMessagePeopleCicleFriend);
		btnMessagePeopleCicleFriend.setOnClickListener(this);

		btnAddMoveToCircle = (Button) findViewById(R.id.btnAddMoveToCircle);
		btnAddMoveToCircle.setOnClickListener(this);
		ivSource = (ImageView) findViewById(R.id.ivSource);

		map_image_btn = (ImageView) findViewById(R.id.map_image_btn);
		map_image_btn.setOnClickListener(this);

		people_icon_image = (ImageView) findViewById(R.id.people_icon_image);
		cover_image_view = (ImageView) findViewById(R.id.cover_image_view);

	}

	private void setDefaultValues() {

		if (people != null) {

			Log.i("Peple PeopleCircleFriendsPrefaranceItemView::::::::::::::::",
					"FirstName: " + people.getFirstName()
							+ people.getLastName() + " Address: "
							+ people.getCurrentAddress() + " Avater:"
							+ people.getAvatar() + " cov pic: "
							+ people.getCoverPhoto() + " RegMedia: "
							+ people.getRegMedia());

			first_name_text.setText(Utility.getFieldText(people));

			if (people.getCurrentAddress() != null) {
				address_text.setText(people.getCurrentAddress());
			}

			distance_text
					.setText(Utility.getFormatedDistance(people.getDistance(),
							StaticValues.myInfo.getSettings().getUnit()));

			if (people.getRegMedia() != null) {

				if (people.getRegMedia().equalsIgnoreCase(
						Constant.sourceFacebook)) {
					ivSource.setImageResource(R.drawable.facebookicon);
				}
			}

			if (people.getAvatar() != null) {
				people_icon_image.setImageResource(R.drawable.img_blank);
				imageDownloader.download(people.getAvatar(), people_icon_image);
			}

			if (people.getCoverPhoto() != null) {
				cover_image_view.setImageResource(R.drawable.img_blank);
				imageDownloader.download(people.getCoverPhoto(),
						cover_image_view);
			}

		}

		if (hideHeader || !isToggle) {
			if (hideHeader) {
				llHeaderPanel.setVisibility(View.GONE);
			}

			llItemContents.setVisibility(View.VISIBLE);
		}

	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		switch (v.getId()) {

		case R.id.btnAddMoveToCircle:

			List<String> selectedCircleList = null;

			String id = people.getId();

			List<Circle> circleList = StaticValues.myInfo.getCircleList();

			if (id != null) {
				selectedCircleList = Utility.getCircleIdsForPeople(id,
						circleList);
			}

			CircleAddMoveToPicker createCirclePicker = new CircleAddMoveToPicker(
					context, new CircleAddMoveToPickerHandler(), "CIRCLE LIST",
					circleList, selectedCircleList, people);

			createCirclePicker.show();
			break;

		case R.id.btnMessagePeopleCicleFriend:
			showMessageDialog(people);

			break;

		case R.id.map_image_btn:
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;

			if (PeopleCircleActivity.getIns() != null) {

				PeopleCircleActivity.getIns().finish();
			}

			break;

		default:
			break;

		}

	}

	public void toggle() {
		if (isExpanded) {
			llItemContents.setVisibility(View.GONE);

			headerSeperator.setVisibility(View.VISIBLE);

		} else {
			llItemContents.setVisibility(View.VISIBLE);

			headerSeperator.setVisibility(View.GONE);
		}
		isExpanded = !isExpanded;
	}

	/*
	 * Send Message to individual Person
	 */
	private void showMessageDialog(final Object people) {
		// TODO Auto-generated method stub
		msgDialog = DialogsAndToasts.showSendMessage(context);
		final EditText msgEditText = (EditText) msgDialog
				.findViewById(R.id.message_body_text);
		Button send = (Button) msgDialog.findViewById(R.id.btnSend);
		Button cancel = (Button) msgDialog.findViewById(R.id.btnCancel);

		// final People p = (People) people;

		send.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				People p = null;
				SecondDegreePeople secondDegreePeople = null;

				if (people instanceof People) {

					p = (People) people;
					if (!msgEditText.getText().toString().trim().equals("")) {
						sendMessage(p.getId(), "Message", msgEditText.getText()
								.toString().trim());
					} else {
						msgEditText.setError("Please enter your message!!");
					}

				} else if (people instanceof SecondDegreePeople) {
					secondDegreePeople = (SecondDegreePeople) people;

					if (!msgEditText.getText().toString().trim().equals("")) {
						sendMessage(secondDegreePeople.getRefId(), "Message",
								msgEditText.getText().toString().trim());
					} else {
						msgEditText.setError("Please enter your message!!");
					}

				}

				hideMessageDialogKeybord(msgEditText);

			}
		});
		cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				hideMessageDialogKeybord(msgEditText);
				msgDialog.dismiss();

			}
		});
		msgDialog.show();
	}

	public void sendMessage(String friendId, String subject, String content) {
		if (Utility.isConnectionAvailble(context.getApplicationContext())) {

			sendMessageFriendId = friendId;
			sendMessageSubject = subject;
			sendMessageContent = content;

			Thread thread = new Thread(null, sendMessageThread,
					"Start send message");
			thread.start();

			// show progress dialog if needed
			m_ProgressDialog = ProgressDialog.show(context, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.sending_request_text), true);

		} else {

			DialogsAndToasts.showNoInternetConnectionDialog(context
					.getApplicationContext());
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

			((Activity) context).runOnUiThread(sendMessageReturnResponse);
		}
	};

	private Runnable sendMessageReturnResponse = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			handleResponseSendMessage(sendMessageStatus, sendMessageResponse);

			// dismiss progress dialog if needed
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog
		Log.d("Send Message", status + ":" + response);
		switch (status) {
		case Constant.STATUS_CREATED:
			// Log.d("Login", status+":"+response);
			Toast.makeText(context, "Message sent successfully.",
					Toast.LENGTH_SHORT).show();
			msgDialog.dismiss();
			break;

		default:
			Toast.makeText(context.getApplicationContext(),
					"Message not delivered,please try again!!",
					Toast.LENGTH_SHORT).show();
			break;

		}

	}

	// Listener
	private class CircleAddMoveToPickerHandler implements
			CircleAddMoveToPickerListener {

		@Override
		public void onCircleSelect(String pickerName, Circle selectedCircle) {
			// TODO Auto-generated method stub
			if (selectedCircle != null) {

				Log.w("CircleAddMoveToPickerHandler in onCircleSelect >>>",
						selectedCircle.toString());

				// MyGeoPoint myGeoPoint = selectedPlace.getLocation();
				// if (myGeoPoint != null) {
				// eventLat = myGeoPoint.getLatitudeE6() / 1E6;
				// eventLng = myGeoPoint.getLongitudeE6() / 1E6;
				// eventAddress = selectedPlace.getVicinity();
				// displayAddress(selectedPlace.getName(), eventAddress);
				// }

			}
		}

	}

	protected void hideMessageDialogKeybord(EditText msgEditText) {
		// TODO Auto-generated method stub

		InputMethodManager mgr = (InputMethodManager) context
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(msgEditText.getWindowToken(), 0);

	}

}
