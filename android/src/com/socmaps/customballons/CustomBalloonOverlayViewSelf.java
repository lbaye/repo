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

public class CustomBalloonOverlayViewSelf<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView name;

	private ImageView image;
	
	private ImageDownloader imageDownloader;

	public CustomBalloonOverlayViewSelf(Context context, int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		this.imageDownloader = imageDownloader;
	}
	
	public CustomBalloonOverlayViewSelf(Context context, int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_self, parent);

		// setup our fields
		name = (TextView) v.findViewById(R.id.title_text);

		image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields

		name.setText("Me");
		
		image.setImageResource(R.drawable.img_blank);

		if (item.getMe().getAvatar() != null) {
			
			imageDownloader.download(item.getMe().getAvatar(), image);
			
			//image.setImageResource(R.drawable.icon);
			/*new FetchImageTask() {
				@Override
				protected void onPostExecute(Bitmap result) {
					if (result != null) {
						image.setImageBitmap(result);
					}
				}
			}.execute(item.getMe().getAvatar());*/
			
			//ImageLoader il = new ImageLoader(getContext());
			//il.DisplayImage(item.getMe().getAvatar(), image, R.drawable.img_blank);
		}
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
