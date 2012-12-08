package com.socmaps.ui;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.Toast;

public class RecommendationActivity extends Activity { 
	
	Context context;

	Button btnBack, btnNotification; 
	Button btnCancel, btnSend;
	//TextView tvTitle; 
	
	EditText etMessage;
	String requestMessage = "", requestAddress = "";

	ProgressDialog m_ProgressDialog;

	int requestCode;

	String responseString;
	int responseStatus = 0;

	ButtonActionListener buttonActionListener; 
	
	private LayoutInflater inflater;
	private Button btnFriendSelect/*, btnCircleSelect*/, btnSelectAll,
			btnUnselectAll, btnCancleSearch;
	EditText etFriendSearch;
	LinearLayout friendListContainer/*, circleListContainer*/;
	ScrollView scrollViewFriends/*, scrollViewCircles*/;
	HashMap<String, Boolean> selectedFriends = new HashMap<String, Boolean>();
	//HashMap<String, Boolean> selectedCircles = new HashMap<String, Boolean>();

	ImageLoader imageLoader; 
	public Place place;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState); 
		setContentView(R.layout.recommanded_layout); 
		
		Object obj = getIntent().getSerializableExtra("place");
		if (obj != null) {
			place = (Place) (obj);
			obj = null;
		} 
		
		Log.d("Place ID", place.getId()+ " " + place.getName() + " " + place.getVicinity());
		
		requestAddress = place.getVicinity(); 
		/*userFirstName = StaticValues.myInfo.getFirstName(); 
		userLastName = StaticValues.myInfo.getLastName(); 
		if(requestAddress != null && ((userFirstName != null) || (userLastName != null))) {
			Log.d("Place Name", requestAddress); 
			Log.d("User First Name", userFirstName); 
			Log.d("User Last Name", userLastName);
		}*/
		
		initialize();
		generateFriendList();
		showFriendList();
	} 
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		Utility.updateNotificationBubbleCounter(btnNotification);

	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	} 
	
	private void initialize() {

		context = RecommendationActivity.this;

		imageLoader = new ImageLoader(context);

		buttonActionListener = new ButtonActionListener();

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(buttonActionListener);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(buttonActionListener);

		btnSend = (Button) findViewById(R.id.btnSend);
		btnSend.setOnClickListener(buttonActionListener);

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(buttonActionListener); 
		
		btnCancleSearch = (Button) findViewById(R.id.btnCancleSearch); 
		btnCancleSearch.setOnClickListener(buttonActionListener);

		//tvTitle = (TextView) findViewById(R.id.tvTitle); 
		etMessage = (EditText) findViewById(R.id.etMessage);


		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		btnFriendSelect = (Button) findViewById(R.id.btnFriendSelect);
		btnFriendSelect.setOnClickListener(buttonActionListener);
		//btnCircleSelect = (Button) findViewById(R.id.btnCircleSelect);
		//btnCircleSelect.setOnClickListener(buttonActionListener);
		btnSelectAll = (Button) findViewById(R.id.btnSelectAll);
		btnSelectAll.setOnClickListener(buttonActionListener);
		btnUnselectAll = (Button) findViewById(R.id.btnUnselectAll);
		btnUnselectAll.setOnClickListener(buttonActionListener);

		etFriendSearch = (EditText) findViewById(R.id.etFriendSearch);
		friendListContainer = (LinearLayout) findViewById(R.id.friendListContainer);
		//circleListContainer = (LinearLayout) findViewById(R.id.circleListContainer);
		scrollViewFriends = (ScrollView) findViewById(R.id.scrollViewFriends);
		//scrollViewCircles = (ScrollView) findViewById(R.id.scrollViewCircles); 
		
		//etMessage.setText(Utility.getFieldText(StaticValues.myInfo) + " recommanded you to visit " + place.getName());

	} 
	
	private class ButtonActionListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if (v == btnBack) {
				finish();
			} else if (v == btnNotification) {
				Intent notificationIntent = new Intent(getApplicationContext(),
						NotificationActivity.class);
				startActivity(notificationIntent);
			} else if (v == btnSend) {
				//Toast.makeText(context, "Coming Soon", Toast.LENGTH_SHORT).show();
				validateRequest();
			}

			else if (v == btnCancel) {
				// showPeoplePicker();
				finish();
			} 
			
			else if (v == btnCancleSearch) { 
				hideKeyBoard();
				etFriendSearch.setText(""); 
			}

			else if (v == btnFriendSelect) {
				showFriendList();
			} /*else if (v == btnCircleSelect) {
				showCircleList();
			}*/ else if (v == btnSelectAll) {
				selectAll();
			} else if (v == btnUnselectAll) {
				unselectAll();
			}

		} 
	} 
	
	private void hideKeyBoard()
	{
		InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(etFriendSearch.getWindowToken(), 0);
	}
		
	private void generateFriendList() {

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

		/*circleListContainer.removeAllViews();
		List<Circle> circles = StaticValues.myInfo.getCircleList();
		if (circles != null) {
			for (int i = 0; i < circles.size(); i++) {
				if (circles.get(i).getFriendList() != null) {
					if (circles.get(i).getFriendList().size() > 0) {
						View v = getItemViewCircle(circles.get(i));
						circleListContainer.addView(v);
					}
				}
			}
		}*/

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

	/*public View getItemViewCircle(Circle cEntity) {

		View v = inflater.inflate(R.layout.circle_item, null);

		TextView titleView = (TextView) v.findViewById(R.id.circleTitle);
		CheckBox chkCircle = (CheckBox) v.findViewById(R.id.chkCircle);

		String title = cEntity.getName();
		final String id = cEntity.getId();
		List<People> friends = cEntity.getFriendList();

		if (friends != null) {
			title += " (" + friends.size() + ")";
		}

		selectedCircles.put(id, false);

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
	}*/

	public void showFriendList() {

		btnFriendSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);
		/*btnCircleSelect.setTextAppearance(context,
				R.style.ButtonTextStyleNormal);*/

		/*if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			scrollViewCircles.setVisibility(View.GONE);
		}*/

		scrollViewFriends.setVisibility(View.VISIBLE);
	}

	/*public void showCircleList() {
		btnFriendSelect.setTextAppearance(context,
				R.style.ButtonTextStyleNormal);
		btnCircleSelect.setTextAppearance(context, R.style.ButtonTextStyleBold);

		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			scrollViewFriends.setVisibility(View.GONE);
		}

		scrollViewCircles.setVisibility(View.VISIBLE);
	}*/

	public void selectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(true);
		} /*else if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			selectionCircles(true);
		}*/
	}

	public void unselectAll() {
		if (scrollViewFriends.getVisibility() == View.VISIBLE) {
			selectionFriends(false);
		} /*else if (scrollViewCircles.getVisibility() == View.VISIBLE) {
			selectionCircles(false);
		}*/
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

	/*public void selectionCircles(boolean isSelect) {

		int totalChild = circleListContainer.getChildCount();
		for (int i = 0; i < totalChild; i++) {
			View v = circleListContainer.getChildAt(i);
			CheckBox chkCircle = (CheckBox) v.findViewById(R.id.chkCircle);
			chkCircle.setChecked(isSelect);
		}
	} */
	
	private void validateRequest() {
		// TODO Auto-generated method stub
		boolean validated = true;
		String messageText = "";

		List<String> invitedPeopleList = Utility
				.getListFromHashMap(selectedFriends);

		/*List<String> invitedCircleList = Utility
				.getListFromHashMap(selectedCircles);*/

		if (invitedPeopleList.size() == 0) {
			validated = false;
			messageText = "No friend is selected to be invited.";
		}

		if (validated) {
			initiateSendData(); 
			//Toast.makeText(context, "Coming Soon", Toast.LENGTH_SHORT).show();
		} else {
			Toast.makeText(context, messageText, Toast.LENGTH_SHORT).show();
		}
	}

	public void initiateSendData() {
		Thread thread = new Thread(null, sendRequestThread,
				"Start send request");
		thread.start();

		// show progress dialog if needed
		m_ProgressDialog = ProgressDialog.show(context, getResources()
				.getString(R.string.please_wait_text), getResources()
				.getString(R.string.sending_request_text), true,true);
	}

	private Runnable sendRequestThread = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub
			RestClient restClient = new RestClient(Constant.smServerUrl+"/recommend/venue/"+place.getId());
			restClient.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));
			

			requestMessage = etMessage.getText().toString().trim();
			Log.d("Message to Sent", requestMessage);
			
			
			restClient.AddParam("metaTitle", place.getName());
			restClient.AddParam("metaContent[note]", requestMessage); 
			restClient.AddParam("metaContent[address]", place.getVicinity()); 
			restClient.AddParam("metaContent[lat]", place.getLatitude()+""); 
			restClient.AddParam("metaContent[lng]", place.getLongitude()+"");

			List<String> invitedPeopleList = Utility
					.getListFromHashMap(selectedFriends);
			for (int i = 0; i < invitedPeopleList.size(); i++) {
				restClient.AddParam("recipients[]", invitedPeopleList.get(i));
			}
			// end of invited people

			// add invited circles
			/*List<String> invitedCircleList = Utility
					.getListFromHashMap(selectedCircles);
			for (int i = 0; i < invitedCircleList.size(); i++) {
				restClient.AddParam("invitedCircles[]",
						invitedCircleList.get(i));
			}*/
			// end of invited circles

			try {
				restClient.Execute(RestClient.RequestMethod.POST);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = restClient.getResponse();
			responseStatus = restClient.getResponseCode();

			runOnUiThread(sendRequestResponse);
		}
	};

	private Runnable sendRequestResponse = new Runnable() {

		@Override
		public void run() { // TODO Auto-generated method stub

			if (m_ProgressDialog != null) {

				m_ProgressDialog.dismiss();

			}

			handleResponseRequest(responseStatus, responseString);

		}
	};

	public void handleResponseRequest(int status, String response) {
		// show proper message through Toast or Dialog

		Log.i("RECOMMANDATION REQUEST RESPONSE", status + ":" + response);

		if (status == Constant.STATUS_CREATED) {

			// etNewMessage.setText("");
			Toast.makeText(context, "Recommandation request sent successfully.",
					Toast.LENGTH_SHORT).show();

			finish();

		} else {
			Toast.makeText(context, "Failed. Please try again.",
					Toast.LENGTH_SHORT).show();
		}

	}

}
