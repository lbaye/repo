package com.socmaps.entity;

public class StationContent {
	public String title;
	public String snippet;
	public double latitude;
	public double longitude;

	public StationContent(double latitude, double longitude, String title, String snippet) {
		this.latitude = latitude;
		this.longitude = longitude;
		this.title = title;
		this.snippet = snippet;
	}
}
