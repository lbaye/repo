package com.socmaps.customballons;

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

import com.google.android.maps.OverlayItem;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.images.ImageDownloader;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class CustomBalloonOverlayViewPeople<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView name, status, distance, age;

	private ImageView image;
	private ImageDownloader imageDownloader;
	
	public CustomBalloonOverlayViewPeople(Context context,
			int balloonBottomOffset,ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
		
	}

	public CustomBalloonOverlayViewPeople(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_user, parent);

		// setup our fields
		name = (TextView) v.findViewById(R.id.name_text);
		status = (TextView) v.findViewById(R.id.status_text);
		distance = (TextView) v.findViewById(R.id.distance_text);
		age = (TextView) v.findViewById(R.id.age_text);
		image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields
		/*
		 * if(isValid(item.getUser().getFirstName())) {
		 * name.setText(item.getUser().getFirstName());
		 * name.setVisibility(View.VISIBLE); } else
		 * name.setVisibility(View.GONE);
		 */

		name.setText(Utility.getFieldText(item.getUser()));
		name.setVisibility(View.VISIBLE);

		if (Utility.isValidString(item.getUser().getStatusMsg())) {
			status.setText(item.getUser().getStatusMsg());
			status.setVisibility(View.VISIBLE);
		} else
			status.setVisibility(View.GONE);
		if (Utility.isValidString(String.format("%.2f", item.getUser().getDistance()))) {
			distance.setText(Utility
					.getFormatedDistance(item.getUser().getDistance(),
							StaticValues.myInfo.getSettings().getUnit())
					+ " away");
			distance.setVisibility(View.VISIBLE);
		} else
			distance.setVisibility(View.GONE);
		if (item.getUser().getAge() != 0) {
			age.setText("-Age:" + item.getUser().getAge());
			age.setVisibility(View.VISIBLE);
		} else
			age.setVisibility(View.GONE);

		image.setImageResource(R.drawable.img_blank);
		/*new FetchImageTask() {
			@Override
			protected void onPostExecute(Bitmap result) {
				if (result != null) {
					image.setImageBitmap(result);
				}
			}
		}.execute(item.getUser().getAvatar());*/
		imageDownloader.download(item.getUser().getAvatar(), image);
		
		//ImageLoader il = new ImageLoader(getContext());
		//il.DisplayImage(item.getUser().getAvatar(), image, R.drawable.img_blank);

	}

	/*private class FetchImageTask extends AsyncTask<String, Integer, Bitmap> {
		@Override
		protected Bitmap doInBackground(String... arg0) {
			Bitmap b = null;
			try {
				b = BitmapFactory.decodeStream((InputStream) new URL(arg0[0])
						.getContent());
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			return b;
		}
	}*/

}
