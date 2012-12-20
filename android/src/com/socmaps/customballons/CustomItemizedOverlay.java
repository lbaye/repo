package com.socmaps.customballons;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.widget.PopupWindow;

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

	/**
	 * Initialization of CustomItemizedOverlay constructor using the specified parameters. 
	 * 
	 * @param defaultMarker 	a Drawable instance which is used for default case only. 
	 * @param mapView			an instance of MapView on which we'll display our objects. 
	 * @param bth 				an instance of interface BubleTapHandle. 
	 * @param flag 				as Integer which defines the flag type. 
	 * @param imageDownloader 	an instance of ImageDownloader which is used to download image from a specific uri. 
	 * @see Drawable 
	 * @see ImageDownloader 
	 * @see MapView 
	 */
	
	public CustomItemizedOverlay(Drawable defaultMarker, MapView mapView,
			BubleTapHandle bth, int flag, ImageDownloader imageDownloader) {
		super(boundCenter(defaultMarker), mapView);
		c = mapView.getContext();
		this.bubleTapHandle = bth;
		this.typeFlag = flag;
		this.imageDownloader = imageDownloader;
	}
	
	/**
	 * This method adds the CustomOverlayItem items to an array list. 
	 * 
	 * @param overlay 	object of type CustomOverlayItem which can be People, Place, Event, Meetup, MySelf, SecondDegreePeople or GeoTag. 
	 * @see #populate() 
	 */

	public void addOverlay(CustomOverlayItem overlay) {
		m_overlays.add(overlay);
		populate();
	} 
	
	/**
	 * This method populates overlay items. 
	 * 
	 * @see #populate() 
	 * @see #setLastFocusedIndex(int) 
	 */ 
	
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
	
	/**
	 * This methods performs the deletion of a particular item from the Map View. 
	 * Actually it deletes the position of that item from the array list. 
	 * 
	 * @param i 	as Integer which indicates the index of that particular item. 
	 * @see #removeItem(int) 
	 * @see #populate()
	 */

	public void removeItem(int i) {
		m_overlays.remove(i);

		populate();
	} 
	
	/**
	 * This methods removes all the item. On other case, it clears the array list which holds all the items. 
	 * 
	 *  @see #populate() 
	 */

	public void removeAllItem() {
		m_overlays.clear();
		populate();
	}
}
