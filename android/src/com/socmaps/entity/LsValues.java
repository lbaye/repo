package com.socmaps.entity;


public class LsValues {

	
	private String name;
	private int duration;
	private int radius;
	private double latitude;
	private double longitude;
	
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getDuration() {
		return duration;
	}
	public void setDuration(int duration) {
		this.duration = duration;
	}
	public int getRadius() {
		return radius;
	}
	public void setRadius(int radius) {
		this.radius = radius;
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
	
	
	
	@Override
	public String toString() {
		return "LsValues [name=" + name + ", duration=" + duration
				+ ", radius=" + radius + ", latitude=" + latitude
				+ ", longitude=" + longitude + "]";
	}
	
	

}
