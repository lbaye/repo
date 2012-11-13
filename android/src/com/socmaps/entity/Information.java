/*
 * This entity class is used for list item which will contain a title and a checkbox.
 */

package com.socmaps.entity;

public class Information {
	public String title;
	public boolean isSet;

	public Information() {
		super();
	}

	public Information(String title, boolean isSet) {
		super();
		this.title = title;
		this.isSet = isSet;
	}
}
