package com.socmaps.entity;

import java.io.Serializable;
import java.util.List;

public class Plan implements Serializable {
	
	private String planId;
	private String planTitle;
	private String description;
	private String planImageUrl;
	private TimeEntity planTime;
	private TimeEntity createDate;
	private double distance;

	// private MyGeoPoint eventLocation;

	private List<People> guestList;
	private List<Circle> circleList;

	private String permission;
	private List<String> permittedUserList;
	private List<String> permittedCircleList;

	double latitude;
	double longitude;
	String address; 
	
	
	public String getPlanId() {
		return planId;
	}
	public void setPlanId(String planId) {
		this.planId = planId;
	}
	public String getPlanTitle() {
		return planTitle;
	}
	public void setPlanTitle(String planTitle) {
		this.planTitle = planTitle;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getPlanImageUrl() {
		return planImageUrl;
	}
	public void setPlanImageUrl(String planImageUrl) {
		this.planImageUrl = planImageUrl;
	}
	public TimeEntity getPlanTime() {
		return planTime;
	}
	public void setPlanTime(TimeEntity planTime) {
		this.planTime = planTime;
	}
	public TimeEntity getCreateDate() {
		return createDate;
	}
	public void setCreateDate(TimeEntity createDate) {
		this.createDate = createDate;
	}
	public double getDistance() {
		return distance;
	}
	public void setDistance(double distance) {
		this.distance = distance;
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
