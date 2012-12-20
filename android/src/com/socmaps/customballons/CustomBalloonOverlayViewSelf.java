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

public class CustomBalloonOverlayViewSelf<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView name;

	private ImageView image;

	private ImageDownloader imageDownloader;

	protected CustomBalloonOverlayViewSelf(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}

	protected CustomBalloonOverlayViewSelf(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_self, parent);

		// setup our fields
		name = (TextView) v.findViewById(R.id.title_text);

		image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields

		name.setText("Me");

		image.setImageResource(R.drawable.img_blank);

		if (item.getMe().getAvatar() != null) {

			imageDownloader.download(item.getMe().getAvatar(), image);
		}
	}
}
