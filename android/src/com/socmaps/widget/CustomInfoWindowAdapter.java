package com.socmaps.widget;

import java.util.HashMap;

import org.apache.commons.lang.StringUtils;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.maps.GoogleMap.InfoWindowAdapter;
import com.google.android.gms.maps.model.Marker;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.Event;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageFetcher;
import com.socmaps.images.singly.ImageCacheListener;
import com.socmaps.images.singly.ImageInfo;
import com.socmaps.images.singly.RemoteImageCache;
import com.socmaps.ui.DirectionActivity;
import com.socmaps.ui.EventDetailsActivity;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class CustomInfoWindowAdapter implements InfoWindowAdapter {
	LayoutInflater inflater = null;
	Context context;
	HashMap<String, Object> itemsOnMap;
	//ImageFetcher imageFetcher;
	
	//ImageDownloadListener imageDownloadListener;
	
	RemoteImageCache remoteImageCache;
	ImageCacheListener imageCacheListener;

	public CustomInfoWindowAdapter(Context context, LayoutInflater inflater,
			HashMap<String, Object> itemsOnMap, RemoteImageCache remoteImageCache, ImageCacheListener imageCacheListener) {
		this.inflater = inflater;
		this.context = context;
		this.itemsOnMap = itemsOnMap;

		this.remoteImageCache = remoteImageCache;
		this.imageCacheListener = imageCacheListener;
	}

	// /@Override
	public View getInfoContents(final Marker marker) {

		// Object item = itemsOnMap.get(marker.getId());

		//Log.i("InfoWindow", "getInfoContents");

		// contents

		return null;

	}

	public View getInfoWindow(Marker marker) {

		//Log.i("InfoWindow", "getInfoWindow");
		// Only changing the content for this tutorial
		// if you return null, it will just use the default window

		Object item = itemsOnMap.get(marker.getId());
		// contents = inflater.inflate(R.layout.content_party, null);

		if (item != null) {
			return getCustomInfoWindow(item);
		}
		return null;
	}

	private View getCustomInfoWindow(Object item) {

		Log.i("InfoWindow", "getCustomInfoWindow:"+item.getClass().getName());
		View contents = null;

		
		
		if (item instanceof People) {
			contents = inflater.inflate(R.layout.info_window_people, null);
			setContentsForPeople((People) item, contents);
		} else if (item instanceof SecondDegreePeople) {
			contents = inflater.inflate(R.layout.info_window_second_degree,
					null);
			setContentsForSecondDegreePeople((SecondDegreePeople) item,
					contents);
		} else if (item instanceof Place) {
			contents = inflater.inflate(R.layout.info_window_place, null);
			setContentsForPlace((Place) item, contents);
		} else if (item instanceof Event) {		
			contents = inflater.inflate(R.layout.info_window_event, null);
			setContentsForEvent((Event) item, contents);
		} else if (item instanceof GeoTag) {
			contents = inflater.inflate(R.layout.info_window_geotag, null);
			setContentsForGeoTag((GeoTag) item, contents);
		} 

		return contents;
	}

	private void setContentsForSecondDegreePeople(SecondDegreePeople item,
			View v) {

		TextView name = (TextView) v.findViewById(R.id.tvName);
		TextView address = (TextView) v.findViewById(R.id.tvAddress);
		TextView date = (TextView) v.findViewById(R.id.tvDate);
		ImageView image = (ImageView) v.findViewById(R.id.balloon_item_image);
		
		image.setImageResource(R.drawable.img_blank);
		setIconImage(item.getRefId(), item.getAvatar(), image);
		//imageFetcher.loadImage(item.getAvatar(), image, imageDownloadListener,item.getRefId());


		name.setText(Utility.getItemTitle(item));
		name.setVisibility(View.VISIBLE);

		if (item.getLastSeenAt() != null) {
			address.setText("at " + item.getLastSeenAt());
			address.setVisibility(View.VISIBLE);
		} else {
			address.setVisibility(View.GONE);
		}

		if (item.getCreateTime() != null) {
			date.setText(Utility.getFormattedDisplayDateForMap(item
					.getCreateTime()));
			date.setVisibility(View.VISIBLE);
		} else {
			date.setVisibility(View.GONE);
		}

		

	}

	private void setContentsForPlace(Place item, View v) {

		TextView title = (TextView) v.findViewById(R.id.title_text);
		TextView address = (TextView) v.findViewById(R.id.address_text);
		TextView distance = (TextView) v.findViewById(R.id.distance_text);
		ImageView image = (ImageView) v.findViewById(R.id.balloon_item_image);

		title.setText(item.getName());
		address.setText(item.getVicinity());
		distance.setText(Utility.getFormatedDistance(item.getDistance(),
				StaticValues.myInfo.getSettings().getUnit()) + " away");

		image.setImageResource(R.drawable.img_blank);
		//imageFetcher.loadImage(item.getIconUrl(), image,imageDownloadListener, item.getId());
		setIconImage(item.getId(), item.getIconUrl(), image);

	}

	private void setContentsForPeople(People item, View contents) {

		TextView name = (TextView) contents.findViewById(R.id.name_text);
		TextView status = (TextView) contents.findViewById(R.id.status_text);
		TextView distance = (TextView) contents
				.findViewById(R.id.distance_text);
		TextView age = (TextView) contents.findViewById(R.id.age_text);
		ImageView image = (ImageView) contents
				.findViewById(R.id.balloon_item_image);
		ImageView ivOnline = (ImageView) contents.findViewById(R.id.ivOnline);

		name.setText(Utility.getItemTitle(item));
		name.setVisibility(View.VISIBLE);

		if (Utility.isValidString(item.getStatusMsg())) {
			status.setText(item.getStatusMsg());
			status.setVisibility(View.VISIBLE);
		} else
			status.setVisibility(View.GONE);
		if (Utility.isValidString(String.format("%.2f", item.getDistance()))) {
			distance.setText(Utility.getFormatedDistance(item.getDistance(),
					StaticValues.myInfo.getSettings().getUnit()) + " away");
			distance.setVisibility(View.VISIBLE);
		} else
			distance.setVisibility(View.GONE);
		if (item.getAge() != 0) {
			age.setText("-Age:" + item.getAge());
			age.setVisibility(View.VISIBLE);
		} else
			age.setVisibility(View.GONE);

		if (item.isOnline()) {
			ivOnline.setImageResource(R.drawable.online);
		} else {
			ivOnline.setImageResource(R.drawable.offline);
		}

		image.setImageResource(R.drawable.img_blank);
		//imageFetcher.loadImage(item.getAvatar(), image, imageDownloadListener,item.getId());
		setIconImage(item.getId(), item.getAvatar(), image);
	}
	
	
	private void setContentsForEvent(final Event event, View v) {

		TextView tvName = (TextView) v.findViewById(R.id.tvName);
		TextView tvAddress = (TextView) v.findViewById(R.id.tvAddress);
		TextView tvDate = (TextView) v.findViewById(R.id.tvDate);
		
		if (event.getEventTitle() != null) {
			tvName.setText(event.getEventTitle());
		} else {
			tvName.setText("");
		}

		if (event.getAddress() != null) {
			tvAddress.setText("at " + event.getAddress());
		} else {
			tvAddress.setText("");
			tvAddress.setVisibility(View.GONE);
		}

		if (event.getEventTime() != null) {
			tvDate.setText(Utility.getFormattedDisplayDateForMap(event
					.getEventTime()));
		} else {
			tvDate.setVisibility(View.GONE);
		}

		

	}
	
	private void setContentsForGeoTag(GeoTag geoTag, View v) {

		TextView tvTitle = (TextView) v.findViewById(R.id.title_text);
		TextView tvUser = (TextView) v.findViewById(R.id.user_text);
		TextView tvAddress = (TextView) v.findViewById(R.id.address_text);
		
		String title = geoTag.getTitle();
		if (title != null && !title.equalsIgnoreCase("")) {
			tvTitle.setText(title + " tagged");
		} else {
			tvTitle.setVisibility(View.GONE);
		}

		if (geoTag.getOwner() != null) {
			String name = Utility.getItemTitle(geoTag.getOwner());
			if (!name.equalsIgnoreCase("")) {
				tvUser.setText("by " + name);
			} else {
				tvUser.setVisibility(View.GONE);
			}
		} else {
			tvUser.setVisibility(View.GONE);
		}

		String address = geoTag.getAddress();
		if (!address.equalsIgnoreCase("")) {
			tvAddress.setText("at " + address);
		} else {
			tvAddress.setVisibility(View.GONE);
		}

	}
	
	private void setIconImage(String itemId, String imageUrl, ImageView imageView)
	{
		if(Utility.isValidString(imageUrl))
		{
			Bitmap bitmap = null;
			ImageInfo imageInfo = new ImageInfo();
	        imageInfo.id = StringUtils.lowerCase(itemId);
	        imageInfo.imageUrl = imageUrl;
	        imageInfo.listener = imageCacheListener;
	        bitmap = remoteImageCache.getImage(imageInfo);
			if(bitmap!=null)
			{
				imageView.setImageBitmap(bitmap);
			}
			
			Log.i("CustomInfoWindow:url", imageUrl);
		}
	}
	
}
