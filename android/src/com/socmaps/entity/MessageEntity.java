package com.socmaps.entity;

import java.util.List;
import java.util.Map;

public class MessageEntity {

	private String messageId;
	private String subject;
	private String content;
	private String createDate;
	private String updateDate;
	private String status;
	
	private String senderId;
	private String senderEmail;
	private String senderFirstName;
	private String senderLastName;
	private String senderUserName;
	private String senderAvatar;
	
	private String lastSenderId;
	private String lastSenderEmail;
	private String lastSenderFirstName;
	private String lastSenderLastName;
	private String lastSenderUserName;
	private String lastSenderAvatar;
	
	private String thread;
	private int replyCount;
	private MetaContent metaContent;
	private String lastMessage;
	
	
	

	private TimeEntity updateTimeEntity;

	private List<MessageEntity> replies;
	private List<Map<String, String>> recipients;

	public void setMessageId(String messageId) {
		this.messageId = messageId;
	}

	public String getMessageId() {
		return messageId;
	}

	public void setSubject(String subject) {
		this.subject = subject;
	}

	public String getSubject() {
		return subject;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getContent() {
		return content;
	}

	public void setCreateDate(String createDate) {
		this.createDate = createDate;
	}

	public String getCreateDate() {
		return createDate;
	}

	public void setUpdateDate(String updateDate) {
		this.updateDate = updateDate;
	}

	public String getUpdateDate() {
		return updateDate;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getStatus() {
		return status;
	}

	public void setSenderId(String senderId) {
		this.senderId = senderId;
	}

	public String getSenderId() {
		return senderId;
	}

	public void setSenderEmail(String senderEmail) {
		this.senderEmail = senderEmail;
	}

	public String getSenderEmail() {
		return senderEmail;
	}

	public void setSenderFirstName(String senderFirstName) {
		this.senderFirstName = senderFirstName;
	}

	public String getSenderFirstName() {
		return senderFirstName;
	}

	public void setSenderLastName(String senderLastName) {
		this.senderLastName = senderLastName;
	}

	public String getSenderLastName() {
		return senderLastName;
	}

	public String getSenderUserName() {
		return senderUserName;
	}

	public void setSenderUserName(String senderUserName) {
		this.senderUserName = senderUserName;
	}

	public void setSenderAvatar(String senderAvatar) {
		this.senderAvatar = senderAvatar;
	}

	public String getSenderAvatar() {
		return senderAvatar;
	}

	public String getLastSenderId() {
		return lastSenderId;
	}

	public void setLastSenderId(String lastSenderId) {
		this.lastSenderId = lastSenderId;
	}

	public String getLastSenderEmail() {
		return lastSenderEmail;
	}

	public void setLastSenderEmail(String lastSenderEmail) {
		this.lastSenderEmail = lastSenderEmail;
	}

	public String getLastSenderFirstName() {
		return lastSenderFirstName;
	}

	public void setLastSenderFirstName(String lastSenderFirstName) {
		this.lastSenderFirstName = lastSenderFirstName;
	}

	public String getLastSenderLastName() {
		return lastSenderLastName;
	}

	public void setLastSenderLastName(String lastSenderLastName) {
		this.lastSenderLastName = lastSenderLastName;
	}

	public String getLastSenderUserName() {
		return lastSenderUserName;
	}

	public void setLastSenderUserName(String lastSenderUserName) {
		this.lastSenderUserName = lastSenderUserName;
	}

	public String getLastSenderAvatar() {
		return lastSenderAvatar;
	}

	public void setLastSenderAvatar(String lastSenderAvatar) {
		this.lastSenderAvatar = lastSenderAvatar;
	}

	public void setThread(String thread) {
		this.thread = thread;
	}

	public String getThread() {
		return thread;
	}

	public void setReplyCount(int replyCount) {
		this.replyCount = replyCount;
	}

	public int getReplyCount() {
		return replyCount;
	}

	public void setReplies(List<MessageEntity> replies) {
		this.replies = replies;
	}

	public List<MessageEntity> getReplies() {
		return replies;
	}

	public List<Map<String, String>> getRecipients() {
		return recipients;
	}

	public void setRecipients(List<Map<String, String>> recipients) {
		this.recipients = recipients;
	}

	public TimeEntity getUpdateTimeEntity() {
		return updateTimeEntity;
	}

	public void setUpdateTimeEntity(TimeEntity timeEntity) {
		this.updateTimeEntity = timeEntity;
	}

	public MetaContent getMetaContent() {
		return metaContent;
	}

	public void setMetaContent(MetaContent metaContent) {
		this.metaContent = metaContent;
	}

	public String getLastMessage() {
		return lastMessage;
	}

	public void setLastMessage(String lastMessage) {
		this.lastMessage = lastMessage;
	}

}
