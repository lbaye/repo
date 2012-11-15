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
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.Photo;
import com.socmaps.images.ImageDownloader;
import com.socmaps.images.ImageDownloader.Mode;
import com.socmaps.ui.R;

public class PhotoZoomDialogPicker extends Dialog implements
		View.OnClickListener {

	private Context context;
	private String pickerName;
	private Button btnPhotoZoomRight, btnPhotoZoomLeft, btnClose;
	// private ImageView ivPhotoZoom;
	private RelativeLayout mainLayPhotoZoom;
	LinearLayout photoContainer;
	TextView tvLoading;

	private int position;

	private List<Photo> photoList;
	private Photo photo;
	ImageDownloader imageDownloader;

	List<ImageView> itemViewList;
	private LayoutInflater inflater;

	public PhotoZoomDialogPicker(Context context, String pickerName,
			List<Photo> photoList, ImageDownloader imageDownloader, int position) {
		super(context);

		this.context = context;
		this.pickerName = pickerName;
		this.photoList = photoList;

		this.imageDownloader = imageDownloader;
		this.imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
		this.position = position;

		/** It will hide the title */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.photo_zoom_layout);

		initialize();

		generateViewList();
		// downloadImage(position);

		displayItems();

		// photoContainer.getChildAt(position).setVisibility(View.VISIBLE);

		showHideButton(false);

	}

	private void displayItems() {
		// TODO Auto-generated method stub
		for (int i = 0; i < itemViewList.size(); i++) {

			if (position == i) {
				itemViewList.get(i).setVisibility(View.VISIBLE);
			}
			photoContainer.addView(itemViewList.get(i));

		}
		//tvLoading.setVisibility(View.GONE);
		photoContainer.setVisibility(View.VISIBLE);

	}

	private void generateViewList() {
		// TODO Auto-generated method stub

		for (int i = 0; i < photoList.size(); i++) {
			itemViewList.add(getItemView(photoList.get(i)));
		}

	}

	private ImageView getItemView(Photo photo) {
		// TODO Auto-generated method stub
		ImageView view = (ImageView) inflater.inflate(
				R.layout.row_photo_details, null);

		if (photo.getImageLarge() != null) {
			if (!photo.getImageLarge().equalsIgnoreCase("")) {
				imageDownloader.download(photo.getImageLarge(), view);
			}
		}

		return view;
	}

	private void initialize() {

		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		photoContainer = (LinearLayout) findViewById(R.id.photoContainer);
		photoContainer.setOnClickListener(this);
		
		tvLoading = (TextView)findViewById(R.id.tvLoading);

		btnPhotoZoomRight = (Button) findViewById(R.id.btnPhotoZoomRight);
		btnPhotoZoomRight.setOnClickListener(this);

		btnPhotoZoomLeft = (Button) findViewById(R.id.btnPhotoZoomLeft);
		btnPhotoZoomLeft.setOnClickListener(this);

		btnClose = (Button) findViewById(R.id.btnPhotoZoomClose);
		btnClose.setOnClickListener(this);

		mainLayPhotoZoom = (RelativeLayout) findViewById(R.id.mainLayPhotoZoom);
		mainLayPhotoZoom.setOnClickListener(this);

		itemViewList = new ArrayList<ImageView>();

		// ivPhotoZoom = (ImageView) findViewById(R.id.ivPhotoZoom);
		// ivPhotoZoom.setOnClickListener(this);

	}

	@Override
	public void onClick(View v) {

		if (v == btnPhotoZoomRight) {

			if (position > -1 && position < itemViewList.size()-1) {
				if (photoContainer.getChildAt(position) != null) {
					photoContainer.getChildAt(position)
							.setVisibility(View.GONE);
				}

				position++;

				if (photoContainer.getChildAt(position) != null) {
					photoContainer.getChildAt(position).setVisibility(
							View.VISIBLE);
				}
			}

		}

		if (v == btnPhotoZoomLeft) {

			if (position > 0) {
				if (photoContainer.getChildAt(position) != null) {
					photoContainer.getChildAt(position)
							.setVisibility(View.GONE);
				}

				position--;

				if (photoContainer.getChildAt(position) != null) {
					photoContainer.getChildAt(position).setVisibility(
							View.VISIBLE);
				}
			}
		}

		if (v == btnClose) {

			dismiss();
		}
		if (v == photoContainer) {
			showHideButton(true);
		}

	}

	/*
	 * Download image from url
	 */
	/*
	 * private void downloadImage(int position) {
	 * 
	 * Log.w("downloadImage PhotoZoomDialogPicker", "position: " + position);
	 * 
	 * ivPhotoZoom.setImageResource(R.drawable.img_blank);
	 * 
	 * if (position < photoList.size() && position >= 0) {
	 * 
	 * if (photoList != null) { photo = photoList.get(position);
	 * 
	 * if (photo.getImageLarge() != null && photo.getImageLarge() != "") {
	 * imageDownloader .download(photo.getImageLarge(), ivPhotoZoom); }
	 * 
	 * }
	 * 
	 * }
	 * 
	 * }
	 */

	private void showHideButton(boolean isShow) {

		if (isShow && photoContainer.getVisibility() == View.VISIBLE) {
			btnPhotoZoomRight.setVisibility(View.VISIBLE);
			btnPhotoZoomLeft.setVisibility(View.VISIBLE);
			btnClose.setVisibility(View.VISIBLE);
		} else {
			btnPhotoZoomRight.setVisibility(View.INVISIBLE);
			btnPhotoZoomLeft.setVisibility(View.INVISIBLE);
			btnClose.setVisibility(View.INVISIBLE);
		}
	}

}