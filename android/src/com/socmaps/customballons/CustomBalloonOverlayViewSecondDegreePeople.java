package com.socmaps.customballons;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
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

public class CustomBalloonOverlayViewSecondDegreePeople<Item extends OverlayItem>
		extends BalloonOverlayView<CustomOverlayItem> {

	private TextView name, address, date;

	private ImageView image;
	
	private ImageDownloader imageDownloader;
	
	public CustomBalloonOverlayViewSecondDegreePeople(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}

	public CustomBalloonOverlayViewSecondDegreePeople(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_user_second_degree, parent);

		// setup our fields
		name = (TextView) v.findViewById(R.id.tvName);
		address = (TextView) v.findViewById(R.id.tvAddress);
		date = (TextView) v.findViewById(R.id.tvDate);
		image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	private boolean isValid(String value) {
		if (value != null)
			if (!value.equals(""))
				return true;
		return false;
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

		name.setText(Utility.getFieldText(item.getSecondDegreePeople()));
		name.setVisibility(View.VISIBLE);



		if (item.getSecondDegreePeople().getLastSeenAt() != null) {
			address.setText("at "+item.getSecondDegreePeople().getLastSeenAt());
			address.setVisibility(View.VISIBLE);
		} else {
			address.setVisibility(View.GONE);
		}
		
		if (item.getSecondDegreePeople().getCreateTime() != null) {
			date.setText(Utility.getFormattedDisplayDateForMap(item.getSecondDegreePeople().getCreateTime()));
			date.setVisibility(View.VISIBLE);
		} else {
			date.setVisibility(View.GONE);
		}


		image.setImageResource(R.drawable.img_blank);
		imageDownloader.download(item.getSecondDegreePeople().getAvatar(), image);
		/*new FetchImageTask() {
			@Override
			protected void onPostExecute(Bitmap result) {
				if (result != null) {
					image.setImageBitmap(result);
				}
			}
		}.execute(item.getSecondDegreePeople().getAvatar());*/
		
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
