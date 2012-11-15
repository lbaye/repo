package com.socmaps.customballons;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.OverlayItem;
import com.socmaps.entity.Event;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SecondDegreePeople;

public class CustomOverlayItem extends OverlayItem {

	private People user;
	private Place place;
	private MyInfo self;
	private Event event;
	private MeetupRequest meetup;
	private SecondDegreePeople secondDegreePeople;
	private GeoTag geoTag;

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Event ee) {
		super(point, title, snipet);
		this.event = ee;
	}

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			MeetupRequest ee) {
		super(point, title, snipet);
		this.meetup = ee;
	}

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			People ou) {
		super(point, title, snipet);
		this.user = ou;
	}

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			Place pe) {
		super(point, title, snipet);
		this.place = pe;
	}

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			MyInfo self) {
		super(point, title, snipet);
		this.self = self;
	}

	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			SecondDegreePeople ou) {
		super(point, title, snipet);
		this.secondDegreePeople = ou;
	}
	
	public CustomOverlayItem(GeoPoint point, String title, String snipet,
			GeoTag geoTag) {
		super(point, title, snipet);
		this.geoTag = geoTag;
	}

	public Event getEvent() {
		return event;
	}

	public MeetupRequest getMeetup() {
		return meetup;
	}

	public People getUser() {
		return user;
	}

	public Place getPlace() {
		return place;
	}

	public MyInfo getMe() {
		return self;
	}

	public SecondDegreePeople getSecondDegreePeople() {
		return secondDegreePeople;
	}
	
	public GeoTag getGeotag() {
		return geoTag;
	}
	

	@Override
	public void setMarker(android.graphics.drawable.Drawable marker) {
		super.setMarker(marker);
	}

}
