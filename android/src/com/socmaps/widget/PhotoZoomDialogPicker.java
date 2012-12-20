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

/**
 * PhotoZoomDialogPicker generates a custom dialog to display photo zoom.
 *
 */
public class PhotoZoomDialogPicker extends Dialog implements
		View.OnClickListener, OnGestureListener {

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
	
	// Gester part
	private GestureDetector detector;

	private static final int SWIPE_MIN_DISTANCE = 150;

	private static final int SWIPE_MAX_OFF_PATH = 100;

	private static final int SWIPE_THRESHOLD_VELOCITY = 100;
	private boolean isShow = false; 
	
	/**
	 * This methods performs to pick out a particular photo to zoom out. 
	 * 
	 * @param context 			Currently active Context. 
	 * @param pickerName 		As String which is the name of the item. 
	 * @param photoList 		An array list of type Photo which contains a list of photos. 
	 * @param imageDownloader 	An instance of ImageDownloader which is used to download image from a particular uri. 
	 * @param position 			As Integer which indicates the idex of a particular photo. 
	 * @see Context 
	 * @see String 
	 * @see ImageDownloader 
	 * @see #initialize() 
	 * @see #generateViewList() 
	 * @see #displayItems() 
	 * @see #showHideButton(boolean)
	 */

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

		displayItems();

		showHideButton(isShow);

	}

	private void displayItems() {
		// TODO Auto-generated method stub
		for (int i = 0; i < itemViewList.size(); i++) {

			if (position == i) {
				itemViewList.get(i).setVisibility(View.VISIBLE);
			}
			photoContainer.addView(itemViewList.get(i));

		}

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

		tvLoading = (TextView) findViewById(R.id.tvLoading);

		btnPhotoZoomRight = (Button) findViewById(R.id.btnPhotoZoomRight);
		btnPhotoZoomRight.setOnClickListener(this);

		btnPhotoZoomLeft = (Button) findViewById(R.id.btnPhotoZoomLeft);
		btnPhotoZoomLeft.setOnClickListener(this);

		btnClose = (Button) findViewById(R.id.btnPhotoZoomClose);
		btnClose.setOnClickListener(this);

		mainLayPhotoZoom = (RelativeLayout) findViewById(R.id.mainLayPhotoZoom);
		mainLayPhotoZoom.setOnClickListener(this);

		itemViewList = new ArrayList<ImageView>();

		detector = new GestureDetector(context, this);

	}

	@Override
	public void onClick(View v) {

		if (v == btnPhotoZoomRight) {
			showNextScreen();
		}

		if (v == btnPhotoZoomLeft) {
			showPrevScreen();

		}

		if (v == btnClose) {

			dismiss();
		}

	}

	private void showHideButton(boolean isShow) {

		if (isShow) {
			btnPhotoZoomRight.setVisibility(View.VISIBLE);
			btnPhotoZoomLeft.setVisibility(View.VISIBLE);
			btnClose.setVisibility(View.VISIBLE);

		} else {
			btnPhotoZoomRight.setVisibility(View.GONE);
			btnPhotoZoomLeft.setVisibility(View.GONE);
			btnClose.setVisibility(View.GONE);
		}
	}

	@Override
	public boolean onDown(MotionEvent arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean onFling(final MotionEvent e1, final MotionEvent e2,
			float velocityX, float velocityY) {

		float dX = e2.getX() - e1.getX();

		float dY = e1.getY() - e2.getY();

		if (Math.abs(dY) < SWIPE_MAX_OFF_PATH &&

		Math.abs(velocityX) >= SWIPE_THRESHOLD_VELOCITY &&

		Math.abs(dX) >= SWIPE_MIN_DISTANCE) {

			if (dX > 0) {			
				showPrevScreen();

			} else {
				showNextScreen();

			}

			return true;

		} else if (Math.abs(dX) < SWIPE_MAX_OFF_PATH &&

		Math.abs(velocityY) >= SWIPE_THRESHOLD_VELOCITY &&

		Math.abs(dY) >= SWIPE_MIN_DISTANCE) {

			if (dY > 0) {

			} else {

			}

			return true;

		}

		return false;

	}

	@Override
	public void onLongPress(MotionEvent arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public boolean onScroll(MotionEvent arg0, MotionEvent arg1, float arg2,
			float arg3) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void onShowPress(MotionEvent arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public boolean onSingleTapUp(MotionEvent arg0) {
		// TODO Auto-generated method stub
		Log.w("PhotoZoomDialogPicker ", "onSingleTapUp got it");

		isShow = !isShow;

		showHideButton(isShow);

		return true;
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		// TODO Auto-generated method stub
		detector.onTouchEvent(event);
		Log.w("PhotoZoomDialogPicker ", "onTouchEvent got it");
		return super.onTouchEvent(event);
	}

	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		// TODO Auto-generated method stub
		super.dispatchTouchEvent(ev);

		return detector.onTouchEvent(ev);

	}

	private void showPrevScreen() {
		// TODO Auto-generated method stub
		if (position > 0) {
			if (photoContainer.getChildAt(position) != null) {
				photoContainer.getChildAt(position).setVisibility(View.GONE);
			}

			position--;

			if (photoContainer.getChildAt(position) != null) {
				photoContainer.getChildAt(position).setVisibility(View.VISIBLE);
			}
		}

		showHideButton(false);
	}

	private void showNextScreen() {
		// TODO Auto-generated method stub
		if (position > -1 && position < itemViewList.size() - 1) {
			if (photoContainer.getChildAt(position) != null) {
				photoContainer.getChildAt(position).setVisibility(View.GONE);
			}

			position++;

			if (photoContainer.getChildAt(position) != null) {
				photoContainer.getChildAt(position).setVisibility(View.VISIBLE);
			}
		}

		showHideButton(false);

	}

}