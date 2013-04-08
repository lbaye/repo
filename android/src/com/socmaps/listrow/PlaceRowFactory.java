package com.socmaps.listrow;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socmaps.entity.Place;
import com.socmaps.images.ImageFetcher;
import com.socmaps.images.ImageFetcher;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * PlaceRowFactory class for generating a row (view), which row (view) is associates with corresponding layout.
 *
 */
public class PlaceRowFactory {

	/**
	 * This method returns a View, that view is associates with corresponding
	 * layout.
	 * 
	 * @param inflater
	 *            to inflate the corresponding layout.
	 * @param placeObj
	 *            an object of type Place.
	 * @param con
	 *            current state of the application/object.
	 * @param convertView
	 *            as view.
	 * @param imageFetcher
	 *            which is used to download image from a specific url.
	 * @param listItemClickListenerPlace
	 *            which is used for a specific action when button is clicked.
	 * @return View
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater,
			final Object placeObj, final Context con,
			 final View convertView,
			final ImageFetcher imageFetcher,
			final ListItemClickListenerPeople listItemClickListenerPlace) {
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
		String iconUrl = place.getIconUrl();
		if (iconUrl != null) {

			holder.avatar.setImageResource(R.drawable.img_blank);
			imageFetcher.loadImage(iconUrl, holder.avatar);
		}

		if (place.getStreetViewImage() != null
				&& !place.getStreetViewImage().equals("")) {
			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			imageFetcher.loadImage(place.getStreetViewImage(), holder.coverPhoto);
		} else {
			holder.coverPhoto.setImageResource(R.drawable.cover_pic_default);
		}

		// ******************************************************************current
		// position

		if (place.getVicinity() != null) {
			holder.addressText.setText(place.getVicinity());
			holder.addressText.setVisibility(View.VISIBLE);
		} else
			holder.addressText.setVisibility(View.GONE);

		double distance = Utility.calculateDistanceFromCurrentLocation(place.getPoint());
		if (distance < Constant.MAX_ITEM_DISTANCE) {
			holder.distanceText
					.setText(Utility.getFormatedDistance(distance,
							StaticValues.myInfo.getSettings().getUnit()));
		} else {
			holder.distanceText.setVisibility(View.INVISIBLE);
			holder.showOnMap.setVisibility(View.INVISIBLE);
		}

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				listItemClickListenerPlace.onShowOnMapButtonClick(place);
			}
		});
		return view;
	}

	/**
	 * This method return the type of the view.
	 * 
	 * @return Integer as the integer value reflects the type.
	 */

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

}
