/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.images.ImageLoader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;

public class PeoplePicker extends Dialog implements OnClickListener {
	Button btnCancel, btnOk;

	PeoplePickerListener peoplePickerListener;
	Context context;
	String pickerName;

	LayoutInflater inflater;
	Button btnFriendSelect, btnCircleSelect, btnSelectAll, btnUnselectAll;
	EditText etFriendSearch;
	LinearLayout friendListContainer, circleListContainer;
	ScrollView scrollViewFriends, scrollViewCircles;
	HashMap<String, Boolean> selectedFriends = new HashMap<String, Boolean>();
	HashMap<String, Boolean> selectedCircles = new HashMap<String, Boolean>();

	List<String> selectedFriendList;
	List<String> selectedCircleList;
	List<String> selectedCircleFriendList;
	List<String> selectedFriendListAll;

	List<String> preSelectedFriendList;
	List<String> preSelectedCircleList;

	List<String> removedFriendList;
	List<String> removedCircleList;

	ImageLoader imageLoader;

	public PeoplePicker(Context context,
			PeoplePickerListener peoplePickerListener, String pickerName,
			List<String> preSelectedFriendList,
			List<String> preSelectedCircleList) {
		this(context, peoplePickerListener, pickerName, preSelectedFriendList,
				preSelectedCircleList, null, null);
	}

	public PeoplePicker(Context context,
			PeoplePickerListener peoplePickerListener, String pickerName,
			List<String> preSelectedFriendList,
			List<String> preSelectedCircleList, List<String> removedFriendList,
			List<String> removedCircleList) {
		super(context);
		this.peoplePickerListener = peoplePickerListener;
		this.context = context;
		this.pickerName = pickerName;

		imageLoader = new ImageLoader(this.context);

		this.preSelectedFriendList = preSelectedFriendList;
		this.preSelectedCircleList = preSelectedCircleList;

		if (removedFriendList != null) {
			this.removedFriendList = removedFriendList;
		} else {
			this.removedFriendList = new ArrayList<String>();
		}

		if (removedCircleList != null) {
			this.removedCircleList = removedCircleList;
		} else {
			this.removedCircleList = new ArrayList<String>();
		}

		/** It will hide the title */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.people_picker_dialog_layout);

