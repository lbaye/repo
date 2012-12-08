package com.socmaps.entity;

public class NotificationCount {

	private int totalCount = 0;
	private int messageCount = 0;
	private int friendRequestCount = 0;
	private int notificationCount = 0;

	public int getTotalCount(boolean isCalculated) {
		
		int count;
		
		if (isCalculated) {
			
			count = messageCount + friendRequestCount + notificationCount;
			 
		} else {
			count =  totalCount;
		}
		
		if(count<0)
		{
			count = 0;
		}
		
		return count;

	}

	public int getTotalCount() {
		if(totalCount<0)
		{
			return 0;
		}
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getMessageCount() {
		if(messageCount<0)
		{
			return 0;
		}
		return messageCount;
	}

	public void setMessageCount(int messageCount) {
		this.messageCount = messageCount;
	}

	public int getFriendRequestCount() {
		if(friendRequestCount<0)
		{
			return 0;
		}
		return friendRequestCount;
	}

	public void setFriendRequestCount(int friendRequestCount) {
		this.friendRequestCount = friendRequestCount;
	}

	public int getNotificationCount() {
		if(notificationCount<0)
		{
			return 0;
		}
		return notificationCount;
	}

	public void setNotificationCount(int notificationCount) {
		this.notificationCount = notificationCount;
	}

}
