package com.socmaps.listrow;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * PeopleRowFactory2 class for generating a row (view), which row (view) is associates with corresponding layout.
 *
 */
public class PeopleRowFactory2 {

	/**
	 * This method returns a View, that view is associates with corresponding
	 * layout.
	 * 
	 * @param inflater
	 *            to inflate the corresponding layout.
	 * @param peopleObj
	 *            an object of type People.
	 * @param con
	 *            current state of the application/object.
	 * @param licl
	 *            which is used for a specific action when button is clicked.
	 * @param convertView
	 *            as view.
	 * @param il
	 *            which is used to download image from a specific url.
	 * @param listItemClickListenerPeople
	 *            which is used for a specific action when button is clicked.
	 * @return View
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater,
			final Object peopleObj, final Context con,
			final ListItemClickListener licl, final View convertView,
			final ImageDownloader il,
			final ListItemClickListenerPeople listItemClickListenerPeople) {
		final ViewHolder holder;
		View view;
		final People people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_item_people_list, null);

			// use the view holder pattern to save of already looked up subviews
			holder = new ViewHolder(
					(ImageView) viewGroup.findViewById(R.id.cover_image_view),
					(ImageView) viewGroup.findViewById(R.id.people_icon_image),
					(ImageView) viewGroup.findViewById(R.id.source_image_btn),
					(ImageView) viewGroup.findViewById(R.id.map_image_btn),
					(TextView) viewGroup.findViewById(R.id.first_name_text),
					(TextView) viewGroup.findViewById(R.id.status_msg_text),
					(TextView) viewGroup.findViewById(R.id.address_text),
					(TextView) viewGroup.findViewById(R.id.time_text),
					(TextView) viewGroup.findViewById(R.id.distance_text),
					(TextView) viewGroup.findViewById(R.id.tvFriendshipStatus),
					(LinearLayout) viewGroup
							.findViewById(R.id.llFriendshipStatusContainer),
					(ImageView) viewGroup.findViewById(R.id.ivOnline));
			viewGroup.setTag(holder);

			view = viewGroup;
		} else {
			// get the holder back out
			holder = (ViewHolder) convertView.getTag();

			view = convertView;
		}

		people = ((People) peopleObj);

		// *****************************************************************check
		// the user type sm/fb
		holder.sourceImage.setVisibility(View.GONE);
		if (people.getRegMedia() != null) {
			if (!people.getRegMedia().equals("")) {
				if (people.getRegMedia().equals("fb")) {
					holder.sourceImage
							.setImageResource(R.drawable.facebookicon);
					holder.sourceImage.setVisibility(View.VISIBLE);
				} else {
					holder.sourceImage.setImageResource(R.drawable.icon);
					holder.sourceImage.setVisibility(View.VISIBLE);
				}

			} else
				holder.sourceImage.setVisibility(View.GONE);
		}

		// ******************************************************************first
		// name

		holder.firstNameText.setText(Utility.getFieldText(people));
		// ******************************************************************status
		if (people.getStatusMsg() != null) {
			if (!people.getStatusMsg().equals("")) {

				holder.statusText.setText(people.getStatusMsg());
				holder.statusText.setVisibility(View.VISIBLE);

			} else
				holder.statusText.setVisibility(View.GONE);
		} else
			holder.statusText.setVisibility(View.GONE);

		// ******************************************************************last
		// log in

		if (people.getLastLogIn() != null) {

			Log.e("Formatted date - ",
					Utility.getFormattedDisplayDate(people.getLastLogIn()));

			holder.timeText.setText(Utility.getFormattedDisplayDate(people
					.getLastLogIn()));
			holder.timeText.setVisibility(View.VISIBLE);
		} else
			holder.timeText.setVisibility(View.GONE);

		// ******************************************************************current
		// position

		if (people.getCurrentAddress() != null) {
			holder.addressText.setText(people.getCurrentAddress());
			holder.addressText.setVisibility(View.VISIBLE);
			Log.d("People Row Factory1", people.getCurrentAddress());
		} else {
			holder.addressText.setVisibility(View.GONE);
		}

		if (people.isOnline()) {
			holder.ivOnline.setImageResource(R.drawable.online);
		}

		if (people.getCoverPhoto() != null
				&& !people.getCoverPhoto().equals("")) {

			holder.coverPhoto.setImageResource(R.drawable.img_blank);

			il.download(people.getCoverPhoto(), holder.coverPhoto);

		} else
			holder.coverPhoto.setImageResource(R.drawable.cover_pic_people);

		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {

				holder.avatar.setImageResource(R.drawable.img_blank);
				il.download(people.getAvatar(), holder.avatar);

			}

		}

		if (people.getDistance() < Constant.MAX_ITEM_DISTANCE) {
			holder.distanceText
					.setText(Utility.getFormatedDistance(people.getDistance(),
							StaticValues.myInfo.getSettings().getUnit()));
		} else {
			holder.distanceText.setVisibility(View.INVISIBLE);
			holder.showOnMap.setVisibility(View.INVISIBLE);
		}

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				listItemClickListenerPeople.onShowOnMapButtonClick(people);

			}
		});

		holder.coverPhoto.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				listItemClickListenerPeople.onItemClick(people);
			}
		});

		holder.avatar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				listItemClickListenerPeople.onItemClick(people);
			}
		});

		if (people.getFriendshipStatus() != null) {
			if (people.getFriendshipStatus().equalsIgnoreCase(
					Constant.STATUS_FRIENDSHIP_FRIEND)) {
				holder.friendshipStatus.setText(people.getFriendshipStatus());
				holder.llFriendshipStatusContainer.setVisibility(View.VISIBLE);
			} else {
				holder.llFriendshipStatusContainer.setVisibility(View.GONE);
			}

		} else {
			holder.llFriendshipStatusContainer.setVisibility(View.GONE);
		}

		return view;
	}

	private static class ViewHolder {
		final ImageView coverPhoto;
		final ImageView avatar;
		final ImageView sourceImage;
		final ImageView showOnMap;
		final TextView firstNameText;
		final TextView statusText;
		final TextView addressText;
		final TextView timeText;
		final TextView distanceText;
		final TextView friendshipStatus;
		final LinearLayout llFriendshipStatusContainer;
		final ImageView ivOnline;

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, ImageView image4, TextView textView1,
				TextView textView2, TextView textView3, TextView textView4,
				TextView textView5, TextView textView6,
				LinearLayout linearLayout, ImageView ivOnline) {
			this.coverPhoto = image1;
			this.avatar = image2;
			this.sourceImage = image3;
			this.showOnMap = image4;
			this.firstNameText = textView1;
			this.statusText = textView2;
			this.addressText = textView3;
			this.timeText = textView4;
			this.distanceText = textView5;
			this.friendshipStatus = textView6;
			this.llFriendshipStatusContainer = linearLayout;
			this.ivOnline = ivOnline;
		}
	}

}
