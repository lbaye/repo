package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.CompoundButton.OnCheckedChangeListener;

import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class SecondDegreePeopleRowFactoryPeopleInvite { 
	
	/**
	 * This method returns a View, that view is associates with corresponding layout.  
	 * 
	 * @param inflater to inflate the corresponding layout. 
	 * @param peopleObj an object of type Secondary People. 
	 * @param con current state of the application/object. 
	 * @param licl which is used for a specific action when button is clicked.  
	 * @param convertView as view.  
	 * @param il which is used to download image from a specific url.  
	 * @param listItemClickListenerSecondDegreePeople which is used for a specific action when button is clicked. 
	 * @return View 
	 * @see View
	 */

	public static View getView(
			final LayoutInflater inflater,
			final Object peopleObj,
			final Context con,
			final ListItemClickListener licl,
			final View convertView,
			final ImageDownloader il,
			final ListItemClickListenerSecondDegreePeople listItemClickListenerSecondDegreePeople,boolean isChecked) {
		ViewHolder holder;
		View view;
		final SecondDegreePeople people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_item_people_second_degree_invite, null);

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
					(Button) viewGroup.findViewById(R.id.btnInvitePeople),
					(CheckBox) viewGroup.findViewById(R.id.checkRow));
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
		holder.avatar.setImageResource(R.drawable.img_blank);
		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {
				// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getAvatar(),
				// holder.avatar, 320,150);
				il.download(people.getAvatar(), holder.avatar);
			}
			// holder.statusText.setText(otherUserEntity.getStatusMsg());
		} // else
			// holder.avatar.setImageResource(R.drawable.icon);
		
		
		if (people.getCoverPhoto() != null
				&& !people.getCoverPhoto().equals("")) {

			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.download(people.getAvatar(), holder.coverPhoto);

		} else
			holder.coverPhoto
					.setImageResource(R.drawable.cover_pic_second_degree);
		

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

		holder.btnInvitePeople.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				listItemClickListenerSecondDegreePeople
						.onInviteButtonClick(people);

			}
		});

		holder.checked
				.setOnCheckedChangeListener(new OnCheckedChangeListener() {

					@Override
					public void onCheckedChanged(CompoundButton arg0,
							boolean flag) {

						listItemClickListenerSecondDegreePeople.onCheckChange(
								people.getRefId(), flag);
					}
				});
		
		
		
		holder.checked.setChecked(isChecked);
		//holder.checked.setChecked(StaticValues.PEOPLE_SELECT_ALL_USERS);

		holder.btnSendMessage.setVisibility(View.INVISIBLE);
		holder.btnInvitePeople.setVisibility(View.INVISIBLE);

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
		final Button btnInvitePeople;
		final CheckBox checked;

		private ViewHolder(ImageView coverPhoto, ImageView avatar,
				ImageView sourceImage, ImageView showOnMap,
				TextView firstNameText, TextView statusText,
				TextView addressText, TextView timeText, TextView distanceText,
				Button sendMessage, Button blockUnblock, CheckBox checkedBox) {
			this.coverPhoto = coverPhoto;
			this.avatar = avatar;
			this.sourceImage = sourceImage;
			this.showOnMap = showOnMap;
			this.firstNameText = firstNameText;
			this.statusText = statusText;
			this.addressText = addressText;
			this.timeText = timeText;
			this.distanceText = distanceText;
			this.btnSendMessage = sendMessage;
			this.btnInvitePeople = blockUnblock;
			this.checked = checkedBox;

		}
	}
}
