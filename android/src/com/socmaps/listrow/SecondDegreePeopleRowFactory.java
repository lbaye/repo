package com.socmaps.listrow;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;
import com.socmaps.images.ImageLoader;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class SecondDegreePeopleRowFactory { 
	
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
			final ListItemClickListenerSecondDegreePeople listItemClickListenerSecondDegreePeople) {
		final ViewHolder holder;
		View view;
		final SecondDegreePeople people;
		// we have a don't have a converView so we'll have to create a new one
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_people_second_degree, null);

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

		// holder.sourceImage.setVisibility(View.GONE);

		holder.firstNameText.setText(Utility.getFieldText(people));
		// ******************************************************************status

		String status = "Checked-in at " + people.getLastSeenAt() + " "
				+ Utility.getFormattedDisplayDateForMap(people.getCreateTime());

		// holder.statusText.setVisibility(View.GONE);
		holder.statusText.setText(status);

		// holder.timeText.setVisibility(View.GONE);

		// ******************************************************************current
		// position

		if (people.getCurrentAddress() != null) {
			holder.addressText.setText(people.getCurrentAddress());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);

		if (people.getAvatar() != null) {
			if (!people.getAvatar().equals("")) {
				// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getAvatar(),
				// holder.avatar, 320,150);
				holder.avatar.setImageResource(R.drawable.img_blank);
				// il.DisplayImage(people.getAvatar(),
				// holder.avatar,R.drawable.img_blank);
				// il.download(people.getAvatar(), holder.avatar);

				holder.avatar.setImageResource(R.drawable.img_blank);
				il.download(people.getAvatar(), holder.avatar);
				/*
				 * new FetchImageTask() {
				 * 
				 * @Override protected void onPostExecute(Bitmap result) { if
				 * (result != null) {
				 * 
				 * holder.avatar.setImageBitmap(result); } else {
				 * holder.avatar.setImageResource(R.drawable.img_blank); } }
				 * }.execute(people.getAvatar());
				 */

			}
			// holder.statusText.setText(otherUserEntity.getStatusMsg());
		} // else holder.avatar.setImageResource(R.drawable.icon);

		if (people.getCoverPhoto() != null
				&& !people.getCoverPhoto().equals("")) {

			// BitmapManager.INSTANCE.loadBitmap(otherUserEntity.getAvatar(),
			// holder.avatar, 320,150);

			// il.DisplayImage(people.getAvatar(),
			// holder.avatar,R.drawable.img_blank);
			// il.download(people.getAvatar(), holder.avatar);

			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.download(people.getAvatar(), holder.coverPhoto);
			/*
			 * new FetchImageTask() {
			 * 
			 * @Override protected void onPostExecute(Bitmap result) { if
			 * (result != null) {
			 * 
			 * holder.avatar.setImageBitmap(result); } else {
			 * holder.avatar.setImageResource(R.drawable.img_blank); } }
			 * }.execute(people.getAvatar());
			 */

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

		holder.coverPhoto.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				listItemClickListenerSecondDegreePeople.onItemClick(people);
			}
		});

		holder.avatar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				listItemClickListenerSecondDegreePeople.onItemClick(people);
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

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image4, TextView textView1, TextView textView2,
				TextView textView3, TextView textView5) {
			this.coverPhoto = image1;
			this.avatar = image2;
			// this.sourceImage = image3;
			this.showOnMap = image4;
			this.firstNameText = textView1;
			this.statusText = textView2;
			this.addressText = textView3;
			// this.timeText = textView4;
			this.distanceText = textView5;
		}
	}

	/*
	 * private static class FetchImageTask extends AsyncTask<String, Integer,
	 * Bitmap> {
	 * 
	 * @Override protected Bitmap doInBackground(String... arg0) { Bitmap b =
	 * null; try { b = BitmapFactory.decodeStream((InputStream) new URL(arg0[0])
	 * .getContent()); } catch (MalformedURLException e) { e.printStackTrace();
	 * } catch (IOException e) { e.printStackTrace(); } return b; } }
	 */
}
