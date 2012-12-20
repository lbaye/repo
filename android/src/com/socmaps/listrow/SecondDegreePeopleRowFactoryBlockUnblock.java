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

import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * SecondDegreePeopleRowFactoryBlockUnblock class for generating a row (view), which row (view) is associates with corresponding layout.
 *
 */
public class SecondDegreePeopleRowFactoryBlockUnblock {

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
	 * @param licl
	 *            which is used for a specific action when button is clicked.
	 * @param convertView
	 *            as view.
	 * @param il
	 *            which is used to download image from a specific url.
	 * @param listItemClickListenerSecondDegreePeople
	 *            which is used for a specific action when button is clicked.
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
			final ListItemClickListenerSecondDegreePeople listItemClickListenerSecondDegreePeople) {
		ViewHolder holder;
		View view;
		final SecondDegreePeople people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_people_second_degree_block_unblock, null);

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

		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {

				il.download(people.getAvatar(), holder.avatar);
			}

		}

		if (people.getCoverPhoto() != null
				&& !people.getCoverPhoto().equals("")) {

			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.download(people.getAvatar(), holder.coverPhoto);

		} else
			holder.coverPhoto
					.setImageResource(R.drawable.cover_pic_second_degree);

		holder.distanceText.setText(Utility.getFormatedDistance(people
				.getDistance(), StaticValues.myInfo.getSettings().getUnit()));

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

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

		holder.checked
				.setOnCheckedChangeListener(new OnCheckedChangeListener() {

					@Override
					public void onCheckedChanged(CompoundButton arg0,
							boolean arg1) {

						Log.i("PeopleRowFactoryBlockUnblock",
								people.getFirstName() + " > isChecked: " + arg1);

						listItemClickListenerSecondDegreePeople.onCheckChange(
								people.getRefId(), arg1);
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
