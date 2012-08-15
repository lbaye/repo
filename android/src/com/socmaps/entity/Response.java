package com.socmaps.entity;

public class Response 
{

	private String status;
	private String data;
	private String message;

	public void setStatus(String status)
	{
		this.status = status;
	}

	public String getStatus()
	{
		return status;
	}

	public void setData(String data)
	{
		this.data = data;
	}

	public String getData()
	{
		return data;
	}

	public void setMessage(String message)
	{
		this.message = message;
	}

	public String getMessage() 
	{
		return message;
	}

}
