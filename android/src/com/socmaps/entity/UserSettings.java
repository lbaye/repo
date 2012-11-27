package com.socmaps.entity;

public class UserSettings {

	private String unit;
	private boolean visibility;
	private int shareLocation;
	private int shareProfilePicture;
	private int shareNewsFeed;

	public String getUnit() {
		return unit;
	}

	public void setUnit(String unit) {
		this.unit = unit;
	}

	public boolean isVisibility() {
		return visibility;
	}

	public void setVisibility(boolean visibility) {
		this.visibility = visibility;
	}

	public int getShareLocation() {
		return shareLocation;
	}

	public void setShareLocation(int shareLocation) {
		this.shareLocation = shareLocation;
	}

	public int getShareProfilePicture() {
		return shareProfilePicture;
	}

	public void setShareProfilePicture(int shareProfilePicture) {
		this.shareProfilePicture = shareProfilePicture;
	}

	public int getShareNewsFeed() {
		return shareNewsFeed;
	}

	public void setShareNewsFeed(int shareNewsFeed) {
		this.shareNewsFeed = shareNewsFeed;
	}

}
