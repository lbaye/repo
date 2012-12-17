package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class SecondDegreePeopleRowFactory2 {

	public static View getView(
			final LayoutInflater inflater,
			final Object peopleObj,
			final Context con,
			final ListItemClickListener licl,
			final View convertView,
			final ImageDownloader il,
			final ListItemClickListenerSecondDegreePeople listItemClickListenerSecondDegreePeople) {
		ViewHolder holder;
		View view;
		final SecondDegreePeople people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_item_people_list_second_degree, null);

			// use the view holder pattern to save of already looked up subviews
			holder = new ViewHolder(
					(ImageView) viewGroup.findViewById(R.id.cover_image_view),
					(ImageView) viewGroup.findViewById(R.id.people_icon_image),
					(ImageView) viewGroup.findViewById(R.id.map_image_btn),
					(TextView) viewGroup.findViewById(R.id.first_name_text),
					(TextView) viewGroup.findViewById(R.id.status_msg_text),
					(TextView) viewGroup.findViewById(R.id.address_text),
					(TextView) viewGroup.findViewById(R.id.distance_text));

			viewGroup.setTag(holder);

			view = viewGroup;
		} else {
			// get the holder back out
			holder = (ViewHolder) convertView.getTag();

			view = convertView;
		}

		people = (SecondDegreePeople) peopleObj;

		holder.firstNameText.setText(Utility.getFieldText(people));
		// ******************************************************************status

		String status = "Checked-in at " + people.getLastSeenAt() + " "
				+ Utility.getFormattedDisplayDateForMap(people.getCreateTime());
		holder.statusText.setText(status);

		// holder.timeText.setVisibility(View.GONE);

		// ******************************************************************current
		// position

		if (people.getCurrentAddress() != null) {
			holder.addressText.setText(people.getCurrentAddress());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);

		// holder.coverPhoto.setImageResource(R.drawable.cover_pic_default);

		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {

				holder.avatar.setImageResource(R.drawable.img_blank);

				holder.avatar.setImageResource(R.drawable.img_blank);
				il.download(people.getAvatar(), holder.avatar);

			}

		}

		// holder.distanceText.setText(Utility.getFormatedDistance(((OtherUserEntity)people).getDistance())+"m");
		holder.distanceText.setText(Utility.getFormatedDistance(people
				.getDistance(), StaticValues.myInfo.getSettings().getUnit()));

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				// AppStaticStorages.selectedPeople=otherUserEntity;
				// licl.onMapButtonClick(RowType.PEOPLE.ordinal());

				listItemClickListenerSecondDegreePeople
						.onShowOnMapButtonClick(people);

			}
		});

		if (people.getCoverPhoto() != null
				&& !people.getCoverPhoto().equals("")) {

			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.download(people.getAvatar(), holder.coverPhoto);
			

		} else
			holder.coverPhoto
					.setImageResource(R.drawable.cover_pic_second_degree);

		// holder.btnSendMessage.setOnClickListener(new View.OnClickListener() {
		//
		// @Override
		// public void onClick(View v) {
		// // TODO Auto-generated method stub
		// listItemClickListenerSecondDegreePeople
		// .onSendMessageButtonClick(people);
		// }
		// });

		// holder.btnSendMessage.setVisibility(View.INVISIBLE);
		// holder.btnSendInvite.setVisibility(View.INVISIBLE);

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

		private ViewHolder(ImageView coverPhoto, ImageView avatar,
				ImageView showOnMap, TextView firstNameText,
				TextView statusText, TextView addressText, TextView distanceText) {
			this.coverPhoto = coverPhoto;
			this.avatar = avatar;
			this.showOnMap = showOnMap;
			this.firstNameText = firstNameText;
			this.statusText = statusText;
			this.addressText = addressText;
			this.distanceText = distanceText;

		}
	}
}
