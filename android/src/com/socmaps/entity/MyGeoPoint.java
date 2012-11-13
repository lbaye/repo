package com.socmaps.entity;

import java.io.Serializable;

import com.google.android.maps.GeoPoint;

public class MyGeoPoint extends GeoPoint implements Serializable {

	public String getAddress() {
		return address;
	}

	private String address;

	public MyGeoPoint(int latitudeE6, int longitudeE6, String add) {
		super(latitudeE6, longitudeE6);
		this.address = add;
		// TODO Auto-generated constructor stub
	}

}
