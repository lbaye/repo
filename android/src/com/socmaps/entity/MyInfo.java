package com.socmaps.entity;

import java.util.List;

public class MyInfo {

	private String id;
	private String email;
	private String firstName;
	private String lastName;
	private String userName;
	private String avatar;
	private String authToken;
	private UserSettings settings;

	private String dateOfBirth;
	private String bio;
	private String gender;
	private String interests;
	private String workStatus;
	private String relationshipStatus;
	private double currentLat;
	private double currentLng;

	private String regMedia;// sm or fb
	private int loginCount;
	private String lastLoginDate;

	private String streetAddress;
	private String city;
	private String country;
	private String postCode;
	private String state;

	private String facebookId;
	private String facebookAuthToken;

	private int age;

	// private Circle[] circles;
	// private Friend[] friends;

	private String statusMsg;
	private String coverPhoto;

	private List<People> friendList;
	private List<Circle> circleList;

	private TimeEntity lastLoginTime;

	private MyGeoPoint currentPosition;

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

	public void setLastLogInDate(String date) {
		this.lastLoginDate = date;
	}

	public String getLastLogInDate() {
		return lastLoginDate;
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

	public void setFacebookId(String facebookId) {
		this.facebookId = facebookId;
	}

	public String getFacebookId() {
		return facebookId;
	}

	public void setFacebookAuthToken(String facebookAuthToken) {
		this.facebookAuthToken = facebookAuthToken;
	}

	public String getFacebookAuthToken() {
		return facebookAuthToken;
	}

	public void setAge(int age) {
		this.age = age;
	}

	public int getAge() {
		return age;
	}

	/*
	 * public void setCircle(Circle[] circles) { this.circles = circles; }
	 * 
	 * public Circle[] getCircle() { return circles; }
	 * 
	 * public void setFriend(Friend[] friends) { this.friends = friends; }
	 * 
	 * public Friend[] getFriend() { return friends; }
	 */

	public List<People> getFriendList() {
		return friendList;
	}

	public void setFriendList(List<People> friendList) {
		this.friendList = friendList;
	}

	public List<Circle> getCircleList() {
		return circleList;
	}

	public void setCircleList(List<Circle> circleList) {
		this.circleList = circleList;
	}

	public TimeEntity getLastLoginTime() {
		return lastLoginTime;
	}

	public void setLastLoginTime(TimeEntity lastLoginTime) {
		this.lastLoginTime = lastLoginTime;
	}

	public MyGeoPoint getCurrentPosition() {
		return currentPosition;
	}

	public void setCurrentPosition(MyGeoPoint currentPosition) {
		this.currentPosition = currentPosition;
	}

	public UserSettings getSettings() {
		return settings;
	}

	public void setSettings(UserSettings settings) {
		this.settings = settings;
	}

}
