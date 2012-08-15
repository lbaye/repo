package com.socmaps.util;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.socmaps.entity.AccountSettingsEntity;
import com.socmaps.entity.LayersEntity;
import com.socmaps.entity.PlatformsEntity;
import com.socmaps.entity.ProfileInfo;

public class ServerResponseParser {

	public static AccountSettingsEntity parseAccountSettings(String response,int flag) {
		AccountSettingsEntity accountSettingsEntity = new AccountSettingsEntity();
		JSONObject jo,results;
		try {
			if(flag==1)
			{
				
				results = (new JSONObject(response)).getJSONObject("result");
			}
			else
			{
				results=new JSONObject(response);
			}
			accountSettingsEntity.setSmID(results.getString("id"));
			Log.i("Id", results.getString("id"));
			accountSettingsEntity.setEmail(results.getString("email"));
			Log.i("email", results.getString("email"));
			if (!results.isNull("firstName"))
				accountSettingsEntity.setFirstName(results
						.getString("firstName"));
			Log.i("firstName", results.getString("firstName"));

			if (!results.isNull("lastName"))
				accountSettingsEntity
						.setLastName(results.getString("lastName"));
			Log.i("lastName", results.getString("lastName"));
			if (!results.isNull("username"))
				accountSettingsEntity
						.setUserName(results.getString("username"));
			Log.i("username", results.getString("username"));
			if (!results.isNull("avatar"))
				accountSettingsEntity.setAvatar(results.getString("avatar"));
			Log.i("avatar", results.getString("avatar"));
			if (!results.isNull("authToken"))
				accountSettingsEntity.setAuthToken(results
						.getString("authToken"));
			Log.i("authToken", results.getString("authToken"));

			if(!results.isNull("gender"))
				accountSettingsEntity.setGender(results.getString("gender"));
			else
				accountSettingsEntity.setGender(results.getString(""));
			Log.i("gender", results.getString("gender"));
			if (!results.isNull("dateOfBirth"))
				accountSettingsEntity.setDateOfBirth(results.getJSONObject(
						"dateOfBirth").getString("date"));
			Log.i("dateOfBirth", results.getString("dateOfBirth"));
			if (!results.isNull("regMedia"))
				accountSettingsEntity
						.setRegMedia(results.getString("regMedia"));
			Log.i("regMedia", results.getString("regMedia"));
			if (!results.isNull("workStatus"))
				accountSettingsEntity.setWorkStatus(results
						.getString("workStatus"));
			Log.i("workStatus", results.getString("workStatus"));
			if (!results.isNull("relationshipStatus"))
				accountSettingsEntity.setRelationshipStatus(results
						.getString("relationshipStatus"));
			else
				accountSettingsEntity.setRelationshipStatus("");
			Log.i("relationshipStatus", results.getString("relationshipStatus"));
			if (!results.isNull("bio"))
				accountSettingsEntity.setBio(results.getString("bio"));
			Log.i("bio", results.getString("bio"));
			if (!results.isNull("interests"))
				accountSettingsEntity.setInterests(results
						.getString("interests"));
			Log.i("interests", results.getString("interests"));

			if (!results.isNull("loginCount"))
				accountSettingsEntity.setLogInCount(results
						.getInt("loginCount"));
			Log.i("loginCount", results.getInt("loginCount") + "");
			if (!results.isNull("currentLocation")) {
				accountSettingsEntity.setCurrentLat(results.getJSONObject(
						"currentLocation").getDouble("lat"));
				Log.i("lat", results.getJSONObject("currentLocation")
						.getDouble("lat") + "");

				accountSettingsEntity.setCurrentLng(results.getJSONObject(
						"currentLocation").getDouble("lng"));
				Log.i("lng", results.getJSONObject("currentLocation")
						.getDouble("lng") + "");
			}
			if (!results.isNull("address")) {

				if (!results.getJSONObject("address").isNull("street"))
					accountSettingsEntity.setStreetAddress(results
							.getJSONObject("address").getString("street"));
				Log.i("street",
						results.getJSONObject("address").getString("street"));
				if(!results.getJSONObject("address").isNull("city"))
					accountSettingsEntity.setCity(results.getJSONObject(
							"address").getString("city"));

				Log.i("city", results.getJSONObject("address")
						.getString("city"));
				if (!results.getJSONObject("address").isNull("country"))
					accountSettingsEntity.setCountry(results.getJSONObject(
							"address").getString("country"));
				Log.i("country",
						results.getJSONObject("address").getString("country"));
				if (!results.getJSONObject("address").isNull("postCode"))
					accountSettingsEntity.setPostCode(results.getJSONObject(
							"address").getString("postCode"));
				Log.i("postCode",
						results.getJSONObject("address").getString("postCode"));
				if (!results.getJSONObject("address").isNull("state"))
					accountSettingsEntity.setState(results.getJSONObject(
							"address").getString("state"));
				Log.i("state",
						results.getJSONObject("address").getString("state"));
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return accountSettingsEntity;
	}

	
	public static LayersEntity parseLayerSettings(String response)
	{
		LayersEntity layersEntity= new LayersEntity();
		try {
			JSONObject jo=new JSONObject(response);
			JSONObject result=jo.getJSONObject("result");
			
			layersEntity.setWikipedia(result.getBoolean("wikipedia"));
			layersEntity.setTripadvisor(result.getBoolean("tripadvisor"));
			layersEntity.setFoodspotting(result.getBoolean("foodspotting"));
			return layersEntity;
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	
	public static PlatformsEntity parsePlatformsSettings(String response)
	{
		PlatformsEntity platformsEntity= new PlatformsEntity();
		try {
			JSONObject jo=new JSONObject(response);
			JSONObject result=jo.getJSONObject("result");
			
			platformsEntity.setFb(result.getBoolean("fb"));
			platformsEntity.setFourSqr(result.getBoolean("4sq"));
			platformsEntity.setGooglePlus(result.getBoolean("googlePlus"));
			return platformsEntity;
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	private static String getDateFromObject(String objectString) {
		if (objectString != null) {
			JSONObject jo;
			try {
				jo = new JSONObject(objectString);
				return jo.getString("date");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
		return null;
	}

}
