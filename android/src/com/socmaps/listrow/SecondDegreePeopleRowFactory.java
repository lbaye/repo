package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageFetcher;
import com.socmaps.images.ImageFetcher;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * SecondDegreePeopleRowFactory class for generating a row (view), which row
 * (view) is associates with corresponding layout.
 * 
 */
public class SecondDegreePeopleRowFactory {

	/**
	 * This method returns a View, that view is associates with corresponding
	 * layout.
	 * 
	 * @param inflater
	 *            to inflate the corresponding layout.
	 * @param peopleObj
	 *            an object of type Secondary People.
	 * @param con
	 *            current state of the application/object.
	 * @param convertView
	 *            as view.
	 * @param imageFetcher
	 *            which is used to download image from a specific url.
	 * @param listItemClickListenerSecondDegreePeople
	 *            which is used for a specific action when button is clicked.
	 * @return View
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater, final Object peopleObj, final Context con, final View convertView, final ImageFetcher imageFetcher,
			final ListItemClickListenerPeople listItemClickListenerSecondDegreePeople) {
		final ViewHolder holder;
		View view;
		final SecondDegreePeople people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(R.layout.row_list_people_second_degree, null);

			// use the view holder pattern to save of already looked up subviews
			holder = new ViewHolder((ImageView) viewGroup.findViewById(R.id.cover_image_view), (ImageView) viewGroup.findViewById(R.id.people_icon_image),
					(ImageView) viewGroup.findViewById(R.id.map_image_btn), (TextView) viewGroup.findViewById(R.id.first_name_text), (TextView) viewGroup.findViewById(R.id.status_msg_text),
					(TextView) viewGroup.findViewById(R.id.address_text), (TextView) viewGroup.findViewById(R.id.distance_text));
			viewGroup.setTag(holder);

			view = viewGroup;
		} else {
			// get the holder back out
			holder = (ViewHolder) convertView.getTag();

			view = convertView;
		}

		people = (SecondDegreePeople) peopleObj;

		holder.firstNameText.setText(Utility.getItemTitle(people));
		// ******************************************************************status

		String status = "Checked-in at " + people.getLastSeenAt() + " " + Utility.getFormattedDisplayDateForMap(people.getCreateTime());

		holder.statusText.setText(status);

		// ******************************************************************current
		// position

		if (people.getCurrentAddress() != null) {
			holder.addressText.setText(people.getCurrentAddress());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);

		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {
				holder.avatar.setImageResource(R.drawable.img_blank);

				holder.avatar.setImageResource(R.drawable.img_blank);
				imageFetcher.loadImage(people.getAvatar(), holder.avatar);
			}

		}

		if (people.getCoverPhoto() != null && !people.getCoverPhoto().equals("")) {

			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			imageFetcher.loadImage(people.getAvatar(), holder.coverPhoto);
		} else {
			holder.coverPhoto.setImageResource(R.drawable.cover_pic_default);
		}

		double distance = Utility.calculateDistanceFromCurrentLocation(people.getPoint());
		holder.distanceText.setText(Utility.getFormatedDistance(distance, StaticValues.myInfo.getSettings().getUnit()));

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				listItemClickListenerSecondDegreePeople.onShowOnMapButtonClick(people);

			}
		});

		holder.coverPhoto.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				// listItemClickListenerSecondDegreePeople.onItemClick(peopleObj);
			}
		});

		holder.avatar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				// listItemClickListenerSecondDegreePeople.onItemClick(peopleObj);
			}
		});

		return view;
	}

	private static class ViewHolder {
		final ImageView coverPhoto;
		final ImageView avatar;
		final ImageView showOnMap;
		final TextView firstNameText;
		final TextView statusText;
		final TextView addressText;
		final TextView distanceText;

		private ViewHolder(ImageView image1, ImageView image2, ImageView image4, TextView textView1, TextView textView2, TextView textView3, TextView textView5) {
			this.coverPhoto = image1;
			this.avatar = image2;

			this.showOnMap = image4;
			this.firstNameText = textView1;
			this.statusText = textView2;
			this.addressText = textView3;
			this.distanceText = textView5;
		}
	}

}
