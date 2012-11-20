package com.socmaps.entity;

import java.io.Serializable;


public class PushData implements Serializable {

	private String objectId = "";
	private String objectType = "";
	private String title = "";
	private String message = "";
	private int badge = 0;
	private String tabCounts = "";
	
	
	public String getObjectId() {
		return objectId;
	}
	public void setObjectId(String objectId) {
		this.objectId = objectId;
	}
	public String getObjectType() {
		return objectType;
	}
	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public int getBadge() {
		return badge;
	}
	public void setBadge(int badge) {
		this.badge = badge;
	}
	public String getTabCounts() {
		return tabCounts;
	}
	public void setTabCounts(String tabCounts) {
		this.tabCounts = tabCounts;
	}
	

	
}
