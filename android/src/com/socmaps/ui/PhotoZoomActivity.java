package com.socmaps.ui;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.images.ImageDownloader;

public class PhotoZoomActivity extends Activity {

	private ImageDownloader imageDownloader;
	private LayoutInflater inflater;
	private Context context;
	ViewPager viewPager;
	ImagePagerAdapter adapter;
	private int position = 0;
	private String[] photo_url;
	private ProgressBar progressBar;
	boolean isShow = false;
	ProgressDialog pDialog;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.photo_zoom_swip_layout);

		inetialize();

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		generateView();
	}

	private void generateView() {
		// TODO Auto-generated method stub

		parse();

		progressBar.setVisibility(View.INVISIBLE);
	}

	private void inetialize() {
		// TODO Auto-generated method stub
		context = PhotoZoomActivity.this;

		position = getIntent().getIntExtra("PHOTO_ZOOM_POSITION", 0);
		photo_url = getIntent().getStringArrayExtra("PHOTO_URLS");

		Log.w("PhotoZoomActivity photo_url size", photo_url.length + " what?");

		// imageDownloader = new ImageDownloader();
		// imageDownloader.setMode(ImageDownloader.Mode.CORRECT);
		imageDownloader = ImageDownloader.getInstance();

		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		viewPager = (ViewPager) findViewById(R.id.view_pager);
		progressBar = (ProgressBar) findViewById(R.id.progressBar);
		viewPager.setOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageSelected(int position) {
				// TODO Auto-generated method stub

				isShow = true;
				Log.i("viewPager onPageSelected", "position:" + position);

			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
				// TODO Auto-generated method stub
			}

			@Override
			public void onPageScrollStateChanged(int state) {
				// TODO Auto-generated method stub
				if (state == ViewPager.SCROLL_STATE_IDLE) {

					Log.d("viewPager onPageScrollStateChanged  SCROLL_STATE_IDLE",
							"state:" + state);

					isShow = false;

				}

			}
		});
	}

	private void parse() {
		// TODO Auto-generated method stub

		pDialog = ProgressDialog.show(context, "Please wait...", "Loading...",
				false, true);

		final Thread d = new Thread(new Runnable() {

			@Override
			public void run() {

				try {
					Thread.sleep(2000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				/*
				 * update the GUI
				 */

				runOnUiThread(new Runnable() {

					@Override
					public void run() {

						if (pDialog != null) {
							pDialog.cancel();
						}

						adapter = new ImagePagerAdapter();
						viewPager.setAdapter(adapter);
						viewPager.setCurrentItem(position);

					}
				});

			}
		});

		d.start();

	}

	private class ImagePagerAdapter extends PagerAdapter {
	

		@Override
		public int getCount() {
			// return mImages.length;
			// return URLS.length;
			return photo_url.length;
		}

		@Override
		public void startUpdate(ViewGroup container) {
			// TODO Auto-generated method stub
			super.startUpdate(container);

			
		}


		@Override
		public boolean isViewFromObject(View view, Object object) {
			

			if (isShow) {
				showHideButton(view.findViewById(R.id.btnPhotoZoomRight),
						view.findViewById(R.id.btnPhotoZoomLeft),
						view.findViewById(R.id.btnPhotoZoomClose));

				Log.w("Test isViewFromObject", "isShow true");

			} else {

				Log.w("Test isViewFromObject", "isShow false");

			}
		

			return view == object;

		}

		@Override
		public Object instantiateItem(ViewGroup container, final int position) {

			final View view = inflater.inflate(R.layout.photo_zoom_item_layout,
					null);

			ImageView ivPhotoZoom = (ImageView) view
					.findViewById(R.id.ivPhotoZoom);
			final Button btnPhotoZoomRight = (Button) view
					.findViewById(R.id.btnPhotoZoomRight);
			final Button btnPhotoZoomLeft = (Button) view
					.findViewById(R.id.btnPhotoZoomLeft);

			final Button btnPhotoZoomClose = (Button) view
					.findViewById(R.id.btnPhotoZoomClose);


			ivPhotoZoom.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {

					showHideButtons(btnPhotoZoomRight, btnPhotoZoomLeft,
							btnPhotoZoomClose);
				}
			});

			btnPhotoZoomRight.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {

					showNextScreen(position);

				}
			});

			btnPhotoZoomLeft.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {

					showPrevScreen(position);

				
				}
			});

			btnPhotoZoomClose.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {

					finish();
				}
			});

			ivPhotoZoom.setImageResource(R.drawable.img_blank);
			imageDownloader.download(photo_url[position], ivPhotoZoom);

			showHideButton(btnPhotoZoomRight, btnPhotoZoomLeft,
					btnPhotoZoomClose);

			((ViewPager) container).addView(view, 0);

			Log.i("What is this", "instantiateItem");

			return view;
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			((ViewPager) container).removeView((View) object);
		}
	}

	public void showHideButton(View v, View v1, View v2) {
		v.setVisibility(View.INVISIBLE);
		v1.setVisibility(View.INVISIBLE);
		v2.setVisibility(View.INVISIBLE);

	}

	public void showHideButtons(View v, View v1, View v2) {

		if (v.getVisibility() == View.VISIBLE) {

			v.setVisibility(View.INVISIBLE);

		} else {

			v.setVisibility(View.VISIBLE);
		}

		if (v1.getVisibility() == View.VISIBLE) {

			v1.setVisibility(View.INVISIBLE);

		} else {

			v1.setVisibility(View.VISIBLE);
		}

		if (v2.getVisibility() == View.VISIBLE) {

			v2.setVisibility(View.INVISIBLE);

		} else {

			v2.setVisibility(View.VISIBLE);
		}

	}

	private void showPrevScreen(int position) {
		// TODO Auto-generated method stub

		int posi = --position;

		viewPager.setCurrentItem(posi);

	}

	private void showNextScreen(int position) {
		// TODO Auto-generated method stub
		int posi = ++position;

		viewPager.setCurrentItem(posi);

	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
	}
}