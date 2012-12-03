/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import java.util.ArrayList;
import java.util.List;

import android.app.Dialog;
import android.content.Context;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.OnGestureListener;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socmaps.entity.Photo;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.R;

public class NewsFeedPhotoZoomDialogPicker extends Dialog {

	private Context context;
	private String url;

	LinearLayout photoContainer;

	ImageDownloader imageDownloader;

	List<ImageView> itemViewList;

	ImageView iv;

	public NewsFeedPhotoZoomDialogPicker(Context context, String url,
			ImageDownloader imageDownloader) {
		super(context);

		this.context = context;
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