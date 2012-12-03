package com.socmaps.entity;

import java.util.ArrayList;
import java.util.HashMap;

public class LocationSharing {

	private String status;
	private LSFriendsAndCircles lSFriendsAndCircles;
	private LsValues strangers;
	private HashMap<String, LsValues> platforms;
	private HashMap<String, LsValues> circlesOnly;
	private ArrayList<LsValues> geo_fences;
	
	
	
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public LSFriendsAndCircles getLSFriendsAndCircles() {
		return lSFriendsAndCircles;
	}
	public void setLSFriendsAndCircles(LSFriendsAndCircles lSFriendsAndCircles) {
		this.lSFriendsAndCircles = lSFriendsAndCircles;
	}
	public LsValues getStrangers() {
		return strangers;
	}
	public void setStrangers(LsValues strangers) {
		this.strangers = strangers;
	}
	public HashMap<String, LsValues> getPlatforms() {
		return platforms;
	}
	public void setPlatforms(HashMap<String, LsValues> platforms) {
		this.platforms = platforms;
	}
	public HashMap<String, LsValues> getCirclesOnly() {
		return circlesOnly;
	}
	public void setCirclesOnly(HashMap<String, LsValues> circlesOnly) {
		this.circlesOnly = circlesOnly;
	}
	public ArrayList<LsValues> getGeo_fences() {
		return geo_fences;
	}
	public void setGeo_fences(ArrayList<LsValues> geo_fences) {
		this.geo_fences = geo_fences;
	}
	@Override
	public String toString() {
		return "LocationSharing [status=" + status + ", lSFriendsAndCircles=" + lSFriendsAndCircles
				+ ", strangers=" + strangers + ", platforms=" + platforms
				+ ", circlesOnly=" + circlesOnly + ", geo_fences=" + geo_fences
				+ "]";
	}
	
	
	
	

}
