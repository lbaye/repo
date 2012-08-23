package com.socmaps.entity;

public class MessageEntity {

		/*"id": "5035049af69c29cb56000000",
		"subject": "hello 2",
		"content": "Hi Mahadi, How are you? How are you? How are you? How are you? How are you? How are you? How are you? How are you? How are you? How are you? How are you? How are you?",
		"createDate": {
		"date": "2012-08-22 17:11:06",
		"timezone_type": 3,
		"timezone": "Europe/London"
		},-
		"updateDate": {
		"date": "2012-08-22 17:11:06",
		"timezone_type": 3,
		"timezone": "Europe/London"
		},-
		"status": "unread",
		"sender": {
		"id": "5034af68f69c293a52000005",
		"email": "shakoor.arif@gmail.com",
		"firstName": "mohammad",
		"lastName": "arif",
		"avatar": "http://203.76.126.69/social_maps/web/images/avatar/5034af68f69c293a52000005.jpeg"
		},-
		"recipients": [(1)
		{
		"id": "50349a0af69c29ca4c000012",
		"email": "hasan.mahadi@genweb2.com",
		"firstName": null,
		"lastName": null,
		"avatar": "http://203.76.126.69/social_maps/web/images/avatar/50349a0af69c29ca4c000012.jpeg"
		}-
		],-
		"thread": null,
		"replies": [(0)]
		}*/
	
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
	private String senderAvatar;
	private String thread;
	
	
	public void setMessageId(String messageId)
	{
		this.messageId = messageId;
	}
	public String getMessageId()
	{
		return messageId;
	}
	
	public void setSubject(String subject)
	{
		this.subject = subject;
	}
	public String getSubject()
	{
		return subject;
	}
	
	public void setContent(String content)
	{
		this.content = content;
	}
	public String getContent()
	{
		return content;
	}
	
	public void setCreateDate(String createDate)
	{
		this.createDate = createDate;
	}
	public String getCreateDate()
	{
		return createDate;
	}
	
	public void setUpdateDate(String updateDate)
	{
		this.updateDate = updateDate;
	}
	public String getUpdateDate()
	{
		return updateDate;
	}
	
	public void setStatus(String status)
	{
		this.status = status;
	}
	public String getStatus()
	{
		return status;
	}
	
	public void setSenderId(String senderId)
	{
		this.senderId = senderId;
	}
	public String getSenderId()
	{
		return senderId;
	}
	

	public void setSenderEmail(String senderEmail)
	{
		this.senderEmail = senderEmail;
	}
	public String getSenderEmail()
	{
		return senderEmail;
	}
	

	public void setSenderFirstName(String senderFirstName)
	{
		this.senderFirstName = senderFirstName;
	}
	public String getSenderFirstName()
	{
		return senderFirstName;
	}

	public void setSenderLastName(String senderLastName)
	{
		this.senderLastName = senderLastName;
	}
	public String getSenderLastName()
	{
		return senderLastName;
	}
	
	
	public void setSenderAvatar(String senderAvatar)
	{
		this.senderAvatar = senderAvatar;
	}
	public String getSenderAvatar()
	{
		return senderAvatar;
	}
	

	public void setThread(String thread)
	{
		this.thread = thread;
	}
	public String getThread()
	{
		return thread;
	}
	
	
	
	
}
