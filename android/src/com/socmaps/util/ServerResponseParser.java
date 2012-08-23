package com.socmaps.util;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.R.bool;
import android.util.Log;

import com.socmaps.entity.AccountSettingsEntity;
import com.socmaps.entity.FriendRequest;
import com.socmaps.entity.InformationSharingEntity;
import com.socmaps.entity.LayersEntity;
import com.socmaps.entity.MessageEntity;
import com.socmaps.entity.NotificationsEntity;
import com.socmaps.entity.OtherUserEntity;
import com.socmaps.entity.PlatformsEntity;

public class ServerResponseParser {

	/*
	 * public static AccountSettingsEntity parseAccountSettings(String
	 * response,int flag) { AccountSettingsEntity accountSettingsEntity = new
	 * AccountSettingsEntity(); JSONObject jo,results; try { if(flag==1) {
	 * 
	 * results = (new JSONObject(response)).getJSONObject("result"); } else {
	 * results=new JSONObject(response); }
	 * accountSettingsEntity.setSmID(results.getString("id")); Log.i("Id",
	 * results.getString("id"));
	 * accountSettingsEntity.setEmail(results.getString("email"));
	 * Log.i("email", results.getString("email")); if
	 * (!results.isNull("firstName")) accountSettingsEntity.setFirstName(results
	 * .getString("firstName")); Log.i("firstName",
	 * results.getString("firstName"));
	 * 
	 * if (!results.isNull("lastName")) accountSettingsEntity
	 * .setLastName(results.getString("lastName")); Log.i("lastName",
	 * results.getString("lastName")); if (!results.isNull("username"))
	 * accountSettingsEntity .setUserName(results.getString("username"));
	 * Log.i("username", results.getString("username")); if
	 * (!results.isNull("avatar"))
	 * accountSettingsEntity.setAvatar(results.getString("avatar"));
	 * Log.i("avatar", results.getString("avatar")); if
	 * (!results.isNull("authToken")) accountSettingsEntity.setAuthToken(results
	 * .getString("authToken")); Log.i("authToken",
	 * results.getString("authToken"));
	 * 
	 * if(!results.isNull("gender"))
	 * accountSettingsEntity.setGender(results.getString("gender")); else
	 * accountSettingsEntity.setGender(""); Log.i("gender",
	 * results.getString("gender")); if (!results.isNull("dateOfBirth"))
	 * accountSettingsEntity.setDateOfBirth(results.getJSONObject(
	 * "dateOfBirth").getString("date")); Log.i("dateOfBirth",
	 * results.getString("dateOfBirth")); if (!results.isNull("regMedia"))
	 * accountSettingsEntity .setRegMedia(results.getString("regMedia"));
	 * Log.i("regMedia", results.getString("regMedia")); if
	 * (!results.isNull("workStatus"))
	 * accountSettingsEntity.setWorkStatus(results .getString("workStatus"));
	 * Log.i("workStatus", results.getString("workStatus")); if
	 * (!results.isNull("relationshipStatus"))
	 * accountSettingsEntity.setRelationshipStatus(results
	 * .getString("relationshipStatus")); else
	 * accountSettingsEntity.setRelationshipStatus("");
	 * Log.i("relationshipStatus", results.getString("relationshipStatus")); if
	 * (!results.isNull("bio"))
	 * accountSettingsEntity.setBio(results.getString("bio")); Log.i("bio",
	 * results.getString("bio")); if (!results.isNull("interests"))
	 * accountSettingsEntity.setInterests(results .getString("interests"));
	 * Log.i("interests", results.getString("interests"));
	 * 
	 * if (!results.isNull("loginCount"))
	 * accountSettingsEntity.setLogInCount(results .getInt("loginCount"));
	 * Log.i("loginCount", results.getInt("loginCount") + ""); if
	 * (!results.isNull("currentLocation")) {
	 * accountSettingsEntity.setCurrentLat(results.getJSONObject(
	 * "currentLocation").getDouble("lat")); Log.i("lat",
	 * results.getJSONObject("currentLocation") .getDouble("lat") + "");
	 * 
	 * accountSettingsEntity.setCurrentLng(results.getJSONObject(
	 * "currentLocation").getDouble("lng")); Log.i("lng",
	 * results.getJSONObject("currentLocation") .getDouble("lng") + ""); } if
	 * (!results.isNull("address")) {
	 * 
	 * if (!results.getJSONObject("address").isNull("street"))
	 * accountSettingsEntity.setStreetAddress(results
	 * .getJSONObject("address").getString("street")); Log.i("street",
	 * results.getJSONObject("address").getString("street"));
	 * if(!results.getJSONObject("address").isNull("city"))
	 * accountSettingsEntity.setCity(results.getJSONObject(
	 * "address").getString("city"));
	 * 
	 * Log.i("city", results.getJSONObject("address") .getString("city")); if
	 * (!results.getJSONObject("address").isNull("country"))
	 * accountSettingsEntity.setCountry(results.getJSONObject(
	 * "address").getString("country")); Log.i("country",
	 * results.getJSONObject("address").getString("country")); if
	 * (!results.getJSONObject("address").isNull("postCode"))
	 * accountSettingsEntity.setPostCode(results.getJSONObject(
	 * "address").getString("postCode")); Log.i("postCode",
	 * results.getJSONObject("address").getString("postCode")); if
	 * (!results.getJSONObject("address").isNull("state"))
	 * accountSettingsEntity.setState(results.getJSONObject(
	 * "address").getString("state")); Log.i("state",
	 * results.getJSONObject("address").getString("state")); }
	 * 
	 * } catch (JSONException e) { // TODO Auto-generated catch block
	 * e.printStackTrace(); }
	 * 
	 * return accountSettingsEntity; }
	 */

