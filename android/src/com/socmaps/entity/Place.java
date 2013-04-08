package com.socmaps.entity;

import java.io.Serializable;
import java.util.ArrayList;

import com.google.android.gms.maps.model.LatLng;

public class Place implements Serializable {

	private String id;
	private String name = "";
	private String iconUrl = "";
	private String reference;
	private String vicinity;
	private double distance = 0;
	private ArrayList<String> types;
	private double latitude = 0;
	private double longitude = 0;
	private String address = "";
	private String venue;
	private String streetViewImage;

	private String category;
	private String description;
	private TimeEntity createDate;
	private People owner;
	private String type;

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLongitude() {
		return longitude;
	}
	
	public LatLng getPoint()
	{
		return new LatLng(latitude, longitude);
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

	public void setId(String id) {
		this.id = id;
	}

	public String getId() {
		return id;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setIconUrl(String iconUrl) {
		this.iconUrl = iconUrl;
	}

	public String getIconUrl() {
		return iconUrl;
	}

	public void setReference(String reference) {
		this.reference = reference;
	}

	public String getReference() {
		return reference;
	}

	public void setVicinity(String vicinity) {
		this.vicinity = vicinity;
	}

	public String getVicinity() {
		return vicinity;
	}

	public void setDistance(double distance) {
		this.distance = distance;
	}

	public double getDistance() {
		return distance;
	}

	public void setTypes(ArrayList<String> types) {
		this.types = types;
	}

	public ArrayList<String> getTypes() {
		return types;
	}

	public String getStreetViewImage() {
		return streetViewImage;
	}

	public void setStreetViewImage(String streetViewImage) {
		this.streetViewImage = streetViewImage;
	}

	public String getVenue() {
		return venue;
	}

	public void setVenue(String venue) {
		this.venue = venue;
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

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

}
