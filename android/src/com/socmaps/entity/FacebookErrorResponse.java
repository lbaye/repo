/**
 * 
 */
package com.socmaps.entity;

/**
 * @author hasan.mahadi
 * 
 */

public class FacebookErrorResponse {
	String message;
	String type;
	int code = 0;
	int errorSubCode = 0;

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public int getErrorSubCode() {
		return errorSubCode;
	}

	public void setErrorSubCode(int errorSubCode) {
		this.errorSubCode = errorSubCode;
	}
}