	public static AccountSettingsEntity parseUserProfileInfo(String response,
			String facebookId, String facebookAuthToken, boolean isResult) {

		AccountSettingsEntity accountSettingsEntity = parseUserProfileInfo(
				response, isResult);

		if (accountSettingsEntity != null) {
			accountSettingsEntity.setFacebookId(facebookId);
			accountSettingsEntity.setFacebookAuthToken(facebookAuthToken);
		}

		return accountSettingsEntity;

	}

	public static AccountSettingsEntity parseUserProfileInfo(String response,
			boolean isResult) {
		AccountSettingsEntity accountSettingsEntity = new AccountSettingsEntity();
		JSONObject results;
		try {
			if (isResult) {

				results = (new JSONObject(response)).getJSONObject("result");
			} else {
				results = new JSONObject(response);
			}

			accountSettingsEntity.setSmID(results.getString("id"));
			// Log.i("Id", results.getString("id"));
			accountSettingsEntity.setEmail(results.getString("email"));
			// Log.i("email", results.getString("email"));
			if (!results.isNull("firstName"))
				accountSettingsEntity.setFirstName(results
						.getString("firstName"));
			// Log.i("firstName", results.getString("firstName"));

			if (!results.isNull("lastName"))
				accountSettingsEntity
						.setLastName(results.getString("lastName"));
			// Log.i("lastName", results.getString("lastName"));
			if (!results.isNull("username"))
				accountSettingsEntity
						.setUserName(results.getString("username"));
			// Log.i("username", results.getString("username"));
			if (!results.isNull("avatar"))
				accountSettingsEntity.setAvatar(results.getString("avatar"));
			// Log.i("avatar", results.getString("avatar"));
			if (!results.isNull("authToken"))
				accountSettingsEntity.setAuthToken(results
						.getString("authToken"));
			// Log.i("authToken", results.getString("authToken"));

			if (!results.isNull("gender"))
				accountSettingsEntity.setGender(results.getString("gender"));
			else
				accountSettingsEntity.setGender("");
			// Log.i("gender", results.getString("gender"));

			if (!results.isNull("dateOfBirth"))
				accountSettingsEntity.setDateOfBirth(results.getJSONObject(
						"dateOfBirth").getString("date"));
			// Log.i("dateOfBirth", results.getString("dateOfBirth"));

			if (!results.isNull("lastLogin"))
				accountSettingsEntity.setLastLogInDate(results.getJSONObject(
						"lastLogin").getString("date"));
			// Log.i("dateOfBirth", results.getString("dateOfBirth"));

			if (!results.isNull("regMedia"))
				accountSettingsEntity
						.setRegMedia(results.getString("regMedia"));
			// Log.i("regMedia", results.getString("regMedia"));
			if (!results.isNull("workStatus"))
				accountSettingsEntity.setWorkStatus(results
						.getString("workStatus"));
			// Log.i("workStatus", results.getString("workStatus"));
			if (!results.isNull("relationshipStatus"))
				accountSettingsEntity.setRelationshipStatus(results
						.getString("relationshipStatus"));
			else
				accountSettingsEntity.setRelationshipStatus("");
			// Log.i("relationshipStatus",
			// results.getString("relationshipStatus"));
			if (!results.isNull("bio"))
				accountSettingsEntity.setBio(results.getString("bio"));
			// Log.i("bio", results.getString("bio"));
			if (!results.isNull("interests"))
				accountSettingsEntity.setInterests(results
						.getString("interests"));
			// Log.i("interests", results.getString("interests"));

			if (!results.isNull("loginCount"))
				accountSettingsEntity.setLogInCount(results
						.getInt("loginCount"));
			// Log.i("loginCount", results.getInt("loginCount") + "");
			if (!results.isNull("currentLocation")) {
				accountSettingsEntity.setCurrentLat(results.getJSONObject(
						"currentLocation").getDouble("lat"));
				// Log.i("lat",
				// results.getJSONObject("currentLocation").getDouble("lat") +
				// "");

				accountSettingsEntity.setCurrentLng(results.getJSONObject(
						"currentLocation").getDouble("lng"));
				// Log.i("lng",
				// results.getJSONObject("currentLocation").getDouble("lng") +
				// "");
			}
			if (!results.isNull("address")) {

				if (!results.getJSONObject("address").isNull("street"))
					accountSettingsEntity.setStreetAddress(results
							.getJSONObject("address").getString("street"));
				// Log.i("street",results.getJSONObject("address").getString("street"));
				if (!results.getJSONObject("address").isNull("city"))
					accountSettingsEntity.setCity(results.getJSONObject(
							"address").getString("city"));

				// Log.i("city",
				// results.getJSONObject("address").getString("city"));
				if (!results.getJSONObject("address").isNull("country"))
					accountSettingsEntity.setCountry(results.getJSONObject(
							"address").getString("country"));
				// Log.i("country",results.getJSONObject("address").getString("country"));
				if (!results.getJSONObject("address").isNull("postCode"))
					accountSettingsEntity.setPostCode(results.getJSONObject(
							"address").getString("postCode"));
				// Log.i("postCode",results.getJSONObject("address").getString("postCode"));
				if (!results.getJSONObject("address").isNull("state"))
					accountSettingsEntity.setState(results.getJSONObject(
							"address").getString("state"));
				// Log.i("state",results.getJSONObject("address").getString("state"));

				// not used yet. Have to add in the ENTITY class
				/*
				 * String deactivated = jsonObject.getString("deactivated");
				 * String source = jsonObject.getString("source"); String
				 * address = jsonObject.getString("address"); boolean enabled =
				 * jsonObject.getBoolean("enabled"); String updateDate =
				 * jsonObject.getString("updateDate"); String settings =
				 * jsonObject.getString("settings"); String circles =
				 * jsonObject.getString("circles"); String createDate =
				 * jsonObject.getString("createDate");
				 */

			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();

			accountSettingsEntity = null;
		}

		return accountSettingsEntity;
	}

	public static FriendRequest[] parseFriendRequest(String response) {
		FriendRequest[] friendRequests = null;
		try {
			JSONArray jArray = new JSONArray(response);
			friendRequests = new FriendRequest[jArray.length()];

			for (int i = 0; i < jArray.length(); i++) {
				friendRequests[i] = new FriendRequest();

				JSONObject jObject = jArray.getJSONObject(i);

				String requestId;
				if (!jObject.isNull("id")) {
					requestId = jObject.getString("id");
					friendRequests[i].setRequestId(requestId);
				}

				String senderId;
				if (!jObject.isNull("userId")) {
					senderId = jObject.getString("userId");
					friendRequests[i].setSenderId(senderId);
				}

				String message;
				if (!jObject.isNull("message")) {
					message = jObject.getString("message");
					friendRequests[i].setMessage(message);
				}

				String senderName;
				if (!jObject.isNull("friendName")) {
					senderName = jObject.getString("friendName");
					friendRequests[i].setSenderName(senderName);
				}

				String recipientId;
				if (!jObject.isNull("recipientId")) {
					recipientId = jObject.getString("recipientId");
					friendRequests[i].setRecipientId(recipientId);
				}

				String accepted;
				if (!jObject.isNull("accepted")) {
					accepted = jObject.getString("accepted");
					friendRequests[i].setAccepted(accepted);
				}

				String date;

				if (!jObject.isNull("createDate")) {
					date = jObject.getJSONObject("createDate")
							.getString("date");
					friendRequests[i].setDate(date);
				}

			}

		} catch (JSONException e) {
			e.printStackTrace();
			friendRequests = null;
		}

		return friendRequests;
	}

	public static MessageEntity[] parseMessages(String response) {
		MessageEntity[] messages = null;
		try {
			JSONArray jArray = new JSONArray(response);
			messages = new MessageEntity[jArray.length()];

			for (int i = 0; i < jArray.length(); i++) {
				messages[i] = new MessageEntity();
				JSONObject jObject = jArray.getJSONObject(i);

				String messageId;
				if (!jObject.isNull("id")) {
					messageId = jObject.getString("id");
					messages[i].setMessageId(messageId);
				}

				String subject;
				if (!jObject.isNull("subject")) {
					subject = jObject.getString("subject");
					messages[i].setSubject(subject);
				}

				String content;
				if (!jObject.isNull("content")) {
					content = jObject.getString("content");
					messages[i].setContent(content);
				}

				String status;
				if (!jObject.isNull("status")) {
					status = jObject.getString("status");
					messages[i].setStatus(status);
				}

				String thread;
				if (!jObject.isNull("thread")) {
					thread = jObject.getString("thread");
					messages[i].setThread(thread);
				}

				String createDate;
				if (!jObject.isNull("createDate")) {
					createDate = jObject.getJSONObject("createDate").getString(
							"date");
					messages[i].setCreateDate(createDate);
				}

				String updateDate;
				if (!jObject.isNull("updateDate")) {
					updateDate = jObject.getJSONObject("updateDate").getString(
							"date");
					messages[i].setUpdateDate(updateDate);
				}

				if (!jObject.isNull("sender")) {
					
					JSONObject senderObj = jObject.getJSONObject("sender");
					
					String senderId;
					if (!senderObj.isNull("id")) {
						senderId = senderObj.getString("id");
						messages[i].setSenderId(senderId);
					}

					String senderEmail;
					if (!senderObj.isNull("email")) {
						senderEmail = senderObj.getString("email");
						messages[i].setSenderEmail(senderEmail);
					}

					String senderFirstName;
					if (!senderObj.isNull("firstName")) {
						senderFirstName = senderObj.getString("firstName");
						messages[i].setSenderFirstName(senderFirstName);
					}

					String senderLastName;
					if (!senderObj.isNull("lastName")) {
						senderLastName = senderObj.getString("lastName");
						messages[i].setSenderLastName(senderLastName);
					}

					String senderAvatar;
					if (!senderObj.isNull("avatar")) {
						senderAvatar = senderObj.getString("avatar");
						messages[i].setSenderAvatar(senderAvatar);
					}
				}

			}

		} catch (JSONException e) {
			e.printStackTrace();
			messages = null;
		}

		return messages;
	}

	public static LayersEntity parseLayerSettings(String response) {
		LayersEntity layersEntity = new LayersEntity();
		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

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

	public static NotificationsEntity parseNotificationSettings(String response) {
		NotificationsEntity notificationsEntity = new NotificationsEntity();

		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

			notificationsEntity.setFriendRequests(result.getJSONObject(
					"friend_requests").getBoolean("sm"));
			notificationsEntity.setPostsByFriends(result.getJSONObject(
					"posts_by_friends").getBoolean("sm"));
			notificationsEntity.setComments(result.getJSONObject("comments")
					.getBoolean("sm"));
			notificationsEntity.setMessages(result.getJSONObject("messages")
					.getBoolean("sm"));
			notificationsEntity.setRecommendations(result.getJSONObject(
					"recommendations").getBoolean("sm"));
			notificationsEntity.setProximityAlerts(result.getJSONObject(
					"proximity_alerts").getBoolean("sm"));
			notificationsEntity.setOfflineNotifications(result.getJSONObject(
					"offline_notifications").getBoolean("sm"));
			notificationsEntity.setProximityRadius(Integer.parseInt(result
					.getString("proximity_radius")));
			return notificationsEntity;

		} catch (JSONException e) {
			e.printStackTrace();
		}

		return null;
	}

	public static PlatformsEntity parsePlatformsSettings(String response) {
		PlatformsEntity platformsEntity = new PlatformsEntity();
		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

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

	public static InformationSharingEntity parseInformationSettings(
			String response) {
		InformationSharingEntity informationSharingEntity = new InformationSharingEntity();
		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

			informationSharingEntity.setNewsFeed(result.getString("newsfeed"));
			informationSharingEntity.setProfilePicture(result
					.getString("avatar"));

			informationSharingEntity.setEmail(result.getString("email"));
			informationSharingEntity.setName(result.getString("firstName"));

			informationSharingEntity.setUserName(result.getString("username"));
			informationSharingEntity.setGender(result.getString("gender"));

			informationSharingEntity.setDateOfBirth(result
					.getString("dateOfBirth"));
			informationSharingEntity.setBiography(result.getString("bio"));

			informationSharingEntity
					.setInterests(result.getString("interests"));
			informationSharingEntity.setAddress(result.getString("address"));

			informationSharingEntity.setService(result.getString("workStatus"));
			informationSharingEntity.setRelationshipStatus(result
					.getString("relationshipStatus"));

			return informationSharingEntity;
		} catch (JSONException e) {
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

	public static ArrayList<OtherUserEntity> parseSearchResultPeople(String response)
	{
		ArrayList<OtherUserEntity> peoples=new ArrayList<OtherUserEntity>();
		JSONObject temp;
		try {
			JSONObject result=new JSONObject(response);
			JSONArray arrayPeople=result.getJSONArray("people");
			for(int i=0;i<arrayPeople.length();i++)
			{
				OtherUserEntity otherUserEntity=new OtherUserEntity();
				temp=arrayPeople.getJSONObject(i);
				otherUserEntity.setSmID(temp.getString("id"));
				Log.i("Id", temp.getString("id"));
				otherUserEntity.setEmail(temp.getString("email"));
				Log.i("email", temp.getString("email"));
				if (!temp.isNull("firstName"))
					otherUserEntity.setFirstName(temp
							.getString("firstName"));
				Log.i("firstName", temp.getString("firstName"));

				if (!temp.isNull("lastName"))
					otherUserEntity
							.setLastName(temp.getString("lastName"));
				Log.i("lastName", temp.getString("lastName"));
				
				if (!temp.isNull("avatar"))
					otherUserEntity.setAvatar(temp.getString("avatar"));
				Log.i("avatar", temp.getString("avatar"));
				

				if(!temp.isNull("gender"))
					otherUserEntity.setGender(temp.getString("gender"));
				else
					otherUserEntity.setGender("");
				
				if (!temp.isNull("dateOfBirth"))
				{
					otherUserEntity.setDateOfBirth(temp.getJSONObject(
							"dateOfBirth").getString("date"));
					Log.i("dateOfBirth", temp.getString("dateOfBirth"));
				}
				if (!temp.isNull("regMedia"))
				{
					otherUserEntity
							.setRegMedia(temp.getString("regMedia"));
					Log.i("regMedia", temp.getString("regMedia"));
				}
				if (!temp.isNull("workStatus"))
				{
					otherUserEntity.setWorkStatus(temp
							.getString("workStatus"));
					Log.i("workStatus", temp.getString("workStatus"));
				}
				if (!temp.isNull("relationshipStatus"))
					otherUserEntity.setRelationshipStatus(temp
							.getString("relationshipStatus"));
				else
					otherUserEntity.setRelationshipStatus("");
				
				if (!temp.isNull("bio"))
				{
					otherUserEntity.setBio(temp.getString("bio"));
					Log.i("bio", temp.getString("bio"));
				}
				if (!temp.isNull("interests"))
				{
					otherUserEntity.setInterests(temp
							.getString("interests"));
				Log.i("interests", temp.getString("interests"));
				}
				if (!temp.isNull("loginCount"))
				{
					otherUserEntity.setLogInCount(temp
							.getInt("loginCount"));
				Log.i("loginCount", temp.getInt("loginCount") + "");
				}
				if (!temp.isNull("currentLocation")) {
					otherUserEntity.setCurrentLat(temp.getJSONObject(
							"currentLocation").getDouble("lat"));
					Log.i("lat", temp.getJSONObject("currentLocation")
							.getDouble("lat") + "");

					otherUserEntity.setCurrentLng(temp.getJSONObject(
							"currentLocation").getDouble("lng"));
					Log.i("lng", temp.getJSONObject("currentLocation")
							.getDouble("lng") + "");
				}
				if (!temp.isNull("address")) {

					if (!temp.getJSONObject("address").isNull("street"))
						otherUserEntity.setStreetAddress(temp
								.getJSONObject("address").getString("street"));
					
					if(!temp.getJSONObject("address").isNull("city"))
						otherUserEntity.setCity(temp.getJSONObject(
								"address").getString("city"));

					
					if (!temp.getJSONObject("address").isNull("country"))
						otherUserEntity.setCountry(temp.getJSONObject(
								"address").getString("country"));
					
					if (!temp.getJSONObject("address").isNull("postCode"))
						otherUserEntity.setPostCode(temp.getJSONObject(
								"address").getString("postCode"));
					
					if (!temp.getJSONObject("address").isNull("state"))
						otherUserEntity.setState(temp.getJSONObject(
								"address").getString("state"));
					
				}
				
				if(!temp.isNull("age"))
				{
					otherUserEntity.setAge(temp.getInt("age"));
					Log.i("age", temp.getInt("age")+"");
				}
				
				if(!temp.isNull("distance"))
				{
					otherUserEntity.setDistance(temp.getInt("distance"));
					Log.i("distance",temp.getInt("distance")+"");
				}
				
				peoples.add(otherUserEntity);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return peoples;
	}
	
	

}
