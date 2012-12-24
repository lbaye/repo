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
import com.socmaps.util.Utility;

public class CustomBalloonOverlayViewSecondDegreePeople<Item extends OverlayItem>
		extends BalloonOverlayView<CustomOverlayItem> {

	private TextView name, address, date;

	private ImageView image;

	private ImageDownloader imageDownloader;

	protected CustomBalloonOverlayViewSecondDegreePeople(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}

	protected CustomBalloonOverlayViewSecondDegreePeople(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_user_second_degree, parent);

		// setup our fields
		name = (TextView) v.findViewById(R.id.tvName);
		address = (TextView) v.findViewById(R.id.tvAddress);
		date = (TextView) v.findViewById(R.id.tvDate);
		image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields
		name.setText(Utility.getFieldText(item.getSecondDegreePeople()));
		name.setVisibility(View.VISIBLE);

		if (item.getSecondDegreePeople().getLastSeenAt() != null) {
			address.setText("at "
					+ item.getSecondDegreePeople().getLastSeenAt());
			address.setVisibility(View.VISIBLE);
		} else {
			address.setVisibility(View.GONE);
		}

		if (item.getSecondDegreePeople().getCreateTime() != null) {
			date.setText(Utility.getFormattedDisplayDateForMap(item
					.getSecondDegreePeople().getCreateTime()));
			date.setVisibility(View.VISIBLE);
		} else {
			date.setVisibility(View.GONE);
		}

		image.setImageResource(R.drawable.img_blank);
		imageDownloader.download(item.getSecondDegreePeople().getAvatar(),
				image);
	}
}
