package com.socmaps.entity;

import java.util.ArrayList;
import java.util.List;

public class Circle {

	private String id;
	private String name;
	private String type;
	private List<People> friendList=new ArrayList<People>();

	

	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getType() {
		return type;
	}

	public List<People> getFriendList() {
		return friendList;
	}

	public void setFriendList(List<People> friendList) {
		this.friendList = friendList;
	}

	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("Circle(");
		sb.append("name: ").append(this.name).append(", id: ").append(this.id);
		if (this.friendList != null)
			sb.append(", friends: ").append(this.friendList.toString());
		sb.append(")");
		return sb.toString();
	}

}
