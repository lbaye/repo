package com.socmaps.customballons;

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

public class CustomOverlayItem extends OverlayItem {

	private People user;
	private Place place;
	private MyInfo self;
	private Event event;
	private MeetupRequest meetup;
	private SecondDegreePeople secondDegreePeople;  
	
	private GeoTag geoTag; 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 	is the Geo Location of that particular event where it is going to happen. 
	 * @param title		as String which corresponds to the name of the particular event. 
	 * @param snipet 	as String which corresponds a sequence of text that describes the address & date of the particular event. 
	 * @param ee		as Object of type Event that corresponds a particular Event. 
	 * @see GeoPoint 
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Event ee) {
		super(point, title, snipet);
		this.event = ee;
	} 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 	is the Geo Location of that particular Meetup where it is going to happen. 
	 * @param title		as String which corresponds to the name of the particular Meetup. 
	 * @param snipet 	as String which corresponds a sequence of text that describes the address & date of the particular Meetup. 
	 * @param ee		as Object of type Event that corresponds a particular Meetup. 
	 * @see GeoPoint 
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			MeetupRequest ee) {
		super(point, title, snipet);
		this.meetup = ee;
	} 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 	is the Geo Location of that particular Person which is an  where he's currently available. 
	 * @param title		as String which corresponds to the name of that person. 
	 * @param snipet 	as String which corresponds a text that describes his distance. 
	 * @param ou		as Object of type People. 
	 * @see GeoPoint 
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			People ou) {
		super(point, title, snipet);
		this.user = ou;
	} 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 	is the Geo Location of that particular Place. 
	 * @param title		as String which corresponds to the name of that Place. 
	 * @param snipet 	as String which corresponds a text that describes the place location & it's distance. 
	 * @param pe		as Object of type Place. 
	 * @see GeoPoint 
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Place pe) {
		super(point, title, snipet);
		this.place = pe;
	} 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 	is the Geo Location of My Self. 
	 * @param title		as String which corresponds to the name of My Self. 
	 * @param snipet 	as String which corresponds a text that describes my location. 
	 * @param self		as Object of type MyInfo. 
	 * @see GeoPoint 
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			MyInfo self) {
		super(point, title, snipet);
		this.self = self;
	} 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 	is the Geo Location of that particular SecondDegreePeople Person which is an  where he's currently available. 
	 * @param title		as String which corresponds to the name of that person. 
	 * @param snipet 	as String which corresponds a text that describes his distance. 
	 * @param ou		as Object of type SecondDegreePeople. 
	 * @see GeoPoint 
	 * @see String
	 */

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			SecondDegreePeople ou) {
		super(point, title, snipet);
		this.secondDegreePeople = ou;
	} 
	
	/**
	 * Initialization of CustomOverlayItem constructor using those specific parameters. 
	 * 
	 * @param point 		is the Geo Location of that particular Geo Tag where it is going to occur. 
	 * @param title			as String which corresponds to the name of the place where this particular Geo Tag will happen. 
	 * @param snipet 		as String which corresponds a sequence of text that describes the name of that person who tagged this Geo Tag 
	 * 						& address of this particular Geo Tag. 
	 * @param geoTag		as Object of type GeoTag that corresponds a particular Geo Tag. 
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
	 * @return Event an object of type Event which contains it's corresponding information
	 */
	
	public Event getEvent() {
		return event;
	} 
	
	/**
	 * This method returns the particular Meetup that will be displayed. 
	 * 
	 * @return Meetup an object of type Meetup which contains it's corresponding information
	 */

	public MeetupRequest getMeetup() {
		return meetup;
	} 
	
	/**
	 * This method returns the particular Person(People) that will be displayed. 
	 * 
	 * @return People an object of type People which contains his corresponding information
	 */

	public People getUser() {
		return user;
	} 
	
	/**
	 * This method returns the particular place(Place) that will be displayed. 
	 * 
	 * @return Place an object of type Place which contains it's corresponding information
	 */

	public Place getPlace() {
		return place;
	} 
	
	/**
	 * This method returns the instance of My Self. 
	 * 
	 * @return MyInfo an object of type MyInfo which contains my  corresponding information
	 */

	public MyInfo getMe() {
		return self;
	} 
	
	/**
	 * This method returns the particular Person(SecondDegreePeople) that will be displayed. 
	 * 
	 * @return SecondDegreePeople an object of type SecondDegreePeople which contains his corresponding information
	 */

	public SecondDegreePeople getSecondDegreePeople() {
		return secondDegreePeople;
	}  
	
	/**
	 * This method returns the particular GeoTag(Geo Tag) that will be displayed. 
	 * 
	 * @return GeoTag an object of type GeoTag which contains it's corresponding information
	 */
	
	public GeoTag getGeotag() {
		return geoTag;
	}
	

	@Override
	public void setMarker(android.graphics.drawable.Drawable marker) {
		super.setMarker(marker);
	}

}
