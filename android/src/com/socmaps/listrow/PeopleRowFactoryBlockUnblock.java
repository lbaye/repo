package com.socmaps.listrow;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PeopleRowFactoryBlockUnblock { 
	
	/** 
	 * This method returns a View, that view is associates with corresponding layout. 
	 * 
	 * @param inflater to inflate the corresponding layout. 
	 * @param peopleObj an object of type People. 
	 * @param con current state of the application/object.
	 * @param licl which is used for a specific action when button is clicked. 
	 * @param convertView as view. 
	 * @param il which is used to download image from a specific url. 
	 * @param listItemClickListenerPeople  which is used for a specific action when button is clicked. 
	 * @return View 
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater,
			final Object peopleObj, final Context con,
			final ListItemClickListener licl, final View convertView,
			final ImageDownloader il,
			final ListItemClickListenerPeople listItemClickListenerPeople) {

		ViewHolder holder;
		View view;
		final People people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_people_block_unblock, null);

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
							.findViewById(R.id.btnMessagePeopleBlockUnblockRow),
					(Button) viewGroup
							.findViewById(R.id.btnBlockUnblockPeopleRow),
					(CheckBox) viewGroup.findViewById(R.id.checkRow));

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
					holder.sourceImage
							.setImageResource(R.drawable.facebookicon);
					// holder.sourceImage.setVisibility(View.VISIBLE);
					// holder.sourceImage.setVisibility(View.GONE);
				} // else
					// holder.sourceImage.setVisibility(View.GONE);

			} else
				holder.sourceImage.setVisibility(View.GONE);
		} else {
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
		if (people.getCoverPhoto() != null
				&& !people.getCoverPhoto().equals("")) {

			// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getCoverPhoto(),
			// holder.coverPhoto, 320,150);
			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.download(people.getCoverPhoto(), holder.coverPhoto);

		} else
			holder.coverPhoto.setImageResource(R.drawable.cover_pic_people);

		// BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource(con.getResources(),
		// R.drawable.icon));
		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {
				// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getAvatar(),
				// holder.avatar, 320,150);

				holder.avatar.setImageResource(R.drawable.img_blank);
				il.download(people.getAvatar(), holder.avatar);

			}
			// holder.statusText.setText(otherUserEntity.getStatusMsg());
		}// else
			// holder.avatar.setImageResource(R.drawable.icon);

		// holder.distanceText.setText(Utility.getFormatedDistance(((OtherUserEntity)people).getDistance())+"m");

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

		holder.btnSendMessage.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				listItemClickListenerPeople.onSendMessageButtonClick(people);
			}
		});

		holder.checked
				.setOnCheckedChangeListener(new OnCheckedChangeListener() {

					@Override
					public void onCheckedChanged(CompoundButton arg0,
							boolean arg1) {

						listItemClickListenerPeople.onCheckChange(
								people.getId(), arg1);
					}
				});

		holder.btnBlockUnblock.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				listItemClickListenerPeople.onBlockButtonClick(people);
			}
		});

		if (people.isBlocked()) {
			holder.btnBlockUnblock.setText("Unblock");
		} else {
			holder.btnBlockUnblock.setText("Block");
		}

		
		
		
		if (people.getUnit() == null) {
			holder.checked.setChecked(people.isBlocked());
			Log.i("people.getUnit() null", ""+people.isBlocked());
		} else if (people.getUnit().equalsIgnoreCase(
				con.getString(R.string.unselectAllLabel))) {
			holder.checked.setChecked(true);
			Log.i("people.getUnit() unselectAllLabel", "true");
		} else if (people.getUnit().equalsIgnoreCase(
				con.getString(R.string.selectAllLabel))) {
			holder.checked.setChecked(false);
			Log.i("people.getUnit() selectAllLabel", "false");
		} else {
			holder.checked.setChecked(people.isBlocked());
			Log.i("people.getUnit() else", ""+people.isBlocked());
		}

		// }

		holder.btnSendMessage.setVisibility(View.INVISIBLE);
		holder.btnBlockUnblock.setVisibility(View.INVISIBLE);

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
		final Button btnBlockUnblock;
		final CheckBox checked;

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, ImageView image4, TextView textView1,
				TextView textView2, TextView textView3, TextView textView4,
				TextView textView5, Button sendMessage, Button blockUnblock,
				CheckBox checkedBox) {
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
			this.btnBlockUnblock = blockUnblock;
			this.checked = checkedBox;

		}
	}
}