		initialize();
		generateFriendList();
		showFriendList();

	}

	private void initialize() {

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

		btnOk = (Button) findViewById(R.id.btnOk);
		btnOk.setOnClickListener(this);

		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		btnFriendSelect = (Button) findViewById(R.id.btnFriendSelect);
		btnFriendSelect.setOnClickListener(this);
		btnCircleSelect = (Button) findViewById(R.id.btnCircleSelect);
		btnCircleSelect.setOnClickListener(this);
		btnSelectAll = (Button) findViewById(R.id.btnSelectAll);
		btnSelectAll.setOnClickListener(this);
		btnUnselectAll = (Button) findViewById(R.id.btnUnselectAll);
		btnUnselectAll.setOnClickListener(this);
		etFriendSearch = (EditText) findViewById(R.id.etFriendSearch);
		friendListContainer = (LinearLayout) findViewById(R.id.friendListContainer);
		circleListContainer = (LinearLayout) findViewById(R.id.circleListContainer);
		scrollViewFriends = (ScrollView) findViewById(R.id.scrollViewFriends);
		scrollViewCircles = (ScrollView) findViewById(R.id.scrollViewCircles);

	}

	@Override
	public void onClick(View v) {
		if (v == btnCancel) {
			dismiss();
		}
		if (v == btnOk) {

			selectedFriendList = new ArrayList<String>();
			selectedCircleList = new ArrayList<String>();
			selectedCircleFriendList = new ArrayList<String>();
			selectedFriendListAll = new ArrayList<String>();

			Set set = selectedFriends.entrySet();
			// Get an iterator
			Iterator iterator = set.iterator();
			// Display elements
			while (iterator.hasNext()) {
				Map.Entry me = (Map.Entry) iterator.next();

				String key = (String) me.getKey();
				boolean isSelected = (Boolean) me.getValue();

				if (isSelected) {
					// Log.e("IsChecked", key);
					selectedFriendList.add(key);
					selectedFriendListAll.add(key);
				}

			}

			List<Circle> circles = StaticValues.myInfo.getCircleList();
			if (circles != null) {
				for (int i = 0; i < circles.size(); i++) {
					String circleId = circles.get(i).getId();

					if (selectedCircles.containsKey(circleId)) {
						boolean isChecked = selectedCircles.get(circleId);
						if (isChecked) {
							// Log.e("IsCheckedCircle", circleId);
							selectedCircleList.add(circleId);

							List<People> friend = circles.get(i)
									.getFriendList();
							if (friend != null) {
								for (int j = 0; j < friend.size(); j++) {
									String friendId = friend.get(j).getId();
									// Log.e("IsChecked", friendId);
									if (!selectedCircleFriendList
											.contains(friendId)) {
										selectedCircleFriendList.add(friendId);
									}

									if (!selectedFriendListAll
											.contains(friendId)
											&& !removedFriendList
													.contains(friendId)) {
										selectedFriendListAll.add(friendId);
									}

								}
							}
						}
					}
				}
			}

			peoplePickerListener.onSelect(pickerName, selectedFriendList,
					selectedCircleList, selectedCircleFriendList,
					selectedFriendListAll);
			dismiss();
		}

		if (v == btnFriendSelect) {
			showFriendList();
		} else if (v == btnCircleSelect) {
			showCircleList();
		} else if (v == btnSelectAll) {
			selectAll();
		} else if (v == btnUnselectAll) {
			unselectAll();
		}
	}

	private void generateFriendList() {

		friendListContainer.removeAllViews();
		List<People> friends = StaticValues.myInfo.getFriendList();

		// Log.e("Friends count", friends.length+"");
		if (friends != null) {

			for (int i = 0; i < friends.size(); i++) {
				// Log.e("FriendList",
				// friends[i].getId()+", "+friends[i].getFirstName());

				String friendId = friends.get(i).getId();
				if (friendId != null) {
					if (!removedFriendList.contains(friendId)) {
						View v = getItemViewFriend(friends.get(i));
						friendListContainer.addView(v);
					}
				}

			}
		}

		circleListContainer.removeAllViews();
		List<Circle> circles = StaticValues.myInfo.getCircleList();
		if (circles != null) {

			for (int i = 0; i < circles.size(); i++) {
				String circleId = circles.get(i).getId();

				if (circleId != null) {

					selectedCircles.put(circleId, false);

					if (!removedCircleList.contains(circleId)) {

						if (circles.get(i).getFriendList() != null) {
							if (circles.get(i).getFriendList().size() > 0) {
								View v = getItemViewCircle(circles.get(i));
								circleListContainer.addView(v);
							}
						}

					}
				}

			}

		}

	}

	public View getItemViewFriend(People people) {

		View v = inflater.inflate(R.layout.people_item, null);

		TextView nameView = (TextView) v.findViewById(R.id.name);
		final ImageView profilePic = (ImageView) v
				.findViewById(R.id.profilePic);

		final LinearLayout proficPicContainer = (LinearLayout) v
				.findViewById(R.id.proficPicContainer);

		String firstName = people.getFirstName();
		String lastName = people.getLastName();
		final String id = people.getId();
		String avatarUrl = people.getAvatar();

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
			 * ( context.getResources(), R.drawable.user_default));
			 * 
			 * BitmapManager.INSTANCE.loadBitmap(avatarUrl, profilePic, 55, 55);
			 */
			imageLoader.DisplayImage(avatarUrl, profilePic,
					R.drawable.user_default);

		}

		profilePic.setOnClickListener(new android.view.View.OnClickListener() {

			@Override
			public void onClick(View v) {
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

		if (preSelectedFriendList != null) {
			boolean isPreSelected = preSelectedFriendList.contains(id);
			if (isPreSelected) {
				selectedFriends.put(id, isPreSelected);
				proficPicContainer
						.setBackgroundResource(R.color.highlightGreen);
			}
		}

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
				selectedCircles.put(id, isChecked);
			}
		});

		if (preSelectedCircleList != null) {
			chkCircle.setChecked(preSelectedCircleList.contains(id));
		}

		return v;
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

	public void setButtonLabels(String positiveButtonLabel,
			String negativeButtonLabel) {
		if (positiveButtonLabel != null) {
			btnOk.setText(positiveButtonLabel);
		}
		if (negativeButtonLabel != null) {
			btnCancel.setText(negativeButtonLabel);
		}
	}

}