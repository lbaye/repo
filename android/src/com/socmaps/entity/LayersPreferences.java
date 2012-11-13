package com.socmaps.entity;

public class LayersPreferences {

	private boolean wikipedia;
	private boolean tripadvisor;
	private boolean foodspotting;

	public void setWikipedia(Boolean wiki) {
		this.wikipedia = wiki;
	}

	public boolean getWikipedia() {
		return wikipedia;
	}

	public void setTripadvisor(Boolean tripadvisor) {
		this.tripadvisor = tripadvisor;
	}

	public boolean getTripadvisor() {
		return tripadvisor;
	}

	public void setFoodspotting(Boolean foodspotting) {
		this.foodspotting = foodspotting;
	}

	public boolean getFoodspotting() {
		return foodspotting;
	}

}
