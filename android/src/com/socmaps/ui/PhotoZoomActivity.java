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
	private int focusedPage = 0;
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

				focusedPage = position;
				isShow = true;

				// viewPager.getChildAt(position)
				// .findViewById(R.id.btnPhotoZoomRight)
				// .setVisibility(View.INVISIBLE);
				// viewPager.getChildAt(position)
				// .findViewById(R.id.btnPhotoZoomLeft)
				// .setVisibility(View.INVISIBLE);
				// viewPager.getChildAt(position)
				// .findViewById(R.id.btnPhotoZoomClose)
				// .setVisibility(View.INVISIBLE);

				Log.i("viewPager onPageSelected", "position:" + position);

			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
				// TODO Auto-generated method stub
				// Log.w("viewPager onPageScrolled", "arg0:" + arg0 + " arg2:"
				// + arg2 + " arg1:" + arg1);
			}

			@Override
			public void onPageScrollStateChanged(int state) {
				// TODO Auto-generated method stub

				// Log.d("viewPager onPageScrollStateChanged", "state:" +
				// state);

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
		// private int[] mImages = new int[] { R.drawable.chiang_mai,
		// R.drawable.himeji, R.drawable.petronas_twin_tower,
		// R.drawable.ulm };

		// private String[] URLS = {
		// "http://lh5.ggpht.com/_mrb7w4gF8Ds/TCpetKSqM1I/AAAAAAAAD2c/Qef6Gsqf12Y/s144-c/_DSC4374%20copy.jpg",
		// "http://lh5.ggpht.com/_Z6tbBnE-swM/TB0CryLkiLI/AAAAAAAAVSo/n6B78hsDUz4/s144-c/_DSC3454.jpg",
		// "http://lh3.ggpht.com/_GEnSvSHk4iE/TDSfmyCfn0I/AAAAAAAAF8Y/cqmhEoxbwys/s144-c/_MG_3675.jpg",
		// "http://lh6.ggpht.com/_Nsxc889y6hY/TBp7jfx-cgI/AAAAAAAAHAg/Rr7jX44r2Gc/s144-c/IMGP9775a.jpg",
		// "http://lh3.ggpht.com/_lLj6go_T1CQ/TCD8PW09KBI/AAAAAAAAQdc/AqmOJ7eg5ig/s144-c/Juvenile%20Gannet%20despute.jpg",
		// "http://lh6.ggpht.com/_ZN5zQnkI67I/TCFFZaJHDnI/AAAAAAAABVk/YoUbDQHJRdo/s144-c/P9250508.JPG",
		// "http://lh4.ggpht.com/_XjNwVI0kmW8/TCOwNtzGheI/AAAAAAAAC84/SxFJhG7Scgo/s144-c/0014.jpg"
		//
		// };

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

			// showHideButton(container.getChildAt(R.id.btnPhotoZoomRight),
			// container.getChildAt(R.id.btnPhotoZoomLeft),
			// container.getChildAt(R.id.btnPhotoZoomClose));
			// Log.w("Test startUpdate ViewGroup", "????");
		}

		// @Override
		// public int getItemPosition(Object object) {
		// // TODO Auto-generated method stub
		// return POSITION_NONE;
		// }

		@Override
		public boolean isViewFromObject(View view, Object object) {
			// return view == ((ImageView) object);

			// Log.w("Test isViewFromObject", "????");

			/*
			 * showHideButton( ((View)
			 * object).findViewById(R.id.btnPhotoZoomRight), ((View)
			 * object).findViewById(R.id.btnPhotoZoomLeft), ((View)
			 * object).findViewById(R.id.btnPhotoZoomClose));
			 */

			if (isShow) {
				showHideButton(view.findViewById(R.id.btnPhotoZoomRight),
						view.findViewById(R.id.btnPhotoZoomLeft),
						view.findViewById(R.id.btnPhotoZoomClose));

				Log.w("Test isViewFromObject", "isShow true");

			} else {

				Log.w("Test isViewFromObject", "isShow false");

			}
			// showHideButton(view.findViewById(R.id.btnPhotoZoomRight),
			// view.findViewById(R.id.btnPhotoZoomLeft),
			// view.findViewById(R.id.btnPhotoZoomClose));

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

			// viewPager.setTag(btnPhotoZoomRight);

			// btnPhotoZoomRight.setTag(btnPhotoZoomRight);

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

					// showHideButton(btnPhotoZoomRight, btnPhotoZoomLeft,
					// btnPhotoZoomClose);
				}
			});

			btnPhotoZoomLeft.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View arg0) {

					showPrevScreen(position);

					// showHideButton(btnPhotoZoomRight, btnPhotoZoomLeft,
					// btnPhotoZoomClose);

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

		// viewPager.findViewWithTag(v).setVisibility(View.INVISIBLE);

		v.setVisibility(View.INVISIBLE);
		v1.setVisibility(View.INVISIBLE);
		v2.setVisibility(View.INVISIBLE);

		// v.findViewWithTag(v).setVisibility(View.INVISIBLE);

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