package com.socmaps.customballons;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.google.android.maps.OverlayItem;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class CustomBalloonOverlayViewMeetup<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView address, distance;
	private ImageDownloader imageDownloader;

	public CustomBalloonOverlayViewMeetup(Context context,
			int balloonBottomOffset,ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}
	
	public CustomBalloonOverlayViewMeetup(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_event, parent);

		// setup our fields

		address = (TextView) v.findViewById(R.id.address_text);
		distance = (TextView) v.findViewById(R.id.distance_text);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields

		address.setText(item.getMeetup().getAddress());
		// distance.setText(String.format("%.2f",
		// item.getMeetup().getDistance())+" miles away");
		distance.setText(Utility.getFormatedDistance(item.getMeetup()
				.getDistance(), StaticValues.myInfo.getSettings().getUnit())
				+ " away");

	}

}
