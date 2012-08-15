package com.socmaps.entity;

public class ProfileInfo 
{

	private int smID;
	private String  email;
	private String firstName;
	private String lastName;
	private String userName;
	private String gender;
	private String dateOfBirth;
	private String regMedia;//sm or fb
	private String streetAddress;
	private String city;
	private String country;
	private String postCode;
	private String service;
	private String relationshipStatus;
	private String profilePic;
	private String bio;
	private String interest;
	private int unit;

	public void setSmID(int smID)
	{
		this.smID = smID;
	}

	public int getSmID()
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
	
	public void setService(String service)
	{
		this.service = service;
	}

	public String getService() 
	{
		return service;
	}
	
	public void setRelationshipStatus(String relationshipStatus)
	{
		this.relationshipStatus = relationshipStatus;
	}

	public String getRelationshipStatus() 
	{
		return relationshipStatus;
	}
	
	public void setProfilePic(String profilePic)
	{
		this.profilePic = profilePic;
	}

	public String getProfilePic() 
	{
		return profilePic;
	}
	
	public void setBio(String bio)
	{
		this.bio = bio;
	}

	public String getBio() 
	{
		return bio;
	}
	
	public String getInterest() 
	{
		return interest;
	}

	public void setInterest(String interest) 
	{
		this.interest = interest;
	}
	public int getUnit() 
	{
		return unit;
	}

	public void setUnit(int unit) 
	{
		this.unit = unit;
	}
}
