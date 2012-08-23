package com.socmaps.entity;

public class OtherUserEntity 
{

	private String smID;
	private String email;
	private String firstName;
	private String lastName;
	private String userName;
	private String avatar;
	private String authToken;
	private String unit;
	
	private String dateOfBirth;
	private String bio;
	private String gender;
	private String interests;
	private String workStatus;
	private String relationshipStatus;
	private double currentLat;
	private double currentLng;
	
	private String regMedia;//sm or fb
	private int loginCount;
	private String lastLoginDate;
	
	private String streetAddress;
	private String city;
	private String country;
	private String postCode;
	private String state;
	private int age;
	private int distance;
	
	
	

	public void setSmID(String smID)
	{
		this.smID = smID;
	}

	public String getSmID()
	{
		return smID;
	}

	public void setEmail(String email)
	{
		this.email = email;
	}

	public String getEmail()
	{
		return email;
	}

	public void setAge(int age)
	{
		this.age = age;
	}

	public int getAge()
	{
		return age;
	}
	
	public void setDistance(int dist)
	{
		this.distance = dist;
	}

	public int getDistance()
	{
		return distance;
	}
	
	public void setFirstName(String firstName)
	{
		this.firstName = firstName;
	}

	public String getFirstName() 
	{
		return firstName;
	}
	public void setLastName(String lastName)
	{
		this.lastName = lastName;
	}

	public String getLastName() 
	{
		return lastName;
	}
	
	public void setUserName(String userName)
	{
		this.userName = userName;
	}

	public String getUserName()
	{
		return userName;
	}
	
	public String getAuthToken() 
	{
		return authToken;
	}

	public void setAuthToken(String authToken)
	{
		this.authToken = authToken;
	}

	
	
	
	public void setGender(String gender)
	{
		this.gender = gender;
	}

	public String getGender() 
	{
		return this.gender;
	}
	public void setDateOfBirth(String dateOfBirth)
	{
		this.dateOfBirth = dateOfBirth;
	}

	public String getDateOfBirth() 
	{
		return dateOfBirth;
	}
	
	public void setRegMedia(String regMedia)
	{
		this.regMedia = regMedia;
	}

	public String getRegMedia() 
	{
		return regMedia;
	}
	
	public void setStreetAddress(String streetAddress)
	{
		this.streetAddress = streetAddress;
	}

	public String getStreetAddress() 
	{
		return streetAddress;
	}
	
	public void setCity(String city)
	{
		this.city = city;
	}

	public String getCity() 
	{
		return city;
	}
	
	public void setCountry(String country)
	{
		this.country = country;
	}

	public String getCountry() 
	{
		return country;
	}
	
	public void setPostCode(String postCode)
	{
		this.postCode = postCode;
	}

	public String getPostCode() 
	{
		return postCode;
	}
	
	public void setWorkStatus(String workStatus)
	{
		this.workStatus = workStatus;
	}

	public String getWorkStatus() 
	{
		return workStatus;
	}
	
	public void setRelationshipStatus(String relationshipStatus)
	{
		this.relationshipStatus = relationshipStatus;
	}

	public String getRelationshipStatus() 
	{
		return relationshipStatus;
	}
	
	public void setAvatar(String avatar)
	{
		this.avatar = avatar;
	}

	public String getAvatar() 
	{
		return avatar;
	}
	
	public void setBio(String bio)
	{
		this.bio = bio;
	}

	public String getBio() 
	{
		return bio;
	}
	
	public String getInterests() 
	{
		return interests;
	}

	public void setInterests(String interests) 
	{
		this.interests = interests;
	}
	public String getUnit() 
	{
		return unit;
	}

	public void setUnit(String unit) 
	{
		this.unit = unit;
	}
	
	public double getCurrentLat() 
	{
		return currentLat;
	}

	public void setCurrentLat(double lat) 
	{
		this.currentLat = lat;
	}
	
	public double getCurrentLng() 
	{
		return currentLng;
	}

	public void setCurrentLng(double lng) 
	{
		this.currentLng = lng;
	}
	
	public void setLastLogInDate(String date)
	{
		this.lastLoginDate = date;
	}

	public String getLastLogInDate() 
	{
		return lastLoginDate;
	}
	
	public void setLogInCount(int count)
	{
		this.loginCount = count;
	}

	public int getLogInCount() 
	{
		return loginCount;
	}
	
	public void setState(String state)
	{
		this.state = state;
	}

	public String getState() 
	{
		return state;
	}
	
	
}
