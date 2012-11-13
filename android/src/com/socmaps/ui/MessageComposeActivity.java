package com.socmaps.ui;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class MessageComposeActivity extends Activity {

	ButtonActionListener buttonActionListener;

	private LayoutInflater inflater;
	private Context context;

	private Button btnFriendSelect, btnCircleSelect, btnCancel, btnSend,
			btnSelectAll, btnUnselectAll;
	EditText etNewMessage, etFriendSearch;

	LinearLayout friendListContainer, circleListContainer;
	ScrollView scrollViewFriends, scrollViewCircles;

	ProgressDialog m_ProgressDialog;
	String messageResponse = "";
	int messageStatus = 0;

	HashMap<String, Boolean> selectedFriends = new HashMap<String, Boolean>();
	HashMap<String, Boolean> selectedCircles = new HashMap<String, Boolean>();

	ImageLoader imageLoader;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.message_compose_activity);

		initialize();

		// generate list
		generateList();

		showFriendList();
	}

	private void generateList() {

		friendListContainer.removeAllViews();
		List<People> friends = StaticValues.myInfo.getFriendList();

		// Log.e("Friends count", friends.length+"");
		if (friends != null) {

			for (int i = 0; i < friends.size(); i++) {
				// Log.e("FriendList",
				// friends[i].getId()+", "+friends[i].getFirstName());
				View v = getItemViewFriend(friends.get(i));
				friendListContainer.addView(v);
			}
		}

		circleListContainer.removeAllViews();
		List<Circle> circles = StaticValues.myInfo.getCircleList();
		if (circles != null) {
			for (int i = 0; i < circles.size(); i++) {

				String circleId = circles.get(i).getId();
				if (circleId != null) {

					selectedCircles.put(circleId, false);

					if (circles.get(i).getFriendList() != null) {
						if (circles.get(i).getFriendList().size() > 0) {
							View v = getItemViewCircle(circles.get(i));
							circleListContainer.addView(v);
						}
					}
				}

				// View v = getItemViewCircle(circles.get(i));
				// circleListContainer.addView(v);
			}
		}

	}

	public View getItemViewFriend(People fEntity) {

		View v = inflater.inflate(R.layout.people_item, null);

		TextView nameView = (TextView) v.findViewById(R.id.name);
		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);

		final LinearLayout proficPicContainer = (LinearLayout) v
				.findViewById(R.id.proficPicContainer);

		String firstName = fEntity.getFirstName();
		String lastName = fEntity.getLastName();
		final String id = fEntity.getId();
		String avatarUrl = fEntity.getAvatar();

		String name = "";

		if (firstName != null) {
			name = firstName + " ";
		}
		if (lastName != null) {
			name += lastName;
		}

		selectedFriends.put(id, false);

		nameView.setText(name);

		if (avatarUrl != null && !avatarUrl.equals("")) {

			/*
			 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource
			 * ( getResources(), R.drawable.user_default));
			 * 
			 * BitmapManager.INSTANCE.loadBitmap(avatarUrl, profilePic, 55, 55);
			 */

			imageLoader.DisplayImage(avatarUrl, profilePic,
					R.drawable.user_default);

		}

		profilePic.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				boolean isSelected = selectedFriends.get(id);
				if (isSelected) {
					proficPicContainer
							.setBackgroundResource(R.color.transparent);
				} else {
					proficPicContainer
							.setBackgroundResource(R.color.highlightGreen);
				}
				selectedFriends.put(id, !isSelected);

			}
		});

		return v;
	}

	public View getItemViewCircle(Circle cEntity) {

		View v = inflater.inflate(R.layout.circle_item, null);

		TextView titleView = (TextView) v.findViewById(R.id.circleTitle);
		CheckBox chkCircle = (CheckBox) v.findViewById(R.id.chkCircle);

		String title = cEntity.getName();
		final String id = cEntity.getId();
		List<People> friends = cEntity.getFriendList();

		if (friends != null) {
			title += " (" + friends.size() + ")";
		}

		titleView.setText(title);

		chkCircle.setOnCheckedChangeListener(new OnCheckedChangeListener() {

			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				// TODO Auto-generated method stub
				if (isChecked) {
					selectedCircles.put(id, true);
				} else {
					selectedCircles.put(id, false);
				}
			}
		});

		return v;
	}

	public void initialize() {
		context = MessageComposeActivity.this;
		buttonActionListener = new ButtonActionListener();

		imageLoader = new ImageLoader(context);

		btnFriendSelect = (Button) findViewById(R.id.btnFriendSelect);
		btnFriendSelect.setOnClickListener(buttonActionListener);
		btnCircleSelect = (Button) findViewById(R.id.btnCircleSelect);
		btnCircleSelect.setOnClickListener(buttonActionListener);
		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener);
		btnSend = (Button) findViewById(R.id.btnSend);
		btnSend.setOnClickListener(buttonActionListener);
		btnSelectAll = (Button) findViewById(R.id.btnSelectAll);
		btnSelectAll.setOnClickListener(buttonActionListener);
		btnUnselectAll = (Button) findViewById(R.id.btnUnselectAll);
		btnUnselectAll.setOnClickListener(buttonActionListener);

		etNewMessage = (EditText) findViewById(R.id.etNewMessage);
		etFriendSearch = (EditText) findViewById(R.id.etFriendSearch);

		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		friendListContainer = (LinearLayout) findViewById(R.id.friendListContainer);
		circleListContainer = (LinearLayout) findViewById(R.id.circleListContainer);

		scrollViewFriends = (ScrollView) findViewById(R.id.scrollViewFriends);
		scrollViewCircles = (ScrollView) findViewById(R.id.scrollViewCircles);

	}

	public void showFriendList() {

		btnFriendSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);
		btnCircleSelect.setTextAppearance(context,
				R.style.ButtonTextStyleNormal);

		if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			scrollViewCircles.setVisibility(View.GONE);
		}

		scrollViewFriends.setVisibility(View.VISIBLE);
	}

	public void showCircleList() {
		btnFriendSelect.setTextAppearance(context,
				R.style.ButtonTextStyleNormal);
		btnCircleSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);

		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			scrollViewFriends.setVisibility(View.GONE);
		}

		scrollViewCircles.setVisibility(View.VISIBLE);
	}

	public void selectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(true);
		} else if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			selectionCircles(true);
		}
	}

	public void unselectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(false);
		} else if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			selectionCircles(false);
		}
	}

	public void selectionFriends(boolean isSelect) {
		int selectionColor;
		if (isSelect) {
			selectionColor = R.color.highlightGreen;
		} else {
			selectionColor = R.color.transparent;
		}

		int totalChild = friendListContainer.getChildCount();
		for (int i = 0; i < totalChild; i++) {
			View v = friendListContainer.getChildAt(i);
			LinearLayout proficPicContainer = (LinearLayout) v
					.findViewById(R.id.proficPicContainer);
			proficPicContainer.setBackgroundResource(selectionColor);
		}

		Set set = selectedFriends.entrySet();
		Iterator iterator = set.iterator();
		while (iterator.hasNext()) {
			Map.Entry me = (Map.Entry) iterator.next();

			String key = (String) me.getKey();
			selectedFriends.put(key, isSelect);
		}
	}

	public void selectionCircles(boolean isSelect) {

		int totalChild = circleListContainer.getChildCount();
		for (int i = 0; i < totalChild; i++) {
			View v = circleListContainer.getChildAt(i);
			CheckBox chkCircle = (CheckBox) v.findViewById(R.id.chkCircle);
			chkCircle.setChecked(isSelect);
		}

		/*
		 * Set set = selectedCircles.entrySet(); Iterator iterator =
		 * set.iterator(); while (iterator.hasNext()) { Map.Entry me =
		 * (Map.Entry) iterator.next();
		 * 
		 * String key = (String) me.getKey(); selectedCircles.put(key,
		 * isSelect); }
		 */
	}

	public void validateNewMessage() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {

			boolean isValidReciever = false;

			Set set = selectedFriends.entrySet();
			// Get an iterator
			Iterator i = set.iterator();
			// Display elements
			while (i.hasNext()) {
				Map.Entry me = (Map.Entry) i.next();

				String key = (String) me.getKey();
				boolean isSelected = (Boolean) me.getValue();

				if (isSelected) {
					isValidReciever = true;
					break;
				}

			}

			if (!isValidReciever) {
				set = selectedCircles.entrySet();
				// Get an iterator
				i = set.iterator();
				// Display elements
				while (i.hasNext()) {
					Map.Entry me = (Map.Entry) i.next();

					String key = (String) me.getKey();
					boolean isSelected = (Boolean) me.getValue();

					if (isSelected) {
						isValidReciever = true;
						break;
					}

				}
			}

			if (!etNewMessage.getText().toString().trim().equalsIgnoreCase("")) {

				if (isValidReciever) {
					Thread thread = new Thread(null, sendMessagesThread,
							"Start send messages");
					thread.start();

					// show progress dialog if needed
					m_ProgressDialog = ProgressDialog
							.show(MessageGroupActivity.group,
									getResources().getString(
											R.string.please_wait_text),
									getResources().getString(
											R.string.sending_request_text),
									true);
				} else {
					Toast.makeText(MessageGroupActivity.group,
							"No recipient selected.", Toast.LENGTH_SHORT)
							.show();
				}

			}

		} else {

			DialogsAndToasts
					.showNoInternetConnectionDialog(getApplicationContext());
		}
	}

	private Runnable sendMessagesThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smMessagesUrl);
			restClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			Set set = selectedFriends.entrySet();
			// Get an iterator
			Iterator iterator = set.iterator();
			// Display elements
			while (iterator.hasNext()) {
				Map.Entry me = (Map.Entry) iterator.next();

				String key = (String) me.getKey();
				boolean isSelected = (Boolean) me.getValue();

				if (isSelected) {
					Log.e("IsChecked", key);
					restClient.AddParam("recipients[]", key);
				}

			}

			List<Circle> circles = StaticValues.myInfo.getCircleList();
			if (circles != null) {
				for (int i = 0; i < circles.size(); i++) {
					String circleId = circles.get(i).getId();

					if (selectedCircles.containsKey(circleId)) {
						boolean isChecked = selectedCircles.get(circleId);
						if (isChecked) {
							Log.e("IsCheckedCircle", circleId);

							List<People> friends = circles.get(i)
									.getFriendList();
							if (friends != null) {
								for (int j = 0; j < friends.size(); j++) {
									String friendId = friends.get(j).getId();
									Log.e("IsChecked", friendId);
									restClient.AddParam("recipients[]",
											friendId);
								}
							}
						}
					}

				}
			}

			restClient.AddParam("subject", "");
			restClient.AddParam("content", etNewMessage.getText().toString()
					.trim());

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			messageResponse = restClient.getResponse();
			messageStatus = restClient.getResponseCode();

			// messageResponse = "success";
			// messageStatus = 201;

			runOnUiThread(sendMessageReturnResponse);
		}
	};

	private Runnable sendMessageReturnResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			m_ProgressDialog.dismiss();

			handleResponseSendMessage(messageStatus, messageResponse);

		}
	};

	public void handleResponseSendMessage(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("MESSAGE RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_CREATED) {

			// etNewMessage.setText("");
			Toast.makeText(MessageGroupActivity.group,
					"Message sent successfully.", Toast.LENGTH_SHORT).show();

			MessageGroupActivity.group.back();

			// Toast.makeText(MessageGroupActivity.group,
			// "Message sent successfully.", Toast.LENGTH_SHORT).show();

		} else {
			Toast.makeText(MessageGroupActivity.group,
					"Sending failed. Please try again.", Toast.LENGTH_SHORT)
					.show();
		}

	}

	@Override
	public void onContentChanged() {
		super.onContentChanged();

		// initialize
		// initialize();

	}

	@Override
	protected void onResume() {
		super.onResume();

	}

	@Override
	protected void onPause() {
		super.onPause();

	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

		}
		return false;

	}

	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnFriendSelect) {
				showFriendList();
			} else if (v == btnCircleSelect) {
				showCircleList();
			} else if (v == btnSend) {
				validateNewMessage();
			} else if (v == btnCancel) {
				MessageGroupActivity.group.back();
			} else if (v == btnSelectAll) {
				selectAll();
			} else if (v == btnUnselectAll) {
				unselectAll();
			}

		}

	}

	/*
	 * private class FetchImageTask extends AsyncTask<String, Integer, Bitmap> {
	 * 
	 * @Override protected Bitmap doInBackground(String... arg0) { Bitmap b =
	 * null; try { b = BitmapFactory.decodeStream((InputStream) new URL(arg0[0])
	 * .getContent()); } catch (MalformedURLException e) { e.printStackTrace();
	 * } catch (IOException e) { e.printStackTrace(); } return b; } }
	 */

}
