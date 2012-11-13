package com.socmaps.entity;

import java.io.Serializable;
import java.util.ArrayList;

public class SearchResult implements Serializable {

	private ArrayList<People> peoples;
	private ArrayList<Place> places;
	private ArrayList<SecondDegreePeople> secondDegreePeoples;

	public ArrayList<People> getPeoples() {
		return peoples;
	}

	public void setPeoples(ArrayList<People> peoples) {
		this.peoples = peoples;
	}

	public ArrayList<Place> getPlaces() {
		return places;
	}

	public void setPlaces(ArrayList<Place> places) {
		this.places = places;
	}

	public ArrayList<SecondDegreePeople> getSecondDegreePeoples() {
		return secondDegreePeoples;
	}

	public void setSecondDegreePeoples(
			ArrayList<SecondDegreePeople> secondDegreePeoples) {
		this.secondDegreePeoples = secondDegreePeoples;
	}

}
