package com.socmaps.entity;

public class FriendRequest {

	private String requestId;
	private String senderId;
	private String message;
	private String senderName;
	private String recipientId;
	private String accepted;
	private TimeEntity sentTime;

	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}

	public String getRequestId() {
		return requestId;
	}

	public void setSenderId(String senderId) {
		this.senderId = senderId;
	}

	public String getSenderId() {
		return senderId;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getMessage() {
		return message;
	}

	public void setSenderName(String senderName) {
		this.senderName = senderName;
	}

	public String getSenderName() {
		return senderName;
	}

	public void setRecipientId(String recipientId) {
		this.recipientId = recipientId;
	}

	public String getRecipientId() {
		return recipientId;
	}

	public void setAccepted(String accepted) {
		this.accepted = accepted;
	}

	public String getAccepted() {
		return accepted;
	}

	public TimeEntity getSentTime() {
		return sentTime;
	}

	public void setSentTime(TimeEntity sentTime) {
		this.sentTime = sentTime;
	}

}
