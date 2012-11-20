package com.socmaps.entity;

public class NotificationCount {

	private int totalCount = 0;
	private int messageCount = 0;
	private int friendRequestCount = 0;
	private int notificationCount = 0;

	public int getTotalCount(boolean isCalculated) {
		if (isCalculated) {
			return messageCount + friendRequestCount + notificationCount;
		} else {
			return totalCount;
		}

	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getMessageCount() {
		return messageCount;
	}

	public void setMessageCount(int messageCount) {
		this.messageCount = messageCount;
	}

	public int getFriendRequestCount() {
		return friendRequestCount;
	}

	public void setFriendRequestCount(int friendRequestCount) {
		this.friendRequestCount = friendRequestCount;
	}

	public int getNotificationCount() {
		return notificationCount;
	}

	public void setNotificationCount(int notificationCount) {
		this.notificationCount = notificationCount;
	}

}
