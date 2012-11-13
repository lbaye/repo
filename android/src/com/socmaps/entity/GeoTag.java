package com.socmaps.entity;

import java.io.Serializable;
import java.util.List;

public class GeoTag implements Serializable{

	private String geotagId;
	private String geotagTitle;
	private String geotagDescription;
	private String geotagImageUrl;
	private String geotagOwner; 
	private String geotagCategory; 
	private TimeEntity geotagTime;

	//private RSVP rsvp;
	private List<People> guestList;
	private List<Circle> circleList;
	
	double latitude;
	double longitude;
	String address;
	
	
	public String getGeotagId() {
		return geotagId;
	}
	
	public void setGeotagId(String geotagId) {
		this.geotagId = geotagId;
	}
	
	public String getGeotagTitle() {
		return geotagTitle;
	}
	
	public void setGeotagTitle(String geotagTitle) {
		this.geotagTitle = geotagTitle;
	}
	
	public String getGeotagDescription() {
		return geotagDescription;
	}
	
	public void setGeotagDescription(String geotagDescription) {
		this.geotagDescription = geotagDescription;
	}
	
	public String getGeotagImageUrl() {
		return geotagImageUrl;
	}
	
	public void setGeotagImageUrl(String geotagImageUrl) {
		this.geotagImageUrl = geotagImageUrl;
	}
	
	public String getGeotagOwner() {
		return geotagOwner;
	}
	
	public void setGeotagOwner(String geotagOwner) {
		this.geotagOwner = geotagOwner;
	} 
	
	public String getGeotagCategory() {
		return geotagCategory;
	}

	public void setGeotagCategory(String geotagCategory) {
		this.geotagCategory = geotagCategory;
	} 
	
	public TimeEntity getGeotagTime() {
		return geotagTime;
	}

	public void setGeotagTime(TimeEntity geotagTime) {
		this.geotagTime = geotagTime;
	}
	
	public List<People> getGuestList() {
		return guestList;
	}
	
	public void setGuestList(List<People> guestList) {
		this.guestList = guestList;
	}
	
	public List<Circle> getCircleList() {
		return circleList;
	}
	public void setCircleList(List<Circle> circleList) {
		this.circleList = circleList;
	}
	
	public double getLatitude() {
		return latitude;
	}
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	public double getLongitude() {
		return longitude;
	}
	
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	
	public String getAddress() {
		return address;
	}
	
	public void setAddress(String address) {
		this.address = address;
	} 
	
	
}
