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
import com.socmaps.util.Utility;

public class CustomBalloonOverlayViewGeotag<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView tvTitle, tvUser, tvAddress;

	protected CustomBalloonOverlayViewGeotag(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
	}

	protected CustomBalloonOverlayViewGeotag(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_geotag, parent);

		// setup our fields
		tvTitle = (TextView) v.findViewById(R.id.title_text);
		tvUser = (TextView) v.findViewById(R.id.user_text);
		tvAddress = (TextView) v.findViewById(R.id.address_text);
	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields
		String title = item.getGeotag().getTitle();
		if (title != null && !title.equalsIgnoreCase("")) {
			tvTitle.setText(title + " tagged");
		} else {
			tvTitle.setVisibility(View.GONE);
		}

		if (item.getGeotag().getOwner() != null) {
			String name = Utility.getFieldText(item.getGeotag().getOwner());
			if (!name.equalsIgnoreCase("")) {
				tvUser.setText("by " + name);
			} else {
				tvUser.setVisibility(View.GONE);
			}
		} else {
			tvUser.setVisibility(View.GONE);
		}

		String address = item.getGeotag().getAddress();
		if (!address.equalsIgnoreCase("")) {
			tvAddress.setText("at " + address);
		} else {
			tvAddress.setVisibility(View.GONE);
		}
	}
}
