package com.socmaps.entity;

import java.util.ArrayList;

public class LSFriendsAndCircles {

	private ArrayList<String> friends;
	private ArrayList<String> circles;
	private int duration;
	private int radius;
	
	
	public ArrayList<String> getFriends() {
		return friends;
	}
	public void setFriends(ArrayList<String> friends) {
		this.friends = friends;
	}
	public ArrayList<String> getCircles() {
		return circles;
	}
	public void setCircles(ArrayList<String> circles) {
		this.circles = circles;
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
	@Override
	public String toString() {
		return "LSFriendsAndCircles [friends=" + friends + ", circles=" + circles
				+ ", duration=" + duration + ", radius=" + radius + "]";
	}
	
	
	
	

}
