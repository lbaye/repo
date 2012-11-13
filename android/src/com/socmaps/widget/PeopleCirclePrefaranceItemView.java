package com.socmaps.widget;

import java.util.List;

import android.content.Context;
import android.graphics.Typeface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.Utility;

public class PeopleCirclePrefaranceItemView extends LinearLayout implements
		View.OnClickListener {

	private Context context;

	String itemId;
	private LinearLayout llHeaderPanel;
	private RelativeLayout rlTitleLayout;
	private View headerSeperator;
	private TextView tvItemTitle;

	private ImageView ivArrowRight;
	private LinearLayout llItemContents;

	private boolean isToggle = true;
	private boolean hideHeader = false;

	public boolean isExpanded = false;

	LinearLayout llCirclePanel, llCircleFriendsList;

	private Circle circle;

	private ImageDownloader imageDownloader;

	public PeopleCirclePrefaranceItemView(Context context, Circle circle,
			ImageDownloader imageDownloader) {
		super(context, null);

		this.context = context;
		this.circle = circle;
		this.imageDownloader = imageDownloader;
		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.row_people_circle_preference_item, this, true);

		init();
		setDefaultValues();
		generateCircleFriendsView();

	}

	private void init() {

		llHeaderPanel = (LinearLayout) findViewById(R.id.llHeaderPanel);
		llHeaderPanel.setOnClickListener(this);

		rlTitleLayout = (RelativeLayout) findViewById(R.id.rlTitleLayout);
		headerSeperator = findViewById(R.id.headerSeperator);

		tvItemTitle = (TextView) findViewById(R.id.tvItemTitle);

		ivArrowRight = (ImageView) findViewById(R.id.ivArrowRight);
		llItemContents = (LinearLayout) findViewById(R.id.llItemContents);

		llCircleFriendsList = (LinearLayout) findViewById(R.id.llCircleFriendsList);

	}

	private void setDefaultValues() {

		if (circle != null) {
			
			
			tvItemTitle.setText(circle.getName() + " ("
					+ circle.getFriendList().size() + ")");
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

		if (v == llHeaderPanel) {
			if (isToggle) {
				toggle();
			}

		}

	}

	public void toggle() {
		if (isExpanded) {
			llItemContents.setVisibility(View.GONE);

			ivArrowRight.setImageResource(R.drawable.icon_arrow_down);
			tvItemTitle.setTypeface(null, Typeface.NORMAL);
			headerSeperator.setVisibility(View.VISIBLE);

		} else {
			llItemContents.setVisibility(View.VISIBLE);

			ivArrowRight.setImageResource(R.drawable.icon_arrow_up);
			tvItemTitle.setTypeface(null, Typeface.BOLD);
			headerSeperator.setVisibility(View.GONE);
		}
		isExpanded = !isExpanded;
	}

	private void generateCircleFriendsView() {

		List<People> friendList = circle.getFriendList();

		Log.w("circle.getFriendList() is", "CircleName: "
				+ circle.getName() + " : " + friendList.size() + " ????");

		llCircleFriendsList.removeAllViews();

		for (People peopleItem : friendList) {

			People people = Utility.getPeopleById(peopleItem.getId());

			Log.w("PeopleCirclePrefaranceItemView peopleItem.getId() in for loop >>>>>>>>>>>>>>",
					peopleItem.getId());

			if (people != null) {

				Log.w("PeopleCirclePrefaranceItemView people >>>>>>>>>>>>>>",
						"Name: " + people.getFirstName() + people.getLastName()
								+ " Address: " + people.getCurrentAddress()
								+ " Avater: " + people.getAvatar());

				llCircleFriendsList
						.addView(new PeopleCircleFriendsPrefaranceItemView(
								context, people, imageDownloader));
			}
		}

	}

}
