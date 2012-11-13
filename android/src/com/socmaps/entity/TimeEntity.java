package com.socmaps.entity;

import java.io.Serializable;

public class TimeEntity implements Serializable {

	private String dateTimeValue;
	private int timeZoneType;
	private String timeZone;

	public String getDateTimeValue() {
		return dateTimeValue;
	}

	public void setDateTimeValue(String dateTimeValue) {
		this.dateTimeValue = dateTimeValue;
	}

	public int getTimeZoneType() {
		return timeZoneType;
	}

	public void setTimeZoneType(int timeZoneType) {
		this.timeZoneType = timeZoneType;
	}

	public String getTimeZone() {
		return timeZone;
	}

	public void setTimeZone(String timeZone) {
		this.timeZone = timeZone;
	}

}
