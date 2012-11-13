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

public class CustomBalloonOverlayViewPlace<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView title, address, distance;

	private ImageView image;
	private ImageDownloader imageDownloader;
	
	public CustomBalloonOverlayViewPlace(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}

	public CustomBalloonOverlayViewPlace(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_place, parent);

		// setup our fields
		title = (TextView) v.findViewById(R.id.title_text);
		address = (TextView) v.findViewById(R.id.address_text);
		distance = (TextView) v.findViewById(R.id.distance_text);

		image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields

		title.setText(item.getPlace().getName());
		address.setText(item.getPlace().getVicinity());
		// distance.setText(String.format("%.2f",
		// item.getPlace().getDistance())+" miles away");
		distance.setText(Utility.getFormatedDistance(item.getPlace()
				.getDistance(), StaticValues.myInfo.getSettings().getUnit())
				+ " away");

		image.setImageResource(R.drawable.img_blank);
		imageDownloader.download(item.getPlace().getIconUrl(), image);
		/*new FetchImageTask() {
			@Override
			protected void onPostExecute(Bitmap result) {
				if (result != null) {
					image.setImageBitmap(result);
				}
			}
		}.execute(item.getPlace().getIconUrl());*/
		
		//ImageLoader il = new ImageLoader(getContext());
		//il.DisplayImage(item.getPlace().getIconUrl(), image, R.drawable.img_blank);

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
