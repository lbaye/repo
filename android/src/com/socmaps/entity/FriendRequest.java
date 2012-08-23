package com.socmaps.entity;

public class FriendRequest {

	/*{
"id": "5034e673f69c29a054000000",
"userId": "503098d0f69c294849000000",
"message": "Hi, Please accept my request.",
"friendName": "Mahadi Masum",
"recipientId": "50349a0af69c29ca4c000012",
"createDate": {
"date": "2012-08-22 15:02:27",
"timezone_type": 3,
"timezone": "Europe/London"
},-
"accepted": null
}*/
	
	private String requestId;
	private String senderId;
	private String message;
	private String senderName;
	private String recipientId;
	private String accepted;
	private String date;
	
	public void setRequestId(String requestId)
	{
		this.requestId = requestId;
	}
	public String getRequestId()
	{
		return requestId;
	}
	
	public void setSenderId(String senderId)
	{
		this.senderId = senderId;
	}
	public String getSenderId()
	{
		return senderId;
	}
	
	public void setMessage(String message)
	{
		this.message = message;
	}
	public String getMessage()
	{
		return message;
	}
	
	public void setSenderName(String senderName)
	{
		this.senderName = senderName;
	}
	public String getSenderName()
	{
		return senderName;
	}
	
	public void setRecipientId(String recipientId)
	{
		this.recipientId = recipientId;
	}
	public String getRecipientId()
	{
		return recipientId;
	}
	
	public void setAccepted(String accepted)
	{
		this.accepted = accepted;
	}
	public String getAccepted()
	{
		return accepted;
	}
	
	public void setDate(String date)
	{
		this.date = date;
	}
	public String getDate()
	{
		return date;
	}
	
	
}
