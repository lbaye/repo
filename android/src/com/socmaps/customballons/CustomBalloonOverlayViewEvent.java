package com.socmaps.customballons;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.maps.OverlayItem;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.Event;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.DirectionActivity;
import com.socmaps.ui.EventDetailsActivity;
import com.socmaps.util.Utility;

public class CustomBalloonOverlayViewEvent<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView tvName, tvAddress, tvDate;

	private Button btnDetails, btnDirection;
	
	private ImageDownloader imageDownloader;
	
	 CustomBalloonOverlayViewEvent(Context context,
			int balloonBottomOffset,ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}

	 CustomBalloonOverlayViewEvent(Context context,
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
		tvName = (TextView) v.findViewById(R.id.tvName);
		tvAddress = (TextView) v.findViewById(R.id.tvAddress);
		tvDate = (TextView) v.findViewById(R.id.tvDate);

		btnDetails = (Button) v.findViewById(R.id.btnDetails);
		btnDirection = (Button) v.findViewById(R.id.btnDirection);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields

		final Event event = item.getEvent();

		if (event.getEventTitle() != null) {
			tvName.setText(event.getEventTitle());
		} else {
			tvName.setText("");
		}

		if (event.getAddress() != null) {
			tvAddress.setText("at " + event.getAddress());
		} else {
			tvAddress.setText("");
			tvAddress.setVisibility(View.GONE);
		}

		if (event.getEventTime() != null) {
			tvDate.setText(Utility.getFormattedDisplayDateForMap(event
					.getEventTime()));
		} else {
			tvDate.setVisibility(View.GONE);
		}

		btnDetails.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent eventDetailsIntent = new Intent(getContext(),
						EventDetailsActivity.class);
				eventDetailsIntent.putExtra("selectedEvent", event);
				eventDetailsIntent.putExtra("source", "map");
				getContext().startActivity(eventDetailsIntent);
			}
		});

		btnDirection.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(getContext(), DirectionActivity.class);
				intent.putExtra("destLat", event.getLatitude());
				intent.putExtra("destLng", event.getLongitude());
				intent.putExtra("destAddress", event.getAddress());
				
				getContext().startActivity(intent);

			}
		});

	}
}
