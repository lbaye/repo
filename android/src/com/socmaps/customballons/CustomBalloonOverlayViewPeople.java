package com.socmaps.customballons;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.maps.OverlayItem;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class CustomBalloonOverlayViewPeople<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView name, status, distance, age;

	private ImageView image, ivOnline, ivOffline;
	private ImageDownloader imageDownloader;

	protected CustomBalloonOverlayViewPeople(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;

	}

	protected CustomBalloonOverlayViewPeople(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_user, parent);

		// setup our fields
		name = (TextView) v.findViewById(R.id.name_text);
		status = (TextView) v.findViewById(R.id.status_text);
		distance = (TextView) v.findViewById(R.id.distance_text);
		age = (TextView) v.findViewById(R.id.age_text);
		image = (ImageView) v.findViewById(R.id.balloon_item_image);
		ivOnline = (ImageView) v.findViewById(R.id.ivOnline);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields

		name.setText(Utility.getFieldText(item.getUser()));
		name.setVisibility(View.VISIBLE);

		if (Utility.isValidString(item.getUser().getStatusMsg())) {
			status.setText(item.getUser().getStatusMsg());
			status.setVisibility(View.VISIBLE);
		} else
			status.setVisibility(View.GONE);
		if (Utility.isValidString(String.format("%.2f", item.getUser()
				.getDistance()))) {
			distance.setText(Utility
					.getFormatedDistance(item.getUser().getDistance(),
							StaticValues.myInfo.getSettings().getUnit())
					+ " away");
			distance.setVisibility(View.VISIBLE);
		} else
			distance.setVisibility(View.GONE);
		if (item.getUser().getAge() != 0) {
			age.setText("-Age:" + item.getUser().getAge());
			age.setVisibility(View.VISIBLE);
		} else
			age.setVisibility(View.GONE);

		if (item.getUser().isOnline()) {
			ivOnline.setImageResource(R.drawable.online);
		} else {
			ivOnline.setImageResource(R.drawable.offline);
		}

		image.setImageResource(R.drawable.img_blank);
		imageDownloader.download(item.getUser().getAvatar(), image);
	}
}
