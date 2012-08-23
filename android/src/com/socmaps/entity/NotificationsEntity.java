package com.socmaps.entity;

public class NotificationsEntity
{
	private boolean friendRequests;
	private boolean postsByFriends;
	private boolean comments;
	private boolean messages;
	private boolean recommendations;
	private boolean proximityAlerts;
	private boolean offlineNotifications;
	private int proximityRadius;
	
	public boolean isFriendRequests()
	{
		return friendRequests;
	}
	
	public void setFriendRequests(boolean friendRequests)
	{
		this.friendRequests = friendRequests;
	}
	
	public boolean isPostsByFriends()
	{
		return postsByFriends;
	}
	
	public void setPostsByFriends(boolean postsByFriends)
	{
		this.postsByFriends = postsByFriends;
	}
	
	public boolean isComments()
	{
		return comments;
	}
	
	public void setComments(boolean comments)
	{
		this.comments = comments;
	}
	
	public boolean isMessages()
	{
		return messages;
	}
	
	public void setMessages(boolean messages)
	{
		this.messages = messages;
	}
	
	public boolean isRecommendations()
	{
		return recommendations;
	}
	
	public void setRecommendations(boolean recommendations)
	{
		this.recommendations = recommendations;
	}
	
	public boolean isProximityAlerts() 
	{
		return proximityAlerts;
	}
	
	public void setProximityAlerts(boolean proximityAlerts) 
	{
		this.proximityAlerts = proximityAlerts;
	}
	
	public boolean isOfflineNotifications()
	{
		return offlineNotifications;
	}
	
	public void setOfflineNotifications(boolean offlineNotifications)
	{
		this.offlineNotifications = offlineNotifications;
	}
	
	public int getProximityRadius()
	{
		return proximityRadius;
	}
	
	public void setProximityRadius(int proximityRadius)
	{
		this.proximityRadius = proximityRadius;
	}	
}
