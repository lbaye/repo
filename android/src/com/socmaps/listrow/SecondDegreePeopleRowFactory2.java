package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageLoader;
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
			final ImageLoader il,
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
					(ImageView) viewGroup.findViewById(R.id.source_image_btn),
					(ImageView) viewGroup.findViewById(R.id.map_image_btn),
					(TextView) viewGroup.findViewById(R.id.first_name_text),
					(TextView) viewGroup.findViewById(R.id.status_msg_text),
					(TextView) viewGroup.findViewById(R.id.address_text),
					(TextView) viewGroup.findViewById(R.id.time_text),
					(TextView) viewGroup.findViewById(R.id.distance_text),
					(Button) viewGroup.findViewById(R.id.btnMessagePeople),
					(Button) viewGroup.findViewById(R.id.btnInvitePeople));
					
			viewGroup.setTag(holder);

			view = viewGroup;
		} else {
			// get the holder back out
			holder = (ViewHolder) convertView.getTag();

			view = convertView;
		}

		people = (SecondDegreePeople) peopleObj;

		holder.sourceImage.setVisibility(View.GONE);

		holder.firstNameText.setText(Utility.getFieldText(people));
		// ******************************************************************status

		holder.statusText.setVisibility(View.GONE);

		holder.timeText.setVisibility(View.GONE);

		// ******************************************************************current
		// position

		if (people.getCurrentAddress() != null) {
			holder.addressText.setText(people.getCurrentAddress());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);

		// holder.coverPhoto.setImageResource(R.drawable.cover_pic_default);

		// BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource(con.getResources(),
		// R.drawable.icon));
		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {
				// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getAvatar(),
				// holder.avatar, 320,150);
				il.DisplayImage(people.getAvatar(), holder.avatar,
						R.drawable.img_blank);
			}
			// holder.statusText.setText(otherUserEntity.getStatusMsg());
		} // else
			// holder.avatar.setImageResource(R.drawable.icon);

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

		holder.btnSendMessage.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				listItemClickListenerSecondDegreePeople
						.onSendMessageButtonClick(people);
			}
		});

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
		final Button btnSendMessage;
		final Button btnSendInvite;
		

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, ImageView image4, TextView textView1,
				TextView textView2, TextView textView3, TextView textView4,
				TextView textView5, Button sendMessage, Button sendInvite
				) {
			this.coverPhoto = image1;
			this.avatar = image2;
			this.sourceImage = image3;
			this.showOnMap = image4;
			this.firstNameText = textView1;
			this.statusText = textView2;
			this.addressText = textView3;
			this.timeText = textView4;
			this.distanceText = textView5;
			this.btnSendMessage = sendMessage;
			this.btnSendInvite = sendInvite;
			

		}
	}
}