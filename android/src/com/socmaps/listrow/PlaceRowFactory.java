package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.Place;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class PlaceRowFactory {

	public static View getView(final LayoutInflater inflater,
			final Object placeObj, final Context con,
			final ListItemClickListener licl, final View convertView,
			final ImageDownloader il,
			final ListItemClickListenerPlace listItemClickListenerPlace) {
		final ViewHolder holder;
		View view;
		final Place place;
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_place, null);
			holder = new ViewHolder(
					(ImageView) viewGroup.findViewById(R.id.cover_image_view),
					(ImageView) viewGroup.findViewById(R.id.people_icon_image),

					(ImageView) viewGroup.findViewById(R.id.map_image_btn),
					(TextView) viewGroup.findViewById(R.id.first_name_text),

					(TextView) viewGroup.findViewById(R.id.address_text),

					(TextView) viewGroup.findViewById(R.id.distance_text));
			viewGroup.setTag(holder);
			view = viewGroup;
		} else {
			view = convertView;
			holder = (ViewHolder) convertView.getTag();
		}

		place = ((Place) placeObj);

		if (place.getName() != null) {
			if (!place.getName().equals(""))
				holder.titleText.setText(place.getName());
		}
		// String
		// url="http://www.marcjulienhomes.com/wp-content/uploads/2011/03/0040-320x150.jpg";
		String iconUrl = place.getIconUrl();
		if (iconUrl != null) {
			/*
			 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource
			 * (con.getResources(), R.drawable.cover_pic_default));
			 * BitmapManager.INSTANCE.loadBitmap(url, holder.coverPhoto,
			 * 320,150);
			 */
			// il.DisplayImage(iconUrl, holder.avatar,R.drawable.img_blank);

			holder.avatar.setImageResource(R.drawable.img_blank);
			il.download(iconUrl, holder.avatar);
			/*
			 * new FetchImageTask() {
			 * 
			 * @Override protected void onPostExecute(Bitmap result) { if
			 * (result != null) {
			 * 
			 * holder.avatar.setImageBitmap(result); } else {
			 * holder.avatar.setImageResource(R.drawable.img_blank); } }
			 * }.execute(iconUrl);
			 */

		}

		String url = place.getStreetViewImage();
		if (url != null) {
			/*
			 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource
			 * (con.getResources(), R.drawable.cover_pic_default));
			 * BitmapManager.INSTANCE.loadBitmap(url, holder.coverPhoto,
			 * 320,150);
			 */
			// il.DisplayImage(url, holder.coverPhoto, R.drawable.img_blank);

			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.download(url, holder.coverPhoto);
		} else {
			holder.coverPhoto.setImageResource(R.drawable.img_blank);
		}

		// ******************************************************************current
		// position

		if (place.getVicinity() != null) {
			holder.addressText.setText(place.getVicinity());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);
		/*
		 * holder.descriptionView.setText(animal.getDescription());
		 * holder.titleView.setText(animal.getName());
		 */

		// holder.distanceText.setText(Utility.getFormatedDistance(((PlaceEntity)placeEntity).getDistance())+"m");

		if (place.getDistance() < Constant.MAX_ITEM_DISTANCE) {
			holder.distanceText
					.setText(Utility.getFormatedDistance(place.getDistance(),
							StaticValues.myInfo.getSettings().getUnit()));
		} else {
			holder.distanceText.setVisibility(View.INVISIBLE);
			holder.showOnMap.setVisibility(View.INVISIBLE);
		}

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				// AppStaticStorages.selectedPlace=placeEntity;
				// licl.onMapButtonClick(RowType.PLACE.ordinal());

				listItemClickListenerPlace.onShowOnMapButtonClick(place);
			}
		});
		return view;
	}

	public int getViewType() {
		return RowType.PLACE.ordinal();
	}

	private static class ViewHolder {
		final ImageView coverPhoto;
		final ImageView avatar;

		final ImageView showOnMap;
		final TextView titleText;

		final TextView addressText;

		final TextView distanceText;

		private ViewHolder(ImageView image1, ImageView image2,
				ImageView image3, TextView textView1, TextView textView2,
				TextView textView3) {
			this.coverPhoto = image1;
			this.avatar = image2;
			this.showOnMap = image3;
			this.titleText = textView1;

			this.addressText = textView2;

			this.distanceText = textView3;
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
