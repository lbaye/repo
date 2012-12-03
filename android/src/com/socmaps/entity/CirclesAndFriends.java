package com.socmaps.entity;

import java.util.List;

public class CirclesAndFriends {

	private List<People> friends;
	private List<Circle> circles;
	
	public List<People> getFriends() {
		return friends;
	}
	public void setFriends(List<People> friends) {
		this.friends = friends;
	}
	public List<Circle> getCircles() {
		return circles;
	}
	public void setCircles(List<Circle> circles) {
		this.circles = circles;
	}
	
}
