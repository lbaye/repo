package com.socmaps.entity;

import java.util.List;

public class RSVP {

	private List<String> yesList;
	private List<String> noList;
	private List<String> maybeList;

	public List<String> getYesList() {
		return yesList;
	}

	public void setYesList(List<String> yesList) {
		this.yesList = yesList;
	}

	public List<String> getNoList() {
		return noList;
	}

	public void setNoList(List<String> noList) {
		this.noList = noList;
	}

	public List<String> getMaybeList() {
		return maybeList;
	}

	public void setMaybeList(List<String> maybeList) {
		this.maybeList = maybeList;
	}

}
