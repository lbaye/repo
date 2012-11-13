package com.socmaps.widget;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.MyLocationOverlay;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.socmaps.ui.R;
import com.socmaps.util.Utility;

public class LocationPicker extends MapActivity implements OnClickListener {
	private MapView map = null;
	private MyLocationOverlay me = null;
	private TextView showLocation;
	private MapController mapController;
	private Drawable marker;
	private List<Overlay> mapOverlays;
	private double lat = 0.0, lng = 0.0;
	private String address = null;
	private String name = null;
	private Button btnOk, btnCancel;
	private final static String DRAGING_MARKER_MESSAGE = "Updating location";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.location_picker_layout);
		init();
		getIntentData();

		updateMap();
		addMyLocationOverlay();
		// map.getController().setCenter(getPoint(23.790116,90.422437));

	}

	private void addMyLocationOverlay() {
		// TODO Auto-generated method stub
		me = new MyLocationOverlay(this, map);
		map.getOverlays().add(me);
	}

	private void getIntentData() {
		// TODO Auto-generated method stub
		lat = getIntent().getDoubleExtra("LAT", 0);
		lng = getIntent().getDoubleExtra("LNG", 0);
	}

	private void updateMap() {
		// TODO Auto-generated method stub
		Utility.getAddressByCoordinate(lat, lng, new LocationAddressHandler());
		SitesOverlay sitesOverlay = new SitesOverlay(marker);
		sitesOverlay.addOverlay(new OverlayItem(getPoint(lat, lng), "", ""));
		mapOverlays.add(sitesOverlay);
		// mapController.setCenter(getPoint(lat,lng));
		mapController.animateTo(getPoint(lat, lng));
	}

	private class LocationAddressHandler extends Handler {
		@Override
		public void handleMessage(Message message) {
			String result = null;
			String locName = null;
			switch (message.what) {
			case 0:
				// failed to get address
				break;
			case 1:
				Bundle bundle = message.getData();
				result = bundle.getString("address");
				locName = bundle.getString("name");

				break;
			default:
				result = null;
			}
			// replace by what you need to do
			if (result != null) {
				name = locName;
				address = result;
				showLocation.setText(result);
			} else {
				Log.e("ADDRESS", "Failed to get.");
			}

		}
	}

	private void init() {
		// TODO Auto-generated method stub
		showLocation = (TextView) findViewById(R.id.latlong);
		map = (MapView) findViewById(R.id.map);
		mapController = map.getController();
		mapController.setZoom(17);
		map.setBuiltInZoomControls(false);
		marker = getResources().getDrawable(R.drawable.marker);

		marker.setBounds(0, 0, marker.getIntrinsicWidth(),
				marker.getIntrinsicHeight());

		mapOverlays = map.getOverlays();
		btnOk = (Button) findViewById(R.id.btnOk);
		btnOk.setOnClickListener(this);
		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

	}

	@Override
	public void onResume() {
		super.onResume();

		// me.enableCompass();
	}

	@Override
	public void onPause() {
		super.onPause();

		// me.disableCompass();
	}

	@Override
	protected boolean isRouteDisplayed() {
		return (false);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_S) {
			map.setSatellite(!map.isSatellite());
			return (true);
		} else if (keyCode == KeyEvent.KEYCODE_Z) {
			map.displayZoomControls(true);
			return (true);
		}

		return (super.onKeyDown(keyCode, event));
	}

	private GeoPoint getPoint(double lat, double lon) {
		return (new GeoPoint((int) (lat * 1000000.0), (int) (lon * 1000000.0)));
	}

	private class SitesOverlay extends ItemizedOverlay<OverlayItem> {
		private List<OverlayItem> items = new ArrayList<OverlayItem>();
		private Drawable marker = null;
		private OverlayItem inDrag = null;
		private ImageView dragImage = null;
		private int xDragImageOffset = 0;
		private int yDragImageOffset = 0;
		private int xDragTouchOffset = 0;
		private int yDragTouchOffset = 0;

		public SitesOverlay(Drawable marker) {
			super(marker);
			this.marker = marker;

			dragImage = (ImageView) findViewById(R.id.drag);
			xDragImageOffset = dragImage.getDrawable().getIntrinsicWidth() / 2;
			yDragImageOffset = dragImage.getDrawable().getIntrinsicHeight();

		}

		public void addOverlay(OverlayItem overlay) {
			items.add(overlay);
			populate();
		}

		@Override
		protected OverlayItem createItem(int i) {
			return (items.get(i));
		}

		@Override
		public void draw(Canvas canvas, MapView mapView, boolean shadow) {
			super.draw(canvas, mapView, shadow);

			boundCenterBottom(marker);
		}

		@Override
		public int size() {
			return (items.size());
		}

		@Override
		public boolean onTouchEvent(MotionEvent event, MapView mapView) {
			final int action = event.getAction();
			final int x = (int) event.getX();
			final int y = (int) event.getY();
			boolean result = false;

			if (action == MotionEvent.ACTION_DOWN) {
				for (OverlayItem item : items) {
					Point p = new Point(0, 0);

					map.getProjection().toPixels(item.getPoint(), p);

					if (hitTest(item, marker, x - p.x, y - p.y)) {
						result = true;
						inDrag = item;
						items.remove(inDrag);
						populate();

						xDragTouchOffset = 0;
						yDragTouchOffset = 0;

						setDragImagePosition(p.x, p.y);
						dragImage.setVisibility(View.VISIBLE);

						xDragTouchOffset = x - p.x;
						yDragTouchOffset = y - p.y;

						break;
					}
				}
			} else if (action == MotionEvent.ACTION_MOVE && inDrag != null) {
				setDragImagePosition(x, y);
				GeoPoint pt = map.getProjection().fromPixels(
						x - xDragTouchOffset, y - yDragTouchOffset);
				showLocation.setText(DRAGING_MARKER_MESSAGE);
				result = true;
			} else if (action == MotionEvent.ACTION_UP && inDrag != null) {
				dragImage.setVisibility(View.GONE);

				GeoPoint pt = map.getProjection().fromPixels(
						x - xDragTouchOffset, y - yDragTouchOffset);
				Utility.getAddressByCoordinate(pt.getLatitudeE6() / 1E6,
						pt.getLongitudeE6() / 1E6, new LocationAddressHandler());
				showLocation.setText(pt.getLatitudeE6() / 1E6 + ""
						+ pt.getLongitudeE6() / 1E6);
				lat = pt.getLatitudeE6() / 1E6;
				lng = pt.getLongitudeE6() / 1E6;
				OverlayItem toDrop = new OverlayItem(pt, inDrag.getTitle(),
						inDrag.getSnippet());

				items.add(toDrop);
				populate();

				inDrag = null;
				result = true;
			}

			return (result || super.onTouchEvent(event, mapView));
		}

		private void setDragImagePosition(int x, int y) {
			RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) dragImage
					.getLayoutParams();

			lp.setMargins(x - xDragImageOffset - xDragTouchOffset, y
					- yDragImageOffset - yDragTouchOffset, 0, 0);
			dragImage.setLayoutParams(lp);
		}
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnOk) {
			Intent i = getIntent();
			i.putExtra("ADDRESS", address);
			i.putExtra("LAT", lat);
			i.putExtra("LNG", lng);
			i.putExtra("NAME", name);
			setResult(RESULT_OK, i);
			finish();

		} else if (v == btnCancel) {
			Intent i = getIntent();
			i.putExtra("ADDRESS", address);
			i.putExtra("LAT", lat);
			i.putExtra("LNG", lng);
			i.putExtra("NAME", name);
			setResult(RESULT_CANCELED, i);
			finish();

		}
	}
}