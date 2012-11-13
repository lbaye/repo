package com.socmaps.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.socmaps.entity.Circle;
import com.socmaps.entity.Event;
import com.socmaps.entity.FacebookErrorResponse;
import com.socmaps.entity.FriendRequest;
import com.socmaps.entity.InformationSharingPreferences;
import com.socmaps.entity.LayersPreferences;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.MessageEntity;
import com.socmaps.entity.MyGeoPoint;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.NotificationPreferences;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.PlatformsPreferences;
import com.socmaps.entity.RSVP;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.entity.TimeEntity;
import com.socmaps.entity.UserSettings;

public class ServerResponseParser {

	private static final String JSON_RECIPIENTS = "recipients";

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

	public static MyInfo parseUserProfileInfo(String response,
			String facebookId, String facebookAuthToken, boolean isResult) {

		MyInfo myInfo = parseUserProfileInfo(response, isResult);

		if (myInfo != null) {
			myInfo.setFacebookId(facebookId);
			myInfo.setFacebookAuthToken(facebookAuthToken);
		}

		return myInfo;

	}

	public static MyInfo parseUserProfileInfo(String response, boolean isResult) {
		MyInfo myInfo = new MyInfo();
		JSONObject results;
		try {
			if (isResult) {

				results = (new JSONObject(response)).getJSONObject("result");
			} else {
				results = new JSONObject(response);
			}

			myInfo.setId(results.getString("id"));
			// Log.i("Id", results.getString("id"));
			myInfo.setEmail(results.getString("email"));
			// Log.i("email", results.getString("email"));
			if (!results.isNull("firstName"))
				myInfo.setFirstName(results.getString("firstName"));
			// Log.i("firstName", results.getString("firstName"));

			if (!results.isNull("lastName"))
				myInfo.setLastName(results.getString("lastName"));
			// Log.i("lastName", results.getString("lastName"));
			if (!results.isNull("username"))
				myInfo.setUserName(results.getString("username"));
			// Log.i("username", results.getString("username"));
			if (!results.isNull("avatar"))
				myInfo.setAvatar(results.getString("avatar"));
			// Log.i("avatar", results.getString("avatar"));

			if (!results.isNull("coverPhoto"))
				myInfo.setCoverPhoto(results.getString("coverPhoto"));

			if (!results.isNull("authToken"))
				myInfo.setAuthToken(results.getString("authToken"));
			// Log.i("authToken", results.getString("authToken"));

			if (!results.isNull("settings")) {
				UserSettings userSettings = new UserSettings();
				userSettings.setUnit(results.getJSONObject("settings")
						.getString("unit"));
				userSettings.setVisibility(results.getJSONObject("settings")
						.getBoolean("visible"));
				myInfo.setSettings(userSettings);
			}

			if (!results.isNull("gender"))
				myInfo.setGender(results.getString("gender"));
			else
				myInfo.setGender("");
			// Log.i("gender", results.getString("gender"));

			if (!results.isNull("dateOfBirth"))
				myInfo.setDateOfBirth(results.getJSONObject("dateOfBirth")
						.getString("date"));
			// Log.i("dateOfBirth", results.getString("dateOfBirth"));

			if (!results.isNull("lastLogin")) {
				myInfo.setLastLogInDate(results.getJSONObject("lastLogin")
						.getString("date"));
				myInfo.setLastLoginTime(getTimeEntityFromJsonObject(results
						.getJSONObject("lastLogin")));
			}

			// Log.i("dateOfBirth", results.getString("dateOfBirth"));

			if (!results.isNull("regMedia"))
				myInfo.setRegMedia(results.getString("regMedia"));
			// Log.i("regMedia", results.getString("regMedia"));
			if (!results.isNull("workStatus"))
				myInfo.setWorkStatus(results.getString("workStatus"));
			// Log.i("workStatus", results.getString("workStatus"));
			if (!results.isNull("relationshipStatus"))
				myInfo.setRelationshipStatus(results
						.getString("relationshipStatus"));
			else
				myInfo.setRelationshipStatus("");
			// Log.i("relationshipStatus",
			// results.getString("relationshipStatus"));
			if (!results.isNull("bio"))
				myInfo.setBio(results.getString("bio"));
			// Log.i("bio", results.getString("bio"));
			if (!results.isNull("interests"))
				myInfo.setInterests(results.getString("interests"));
			// Log.i("interests", results.getString("interests"));

			if (!results.isNull("loginCount")) {
				myInfo.setLogInCount(results.getInt("loginCount"));
			}

			// Log.i("loginCount", results.getInt("loginCount") + "");

			if (!results.isNull("status")) {
				myInfo.setStatusMsg(results.getString("status"));
			}

			if (!results.isNull("age")) {
				myInfo.setAge(results.getInt("age"));
			}

			if (!results.isNull("currentLocation")) {
				myInfo.setCurrentLat(results.getJSONObject("currentLocation")
						.getDouble("lat"));

				myInfo.setCurrentLng(results.getJSONObject("currentLocation")
						.getDouble("lng"));

				myInfo.setCurrentPosition(getGeoPointFromjsonObject(results
						.getJSONObject("currentLocation")));

			}

			if (!results.isNull("address")) {

				if (!results.getJSONObject("address").isNull("street"))
					myInfo.setStreetAddress(results.getJSONObject("address")
							.getString("street"));
				// Log.i("street",results.getJSONObject("address").getString("street"));
				if (!results.getJSONObject("address").isNull("city"))
					myInfo.setCity(results.getJSONObject("address").getString(
							"city"));

				// Log.i("city",
				// results.getJSONObject("address").getString("city"));
				if (!results.getJSONObject("address").isNull("country"))
					myInfo.setCountry(results.getJSONObject("address")
							.getString("country"));
				// Log.i("country",results.getJSONObject("address").getString("country"));
				if (!results.getJSONObject("address").isNull("postCode"))
					myInfo.setPostCode(results.getJSONObject("address")
							.getString("postCode"));
				// Log.i("postCode",results.getJSONObject("address").getString("postCode"));
				if (!results.getJSONObject("address").isNull("state"))
					myInfo.setState(results.getJSONObject("address").getString(
							"state"));
				// Log.i("state",results.getJSONObject("address").getString("state"));

			}

			if (!results.isNull("circles")) {
				// parse circles
				JSONArray cjArray = results.getJSONArray("circles");
				if (cjArray != null) {

					myInfo.setCircleList(getCircleList(cjArray));

					/*
					 * List<Circle> circleList = new ArrayList<Circle>(); //
					 * Circle[] circles = new Circle[cjArray.length()]; for (int
					 * i = 0; i < cjArray.length(); i++) {
					 * 
					 * JSONObject cObj = cjArray.getJSONObject(i);
					 * 
					 * Circle circle = parseCircleEntity(cObj); if
					 * (!circle.getName().equalsIgnoreCase("second_degree"))
					 * circleList.add(circle);
					 * 
					 * }
					 * 
					 * myInfo.setCircleList(circleList); //
					 * accountSettingsEntity.setCircle(circles);
					 */

				}
			}

			if (!results.isNull("friends")) {
				// parse circles
				JSONArray fjArray = results.getJSONArray("friends");
				if (fjArray != null) {

					List<People> friendList = new ArrayList<People>();

					// Friend[] friends = new Friend[fjArray.length()];
					for (int i = 0; i < fjArray.length(); i++) {

						JSONObject fObj = fjArray.getJSONObject(i);

						People friend = parsePeople(fObj);

						friendList.add(friend);

					}
					myInfo.setFriendList(friendList);
					// accountSettingsEntity.setFriend(friends);

				}
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();

			myInfo = null;
		}

		return myInfo;
	}

	public static Circle parseCircleEntity(JSONObject jObj) {
		Circle circle = new Circle();

		try {
			if (!jObj.isNull("id")) {
				circle.setId(jObj.getString("id"));
			}
			if (!jObj.isNull("name")) {
				circle.setName(jObj.getString("name"));

			}
			if (!jObj.isNull("type")) {
				circle.setType(jObj.getString("type"));
			}

			if (!jObj.isNull("friends")) {
				JSONArray fjArray = jObj.getJSONArray("friends");
				// Friend[] friends = new Friend[fjArray.length()];
				List<People> friendList = new ArrayList<People>();

				for (int j = 0; j < fjArray.length(); j++) {
					People people = new People();
					String friendId = fjArray.getString(j);

					try {
						JSONObject friendInfo = fjArray.getJSONObject(j);
						Log.d(ServerResponseParser.class.getName(),
								friendInfo.toString());
						people.setId(friendInfo.getString("id"));
					} catch (JSONException e) {
						Log.w(ServerResponseParser.class.getName(), e);
						people.setId(fjArray.getString(j));
					}

					friendList.add(people);
				}

				circle.setFriendList(friendList);

			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return circle;
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

	public static MessageEntity parseMessageThread(JSONObject jObject) {
		MessageEntity mEntity = new MessageEntity();

		try {

			// ////////////////////////////////////////////////////////////////
			String messageId;
			if (!jObject.isNull("id")) {
				messageId = jObject.getString("id");
				mEntity.setMessageId(messageId);
			}

			String subject;
			if (!jObject.isNull("subject")) {
				subject = jObject.getString("subject");
				mEntity.setSubject(subject);
			}

			String content;
			if (!jObject.isNull("content")) {
				content = jObject.getString("content");
				mEntity.setContent(content);
			}

			String status;
			if (!jObject.isNull("status")) {
				status = jObject.getString("status");
				mEntity.setStatus(status);
			}

			String thread;
			if (!jObject.isNull("thread")) {
				thread = jObject.getString("thread");
				mEntity.setThread(thread);
			}

			String createDate;
			if (!jObject.isNull("createDate")) {
				createDate = jObject.getJSONObject("createDate").getString(
						"date");
				mEntity.setCreateDate(createDate);
			}

			String updateDate;
			if (!jObject.isNull("updateDate")) {
				updateDate = jObject.getJSONObject("updateDate").getString(
						"date");
				mEntity.setUpdateDate(updateDate);

				TimeEntity timeEntity = new TimeEntity();
				timeEntity.setDateTimeValue(jObject.getJSONObject("updateDate")
						.getString("date"));
				timeEntity.setTimeZoneType(jObject.getJSONObject("updateDate")
						.getInt("timezone_type"));
				timeEntity.setTimeZone(jObject.getJSONObject("updateDate")
						.getString("timezone"));

				mEntity.setUpdateTimeEntity(timeEntity);

			}

			int replyCount;
			if (!jObject.isNull("reply_count")) {
				replyCount = jObject.getInt("reply_count");
				mEntity.setReplyCount(replyCount);
			}

			if (!jObject.isNull("sender")) {

				JSONObject senderObj = jObject.getJSONObject("sender");

				String senderId;
				if (!senderObj.isNull("id")) {
					senderId = senderObj.getString("id");
					mEntity.setSenderId(senderId);
				}

				String senderEmail;
				if (!senderObj.isNull("email")) {
					senderEmail = senderObj.getString("email");
					mEntity.setSenderEmail(senderEmail);
				}

				String senderFirstName;
				if (!senderObj.isNull("firstName")) {
					senderFirstName = senderObj.getString("firstName");
					mEntity.setSenderFirstName(senderFirstName);
				}

				String senderLastName;
				if (!senderObj.isNull("lastName")) {
					senderLastName = senderObj.getString("lastName");
					mEntity.setSenderLastName(senderLastName);
				}

				String senderAvatar;
				if (!senderObj.isNull("avatar")) {
					senderAvatar = senderObj.getString("avatar");
					mEntity.setSenderAvatar(senderAvatar);
				}

			}

			mEntity.setReplies(buildReplies(jObject));
			mEntity.setRecipients(buildRecipients(jObject));
			// Log.e("Recipients", mEntity.getRecipients().toString());

		} catch (JSONException e) {
			// TODO: handle exception
		}

		return mEntity;
	}

	private static List<Map<String, String>> buildRecipients(JSONObject jObject)
			throws JSONException {
		List<Map<String, String>> recipients = new ArrayList<Map<String, String>>();

		if (jObject.has(JSON_RECIPIENTS)) {
			JSONArray objects = jObject.getJSONArray(JSON_RECIPIENTS);
			for (int i = 0; i < objects.length(); i++) {
				JSONObject object = objects.getJSONObject(i);
				Map<String, String> map = new HashMap<String, String>();
				for (Iterator iterator = object.keys(); iterator.hasNext();) {
					String key = (String) iterator.next();
					String value = object.getString(key);

					map.put(key, value);
				}
				recipients.add(map);
			}
		}

		return recipients;
	}

	private static List<MessageEntity> buildReplies(JSONObject jObject)
			throws JSONException {
		List<MessageEntity> replies = new ArrayList<MessageEntity>();

		if (!jObject.isNull("replies")) {

			JSONArray rjArray = jObject.getJSONArray("replies");

			for (int j = 0; j < rjArray.length(); j++) {
				MessageEntity replyEntity = new MessageEntity();
				JSONObject rjObject = rjArray.getJSONObject(j);

				String rMessageId;
				if (!rjObject.isNull("id")) {
					rMessageId = rjObject.getString("id");
					replyEntity.setMessageId(rMessageId);
				}

				String rContent;
				if (!rjObject.isNull("content")) {
					rContent = rjObject.getString("content");
					replyEntity.setContent(rContent);
				}

				String rStatus;
				if (!rjObject.isNull("status")) {
					rStatus = rjObject.getString("status");
					replyEntity.setStatus(rStatus);
				}

				String rCreateDate;
				if (!rjObject.isNull("createDate")) {
					rCreateDate = rjObject.getJSONObject("createDate")
							.getString("date");
					replyEntity.setCreateDate(rCreateDate);
				}

				String rUpdateDate;
				if (!rjObject.isNull("updateDate")) {
					rUpdateDate = rjObject.getJSONObject("updateDate")
							.getString("date");
					replyEntity.setUpdateDate(rUpdateDate);

					TimeEntity timeEntity = new TimeEntity();
					timeEntity.setDateTimeValue(jObject.getJSONObject(
							"updateDate").getString("date"));
					timeEntity.setTimeZoneType(jObject.getJSONObject(
							"updateDate").getInt("timezone_type"));
					timeEntity.setTimeZone(jObject.getJSONObject("updateDate")
							.getString("timezone"));

					replyEntity.setUpdateTimeEntity(timeEntity);

				}

				if (!rjObject.isNull("sender")) {

					JSONObject rSenderObj = rjObject.getJSONObject("sender");

					String rSenderId;
					if (!rSenderObj.isNull("id")) {
						rSenderId = rSenderObj.getString("id");
						replyEntity.setSenderId(rSenderId);
					}

					String rSenderEmail;
					if (!rSenderObj.isNull("email")) {
						rSenderEmail = rSenderObj.getString("email");
						replyEntity.setSenderEmail(rSenderEmail);
					}

					String rSenderFirstName;
					if (!rSenderObj.isNull("firstName")) {
						rSenderFirstName = rSenderObj.getString("firstName");
						replyEntity.setSenderFirstName(rSenderFirstName);
					}

					String rSenderLastName;
					if (!rSenderObj.isNull("lastName")) {
						rSenderLastName = rSenderObj.getString("lastName");
						replyEntity.setSenderLastName(rSenderLastName);
					}

					String rSenderAvatar;
					if (!rSenderObj.isNull("avatar")) {
						rSenderAvatar = rSenderObj.getString("avatar");
						replyEntity.setSenderAvatar(rSenderAvatar);
					}
				}

				replies.add(replyEntity);

			}

			return replies;
		}

		return null;
	}

	public static List<MessageEntity> parseMessages(String response) {
		List<MessageEntity> messages = new ArrayList<MessageEntity>();
		try {
			JSONArray jArray = new JSONArray(response);

			for (int i = 0; i < jArray.length(); i++) {
				messages.add(parseMessageThread(jArray.getJSONObject(i)));
			}

		} catch (JSONException e) {
			e.printStackTrace();
		}

		return messages;
	}

	public static LayersPreferences parseLayerSettings(String response) {
		LayersPreferences layersPreferences = new LayersPreferences();
		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

			layersPreferences.setWikipedia(result.getBoolean("wikipedia"));
			layersPreferences.setTripadvisor(result.getBoolean("tripadvisor"));
			layersPreferences
					.setFoodspotting(result.getBoolean("foodspotting"));
			return layersPreferences;

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	public static NotificationPreferences parseNotificationSettings(
			String response) {
		NotificationPreferences notificationPreferences = new NotificationPreferences();

		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

			notificationPreferences.setFriendRequests(result.getJSONObject(
					"friend_requests").getBoolean("sm"));
			notificationPreferences.setPostsByFriends(result.getJSONObject(
					"posts_by_friends").getBoolean("sm"));
			notificationPreferences.setComments(result
					.getJSONObject("comments").getBoolean("sm"));
			notificationPreferences.setMessages(result
					.getJSONObject("messages").getBoolean("sm"));
			notificationPreferences.setRecommendations(result.getJSONObject(
					"recommendations").getBoolean("sm"));
			notificationPreferences.setProximityAlerts(result.getJSONObject(
					"proximity_alerts").getBoolean("sm"));
			notificationPreferences.setOfflineNotifications(result
					.getJSONObject("offline_notifications").getBoolean("sm"));
			notificationPreferences.setProximityRadius(Integer.parseInt(result
					.getString("proximity_radius")));
			return notificationPreferences;

		} catch (JSONException e) {
			e.printStackTrace();
		}

		return null;
	}

	public static PlatformsPreferences parsePlatformsSettings(String response) {
		PlatformsPreferences platformsPreferences = new PlatformsPreferences();
		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

			platformsPreferences.setFb(result.getBoolean("fb"));
			platformsPreferences.setFourSqr(result.getBoolean("4sq"));
			platformsPreferences.setGooglePlus(result.getBoolean("googlePlus"));
			return platformsPreferences;

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	public static InformationSharingPreferences parseInformationSettings(
			String response) {
		InformationSharingPreferences informationSharingPreferences = new InformationSharingPreferences();
		try {
			JSONObject jo = new JSONObject(response);
			JSONObject result = jo.getJSONObject("result");

			informationSharingPreferences.setNewsFeed(result
					.getString("newsfeed"));
			informationSharingPreferences.setProfilePicture(result
					.getString("avatar"));

			informationSharingPreferences.setEmail(result.getString("email"));
			informationSharingPreferences
					.setName(result.getString("firstName"));

			informationSharingPreferences.setUserName(result
					.getString("username"));
			informationSharingPreferences.setGender(result.getString("gender"));

			informationSharingPreferences.setDateOfBirth(result
					.getString("dateOfBirth"));
			informationSharingPreferences.setBiography(result.getString("bio"));

			informationSharingPreferences.setInterests(result
					.getString("interests"));
			informationSharingPreferences.setAddress(result
					.getString("address"));

			informationSharingPreferences.setService(result
					.getString("workStatus"));
			informationSharingPreferences.setRelationshipStatus(result
					.getString("relationshipStatus"));

			return informationSharingPreferences;
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

	public static SearchResult parseSeachResult(String response) {
		SearchResult searchResult = new SearchResult();
		searchResult.setPeoples(parseSearchResultPeople(response));
		searchResult.setPlaces(parseSearchResultPlace(response));
		searchResult
				.setSecondDegreePeoples(parseSearchResultSecondDegreePeople(response));
		return searchResult;
	}

	public static ArrayList<Place> parseSearchResultPlace(String response) {

		ArrayList<Place> places = new ArrayList<Place>();
		JSONObject placeObj;
		try {
			JSONObject result = new JSONObject(response);
			JSONArray arrayPlace = result.getJSONArray("places");
			for (int i = 0; i < arrayPlace.length(); i++) {

				placeObj = arrayPlace.getJSONObject(i);
				places.add(parsePlace(placeObj));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return places;
	}

	public static Place parsePlace(JSONObject placeObj) {
		Place place = new Place();

		try {
			if (!placeObj.isNull("id")) {
				place.setId(placeObj.getString("id"));
				// Log.i("Place id", temp.getString("id"));
			}
			if (!placeObj.isNull("name")) {
				place.setName(placeObj.getString("name"));
				// Log.i("Place Name", temp.getString("name"));
			}
			if (!placeObj.isNull("reference")) {
				place.setReference(placeObj.getString("reference"));
				// Log.i("Place Reference", temp.getString("reference"));
			}

			if (!placeObj.isNull("icon")) {
				place.setIconUrl(placeObj.getString("icon"));
				// Log.i("Place iconUrl", temp.getString("icon"));
			}

			if (!placeObj.isNull("vicinity")) {
				place.setVicinity(placeObj.getString("vicinity"));
				// Log.i("Place Vicinity", temp.getString("vicinity"));
			}

			if (!placeObj.isNull("distance")) {

				place.setDistance(placeObj.getDouble("distance"));
				// Log.i("Distance", temp.getDouble("distance") + "");
			}

			if (!placeObj.isNull("streetViewImage")) {
				place.setStreetViewImage(placeObj.getString("streetViewImage"));
			}

			if (!placeObj.isNull("types")) {
				ArrayList<String> types = new ArrayList<String>();
				JSONArray jArrayTypes = placeObj.getJSONArray("types");
				for (int j = 0; j < jArrayTypes.length(); j++) {
					types.add(jArrayTypes.getString(j));
					// Log.i("Types", jArrayTypes.getString(j));
				}
				if (types.size() > 0) {
					place.setTypes(types);
				}
			}

			/*if (!placeObj.isNull("lastSeenAt")) {

				place.setVenue(placeObj.getString("lastSeenAt"));

			}*/
			if (!placeObj.isNull("geometry")) {
				JSONObject geometry = placeObj.getJSONObject("geometry");
				if (!geometry.isNull("location")) {
					JSONObject location = geometry.getJSONObject("location");
					/*
					 * double lat = location.getDouble("lat"); double lng =
					 * location.getDouble("lng"); Log.i("Location", lat + " " +
					 * lng);
					 */
					if (!location.isNull("lat")) {
						place.setLatitude(location.getDouble("lat"));
					}
					if (!location.isNull("lng")) {
						place.setLongitude(location.getDouble("lng"));
					}

					// 'place.setLocation(getGeoPointFromjsonObject(location));

				}

				/*
				 * if (!geometry.isNull("viewport")) { JSONObject viewPort =
				 * geometry .getJSONObject("viewport"); if
				 * (!viewPort.isNull("northeast")) { JSONObject northeast =
				 * viewPort .getJSONObject("northeast");
				 * 
				 * place.setNortheast(getGeoPointFromjsonObject(northeast)); }
				 * if (!viewPort.isNull("southwest")) { JSONObject southwest =
				 * viewPort .getJSONObject("southwest");
				 * 
				 * place.setSouthwest(getGeoPointFromjsonObject(southwest)); } }
				 */
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return place;
	}
	
	
	
	public static ArrayList<Place> parseSavedPlaces(String response) {

		ArrayList<Place> places = new ArrayList<Place>();
		JSONObject placeObj;		
		try {
			
			JSONArray arrayPlace = new JSONArray(response);
			for (int i = 0; i < arrayPlace.length(); i++) {

				placeObj = arrayPlace.getJSONObject(i);
				places.add(parseSavedPlace(placeObj));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return places;
	}
	
	public static Place parseSavedPlace(JSONObject placeObj) {
		Place place = new Place();

		try {
			if (!placeObj.isNull("id")) {
				place.setId(placeObj.getString("id"));
			}
			if (!placeObj.isNull("title")) {
				place.setName(placeObj.getString("title"));
			}
			if (!placeObj.isNull("category")) {
				place.setCategory(placeObj.getString("category"));
			}			
			if (!placeObj.isNull("description")) {
				place.setDescription(placeObj.getString("description"));
			}			
			if (!placeObj.isNull("photo")) {
				place.setStreetViewImage(placeObj.getString("photo"));
			}
			if(!placeObj.isNull("createDate"))
			{
				place.setCreateDate(getTimeEntityFromJsonObject(placeObj.getJSONObject("createDate")));
			}
			/*if(!placeObj.isNull("owner"))
			{
				place.setOwner(parsePeople(placeObj.getJSONObject("owner")));
			}*/
			if (!placeObj.isNull("location")) {
				JSONObject location = placeObj.getJSONObject("location");

				if (!location.isNull("lat")) {
					place.setLatitude(location.getDouble("lat"));
				}
				if (!location.isNull("lng")) {
					place.setLongitude(location.getDouble("lng"));
				}
				if (!location.isNull("address")) {
					place.setAddress(location.getString("address"));
				}
			}
			
			if (!placeObj.isNull("type")) {
				place.setType(placeObj.getString("type"));
			}
			
			if (!placeObj.isNull("distance")) {

				place.setDistance(placeObj.getDouble("distance"));
				// Log.i("Distance", temp.getDouble("distance") + "");
			}


			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return place;
	}

	public static ArrayList<People> parseSearchResultPeople(String response) {
		ArrayList<People> peoples = new ArrayList<People>();
		JSONObject peopleJSONObj;
		try {
			JSONObject result = new JSONObject(response);
			JSONArray arrayPeople = result.getJSONArray("people");
			for (int i = 0; i < arrayPeople.length(); i++) {

				peopleJSONObj = arrayPeople.getJSONObject(i);

				peoples.add(parsePeople(peopleJSONObj));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return peoples;
	}

	public static ArrayList<SecondDegreePeople> parseSearchResultSecondDegreePeople(
			String response) {
		ArrayList<SecondDegreePeople> secondDegreePeoples = new ArrayList<SecondDegreePeople>();
		JSONObject peopleJSONObj;
		try {

			JSONObject result = new JSONObject(response);

			if (!result.isNull("facebookFriends")) {
				JSONArray arrayPeople = result.getJSONArray("facebookFriends");
				for (int i = 0; i < arrayPeople.length(); i++) {

					peopleJSONObj = arrayPeople.getJSONObject(i);

					secondDegreePeoples
							.add(parseSecondDegreePeople(peopleJSONObj));
				}
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return secondDegreePeoples;
	}

	public static People parsePeople(JSONObject peopleJSONObj) {
		People people = new People();

		try {
			if (!peopleJSONObj.isNull("id")) {
				people.setId(peopleJSONObj.getString("id"));
				// Log.i("Id", temp.getString("id"));
			}

			if (!peopleJSONObj.isNull("email")) {
				people.setEmail(peopleJSONObj.getString("email"));
				// Log.i("email", temp.getString("email"));
			}

			if (!peopleJSONObj.isNull("firstName"))
				people.setFirstName(peopleJSONObj.getString("firstName"));
			// Log.i("firstName", temp.getString("firstName"));

			if (!peopleJSONObj.isNull("lastName"))
				people.setLastName(peopleJSONObj.getString("lastName"));
			// Log.i("lastName", temp.getString("lastName"));

			if (!peopleJSONObj.isNull("avatar"))
				people.setAvatar(peopleJSONObj.getString("avatar"));
			// Log.i("avatar", temp.getString("avatar"));

			if (!peopleJSONObj.isNull("gender"))
				people.setGender(peopleJSONObj.getString("gender"));
			else
				people.setGender("");

			if (!peopleJSONObj.isNull("dateOfBirth")) {
				people.setDateOfBirth(peopleJSONObj
						.getJSONObject("dateOfBirth").getString("date"));
				// Log.i("dateOfBirth", temp.getString("dateOfBirth"));
			}
			if (!peopleJSONObj.isNull("regMedia")) {
				people.setRegMedia(peopleJSONObj.getString("regMedia"));
				// Log.i("regMedia", temp.getString("regMedia"));
			}
			if (!peopleJSONObj.isNull("workStatus")) {
				people.setWorkStatus(peopleJSONObj.getString("workStatus"));
				// Log.i("workStatus", temp.getString("workStatus"));
			}
			if (!peopleJSONObj.isNull("relationshipStatus"))
				people.setRelationshipStatus(peopleJSONObj
						.getString("relationshipStatus"));
			else
				people.setRelationshipStatus("");

			if (!peopleJSONObj.isNull("bio")) {
				people.setBio(peopleJSONObj.getString("bio"));
				// Log.i("bio", temp.getString("bio"));
			}
			if (!peopleJSONObj.isNull("interests")) {
				people.setInterests(peopleJSONObj.getString("interests"));
				// Log.i("interests", temp.getString("interests"));
			}
			if (!peopleJSONObj.isNull("loginCount")) {
				people.setLogInCount(peopleJSONObj.getInt("loginCount"));
				// Log.i("loginCount", temp.getInt("loginCount") + "");
			}
			if (!peopleJSONObj.isNull("currentLocation")) {

				// people.setCurrentPosition(getGeoPointFromjsonObject(peopleJSONObj.getJSONObject("currentLocation")));

				JSONObject jo = peopleJSONObj.getJSONObject("currentLocation");

				if (!jo.isNull("lat"))
					people.setCurrentLat(jo.getDouble("lat"));
				if (!jo.isNull("lng"))
					people.setCurrentLng(jo.getDouble("lng"));
				if (!jo.isNull("address"))
					people.setCurrentAddress(jo.getString("address"));
			}
			if (!peopleJSONObj.isNull("address")) {

				if (!peopleJSONObj.getJSONObject("address").isNull("street"))
					people.setStreetAddress(peopleJSONObj.getJSONObject(
							"address").getString("street"));

				if (!peopleJSONObj.getJSONObject("address").isNull("city"))
					people.setCity(peopleJSONObj.getJSONObject("address")
							.getString("city"));

				if (!peopleJSONObj.getJSONObject("address").isNull("country"))
					people.setCountry(peopleJSONObj.getJSONObject("address")
							.getString("country"));

				if (!peopleJSONObj.getJSONObject("address").isNull("postCode"))
					people.setPostCode(peopleJSONObj.getJSONObject("address")
							.getString("postCode"));

				if (!peopleJSONObj.getJSONObject("address").isNull("state"))
					people.setState(peopleJSONObj.getJSONObject("address")
							.getString("state"));

			}

			if (!peopleJSONObj.isNull("age")) {
				people.setAge(peopleJSONObj.getInt("age"));
				// Log.i("age", temp.getInt("age") + "");
			}

			if (!peopleJSONObj.isNull("distance")) {
				people.setDistance(peopleJSONObj.getDouble("distance"));
				// Log.i("distance", temp.getDouble("distance") + "");
			}
			if (!peopleJSONObj.isNull("isFriend")) {
				people.setIsFrnd(peopleJSONObj.getBoolean("isFriend"));
				// Log.i("isFriend",temp.getBoolean("isFriend")+"");
			}
			if (!peopleJSONObj.isNull("status")) {
				people.setStatusMsg(peopleJSONObj.getString("status"));
				// Log.i("Status msg", temp.getString("status"));
			}
			if (!peopleJSONObj.isNull("coverPhoto")) {
				people.setCoverPhoto(peopleJSONObj.getString("coverPhoto"));
				// Log.i("Cover photo", temp.getString("coverPhoto"));
			}

			if (!peopleJSONObj.isNull("lastLogin")) {
				TimeEntity timeEntity = new TimeEntity();
				timeEntity.setDateTimeValue(peopleJSONObj.getJSONObject(
						"lastLogin").getString("date"));
				timeEntity.setTimeZoneType(peopleJSONObj.getJSONObject(
						"lastLogin").getInt("timezone_type"));
				timeEntity.setTimeZone(peopleJSONObj.getJSONObject("lastLogin")
						.getString("timezone"));

				people.setLastLogIn(timeEntity);

			}
			if (!peopleJSONObj.isNull("lastSeenAt")) {

				people.setCurrentAddress(peopleJSONObj.getString("lastSeenAt"));

			}

			if (!peopleJSONObj.isNull("friendship")) {

				people.setFriendshipStatus(peopleJSONObj
						.getString("friendship"));
			}

			if (!peopleJSONObj.isNull("blockStatus")) {

				if (peopleJSONObj.getString("blockStatus").equalsIgnoreCase(
						"blocked")) {
					people.setBlocked(true);
				} else {
					people.setBlocked(false);
				}

			}

		} catch (JSONException e) {
			// TODO: handle exception
		}

		return people;
	}

	public static SecondDegreePeople parseSecondDegreePeople(
			JSONObject peopleJSONObj) {
		SecondDegreePeople secondDegreePeople = new SecondDegreePeople();

		try {
			if (!peopleJSONObj.isNull("refId")) {
				secondDegreePeople.setRefId(peopleJSONObj.getString("refId"));
			}

			if (!peopleJSONObj.isNull("firstName"))
				secondDegreePeople.setFirstName(peopleJSONObj
						.getString("firstName"));

			if (!peopleJSONObj.isNull("lastName"))
				secondDegreePeople.setLastName(peopleJSONObj
						.getString("lastName"));

			if (!peopleJSONObj.isNull("refType"))
				secondDegreePeople.setRefType((peopleJSONObj
						.getString("refType")));

			if (!peopleJSONObj.isNull("avatar"))
				secondDegreePeople.setAvatar(peopleJSONObj.getString("avatar"));

			if (!peopleJSONObj.isNull("lastSeenAt")) {

				secondDegreePeople.setLastSeenAt(peopleJSONObj
						.getString("lastSeenAt"));

			}

			if (!peopleJSONObj.isNull("currentLocation")) {

				// secondDegreePeople.setCurrentPosition(getGeoPointFromjsonObject(peopleJSONObj.getJSONObject("currentLocation")));

				JSONObject jo = peopleJSONObj.getJSONObject("currentLocation");

				if (!jo.isNull("lat"))
					secondDegreePeople.setCurrentLat(jo.getDouble("lat"));
				if (!jo.isNull("lng"))
					secondDegreePeople.setCurrentLng(jo.getDouble("lng"));
				if (!jo.isNull("address"))
					secondDegreePeople.setCurrentAddress(jo
							.getString("address"));

			}

			if (!peopleJSONObj.isNull("distance")) {
				secondDegreePeople.setDistance(peopleJSONObj
						.getDouble("distance"));
				// Log.i("distance", temp.getDouble("distance") + "");
			}

			if (!peopleJSONObj.isNull("createdAt")) {
				JSONObject createdAtObj = peopleJSONObj
						.getJSONObject("createdAt");

				if (!createdAtObj.isNull("date")) {
					secondDegreePeople
							.setCreateTime(getTimeEntityFromJsonObject(createdAtObj
									.getJSONObject("date")));
				}

			}

			// have to parse sm friends

			if (!peopleJSONObj.isNull("smFriends")) {
				ArrayList<String> smFriends = new ArrayList<String>();
				JSONArray smFriendsArray = peopleJSONObj
						.getJSONArray("smFriends");
				for (int i = 0; i < smFriendsArray.length(); i++) {
					smFriends.add(smFriendsArray.getString(i));
				}

				secondDegreePeople.setSmFriends(smFriends);
			}

		} catch (JSONException e) {
			// TODO: handle exception
		}

		return secondDegreePeople;
	}

	public static MyGeoPoint getGeoPointByLatLong(double lat, double lng) {

		return new MyGeoPoint((int) (lat * 1E6), (int) (lng * 1E6), null);

	}

	private static List<People> getGuestList(JSONArray ja) throws JSONException {
		List<People> peopleList = new ArrayList<People>();
		JSONObject peopleJSONObj;
		for (int i = 0; i < ja.length(); i++) {

			peopleJSONObj = ja.getJSONObject(i);

			People people = parsePeople(peopleJSONObj);
			peopleList.add(people);
		}
		return peopleList;
	}

	public static List<Circle> getCircleList(JSONArray ja) throws JSONException {
		List<Circle> circles = new ArrayList<Circle>();
		for (int i = 0; i < ja.length(); i++) {

			JSONObject circleObj = ja.getJSONObject(i);
			Circle circle = parseCircleEntity(circleObj);
			if (!circle.getName().equalsIgnoreCase("second_degree")) {
				Log.d("ServerResponseParse", circle.toString());
				circles.add(circle);
			}

		}
		return circles;
	}

	private static MyGeoPoint getGeoPointFromjsonObject(JSONObject jo)
			throws JSONException {
		// oMyGeoPoint point=new MyGeoPoint(latitudeE6, longitudeE6)
		double lat = 0, lng = 0;
		String add = "";
		if (!jo.isNull("lat"))
			lat = jo.getDouble("lat");
		if (!jo.isNull("lng"))
			lng = jo.getDouble("lng");
		if (!jo.isNull("address"))
			add = jo.getString("address");
		return new MyGeoPoint((int) (lat * 1E6), (int) (lng * 1E6), add);
	}

	private static TimeEntity getTimeEntityFromJsonObject(JSONObject jo)
			throws JSONException {
		TimeEntity timeEntity = new TimeEntity();
		if (!jo.isNull("date"))
			timeEntity.setDateTimeValue(jo.getString("date"));
		if (!jo.isNull("timezone_type"))
			timeEntity.setTimeZoneType(jo.getInt("timezone_type"));
		if (!jo.isNull("timezone"))
			timeEntity.setTimeZone(jo.getString("timezone"));
		return timeEntity;
	}

	public static Event parseGetEventDetailsResult(String result) {

		Event event = new Event();
		JSONObject jo;
		try {
			jo = new JSONObject(result);
			event = parseIndividualEvent(jo, event);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return event;

	}

	public static ArrayList<Event> parseGetEventListResult(String result) {
		ArrayList<Event> events = new ArrayList<Event>();

		try {
			JSONArray jArray = new JSONArray(result);
			for (int i = 0; i < jArray.length(); i++) {
				Event event = new Event();
				parseIndividualEvent(jArray.getJSONObject(i), event);
				events.add(event);
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return events;
	}

	private static Event parseIndividualEvent(JSONObject jsonObject, Event event)
			throws JSONException {
		// TODO Auto-generated method stub
		if (!jsonObject.isNull("id")) {
			event.setEventId(jsonObject.getString("id"));
			// Log.i("Event", jsonObject.getString("id"));
		}

		if (!jsonObject.isNull("title")) {
			event.setEventTitle(jsonObject.getString("title"));
			// Log.i("Event", jsonObject.getString("title"));
		}

		if (!jsonObject.isNull("description")) {
			event.setDescription(jsonObject.getString("description"));
			// Log.i("Event", jsonObject.getString("description"));
		}

		if (!jsonObject.isNull("eventShortSummary")) {
			event.setShortSummary(jsonObject.getString("eventShortSummary"));
			// Log.i("Event", jsonObject.getString("eventShortSummary"));
		}

		if (!jsonObject.isNull("eventImage")) {
			event.setEventImageUrl(jsonObject.getString("eventImage"));
			// Log.i("Event", jsonObject.getString("eventImage"));
		}
		if (!jsonObject.isNull("owner")) {
			event.setOwner(jsonObject.getString("owner"));
			// Log.i("Event", jsonObject.getString("owner"));
		}
		if (!jsonObject.isNull("event_type")) {
			event.setEvent_type(jsonObject.getString("event_type"));
			// Log.i("Event", jsonObject.getString("event_type"));
		}
		if (!jsonObject.isNull("my_response")) {
			event.setMyResponse(jsonObject.getString("my_response"));
			// Log.i("Event", jsonObject.getString("my_response"));
		}

		if (!jsonObject.isNull("time")) {
			event.setEventTime(getTimeEntityFromJsonObject(jsonObject
					.getJSONObject("time")));
		}

		if (!jsonObject.isNull("createDate")) {
			event.setCreateDate(getTimeEntityFromJsonObject(jsonObject
					.getJSONObject("createDate")));
		}

		if (!jsonObject.isNull("distance")) {
			event.setDistance(jsonObject.getDouble("distance"));
			// Log.i("distance", jsonObject.getDouble("distance") + "");
		}

		if (!jsonObject.isNull("guestsCanInvite")) {
			event.setGuestCanInvite(jsonObject.getBoolean("guestsCanInvite"));
			// Log.i("isFriend",temp.getBoolean("isFriend")+"");
		}

		if (!jsonObject.isNull("is_invited")) {
			event.setInvited(jsonObject.getBoolean("is_invited"));
			// Log.i("isFriend",temp.getBoolean("isFriend")+"");
		}
		if (!jsonObject.isNull("location")) {
			/*
			 * event.setEventLocation(getGeoPointFromjsonObject(jsonObject
			 * .getJSONObject("location")));
			 */

			JSONObject jo = jsonObject.getJSONObject("location");

			if (!jo.isNull("lat"))
				event.setLatitude(jo.getDouble("lat"));
			if (!jo.isNull("lng"))
				event.setLongitude(jo.getDouble("lng"));
			if (!jo.isNull("address"))
				event.setAddress(jo.getString("address"));

		}
		if (!jsonObject.isNull("guests")) {

			JSONObject guestObj = jsonObject.getJSONObject("guests");
			if (!guestObj.isNull("users")) {
				event.setGuestList(getGuestList(guestObj.getJSONArray("users")));
			}

			if (!guestObj.isNull("circles")) {
				event.setCircleList(getCircleList(guestObj
						.getJSONArray("circles")));
			}

		}

		if (!jsonObject.isNull("permission")) {
			event.setPermission(jsonObject.getString("permission"));
		}

		if (!jsonObject.isNull("permittedUsers")) {

			event.setPermittedUserList(getListFromJSONArray(jsonObject
					.getJSONArray("permittedUsers")));
		}
		if (!jsonObject.isNull("permittedCircles")) {
			event.setPermittedCircleList(getListFromJSONArray(jsonObject
					.getJSONArray("permittedCircles")));
		}

		return event;
	}

	public static List<String> getListFromJSONArray(JSONArray jArray) {
		List<String> itemList = new ArrayList<String>();

		try {
			if (jArray != null) {
				for (int i = 0; i < jArray.length(); i++) {
					itemList.add(jArray.getString(i));
				}
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return itemList;
	}

	public static List<MeetupRequest> parseMeetupRequestList(String result) {
		List<MeetupRequest> meetups = new ArrayList<MeetupRequest>();

		try {
			JSONArray jArray = new JSONArray(result);
			for (int i = 0; i < jArray.length(); i++) {
				MeetupRequest entity = new MeetupRequest();
				parseIndividualMeetupRequest(jArray.getJSONObject(i), entity);
				meetups.add(entity);
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return meetups;
	}

	private static MeetupRequest parseIndividualMeetupRequest(
			JSONObject jsonObject, MeetupRequest meetupEntity)
			throws JSONException {
		// TODO Auto-generated method stub
		if (!jsonObject.isNull("id")) {
			meetupEntity.setId(jsonObject.getString("id"));
		}

		if (!jsonObject.isNull("message")) {
			meetupEntity.setMessage(jsonObject.getString("message"));
		}

		if (!jsonObject.isNull("ownerDetail")) {
			JSONObject ownerObj = jsonObject.getJSONObject("ownerDetail");
			if (!ownerObj.isNull("id")) {
				meetupEntity.setOwnerId(ownerObj.getString("id"));
			}

			if (!ownerObj.isNull("firstName")) {
				meetupEntity.setOwnerFirstName(ownerObj.getString("firstName"));
			}
			if (!ownerObj.isNull("lastName")) {
				meetupEntity.setOwnerLastName(ownerObj.getString("lastName"));
			}
			if (!ownerObj.isNull("avatar")) {
				meetupEntity.setOwnerAvatar(ownerObj.getString("avatar"));
			}
		}

		if (!jsonObject.isNull("type")) {
			meetupEntity.setType(jsonObject.getString("type"));
		}

		if (!jsonObject.isNull("my_response")) {
			meetupEntity.setMyResponse(jsonObject.getString("my_response"));
		}

		if (!jsonObject.isNull("time")) {
			meetupEntity.setTime(getTimeEntityFromJsonObject(jsonObject
					.getJSONObject("time")));
		}

		if (!jsonObject.isNull("createDate")) {
			meetupEntity.setCreateDate(getTimeEntityFromJsonObject(jsonObject
					.getJSONObject("createDate")));
		}

		if (!jsonObject.isNull("distance")) {
			meetupEntity.setDistance(jsonObject.getDouble("distance"));
		}

		if (!jsonObject.isNull("sendDirection")) {
			meetupEntity.setSendDirection(jsonObject
					.getBoolean("sendDirection"));
		}

		/*
		 * if (!jsonObject.isNull("is_invited")) {
		 * meetupEntity.setInvited(jsonObject.getBoolean("is_invited")); //
		 * Log.i("isFriend",temp.getBoolean("isFriend")+""); }
		 */
		if (!jsonObject.isNull("location")) {

			JSONObject locationObj = jsonObject.getJSONObject("location");

			meetupEntity.setLocation(getGeoPointFromjsonObject(locationObj));

			if (!locationObj.isNull("lat")) {
				meetupEntity.setLat(locationObj.getDouble("lat"));
			}

			if (!locationObj.isNull("lng")) {
				meetupEntity.setLng(locationObj.getDouble("lng"));
			}
			if (!locationObj.isNull("address")) {
				meetupEntity.setAddress(locationObj.getString("address"));
			}

		}

		if (!jsonObject.isNull("guests")) {

			JSONObject guestObj = jsonObject.getJSONObject("guests");
			if (!guestObj.isNull("users")) {
				meetupEntity.setGuestList(getGuestList(guestObj
						.getJSONArray("users")));
			}

			if (!guestObj.isNull("circles")) {
				meetupEntity.setCircleList(getCircleList(guestObj
						.getJSONArray("circles")));
			}

		}

		if (!jsonObject.isNull("rsvp")) {
			JSONObject rsvpObj = jsonObject.getJSONObject("rsvp");

			meetupEntity.setRSVP(getRSVP(rsvpObj));

		}

		return meetupEntity;
	}

	public static RSVP getRSVP(JSONObject jObj) {
		RSVP rsvp = new RSVP();

		List<String> yesList = new ArrayList<String>();
		List<String> noList = new ArrayList<String>();
		List<String> maybeList = new ArrayList<String>();
		try {

			if (!jObj.isNull(Constant.MY_RESPONSE_YES)) {
				JSONArray jArray = jObj.getJSONArray(Constant.MY_RESPONSE_YES);

				for (int i = 0; i < jArray.length(); i++) {
					yesList.add(jArray.getString(i));
				}
			}
			if (!jObj.isNull(Constant.MY_RESPONSE_NO)) {
				JSONArray jArray = jObj.getJSONArray(Constant.MY_RESPONSE_NO);

				for (int i = 0; i < jArray.length(); i++) {
					noList.add(jArray.getString(i));
				}
			}
			if (!jObj.isNull(Constant.MY_RESPONSE_MAYBE)) {
				JSONArray jArray = jObj
						.getJSONArray(Constant.MY_RESPONSE_MAYBE);

				for (int i = 0; i < jArray.length(); i++) {
					maybeList.add(jArray.getString(i));
				}
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		rsvp.setYesList(yesList);
		rsvp.setNoList(noList);
		rsvp.setMaybeList(maybeList);

		return rsvp;
	}

	public static FacebookErrorResponse parseFacebookError(String response) {
		FacebookErrorResponse fbResponseEntity = new FacebookErrorResponse();

		try {

			JSONObject jObj = new JSONObject(response);
			if (!jObj.isNull("error")) {
				JSONObject errObj = jObj.getJSONObject("error");
				if (!errObj.isNull("message")) {
					fbResponseEntity.setMessage(errObj.getString("message"));
				}
				if (!errObj.isNull("type")) {
					fbResponseEntity.setType(errObj.getString("type"));
				}
				if (!errObj.isNull("code")) {
					fbResponseEntity.setCode(errObj.getInt("code"));
				}
				if (!errObj.isNull("error_subcode")) {
					fbResponseEntity.setErrorSubCode(errObj
							.getInt("error_subcode"));
				}
			}
		} catch (JSONException e) {
			// TODO: handle exception
		}

		return fbResponseEntity;
	}

}
