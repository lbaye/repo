package com.socmaps.entity;

import java.io.Serializable;
import java.util.List;

public class Event implements Serializable {

	private String eventId;
	private String eventTitle;
	private String description;
	private String shortSummary;
	private String eventImageUrl;
	private TimeEntity eventTime;
	private boolean isGuestCanInvite;
	private TimeEntity createDate;
	private String owner;
	private double distance;
	private String event_type;
	private String myResponse;
	private boolean isInvited;

	// private MyGeoPoint eventLocation;
	private RSVP rsvp;
	private List<People> guestList;
	private List<Circle> circleList;

	private String permission;
	private List<String> permittedUserList;
	private List<String> permittedCircleList;

	double latitude;
	double longitude;
	String address;

	public String getEventId() {
		return eventId;
	}

	public void setEventId(String eventId) {
		this.eventId = eventId;
	}

	public String getEventTitle() {
		return eventTitle;
	}

	public void setEventTitle(String eventTitle) {
		this.eventTitle = eventTitle;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getShortSummary() {
		return shortSummary;
	}

	public void setShortSummary(String shortSummary) {
		this.shortSummary = shortSummary;
	}

	public String getEventImageUrl() {
		return eventImageUrl;
	}

	public void setEventImageUrl(String eventImageUrl) {
		this.eventImageUrl = eventImageUrl;
	}

	public TimeEntity getEventTime() {
		return eventTime;
	}

	public void setEventTime(TimeEntity eventTime) {
		this.eventTime = eventTime;
	}

	public boolean isGuestCanInvite() {
		return isGuestCanInvite;
	}

	public void setGuestCanInvite(boolean isGuestCanInvite) {
		this.isGuestCanInvite = isGuestCanInvite;
	}

	public TimeEntity getCreateDate() {
		return createDate;
	}

	public void setCreateDate(TimeEntity createDate) {
		this.createDate = createDate;
	}

	public String getOwner() {
		return owner;
	}

	public void setOwner(String owner) {
		this.owner = owner;
	}

	public double getDistance() {
		return distance;
	}

	public void setDistance(double distance) {
		this.distance = distance;
	}

	public String getEvent_type() {
		return event_type;
	}

	public void setEvent_type(String event_type) {
		this.event_type = event_type;
	}

	public String getMyResponse() {
		return myResponse;
	}

	public void setMyResponse(String myResponse) {
		this.myResponse = myResponse;
	}

	public boolean isInvited() {
		return isInvited;
	}

	public void setInvited(boolean isInvited) {
		this.isInvited = isInvited;
	}

	/*
	 * public MyGeoPoint getEventLocation() { return eventLocation; }
	 * 
	 * public void setEventLocation(MyGeoPoint eventLocation) {
	 * this.eventLocation = eventLocation; }
	 */

	public RSVP getRsvp() {
		return rsvp;
	}

	public void setRsvp(RSVP rsvp) {
		this.rsvp = rsvp;
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

	public String getPermission() {
		return permission;
	}

	public void setPermission(String permission) {
		this.permission = permission;
	}

	public List<String> getPermittedUserList() {
		return permittedUserList;
	}

	public void setPermittedUserList(List<String> permittedUserList) {
		this.permittedUserList = permittedUserList;
	}

	public List<String> getPermittedCircleList() {
		return permittedCircleList;
	}

	public void setPermittedCircleList(List<String> permittedCircleList) {
		this.permittedCircleList = permittedCircleList;
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
