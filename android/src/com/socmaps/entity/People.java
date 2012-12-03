package com.socmaps.entity;

import java.io.Serializable;

public class People implements Serializable {

	private String id;
	private String email;
	private String firstName;
	private String lastName;
	private String userName;
	private String avatar;
	private String authToken;
	private String unit;

	private String dateOfBirth;
	private String bio;
	private String gender;
	private String interests;
	private String workStatus;
	private String relationshipStatus;
	private double currentLat;
	private double currentLng;
	// private MyGeoPoint currentPosition;
	private String regMedia;// sm or fb
	private int loginCount;

	private String streetAddress;
	private String city;
	private String country;
	private String postCode;
	private String state;
	private int age;
	private double distance;
	private boolean isFriend;
	private String statusMsg;
	private String coverPhoto;

	private TimeEntity lastLogIn;

	private String currentAddress;

	private String friendshipStatus = "";

	private boolean isBlocked;

	public String getCurrentAddress() {
		return currentAddress;
	}

	public void setCurrentAddress(String currentAddress) {
		this.currentAddress = currentAddress;
	}

	public TimeEntity getLastLogIn() {
		return lastLogIn;
	}

	public void setLastLogIn(TimeEntity lastLogIn) {
		this.lastLogIn = lastLogIn;
	}

	public void setCoverPhoto(String url) {
		this.coverPhoto = url;
	}

	public String getCoverPhoto() {
		return coverPhoto;
	}

	public void setStatusMsg(String msg) {
		this.statusMsg = msg;
	}

	public String getStatusMsg() {
		return statusMsg;
	}

	// --- *** --- //

	/*
	 * public void setCurrentPosition(MyGeoPoint point) { this.currentPosition =
	 * point; }
	 * 
	 * public MyGeoPoint getCurrentPosition() { return currentPosition; }
	 */

	// --- *** --- //

	public void setId(String id) {
		this.id = id;
	}

	public String getId() {
		return id;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getEmail() {
		return email;
	}

	public void setAge(int age) {
		this.age = age;
	}

	public int getAge() {
		return age;
	}

	public void setDistance(double dist) {
		this.distance = dist;
	}

	public double getDistance() {
		return distance;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getUserName() {
		return userName;
	}

	public String getAuthToken() {
		return authToken;
	}

	public void setAuthToken(String authToken) {
		this.authToken = authToken;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public String getGender() {
		return this.gender;
	}

	public void setDateOfBirth(String dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}

	public String getDateOfBirth() {
		return dateOfBirth;
	}

	public void setRegMedia(String regMedia) {
		this.regMedia = regMedia;
	}

	public String getRegMedia() {
		return regMedia;
	}

	public void setStreetAddress(String streetAddress) {
		this.streetAddress = streetAddress;
	}

	public String getStreetAddress() {
		return streetAddress;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getCity() {
		return city;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getCountry() {
		return country;
	}

	public void setPostCode(String postCode) {
		this.postCode = postCode;
	}

	public String getPostCode() {
		return postCode;
	}

	public void setWorkStatus(String workStatus) {
		this.workStatus = workStatus;
	}

	public String getWorkStatus() {
		return workStatus;
	}

	public void setRelationshipStatus(String relationshipStatus) {
		this.relationshipStatus = relationshipStatus;
	}

	public String getRelationshipStatus() {
		return relationshipStatus;
	}

	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}

	public String getAvatar() {
		return avatar;
	}

	public void setBio(String bio) {
		this.bio = bio;
	}

	public String getBio() {
		return bio;
	}

	public String getInterests() {
		return interests;
	}

	public void setInterests(String interests) {
		this.interests = interests;
	}

	public String getUnit() {
		return unit;
	}

	public void setUnit(String unit) {
		this.unit = unit;
	}

	public double getCurrentLat() {
		return currentLat;
	}

	public void setCurrentLat(double lat) {
		this.currentLat = lat;
	}

	public double getCurrentLng() {
		return currentLng;
	}

	public void setCurrentLng(double lng) {
		this.currentLng = lng;
	}

	public void setLogInCount(int count) {
		this.loginCount = count;
	}

	public int getLogInCount() {
		return loginCount;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getState() {
		return state;
	}

	public boolean getIsFrnd() {
		return isFriend;
	}

	public void setIsFrnd(boolean flag) {
		this.isFriend = flag;
	}

	public String getFriendshipStatus() {
		return friendshipStatus;
	}

	public void setFriendshipStatus(String friendshipStatus) {
		this.friendshipStatus = friendshipStatus;
	}

	public boolean isBlocked() {
		return isBlocked;
	}

	public void setBlocked(boolean isBlocked) {
		this.isBlocked = isBlocked;
	}

}
