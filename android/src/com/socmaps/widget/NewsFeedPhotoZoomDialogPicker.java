/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import java.util.List;

import android.app.Dialog;
import android.content.Context;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;


/**
 * NewsFeedPhotoZoomDialogPicker generates a  dialog to display photo zoom.
 *
 */
public class NewsFeedPhotoZoomDialogPicker extends Dialog {

	private String url;

	LinearLayout photoContainer;

	ImageDownloader imageDownloader;

	List<ImageView> itemViewList;

	ImageView iv; 
	
	/**
	 * This method is used to perform to enlarge the newsfeed photo. When we click on that photo, the photo will be 
	 * enlarged through the entire screen. 
	 * 
	 * @param context Currently active Context. 
	 * @param url 	As String which is basically an URL from where we've to download that particular image. 
	 * @param imageDownloader An instance of ImageDownloader to download a particular image. 
	 * @see #initialize() 
	 * @see #loadImage()
	 */

	public NewsFeedPhotoZoomDialogPicker(Context context, String url,
			ImageDownloader imageDownloader) {
		super(context);

		this.url = url;

		this.imageDownloader = imageDownloader;
		this.imageDownloader.setMode(ImageDownloader.Mode.CORRECT);

		/** It will hide the title */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.newsfeed_photo_zoom);

		initialize();
		loadImage();

	}

	private void loadImage() {
		if (url != null) {
			iv.setImageResource(R.drawable.img_blank);
			imageDownloader.download(url, iv);
		}
	}

	private void initialize() {
		iv = (ImageView) findViewById(R.id.ivNFPhotoZoom);

	}
}