package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.socmaps.entity.Event;
import com.socmaps.images.ImageDownloader;
import com.socmaps.images.ImageLoader;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class EventRowFactory { 
	
	/**
	 * This method returns a View, that view is associates with corresponding layout. 
	 * 
	 * @param inflater  to inflate the corresponding layout. 
	 * @param event     an object of type Event. 
	 * @param context   current state of the application/object.
	 * @param clickListener which is used for a specific action when button is clicked. 
	 * @param position as Integer which refers to the item position of the list
	 * @param convertView as view. 
	 * @param il which is used to download image from a specific url. 
	 * @return View 
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater,
			final Event event, final Context context,
			final ListItemClickListenerEvent clickListener, final int position,
			final View convertView, final ImageDownloader il) {

		ViewHolder holder;
		View view;

		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_event, null);

			// use the view holder pattern to save of already looked up subviews
			holder = buildViewHolder(viewGroup);
			viewGroup.setTag(holder);

			view = viewGroup;
		} else {
			// get the holder back out
			holder = (ViewHolder) convertView.getTag();

			view = convertView;
		}

		// set Title text
		if (event.getEventTitle() != null) {
			if (!event.getEventTitle().equals("")) {
				holder.eventNameText.setText(event.getEventTitle());
				holder.eventNameText.setVisibility(View.VISIBLE);
			} else
				holder.eventNameText.setVisibility(View.GONE);
		} else
			holder.eventNameText.setVisibility(View.GONE);

		// set short summary text
		if (event.getShortSummary() != null) {
			if (!event.getShortSummary().equals("")) {
				holder.shortSummaryText.setText(event.getShortSummary());
				holder.shortSummaryText.setVisibility(View.VISIBLE);
			} else
				holder.shortSummaryText.setVisibility(View.GONE);
		} else
			holder.shortSummaryText.setVisibility(View.GONE);

		// set address
		if (event.getAddress() != null) {
			if (!event.getAddress().equals("")) {
				holder.addressText.setText(event
						.getAddress());
				holder.addressText.setVisibility(View.VISIBLE);
			} else
				holder.addressText.setVisibility(View.GONE);
		} else
			holder.addressText.setVisibility(View.GONE);

		// set Date
		if (event.getEventTime() != null) {

			holder.eventDateTimeText.setText(Utility
					.getFormattedDisplayDateEventList(event.getEventTime()));
			holder.eventDateTimeText.setVisibility(View.VISIBLE);

		} else
			holder.eventDateTimeText.setVisibility(View.GONE);

		// set image Lazy load
		holder.coverPhoto.setImageResource(R.drawable.img_blank);
		if (event.getEventImageUrl() != null) {

			if (!event.getEventImageUrl().equalsIgnoreCase("")) {
				//il.DisplayImage(event.getEventImageUrl(), holder.coverPhoto,R.drawable.img_blank);
				il.download(event.getEventImageUrl(), holder.coverPhoto);
			}

			/*
			 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource
			 * ( context.getResources(), R.drawable.event_item_bg)); if
			 * (!eventEntity.getEventImageUrl().equals("")) {
			 * Log.e("Event image:", eventEntity.getEventImageUrl());
			 * 
			 * holder.coverPhoto.setTag(eventEntity.getEventImageUrl());
			 * BitmapManager.INSTANCE.loadBitmap(
			 * eventEntity.getEventImageUrl(), holder.coverPhoto, 320, 180); }
			 * // holder.statusText.setText(otherUserEntity.getStatusMsg());
			 */
		} // else holder.coverPhoto.setImageResource(R.drawable.event_item_bg);

		// Rsvp Panel show hide &&
		// !("my_event").equalsIgnoreCase(eventEntity.getEvent_type())
		if (event.isInvited()
				&& !("my_event").equalsIgnoreCase(event.getEvent_type())) {
			holder.rsvpPanel.setVisibility(View.VISIBLE);
			setRadioGroupValue(holder.rsvpGroup, event.getMyResponse());

		} else
			holder.rsvpPanel.setVisibility(View.GONE);

		RadioButtonClickListener listener = new RadioButtonClickListener(event,
				clickListener);

		holder.yesBtn.setOnClickListener(listener);
		holder.noBtn.setOnClickListener(listener);
		holder.maybeBtn.setOnClickListener(listener);

		// set distance
		String unit = Constant.UNIT_METRIC;
		if(StaticValues.myInfo!=null)
		{
			if(StaticValues.myInfo.getSettings()!=null)
			{
				if(StaticValues.myInfo.getSettings().getUnit()!=null)
				{
					unit = StaticValues.myInfo.getSettings().getUnit();
				}
			}
		}
		
		holder.distanceText.setText(Utility.getFormatedDistance(event
				.getDistance(), unit));

		// set arrowClicklistener
		holder.rightArrow.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				//StaticValues.selectedEvent = event;
				clickListener.onArrowButtonClick(event);
			}
		});

		holder.coverPhoto.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				//StaticValues.selectedEvent = event;
				clickListener.onItemClick(event);
			}
		});

		// set mapButtonClick

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				clickListener.onShowOnMapButtonClick(event);
			}
		});

		return view;
	}

	private static ViewHolder buildViewHolder(final ViewGroup viewGroup) {
		return new ViewHolder(
				(ImageView) viewGroup.findViewById(R.id.cover_image_view),
				(ImageView) viewGroup.findViewById(R.id.map_image_btn),
				(ImageView) viewGroup.findViewById(R.id.arrow_right),
				(TextView) viewGroup.findViewById(R.id.event_name_text),
				(TextView) viewGroup.findViewById(R.id.event_date_text),
				(TextView) viewGroup.findViewById(R.id.address_text),
				(TextView) viewGroup.findViewById(R.id.distance_text),
				(TextView) viewGroup.findViewById(R.id.short_summary_text),
				(LinearLayout) viewGroup.findViewById(R.id.rsvp_panel),
				(RadioGroup) viewGroup.findViewById(R.id.rgRSVPSelector),
				(RadioButton) viewGroup.findViewById(R.id.yes_btn),
				(RadioButton) viewGroup.findViewById(R.id.no_btn),
				(RadioButton) viewGroup.findViewById(R.id.maybe_btn));
	}

	private static class RadioButtonClickListener implements OnClickListener {

		private ListItemClickListenerEvent mListener;
		private Event mEntity;

		public RadioButtonClickListener(final Event entity,
				final ListItemClickListenerEvent clickListener) {
			mListener = clickListener;
			mEntity = entity;
		}

		@Override
		public void onClick(View v) {
			boolean checked = ((RadioButton) v).isChecked();

			switch (v.getId()) {
			case R.id.yes_btn:
				if (checked)
					mListener.onRSVPSelection(mEntity, Constant.MY_RESPONSE_YES);
				break;
			case R.id.no_btn:
				if (checked)
					mListener.onRSVPSelection(mEntity, Constant.MY_RESPONSE_NO);
				break;
			case R.id.maybe_btn:
				if (checked)
					mListener.onRSVPSelection(mEntity, Constant.MY_RESPONSE_MAYBE);
				break;
			}
		}
	}

	private static void setRadioGroupValue(RadioGroup rG, String status) {
		if (Constant.MY_RESPONSE_YES.equalsIgnoreCase(status)) {
			((RadioButton) rG.findViewById(R.id.yes_btn)).setChecked(true);
		} else if (Constant.MY_RESPONSE_NO.equalsIgnoreCase(status)) {
			((RadioButton) rG.findViewById(R.id.no_btn)).setChecked(true);
		} else {
			((RadioButton) rG.findViewById(R.id.maybe_btn)).setChecked(true);
		}

	}

	private static class ViewHolder {
		final ImageView coverPhoto;
		final ImageView showOnMap;
		final TextView eventNameText;
		final TextView eventDateTimeText;
		final TextView addressText;
		final TextView shortSummaryText;
		final TextView distanceText;
		final LinearLayout rsvpPanel;
		final RadioGroup rsvpGroup;
		final RadioButton yesBtn, noBtn, maybeBtn;
		final ImageView rightArrow;

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, TextView textView1, TextView textView2,
				TextView textView3, TextView textView4, TextView textView5,
				LinearLayout rsvp, RadioGroup rg, RadioButton rb1,
				RadioButton rb2, RadioButton rb3) {
			this.coverPhoto = image1;
			this.rightArrow = image3;
			this.showOnMap = image2;
			this.eventNameText = textView1;
			this.eventDateTimeText = textView2;
			this.addressText = textView3;
			this.shortSummaryText = textView5;
			this.distanceText = textView4;
			this.rsvpPanel = rsvp;
			this.rsvpGroup = rg;
			this.yesBtn = rb1;
			this.noBtn = rb2;
			this.maybeBtn = rb3;
		}
	}

	/*
	 * @Override public int getViewType() { // TODO Auto-generated method stub
	 * return 0; }
	 */

}
