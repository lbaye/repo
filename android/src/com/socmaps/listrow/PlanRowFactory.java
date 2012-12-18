package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.maps.GeoPoint;
import com.socmaps.entity.Plan;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PlanRowFactory { 
	
	/**
	 * This method returns a View, that view is associates with corresponding layout.  
	 * 
	 * @param inflater to inflate the corresponding layout. 
	 * @param plan an object of type Plan.
	 * @param context current state of the application/object.  
	 * @param clickListener which is used for a specific action when button is clicked.  
	 * @param position as Integer which refers to the item position of the list 
	 * @param convertView as view 
	 * @param il which is used to download image from a specific url.  
	 * @param a as Integer which is used to determine if it comes from Own Profile or Friends Profile
	 * @return View 
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater, final Plan plan,
			final Context context,
			final ListItemClickListenerPlan clickListener, final int position,
			final View convertView, final ImageDownloader il, int a) {

		ViewHolder holder;
		View view;

		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_plan, null);

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
		if (plan.getDescription() != null) {
			if (!plan.getDescription().equals("")) {
				holder.planNameText.setText(plan.getDescription());
				holder.planNameText.setVisibility(View.VISIBLE);
			} else
				holder.planNameText.setVisibility(View.GONE);
		} else
			holder.planNameText.setVisibility(View.GONE);

		// set address
		if (plan.getAddress() != null) {
			if (!plan.getAddress().equals("")) {
				holder.addressText.setText(plan.getAddress());
				holder.addressText.setVisibility(View.VISIBLE);
			} else
				holder.addressText.setVisibility(View.GONE);
		} else
			holder.addressText.setVisibility(View.GONE);

		// set Date
		if (plan.getPlanTime() != null) {

			// holder.planDateTimeText.setText(Utility.getFormattedDisplayDateplanList(plan.getPlanTime()));
			holder.planDateTimeText.setText(Utility
					.getFormattedDisplayDateEventList(plan.getPlanTime()));
			holder.planDateTimeText.setVisibility(View.VISIBLE);

		} else
			holder.planDateTimeText.setVisibility(View.GONE);

		// set image Lazy load
		holder.coverPhoto.setImageResource(R.drawable.img_blank);
		if (plan.getPlanImageUrl() != null) {

			if (!plan.getPlanImageUrl().equalsIgnoreCase("")) {
				// il.DisplayImage(plan.getplanImageUrl(),
				// holder.coverPhoto,R.drawable.img_blank);
				il.download(plan.getPlanImageUrl(), holder.coverPhoto);
			}
		}

		// set distance
		// holder.distanceText.setText(Utility.getFormatedDistance(((Plan)
		// plan).getDistance(), StaticValues.myInfo.getSettings().getUnit()));
		if (StaticValues.myPoint != null) {
			holder.distanceText.setText(Utility.getFormatedDistance(Utility
					.calculateDistance(StaticValues.myPoint,
							new GeoPoint((int) (plan.getLatitude() * 1E6),
									(int) (plan.getLongitude() * 1E6))),
					StaticValues.myInfo.getSettings().getUnit()));
		}

		// set arrowClicklistener
		holder.rightArrow.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				clickListener.onArrowButtonClick(plan);

			}
		});

		holder.coverPhoto.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				clickListener.onItemClick(plan);
			}
		});

		// set mapButtonClick

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				clickListener.onShowOnMapButtonClick(plan);
			}
		});

		if (a == 1) {
			holder.btnEdit.setVisibility(View.VISIBLE);
			holder.btnDelete.setVisibility(View.VISIBLE);
			holder.ivSeparator.setVisibility(View.VISIBLE);
			// holder.btnEditPlace.setVisibility(View.VISIBLE);
		} else {
			holder.btnEdit.setVisibility(View.INVISIBLE);
			holder.btnDelete.setVisibility(View.INVISIBLE);
			holder.ivSeparator.setVisibility(View.INVISIBLE);
			// holder.btnEditPlace.setVisibility(View.INVISIBLE);
		}

		holder.btnEdit.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				clickListener.onShowEditButtonClick(plan);
			}
		});

		holder.btnDelete.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				clickListener.onShowDeleteButtonClick(plan);
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
				(Button) viewGroup.findViewById(R.id.editPlanBtn),
				(Button) viewGroup.findViewById(R.id.deletePlanBtn),
				(ImageView) viewGroup.findViewById(R.id.ivSeparator));
	}

	private static class ViewHolder {
		final ImageView coverPhoto;
		final ImageView showOnMap;
		final TextView planNameText;
		final TextView planDateTimeText;
		final TextView addressText;
		final TextView distanceText;
		final ImageView rightArrow;
		final Button btnEdit;
		final Button btnDelete;
		final ImageView ivSeparator;

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, TextView textView1, TextView textView2,
				TextView textView3, TextView textView4, Button button1,
				Button button2, ImageView image4) {
			this.coverPhoto = image1;
			this.rightArrow = image3;
			this.showOnMap = image2;
			this.planNameText = textView1;
			this.planDateTimeText = textView2;
			this.addressText = textView3;
			this.distanceText = textView4;

			this.btnEdit = button1;
			this.btnDelete = button2;

			this.ivSeparator = image4;
		}
	}

}
