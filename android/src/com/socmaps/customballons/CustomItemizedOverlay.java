package com.socmaps.customballons;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.drawable.Drawable;

import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;
import com.readystatesoftware.mapviewballoons.BalloonItemizedOverlay;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.socmaps.images.ImageDownloader;
import com.socmaps.util.Constant;

public class CustomItemizedOverlay<Item extends OverlayItem> extends
		BalloonItemizedOverlay<CustomOverlayItem> {

	public ArrayList<CustomOverlayItem> m_overlays = new ArrayList<CustomOverlayItem>();
	private Context c;
	private BubleTapHandle bubleTapHandle;
	private int typeFlag;
	private ImageDownloader imageDownloader;

	/*
	 * private boolean isVisible=true;
	 * 
	 * 
	 * @Override //protected final boolean onTap(int index) { public final
	 * boolean onTap(int index) {
	 * 
	 * if(isVisible) { super.onTap(index); }
	 * 
	 * return true; }
	 * 
	 * 
	 * @Override public void draw(Canvas canvas, MapView mapView, boolean
	 * shadow) { // TODO Auto-generated method stub
	 * 
	 * if(isVisible) { super.draw(canvas, mapView, shadow); } }
	 * 
	 * public Boolean getIsVisible() { return isVisible; }
	 * 
	 * public void setIsVisible(Boolean visible) { this.isVisible = visible; }
	 * 
	 * public void toggleVisible() { this.isVisible = !isVisible; }
	 */
	public CustomItemizedOverlay(Drawable defaultMarker, MapView mapView,
			BubleTapHandle bth, int flag, ImageDownloader imageDownloader) {
		super(boundCenter(defaultMarker), mapView);
		c = mapView.getContext();
		this.bubleTapHandle = bth;
		this.typeFlag = flag;
		this.imageDownloader = imageDownloader;
	}

	public void addOverlay(CustomOverlayItem overlay) {
		m_overlays.add(overlay);
		populate();
	}

	public void populateItemizedOverlay() {
		populate();
		setLastFocusedIndex(-1);
	}

	@Override
	protected CustomOverlayItem createItem(int i) {
		return m_overlays.get(i);
	}

	@Override
	public int size() {
		return m_overlays.size();
	}

	@Override
	protected boolean onBalloonTap(int index, CustomOverlayItem item) {
		/*
		 * Toast.makeText(c, "onBalloonTap for overlay index " +
		 * item.getUser().getFirstName(), Toast.LENGTH_LONG).show();
		 */
		// DialogsAndToasts.showExtendedUserInfoDialog(c);
		bubleTapHandle.catchBubleTap(item, typeFlag);
		return true;
	}

	@Override
	protected BalloonOverlayView<CustomOverlayItem> createBalloonOverlayView() {
		// use our custom balloon view with our custom overlay item type:

		if (typeFlag == Constant.FLAG_PEOPLE)
			return new CustomBalloonOverlayViewPeople<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(), imageDownloader);
		else if (typeFlag == Constant.FLAG_PLACE)
			return new CustomBalloonOverlayViewPlace<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(),imageDownloader);
		else if (typeFlag == Constant.FLAG_EVENT)
			return new CustomBalloonOverlayViewEvent<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(),imageDownloader);
		else if (typeFlag == Constant.FLAG_MEETUP)
			return new CustomBalloonOverlayViewMeetup<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(),imageDownloader);
		else if (typeFlag == Constant.FLAG_SECOND_DEGREE)
			return new CustomBalloonOverlayViewSecondDegreePeople<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(),imageDownloader);
		else if (typeFlag == Constant.FLAG_GEOTAG)
			return new CustomBalloonOverlayViewGeotag<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(),imageDownloader);
		else
			return new CustomBalloonOverlayViewSelf<CustomOverlayItem>(
					getMapView().getContext(), getBalloonBottomOffset(),imageDownloader);
	}

	public void removeItem(int i) {
		m_overlays.remove(i);

		populate();
	}

	public void removeAllItem() {
		m_overlays.clear();
		populate();
	}
}
