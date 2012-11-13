package com.socmaps.entity;

import java.util.List;

public class MeetupRequest {

	private String Id;
	private String title;
	private String message;
	private TimeEntity time;
	private boolean sendDirection;
	private TimeEntity createDate;
	private String ownerId;
	private String ownerFirstName;
	private String ownerLastName;
	private String ownerAvatar;
	private double lat;
	private double lng;
	private double distance;
	private String address;
	private String type;
	private String myResponse;
	private boolean isInvited;
	private RSVP rsvp;
	private List<People> guestList;
	private List<Circle> circleList;
	private MyGeoPoint location;

	public String getId() {
		return Id;
	}

	public void setId(String id) {
		Id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public TimeEntity getTime() {
		return time;
	}

	public void setTime(TimeEntity time) {
		this.time = time;
	}

	public boolean isSendDirection() {
		return sendDirection;
	}

	public void setSendDirection(boolean sendDirection) {
		this.sendDirection = sendDirection;
	}

	public TimeEntity getCreateDate() {
		return createDate;
	}

	public void setCreateDate(TimeEntity createDate) {
		this.createDate = createDate;
	}

	public String getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(String ownerId) {
		this.ownerId = ownerId;
	}

	public String getOwnerFirstName() {
		return ownerFirstName;
	}

	public void setOwnerFirstName(String ownerFirstName) {
		this.ownerFirstName = ownerFirstName;
	}

	public String getOwnerLastName() {
		return ownerLastName;
	}

	public void setOwnerLastName(String ownerLastName) {
		this.ownerLastName = ownerLastName;
	}

	public String getOwnerAvatar() {
		return ownerAvatar;
	}

	public void setOwnerAvatar(String ownerAvatar) {
		this.ownerAvatar = ownerAvatar;
	}

	public double getLat() {
		return lat;
	}

	public void setLat(double lat) {
		this.lat = lat;
	}

	public double getLng() {
		return lng;
	}

	public void setLng(double lng) {
		this.lng = lng;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public double getDistance() {
		return distance;
	}

	public void setDistance(double distance) {
		this.distance = distance;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
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

	public RSVP getRSVP() {
		return rsvp;
	}

	public void setRSVP(RSVP rsvp) {
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

	public MyGeoPoint getLocation() {
		return location;
	}

	public void setLocation(MyGeoPoint location) {
		this.location = location;
	}

}
