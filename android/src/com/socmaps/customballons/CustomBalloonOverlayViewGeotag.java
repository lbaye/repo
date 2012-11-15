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

public class CustomBalloonOverlayViewGeotag<Item extends OverlayItem> extends
		BalloonOverlayView<CustomOverlayItem> {

	private TextView tvTitle, tvUser, tvAddress;

	//private ImageView image;
	//private ImageDownloader imageDownloader;
	
	public CustomBalloonOverlayViewGeotag(Context context,
			int balloonBottomOffset, ImageDownloader imageDownloader) {
		this(context, balloonBottomOffset);
		//this.imageDownloader = imageDownloader;
	}

	public CustomBalloonOverlayViewGeotag(Context context,
			int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}

	@Override
	protected void setupView(Context context, final ViewGroup parent) {

		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_geotag, parent);

		// setup our fields
		tvTitle = (TextView) v.findViewById(R.id.title_text);
		tvUser = (TextView) v.findViewById(R.id.user_text);
		tvAddress = (TextView) v.findViewById(R.id.address_text);

		//image = (ImageView) v.findViewById(R.id.balloon_item_image);

	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {

		// map our custom item data to fields
		String title = item.getGeotag().getTitle();
		if(title!=null && !title.equalsIgnoreCase(""))
		{
			tvTitle.setText(title+" tagged");
		}
		else
		{
			tvTitle.setVisibility(View.GONE);
		}
		
		if(item.getGeotag().getOwner()!=null)
		{
			String name = Utility.getFieldText(item.getGeotag().getOwner());
			if(!name.equalsIgnoreCase(""))
			{
				tvUser.setText("by "+name);
			}
			else
			{
				tvUser.setVisibility(View.GONE);
			}
		}
		else
		{
			tvUser.setVisibility(View.GONE);
		}
		
		String address = item.getGeotag().getAddress();
		if(!address.equalsIgnoreCase(""))
		{
			tvAddress.setText("at "+address);
		}
		else
		{
			tvAddress.setVisibility(View.GONE);
		}

		//image.setImageResource(R.drawable.img_blank);
		//imageDownloader.download(item.getPlace().getIconUrl(), image);

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
