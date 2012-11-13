package com.socmaps.entity;

import java.io.Serializable;
import java.util.List;

public class SecondDegreePeople implements Serializable {

	private String refId;
	private String firstName;
	private String lastName;
	private String refType;
	private String avatar;
	private double currentLat;
	private double currentLng;
	//private MyGeoPoint currentPosition;
	private double distance;
	private String currentAddress;
	private String lastSeenAt;
	private List<String> smFriends;
	private TimeEntity createTime;

	public String getRefId() {
		return refId;
	}

	public void setRefId(String refId) {
		this.refId = refId;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getRefType() {
		return refType;
	}

	public void setRefType(String refType) {
		this.refType = refType;
	}

	public String getAvatar() {
		return avatar;
	}

	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}

	public double getCurrentLat() {
		return currentLat;
	}

	public void setCurrentLat(double currentLat) {
		this.currentLat = currentLat;
	}

	public double getCurrentLng() {
		return currentLng;
	}

	public void setCurrentLng(double currentLng) {
		this.currentLng = currentLng;
	}

	/*public MyGeoPoint getCurrentPosition() {
		return currentPosition;
	}

	public void setCurrentPosition(MyGeoPoint currentPosition) {
		this.currentPosition = currentPosition;
	}*/

	public double getDistance() {
		return distance;
	}

	public void setDistance(double distance) {
		this.distance = distance;
	}

	public String getCurrentAddress() {
		return currentAddress;
	}

	public void setCurrentAddress(String currentAddress) {
		this.currentAddress = currentAddress;
	}

	public String getLastSeenAt() {
		return lastSeenAt;
	}

	public void setLastSeenAt(String lastSeenAt) {
		this.lastSeenAt = lastSeenAt;
	}

	public List<String> getSmFriends() {
		return smFriends;
	}

	public void setSmFriends(List<String> smFriends) {
		this.smFriends = smFriends;
	}

	public TimeEntity getCreateTime() {
		return createTime;
	}

	public void setCreateTime(TimeEntity createTime) {
		this.createTime = createTime;
	}

}
