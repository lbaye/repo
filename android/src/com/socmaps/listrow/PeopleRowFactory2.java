package com.socmaps.listrow;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.People;
import com.socmaps.images.ImageLoader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PeopleRowFactory2 {

	public static View getView(final LayoutInflater inflater,
			final Object peopleObj, final Context con,
			final ListItemClickListener licl, final View convertView,
			final ImageLoader il,
			final ListItemClickListenerPeople listItemClickListenerPeople) {

		ViewHolder holder;
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
					(Button) viewGroup
							.findViewById(R.id.btnMessagePeopleSocialMaps));

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
		if (people.getRegMedia() != null) {
			if (!people.getRegMedia().equals("")) {
				if (people.getRegMedia().equals("fb")) {
					holder.sourceImage.setImageResource(R.drawable.source_fb);
					// holder.sourceImage.setVisibility(View.VISIBLE);
					holder.sourceImage.setVisibility(View.GONE);
				} else
					holder.sourceImage.setVisibility(View.GONE);

			} else
				holder.sourceImage.setVisibility(View.GONE);
		}

		// ******************************************************************first

		holder.firstNameText.setText(Utility.getFieldText(people));
		// ******************************************************************status
		if (people.getStatusMsg() != null) {
			if (!people.getStatusMsg().equals("")) {

				holder.statusText.setText(people.getStatusMsg());
				// holder.statusText.setVisibility(View.VISIBLE);
				holder.statusText.setVisibility(View.GONE);
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
			// holder.timeText.setVisibility(View.VISIBLE);
			holder.timeText.setVisibility(View.GONE);
		} else
			holder.timeText.setVisibility(View.GONE);

		// ******************************************************************current
		// position

		if (people.getCurrentAddress() != null) {
			holder.addressText.setText(people.getCurrentAddress());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);

		// BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource(con.getResources(),
		// R.drawable.cover_pic_default));
		if (people.getCoverPhoto() != null) {
			if (!people.getCoverPhoto().equals("")) {
				// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getCoverPhoto(),
				// holder.coverPhoto, 320,150);
				il.DisplayImage(people.getCoverPhoto(), holder.coverPhoto,
						R.drawable.img_blank);
			}
			// holder.statusText.setText(otherUserEntity.getStatusMsg());
		} // else
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
		}// else
			// holder.avatar.setImageResource(R.drawable.icon);

		// holder.distanceText.setText(Utility.getFormatedDistance(((OtherUserEntity)people).getDistance())+"m");
		holder.distanceText.setText(Utility.getFormatedDistance(
				((People) peopleObj).getDistance(), StaticValues.myInfo
						.getSettings().getUnit()));

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				// AppStaticStorages.selectedPeople=otherUserEntity;
				// licl.onMapButtonClick(RowType.PEOPLE.ordinal());

				listItemClickListenerPeople.onShowOnMapButtonClick(people);

			}
		});

		holder.btnSendMessage.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				listItemClickListenerPeople.onSendMessageButtonClick(people);
			}
		});

		// holder.btnSendMessage.setTag(people);
		// holder.btnSendMessage.setOnClickListener(messageBtnListener);

		

		

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
		

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, ImageView image4, TextView textView1,
				TextView textView2, TextView textView3, TextView textView4,
				TextView textView5, Button sendBtn) {
			this.coverPhoto = image1;
			this.avatar = image2;
			this.sourceImage = image3;
			this.showOnMap = image4;
			this.firstNameText = textView1;
			this.statusText = textView2;
			this.addressText = textView3;
			this.timeText = textView4;
			this.distanceText = textView5;
			this.btnSendMessage = sendBtn;
			

		}
	}
}
