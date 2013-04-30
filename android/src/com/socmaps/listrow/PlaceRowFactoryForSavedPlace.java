package com.socmaps.listrow;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.maps.GeoPoint;
import com.socmaps.entity.Place;
import com.socmaps.images.ImageFetcher;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;



/**
 * PlaceRowFactoryForSavedPlace class for generating a row (view), which row (view) is associates with corresponding layout.
 *
 */
public class PlaceRowFactoryForSavedPlace {

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
	 * @param il
	 *            which is used to download image from a specific url.
	 * @param listItemClickListenerPlace
	 *            which is used for a specific action when button is clicked.
	 * @param a
	 *            as Integer which is used to determine if it comes from Own
	 *            Profile or Friends Profile
	 * @return View
	 * @see View
	 */

	public static View getView(final LayoutInflater inflater,
			final Place placeObj, final Context con,
			 final View convertView,
			final ImageFetcher il,
			final ListItemClickListenerPlace listItemClickListenerPlace, int a) {
		final ViewHolder holder;
		View view;
		final Place place;
		if (convertView == null) {
			ViewGroup viewGroup = (ViewGroup) inflater.inflate(
					R.layout.row_list_saved_place, null);
			holder = new ViewHolder(
					(ImageView) viewGroup.findViewById(R.id.cover_image_view),
					(ImageView) viewGroup.findViewById(R.id.map_image_btn),
					(TextView) viewGroup.findViewById(R.id.first_name_text),
					(TextView) viewGroup.findViewById(R.id.address_text),
					(TextView) viewGroup.findViewById(R.id.distance_text),
					(Button) viewGroup.findViewById(R.id.btnEditPlace));
			viewGroup.setTag(holder);
			view = viewGroup;
		} else {
			view = convertView;
			holder = (ViewHolder) convertView.getTag();
		}

		place = placeObj;

		if (place.getName() != null) {
			if (!place.getName().equals(""))
				holder.titleText.setText(place.getName());
		}

		if (place.getStreetViewImage() != null
				&& !place.getStreetViewImage().equals("")) {
			holder.coverPhoto.setImageResource(R.drawable.img_blank);
			il.loadImage(place.getStreetViewImage(), holder.coverPhoto);
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

		if (StaticValues.myPoint != null) {
			holder.distanceText.setText(Utility.getFormatedDistance(Utility
					.calculateDistance(StaticValues.myPoint,
							new LatLng(place.getLatitude(),
									place.getLongitude() )),
					StaticValues.myInfo.getSettings().getUnit()));
		}

		holder.showOnMap.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				listItemClickListenerPlace.onShowOnMapButtonClick(place);
			}
		});

		if (a == 1) {
			holder.btnEditPlace.setVisibility(View.VISIBLE);
		} else {
			holder.btnEditPlace.setVisibility(View.INVISIBLE);
		}

		holder.btnEditPlace.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub

				listItemClickListenerPlace.onReviewButtonClick(place);
			}
		});

		Utility.log("Save Place Data PlaceRowFactoryForSavedPlace>>>",
				"Name: " + place.getName() + " Phopt: "
						+ place.getStreetViewImage() + " Address:"
						+ place.getAddress() + " Category:"
						+ place.getCategory());

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

		final ImageView showOnMap;
		final TextView titleText;

		final TextView addressText;

		final TextView distanceText;
		final Button btnEditPlace;

		private ViewHolder(ImageView image1, ImageView image3,
				TextView textView1, TextView textView2, TextView textView3,
				Button btnEditPlace) {
			this.coverPhoto = image1;

			this.showOnMap = image3;
			this.titleText = textView1;

			this.addressText = textView2;

			this.distanceText = textView3;
			this.btnEditPlace = btnEditPlace;
		}
	}

}
