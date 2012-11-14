package com.socmaps.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Photo implements Serializable {

	private String id = "";
	private String description = "";
	private String title = "";
	private String permission = "";
	private List<String> permittedUsers = new ArrayList<String>();
	private List<String> permittedCircles = new ArrayList<String>();
	private String imageThumb = "";
	private String imageMedium = "";
	private String imageLarge = "";
	private double latitude = 0;
	private double longitude = 0;
	private String address = "";
	private People owner;
	private TimeEntity createDate;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getPermission() {
		return permission;
	}

	public void setPermission(String permission) {
		this.permission = permission;
	}

	public List<String> getPermittedUsers() {
		return permittedUsers;
	}

	public void setPermittedUsers(List<String> permittedUsers) {
		this.permittedUsers = permittedUsers;
	}

	public List<String> getPermittedCircles() {
		return permittedCircles;
	}

	public void setPermittedCircles(List<String> permittedCircles) {
		this.permittedCircles = permittedCircles;
	}

	public String getImageThumb() {
		return imageThumb;
	}

	public void setImageThumb(String imageThumb) {
		this.imageThumb = imageThumb;
	}

	public String getImageMedium() {
		return imageMedium;
	}

	public void setImageMedium(String imageMedium) {
		this.imageMedium = imageMedium;
	}

	public String getImageLarge() {
		return imageLarge;
	}

	public void setImageLarge(String imageLarge) {
		this.imageLarge = imageLarge;
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

	public People getOwner() {
		return owner;
	}

	public void setOwner(People owner) {
		this.owner = owner;
	}

	public TimeEntity getCreateDate() {
		return createDate;
	}

	public void setCreateDate(TimeEntity createDate) {
		this.createDate = createDate;
	}

}
