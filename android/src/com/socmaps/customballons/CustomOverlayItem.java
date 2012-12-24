package com.socmaps.customballons;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.os.AsyncTask;
import android.util.Log;
import android.view.View;
import android.view.View.MeasureSpec;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SlidingDrawer;
import android.widget.TextView;

import com.socmaps.ui.R;
import com.socmaps.util.Utility;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.OverlayItem;
import com.socmaps.entity.Event;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.Plan;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.ImageDownloader;

public class CustomOverlayItem extends OverlayItem {

	private People user;
	private Place place;
	private MyInfo self;
	private Event event;
	private MeetupRequest meetup;
	private SecondDegreePeople secondDegreePeople;

	private GeoTag geoTag;

	LinearLayout markerLayout;
	StateListDrawable marker;
	ImageDownloader imageDownloader;

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of that particular event where it is going
	 *            to happen.
	 * @param title
	 *            as String which corresponds to the name of the particular
	 *            event.
	 * @param snipet
	 *            as String which corresponds a sequence of text that describes
	 *            the address & date of the particular event.
	 * @param ee
	 *            as Object of type Event that corresponds a particular Event.
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Event ee) {
		super(point, title, snipet);
		this.event = ee;
	}

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of that particular Meetup where it is
	 *            going to happen.
	 * @param title
	 *            as String which corresponds to the name of the particular
	 *            Meetup.
	 * @param snipet
	 *            as String which corresponds a sequence of text that describes
	 *            the address & date of the particular Meetup.
	 * @param ee
	 *            as Object of type Event that corresponds a particular Meetup.
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			MeetupRequest ee) {
		super(point, title, snipet);
		this.meetup = ee;
	}

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of that particular Person which is an
	 *            where he's currently available.
	 * @param title
	 *            as String which corresponds to the name of that person.
	 * @param snipet
	 *            as String which corresponds a text that describes his
	 *            distance.
	 * @param ou
	 *            as Object of type People.         
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			People ou) {
		super(point, title, snipet);
		this.user = ou;
	}

	
	/**
	 * 
	 * @param point is the Geo Location of that particular Person which is an  where he's currently available.
	 * @param title as String which corresponds to the name of that person.
	 * @param snipet  as String which corresponds a text that describes his distance.
	 * @param ou  as Object of type People.  
	 * @param markerLayout is a view related to overlay item
	 * @param imageDownloader an object to download image using url
	 */
	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			People ou, LinearLayout markerLayout,
			ImageDownloader imageDownloader) {
		super(point, title, snipet);
		this.user = ou;

		this.markerLayout = markerLayout;
		this.imageDownloader = imageDownloader;
		this.marker = generateStateListDrawable(ou);

	}

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of that particular Place.
	 * @param title
	 *            as String which corresponds to the name of that Place.
	 * @param snipet
	 *            as String which corresponds a text that describes the place
	 *            location & it's distance.
	 * @param pe
	 *            as Object of type Place.
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Place pe) {
		super(point, title, snipet);
		this.place = pe;
	}

	/**
	 * 
	 * @param point is the Geo Location of that particular Person which is an  where he's currently available.
	 * @param title as String which corresponds to the name of that person.
	 * @param snipet  as String which corresponds a text that describes his distance.
	 * @param pe  as Object of type Place.  
	 * @param markerLayout is a view related to overlay item
	 * @param imageDownloader an object to download image using url
	 */
	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Place pe, LinearLayout markerLayout, ImageDownloader imageDownloader) {
		super(point, title, snipet);
		this.place = pe;

		this.markerLayout = markerLayout;
		this.imageDownloader = imageDownloader;
		this.marker = generateStateListDrawable(pe);

	}

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of My Self.
	 * @param title
	 *            as String which corresponds to the name of My Self.
	 * @param snipet
	 *            as String which corresponds a text that describes my location.
	 * @param self
	 *            as Object of type MyInfo.
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			MyInfo self) {
		super(point, title, snipet);
		this.self = self;
	}

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of that particular SecondDegreePeople
	 *            Person which is an where he's currently available.
	 * @param title
	 *            as String which corresponds to the name of that person.
	 * @param snipet
	 *            as String which corresponds a text that describes his
	 *            distance.
	 * @param ou
	 *            as Object of type SecondDegreePeople.
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			SecondDegreePeople ou) {
		super(point, title, snipet);
		this.secondDegreePeople = ou;
	}

	/**
	 * 
	 * @param point is the Geo Location of that particular Person which is an  where he's currently available.
	 * @param title as String which corresponds to the name of that person.
	 * @param snipet  as String which corresponds a text that describes his distance.
	 * @param ou  as Object of type SecondDegreePeople.  
	 * @param markerLayout is a view related to overlay item
	 * @param imageDownloader an object to download image using url
	 */
	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			SecondDegreePeople ou, LinearLayout markerLayout,
			ImageDownloader imageDownloader) {
		super(point, title, snipet);
		this.secondDegreePeople = ou;

		this.markerLayout = markerLayout;
		this.imageDownloader = imageDownloader;
		this.marker = generateStateListDrawable(ou);
	}

	/**
	 * Initialization of CustomOverlayItem constructor using those specific
	 * parameters.
	 * 
	 * @param point
	 *            is the Geo Location of that particular Geo Tag where it is
	 *            going to occur.
	 * @param title
	 *            as String which corresponds to the name of the place where
	 *            this particular Geo Tag will happen.
	 * @param snipet
	 *            as String which corresponds a sequence of text that describes
	 *            the name of that person who tagged this Geo Tag & address of
	 *            this particular Geo Tag.
	 * @param geoTag
	 *            as Object of type GeoTag that corresponds a particular Geo
	 *            Tag.
	 * @see GeoPoint
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			GeoTag geoTag) {
		super(point, title, snipet);
		this.geoTag = geoTag;
	}

	/**
	 * This method returns the particular Event that will be displayed.
	 * 
	 * @return Event an object of type Event which contains it's corresponding
	 *         information
	 */

	public Event getEvent() {
		return event;
	}

	/**
	 * This method returns the particular Meetup that will be displayed.
	 * 
	 * @return Meetup an object of type Meetup which contains it's corresponding
	 *         information
	 */

	public MeetupRequest getMeetup() {
		return meetup;
	}

	/**
	 * This method returns the particular Person(People) that will be displayed.
	 * 
	 * @return People an object of type People which contains his corresponding
	 *         information
	 */

	public People getUser() {
		return user;
	}

	/**
	 * This method returns the particular place(Place) that will be displayed.
	 * 
	 * @return Place an object of type Place which contains it's corresponding
	 *         information
	 */

	public Place getPlace() {
		return place;
	}

	/**
	 * This method returns the instance of My Self.
	 * 
	 * @return MyInfo an object of type MyInfo which contains my corresponding
	 *         information
	 */

	public MyInfo getMe() {
		return self;
	}

	/**
	 * This method returns the particular Person(SecondDegreePeople) that will
	 * be displayed.
	 * 
	 * @return SecondDegreePeople an object of type SecondDegreePeople which
	 *         contains his corresponding information
	 */

	public SecondDegreePeople getSecondDegreePeople() {
		return secondDegreePeople;
	}

	/**
	 * This method returns the particular GeoTag(Geo Tag) that will be
	 * displayed.
	 * 
	 * @return GeoTag an object of type GeoTag which contains it's corresponding
	 *         information
	 */

	public GeoTag getGeotag() {
		return geoTag;
	}

	@Override
	public void setMarker(android.graphics.drawable.Drawable marker) {

		super.setMarker(marker);
	}

	// main function where we create our Drawable by using the marker layout,
	// adding our string label, then converting to a bitmap drawable
	private Drawable generateMarker(final Object obj, boolean selected) {

		Bitmap viewCapture = null;
		Drawable drawOverlay = null;

		// make sure our marker layout isn't null
		if (markerLayout != null) {

			String avatarUrl = "";
			
			ImageView ivOnline = (ImageView)markerLayout.findViewById(R.id.ivOnline);
			ivOnline.setVisibility(View.GONE);

			if (obj instanceof People) {
				avatarUrl = ((People) obj).getAvatar();
				// Log.i("CustomOverlayItem:People",avatarUrl);
				ivOnline.setVisibility(View.VISIBLE);
				if(((People)obj).isOnline())
				{
					ivOnline.setImageResource(R.drawable.online);
				}
				else
				{
					ivOnline.setImageResource(R.drawable.offline);
				}

			} else if (obj instanceof SecondDegreePeople) {
				avatarUrl = ((SecondDegreePeople) obj).getAvatar();
				// Log.i("CustomOverlayItem:SecondDegreePeople",avatarUrl);

			} else if (obj instanceof Place) {
				avatarUrl = ((Place) obj).getIconUrl();
				// Log.i("CustomOverlayItem:Place",avatarUrl);
			}

			final String avatarSource = avatarUrl;

			ImageView avatar = (ImageView) markerLayout
					.findViewById(R.id.avatar);
			imageDownloader.download(avatarSource, avatar);

			// we need to enable the drawing cache
			markerLayout.setDrawingCacheEnabled(true);

			// this is the important code
			// Without it the view will have a dimension of 0,0 and the bitmap
			// will be null
			markerLayout.measure(
					MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
					MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED));
			markerLayout.layout(0, 0, markerLayout.getMeasuredWidth(),
					markerLayout.getMeasuredHeight());

			// we need to build our drawing cache
			markerLayout.buildDrawingCache(true);

			/*
			 * try { Thread.sleep(50); } catch (InterruptedException e) { //
			 * TODO Auto-generated catch block e.printStackTrace(); }
			 */

			// not null? then we are ready to capture our bitmap image
			if (markerLayout.getDrawingCache() != null) {
				viewCapture = Bitmap.createBitmap(markerLayout
						.getDrawingCache());

				// if the view capture is not null we should turn off the
				// drawing cache
				// and then create our marker drawable with the view capture
				if (viewCapture != null) {
					markerLayout.setDrawingCacheEnabled(false);
					drawOverlay = new BitmapDrawable(viewCapture);
					return drawOverlay;
				}
			} else {
				Log.d("CustomMapMarkers",
						"Item * generateMarker *** getDrawingCache is null");
			}
		}
		Log.d("CustomMapMarkers", "Item * generateMarker *** returning null");
		return null;
	}

	/*
	 * (copied from the Google API docs) Sets the state of a drawable to match a
	 * given state bitset. This is done by converting the state bitset bits into
	 * a state set of R.attr.state_pressed, R.attr.state_selected and
	 * R.attr.state_focused attributes, and then calling {@link
	 * Drawable.setState(int[])}.
	 */
	public static void setState(final Drawable drawable, final int stateBitset) {
		final int[] states = new int[3];
		int index = 0;
		if ((stateBitset & ITEM_STATE_PRESSED_MASK) > 0)
			states[index++] = android.R.attr.state_pressed;
		if ((stateBitset & ITEM_STATE_SELECTED_MASK) > 0)
			states[index++] = android.R.attr.state_selected;
		if ((stateBitset & ITEM_STATE_FOCUSED_MASK) > 0)
			states[index++] = android.R.attr.state_focused;

		drawable.setState(states);

	}

	@Override
	public StateListDrawable getMarker(int stateBitset) {

		if (marker == null)
			return null;

		setState((Drawable) marker, stateBitset);
		marker.setBounds(0 - marker.getIntrinsicWidth() / 2,
				0 - marker.getIntrinsicHeight() / 2,
				marker.getIntrinsicWidth() / 2, marker.getIntrinsicHeight() / 2);
		return (marker);
	}

	public Drawable getDefaultMarker() {
		if (marker == null)
			marker = generateStateListDrawable(this.user);

		return marker;
	}

	// We create our statelist drawable by setting various states and the marker
	// to be displayed by that state;
	// the generateMarker() function takes in whether the drawable is selected
	// or not selected
	private StateListDrawable generateStateListDrawable(Object object) {
		StateListDrawable drawables = new StateListDrawable();
		drawables.addState(new int[] {}, generateMarker(object, false));
		return drawables;
	}

}
