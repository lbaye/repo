package com.socmaps.entity;

import java.io.Serializable;
import java.util.List;

public class GeoTag implements Serializable {

	private String id = "";
	private String title = "";
	private String category = "";
	private String description = "";
	private String photo = "";
	private TimeEntity createDate;
	private People owner;
	private double latitude = 0;
	private double longitude = 0;
	private String address = "";
	private double distance = 0;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public TimeEntity getCreateDate() {
		return createDate;
	}

	public void setCreateDate(TimeEntity createDate) {
		this.createDate = createDate;
	}

	public People getOwner() {
		return owner;
	}

	public void setOwner(People owner) {
		this.owner = owner;
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

	public double getDistance() {
		return distance;
	}

	public void setDistance(double distance) {
		this.distance = distance;
	}

}
