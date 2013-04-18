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

import com.google.android.gms.maps.model.LatLng;
import com.socmaps.entity.Circle;
import com.socmaps.entity.CirclesAndFriends;
import com.socmaps.entity.Event;
import com.socmaps.entity.FacebookErrorResponse;
import com.socmaps.entity.FriendRequest;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.InformationSharingPreferences;
import com.socmaps.entity.LSFriendsAndCircles;
import com.socmaps.entity.LayersPreferences;
import com.socmaps.entity.LocationSharing;
import com.socmaps.entity.LsValues;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.MessageEntity;
import com.socmaps.entity.MetaContent;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.NotificationCount;
import com.socmaps.entity.NotificationPreferences;
import com.socmaps.entity.People;
import com.socmaps.entity.Photo;
import com.socmaps.entity.Place;
import com.socmaps.entity.Plan;
import com.socmaps.entity.PlatformsPreferences;
import com.socmaps.entity.RSVP;
import com.socmaps.entity.SearchResult;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.entity.TimeEntity;
import com.socmaps.entity.UserSettings;

/**
 * ServerResponseParser class for parsing all server response.
 * 
 */
public class ServerResponseParser {

	private static final String JSON_RECIPIENTS = "recipients";

	/**
	 * Parse server (JSON) response and binds to MyInfo object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @param facebookId
	 *            is user facebookId
	 * @param facebookAuthToken
	 *            is user facebookAuthToken
	 * @param isResult
	 *            is true if the JSON response starts with result tag, false
	 *            otherwise
	 * @return MyInfo object which is binds with all data
	 * @see com.socmaps.entity.MyInfo
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

	/**
	 * Parse server (JSON) response and binds to MyInfo object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @param isResult
	 *            is true if the JSON response starts with result tag, false
	 *            otherwise
	 * @return MyInfo object which is binds with all data
	 * @see com.socmaps.entity.MyInfo
	 */

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
			myInfo.setEmail(results.getString("email"));
			if (!results.isNull("firstName"))
				myInfo.setFirstName(results.getString("firstName"));

			if (!results.isNull("lastName"))
				myInfo.setLastName(results.getString("lastName"));
			if (!results.isNull("username"))
				myInfo.setUserName(results.getString("username"));
			if (!results.isNull("avatar"))
				myInfo.setAvatar(results.getString("avatar"));

			if (!results.isNull("coverPhoto"))
				myInfo.setCoverPhoto(results.getString("coverPhoto"));

			if (!results.isNull("authToken"))
				myInfo.setAuthToken(results.getString("authToken"));

			UserSettings userSettings = new UserSettings();

			if (!results.isNull("settings")) {
				userSettings.setUnit(results.getJSONObject("settings")
						.getString("unit"));
				userSettings.setVisibility(results.getJSONObject("settings")
						.getBoolean("visible"));
			}

			if (!results.isNull("shareLocation")) {
				userSettings.setShareLocation(results.getInt("shareLocation"));
			}
			if (!results.isNull("shareProfilePicture")) {
				userSettings.setShareProfilePicture(results
						.getInt("shareProfilePicture"));
			}
			if (!results.isNull("shareNewsFeed")) {
				userSettings.setShareNewsFeed(results.getInt("shareNewsFeed"));
			}
			myInfo.setSettings(userSettings);

			if (!results.isNull("gender"))
				myInfo.setGender(results.getString("gender"));
			else
				myInfo.setGender("");

			if (!results.isNull("dateOfBirth"))
				myInfo.setDateOfBirth(results.getJSONObject("dateOfBirth")
						.getString("date"));

			if (!results.isNull("lastLogin")) {
				myInfo.setLastLogInDate(results.getJSONObject("lastLogin")
						.getString("date"));
				myInfo.setLastLoginTime(getTimeEntityFromJsonObject(results
						.getJSONObject("lastLogin")));
			}

			if (!results.isNull("regMedia"))
				myInfo.setRegMedia(results.getString("regMedia"));
			if (!results.isNull("workStatus"))
				myInfo.setWorkStatus(results.getString("workStatus"));
			if (!results.isNull("relationshipStatus"))
				myInfo.setRelationshipStatus(results
						.getString("relationshipStatus"));
			else
				myInfo.setRelationshipStatus("");
			if (!results.isNull("bio"))
				myInfo.setBio(results.getString("bio"));
			if (!results.isNull("interests"))
				myInfo.setInterests(results.getString("interests"));

			if (!results.isNull("loginCount")) {
				myInfo.setLogInCount(results.getInt("loginCount"));
			}

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
			}

			if (!results.isNull("address")) {

				if (!results.getJSONObject("address").isNull("street"))
					myInfo.setStreetAddress(results.getJSONObject("address")
							.getString("street"));
				if (!results.getJSONObject("address").isNull("city"))
					myInfo.setCity(results.getJSONObject("address").getString(
							"city"));
				if (!results.getJSONObject("address").isNull("country"))
					myInfo.setCountry(results.getJSONObject("address")
							.getString("country"));
				if (!results.getJSONObject("address").isNull("postCode"))
					myInfo.setPostCode(results.getJSONObject("address")
							.getString("postCode"));
				if (!results.getJSONObject("address").isNull("state"))
					myInfo.setState(results.getJSONObject("address").getString(
							"state"));
			}

			if (!results.isNull("circles")) {
				// parse circles
				JSONArray cjArray = results.getJSONArray("circles");
				if (cjArray != null) {

					myInfo.setCircleList(getCircleList(cjArray));

				}
			}

			if (!results.isNull("friends")) {
				// parse circles
				JSONArray fjArray = results.getJSONArray("friends");
				if (fjArray != null) {

					myInfo.setFriendList(parsePeoples(fjArray));
				}
			}

			if (!results.isNull("notification_count")) {
				NotificationCount notificationCount = new NotificationCount();
				JSONObject nObj = results.getJSONObject("notification_count");

				int notifications = 0;
				int friendRequest = 0;
				int messageCount = 0;

				if (!nObj.isNull("notifications")) {
					notificationCount.setNotificationCount(notifications);
				}
				if (!nObj.isNull("friendRequest")) {
					friendRequest = nObj.getInt("friendRequest");
					notificationCount.setFriendRequestCount(friendRequest);
				}
				if (!nObj.isNull("messageCount")) {
					messageCount = nObj.getInt("messageCount");
					notificationCount.setMessageCount((messageCount));
				}

				notificationCount.setTotalCount(notifications + friendRequest
						+ messageCount);

				myInfo.setNotificationCount(notificationCount);
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();

			myInfo = null;
		}

		return myInfo;
	}

	/**
	 * Parse server (JSON) response and returns CirclesAndFriends object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return CirclesAndFriends object which is binds with all data
	 * @see com.socmaps.entity.CirclesAndFriends
	 */
	public static CirclesAndFriends parseCircleAndFriends(String response) {
		CirclesAndFriends circlesAndFriends = new CirclesAndFriends();

		try {
			JSONObject result = new JSONObject(response);

			if (!result.isNull("circles")) {
				// parse circles
				JSONArray cjArray = result.getJSONArray("circles");
				if (cjArray != null) {

					circlesAndFriends.setCircles(getCircleList(cjArray));

				}
			}

			if (!result.isNull("friends")) {
				// parse circles
				JSONArray fjArray = result.getJSONArray("friends");
				if (fjArray != null) {

					circlesAndFriends.setFriends(parsePeoples(fjArray));
				}
			}

		} catch (JSONException e) {

		} catch (Exception e) {
			// TODO: handle exception
		}

		return circlesAndFriends;
	}

	/**
	 * Parse server (JSON) response which is people JSONArray.
	 * 
	 * @param jArray
	 *            is server response which is people JSONArray
	 * @return List of peoples
	 * @see List
	 * @see com.socmaps.entity.People
	 */

	public static List<People> parsePeoples(JSONArray jArray) {
		List<People> friendList = new ArrayList<People>();

		try {
			for (int i = 0; i < jArray.length(); i++) {

				JSONObject fObj = jArray.getJSONObject(i);

				People friend = parsePeople(fObj);

				friendList.add(friend);

			}
		} catch (JSONException e) {
			// TODO: handle exception
		}
		return friendList;

	}

	/**
	 * Parse server (JSON) response which is circle JSONObject.
	 * 
	 * @param jObj
	 *            is server response which is circle JSONObject
	 * @return Circle object binds with all data
	 * @see com.socmaps.entity.Circle
	 */
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
				List<People> friendList = new ArrayList<People>();

				for (int j = 0; j < fjArray.length(); j++) {
					People people = new People();
					String friendId = fjArray.getString(j);

					people.setId(friendId);
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

	/**
	 * Parse server (JSON) response which is circle JSONObject with Details.
	 * 
	 * @param jObj
	 *            is server response which is circle JSONObject
	 * @return Circle object binds with all data
	 * @see com.socmaps.entity.Circle
	 */

	public static Circle parseCircleEntityDetails(JSONObject jObj) {
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
				List<People> friendList = new ArrayList<People>();

				for (int j = 0; j < fjArray.length(); j++) {
					People people = parsePeople(fjArray.getJSONObject(j));
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

	/**
	 * Parse server (JSON) response and returns array of FriendRequest.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return FriendRequest[] array
	 * @see com.socmaps.entity.FriendRequest
	 */

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

				if (!jObject.isNull("createDate")) {

					friendRequests[i]
							.setSentTime(getTimeEntityFromJsonObject(jObject
									.getJSONObject("createDate")));

				}

			}

		} catch (JSONException e) {
			e.printStackTrace();
			friendRequests = null;
		}

		return friendRequests;
	}

	/**
	 * Parse server (JSON) response which is MessageThread JSONObject.
	 * 
	 * @param jObject
	 *            is server response which is MessageThread JSONObject
	 * @return MessageEntity object
	 * @see com.socmaps.entity.MessageEntity
	 */

	public static MessageEntity parseMessageThread(JSONObject jObject) {
		MessageEntity mEntity = new MessageEntity();

		try {
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

			String lastMessage;
			if (!jObject.isNull("lastMessage")) {
				lastMessage = jObject.getString("lastMessage");
				mEntity.setLastMessage(lastMessage);
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

				mEntity.setUpdateTimeEntity(getTimeEntityFromJsonObject(jObject
						.getJSONObject("updateDate")));

				updateDate = jObject.getJSONObject("updateDate").getString(
						"date");
				mEntity.setUpdateDate(updateDate);

			}

			MetaContent metaContent = new MetaContent();
			if (!jObject.isNull("metaType")) {
				metaContent.setType(jObject.getString("metaType"));
			}

			if (!jObject.isNull("metaContent")) {
				JSONObject mcObject = jObject.getJSONObject("metaContent");

				if (!mcObject.isNull("id")) {
					metaContent.setId(mcObject.getString("id"));
				}
				if (!mcObject.isNull("content")) {
					JSONObject contentObject = mcObject
							.getJSONObject("content");
					if (!contentObject.isNull("note")) {
						metaContent.setNote(contentObject.getString("note"));
					}
					if (!contentObject.isNull("address")) {
						metaContent.setAddress(contentObject
								.getString("address"));
					}

					if (!contentObject.isNull("lat")) {
						metaContent.setLatitude(contentObject.getDouble("lat"));
					}

					if (!contentObject.isNull("lng")) {
						metaContent
								.setLongitude(contentObject.getDouble("lng"));
					}
				}
			}

			mEntity.setMetaContent(metaContent);

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

				String senderUserName;
				if (!senderObj.isNull("username")) {
					senderUserName = senderObj.getString("username");
					mEntity.setSenderUserName(senderUserName);
				}

				String senderAvatar;
				if (!senderObj.isNull("avatar")) {
					senderAvatar = senderObj.getString("avatar");
					mEntity.setSenderAvatar(senderAvatar);
				}

			}

			if (!jObject.isNull("lastSender")) {

				JSONObject senderObj = jObject.getJSONObject("lastSender");

				String senderId;
				if (!senderObj.isNull("id")) {
					senderId = senderObj.getString("id");
					mEntity.setLastSenderId(senderId);
				}

				String senderEmail;
				if (!senderObj.isNull("email")) {
					senderEmail = senderObj.getString("email");
					mEntity.setLastSenderEmail(senderEmail);
				}

				String senderFirstName;
				if (!senderObj.isNull("firstName")) {
					senderFirstName = senderObj.getString("firstName");
					mEntity.setLastSenderFirstName(senderFirstName);
				}

				String senderLastName;
				if (!senderObj.isNull("lastName")) {
					senderLastName = senderObj.getString("lastName");
					mEntity.setLastSenderLastName(senderLastName);
				}

				String senderUserName;
				if (!senderObj.isNull("username")) {
					senderUserName = senderObj.getString("username");
					mEntity.setLastSenderUserName(senderUserName);
				}

				String senderAvatar;
				if (!senderObj.isNull("avatar")) {
					senderAvatar = senderObj.getString("avatar");
					mEntity.setLastSenderAvatar(senderAvatar);
				}

			}

			mEntity.setReplies(buildReplies(jObject));
			mEntity.setRecipients(buildRecipients(jObject));
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
					if (!object.isNull(key)) {
						String value = object.getString(key);
						map.put(key, value);
					}

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
					timeEntity.setDateTimeValue(rjObject.getJSONObject(
							"updateDate").getString("date"));
					timeEntity.setTimeZoneType(rjObject.getJSONObject(
							"updateDate").getInt("timezone_type"));
					timeEntity.setTimeZone(rjObject.getJSONObject("updateDate")
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
					String senderUserName;
					if (!rSenderObj.isNull("username")) {
						senderUserName = rSenderObj.getString("username");
						replyEntity.setSenderUserName(senderUserName);
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

	/**
	 * Parse server (JSON) response and returns List of MessageEntity.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return List of MessageEntity
	 * @see List
	 * @see com.socmaps.entity.MessageEntity
	 */
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

	/**
	 * Parse server (JSON) response and returns LayersPreferences object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return LayersPreferences object
	 * @see com.socmaps.entity.LayersPreferences
	 */
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

	/**
	 * Parse server (JSON) response and returns NotificationPreferences object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return NotificationPreferences object
	 * @see com.socmaps.entity.NotificationPreferences
	 */
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

	/**
	 * Parse server (JSON) response and returns PlatformsPreferences object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return PlatformsPreferences object
	 * @see com.socmaps.entity.PlatformsPreferences
	 */
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

	/**
	 * Parse server (JSON) response and returns InformationSharingPreferences
	 * object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return InformationSharingPreferences object
	 * @see com.socmaps.entity.InformationSharingPreferences
	 */
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

	/**
	 * Parse server (JSON) response and returns SearchResult object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return SearchResult object
	 * @see com.socmaps.entity.SearchResult
	 */
	public static SearchResult parseSeachResult(String response) {
		SearchResult searchResult = new SearchResult();
		searchResult.setPeoples(parseSearchResultPeople(response));
		searchResult.setPlaces(parseSearchResultPlace(response));
		searchResult
				.setSecondDegreePeoples(parseSearchResultSecondDegreePeople(response));
		return searchResult;
	}

	/**
	 * Parse server (JSON) response and returns ArrayList of Place.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of Place
	 * @see ArrayList
	 * @see com.socmaps.entity.Place
	 */
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
		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return places;
	}

	/**
	 * Parse server (JSON) response which is place JSONObject
	 * 
	 * @param placeObj
	 *            is server response which is place JSONObject
	 * @return Place object binds with all data
	 * @see com.socmaps.entity.Place
	 */
	public static Place parsePlace(JSONObject placeObj) {
		Place place = new Place();

		try {
			if (!placeObj.isNull("id")) {
				place.setId(placeObj.getString("id"));
			}
			if (!placeObj.isNull("name")) {
				place.setName(placeObj.getString("name"));
			}
			if (!placeObj.isNull("reference")) {
				place.setReference(placeObj.getString("reference"));
			}

			if (!placeObj.isNull("icon")) {
				place.setIconUrl(placeObj.getString("icon"));
			}

			if (!placeObj.isNull("vicinity")) {
				place.setVicinity(placeObj.getString("vicinity"));
			}

			if (!placeObj.isNull("distance")) {

				place.setDistance(placeObj.getDouble("distance"));
			}

			if (!placeObj.isNull("streetViewImage")) {
				place.setStreetViewImage(placeObj.getString("streetViewImage"));
			}

			if (!placeObj.isNull("types")) {
				ArrayList<String> types = new ArrayList<String>();
				JSONArray jArrayTypes = placeObj.getJSONArray("types");
				for (int j = 0; j < jArrayTypes.length(); j++) {
					types.add(jArrayTypes.getString(j));
				}
				if (types.size() > 0) {
					place.setTypes(types);
				}
			}

			if (!placeObj.isNull("geometry")) {
				JSONObject geometry = placeObj.getJSONObject("geometry");
				if (!geometry.isNull("location")) {
					JSONObject location = geometry.getJSONObject("location");

					if (!location.isNull("lat")) {
						place.setLatitude(location.getDouble("lat"));
					}
					if (!location.isNull("lng")) {
						place.setLongitude(location.getDouble("lng"));
					}
				}
			}
		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return place;
	}

	/**
	 * Parse server (JSON) response and returns ArrayList of Place.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of Place
	 * @see ArrayList
	 * @see com.socmaps.entity.Place
	 */
	public static ArrayList<Place> parseSavedPlaces(String response) {

		ArrayList<Place> places = new ArrayList<Place>();
		JSONObject placeObj;
		try {

			JSONArray arrayPlace = new JSONArray(response);
			for (int i = 0; i < arrayPlace.length(); i++) {

				placeObj = arrayPlace.getJSONObject(i);
				places.add(parseSavedPlace(placeObj));
			}
		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return places;
	}

	/**
	 * Parse server (JSON) response and returns LocationSharing object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return LocationSharing object.
	 * @see com.socmaps.entity.LocationSharing
	 */
	public static LocationSharing savedLocationSharingParser(String response) {

		LocationSharing locationSharing = new LocationSharing();
		JSONObject results;

		try {
			results = (new JSONObject(response)).getJSONObject("result");

			if (!results.isNull("status")) {
				locationSharing.setStatus(results.getString("status"));
			}

			if (!results.isNull("friends_and_circles")) {

				JSONObject friends_and_circlesJsonObject = results
						.getJSONObject("friends_and_circles");

				locationSharing
						.setLSFriendsAndCircles(parseLsFriends(friends_and_circlesJsonObject));
			}

			if (!results.isNull("strangers")) {

				JSONObject strangersJsonObject = results
						.getJSONObject("strangers");

				locationSharing
						.setStrangers(parseLsValues(strangersJsonObject));
			}

			if (!results.isNull("platforms")) {

				JSONObject platformsJsonObject = results
						.getJSONObject("platforms");

				locationSharing
						.setPlatforms(parseLSItemObject(platformsJsonObject));
			}

			if (!results.isNull("circles_only")) {

				JSONObject circlesOnlyJsonObject = results
						.optJSONObject("circles_only");

				if (circlesOnlyJsonObject != null) {
					locationSharing
							.setCirclesOnly(parseLSItemObject(circlesOnlyJsonObject));
				} else {

					JSONArray categories = results.optJSONArray("circles_only");
					locationSharing
							.setCirclesOnly(parseLsCirclesOnly(categories));

				}

			}

			if (!results.isNull("geo_fences")) {

				JSONArray geo_fencesJsonArray = results
						.getJSONArray("geo_fences");

				locationSharing
						.setGeo_fences(parseLsGeoFences(geo_fencesJsonArray));
			}

		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return locationSharing;
	}

	private static HashMap<String, LsValues> parseLsCirclesOnly(
			JSONArray circlesOnlyJsonArray) {

		HashMap<String, LsValues> circlesOnly = new HashMap<String, LsValues>();

		try {

			for (int i = 0; i < circlesOnlyJsonArray.length(); i++) {

				JSONObject circleOnlyJsonObject = circlesOnlyJsonArray
						.getJSONObject(i);

				Iterator keys = circleOnlyJsonObject.keys();

				while (keys.hasNext()) {
					String curentkey = (String) keys.next();

					if (!circleOnlyJsonObject.isNull(curentkey)) {

						circlesOnly.put(curentkey,
								parseLsValues(circleOnlyJsonObject
										.getJSONObject(curentkey)));
					}

				}

			}

		} catch (JSONException e) {

		}

		return circlesOnly;

	}

	private static ArrayList<LsValues> parseLsGeoFences(
			JSONArray geo_fencesJsonArray) {

		ArrayList<LsValues> geoFencesJsonArray = new ArrayList<LsValues>();

		try {

			for (int i = 0; i < geo_fencesJsonArray.length(); i++) {

				JSONObject geo_fencesJsonObject = geo_fencesJsonArray
						.getJSONObject(i);

				geoFencesJsonArray.add(parseLsValues(geo_fencesJsonObject));

			}

		} catch (JSONException e) {

		}

		return geoFencesJsonArray;
	}

	private static HashMap<String, LsValues> parseLSItemObject(
			JSONObject platformsJsonObject) {

		HashMap<String, LsValues> platform = new HashMap<String, LsValues>();

		try {

			Iterator keys = platformsJsonObject.keys();

			while (keys.hasNext()) {
				String curentkey = (String) keys.next();

				if (!platformsJsonObject.isNull(curentkey)) {

					platform.put(curentkey, parseLsValues(platformsJsonObject
							.getJSONObject(curentkey)));
				}

			}

		} catch (JSONException e) {

		}

		return platform;
	}

	private static LsValues parseLsValues(JSONObject strangersJsonObject) {

		LsValues lsValues = new LsValues();

		try {

			if (!strangersJsonObject.isNull("name")) {

				lsValues.setName(strangersJsonObject.getString("name"));

			}

			if (!strangersJsonObject.isNull("duration")) {

				lsValues.setDuration(strangersJsonObject.getInt("duration"));

			}
			if (!strangersJsonObject.isNull("radius")) {

				lsValues.setRadius(strangersJsonObject.getInt("radius"));

			}

			if (!strangersJsonObject.isNull("location")) {

				JSONObject locationJsonObject = strangersJsonObject
						.getJSONObject("location");

				if (!locationJsonObject.isNull("lat")) {
					lsValues.setLatitude(locationJsonObject.getDouble("lat"));

				}

				if (!locationJsonObject.isNull("lng")) {
					lsValues.setLongitude(locationJsonObject.getDouble("lng"));

				}

			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// TODO Auto-generated method stub
		return lsValues;
	}

	private static LSFriendsAndCircles parseLsFriends(
			JSONObject lsFriendsJsonObject) {

		LSFriendsAndCircles lSFriendsAndCircles = new LSFriendsAndCircles();
		try {

			if (!lsFriendsJsonObject.isNull("friends")) {

				JSONArray permitted_users = lsFriendsJsonObject
						.getJSONArray("friends");

				ArrayList<String> friends = new ArrayList<String>();

				for (int i = 0; i < permitted_users.length(); i++) {

					friends.add(permitted_users.getString(i));

				}

				lSFriendsAndCircles.setFriends(friends);

			}

			if (!lsFriendsJsonObject.isNull("circles")) {

				JSONArray permitted_circles = lsFriendsJsonObject
						.getJSONArray("circles");

				ArrayList<String> circles = new ArrayList<String>();

				for (int i = 0; i < permitted_circles.length(); i++) {

					circles.add(permitted_circles.getString(i));

				}

				lSFriendsAndCircles.setCircles(circles);

			}

			if (!lsFriendsJsonObject.isNull("duration")) {

				lSFriendsAndCircles.setDuration(lsFriendsJsonObject
						.getInt("duration"));

			}
			if (!lsFriendsJsonObject.isNull("radius")) {

				lSFriendsAndCircles.setRadius(lsFriendsJsonObject
						.getInt("radius"));

			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return lSFriendsAndCircles;
	}

	/**
	 * Parse server (JSON) response which is place JSONObject.
	 * 
	 * @param placeObj
	 *            is server response which is place JSONObject
	 * @return Place object binds with all data
	 * @see com.socmaps.entity.Place
	 */
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
			if (!placeObj.isNull("createDate")) {
				place.setCreateDate(getTimeEntityFromJsonObject(placeObj
						.getJSONObject("createDate")));
			}
			if (!placeObj.isNull("location")) {
				JSONObject location = placeObj.getJSONObject("location");

				if (!location.isNull("lat")) {
					place.setLatitude(location.getDouble("lat"));
				}
				if (!location.isNull("lng")) {
					place.setLongitude(location.getDouble("lng"));
				}
				if (!location.isNull("address")) {
					place.setVicinity(location.getString("address"));
				}
			}

			if (!placeObj.isNull("type")) {
				place.setType(placeObj.getString("type"));
			}

			if (!placeObj.isNull("distance")) {

				place.setDistance(placeObj.getDouble("distance"));
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return place;
	}

	/**
	 * Parse server (JSON) response and returns ArrayList of Photo.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of Photo
	 * @see ArrayList
	 * @see com.socmaps.entity.Photo
	 */
	public static ArrayList<Photo> parsePhotos(String response) {

		ArrayList<Photo> photos = new ArrayList<Photo>();
		JSONObject photoObj;
		try {

			JSONArray arrayPhotos = new JSONArray(response);
			for (int i = 0; i < arrayPhotos.length(); i++) {

				photoObj = arrayPhotos.getJSONObject(i);
				photos.add(parsePhoto(photoObj));
			}
		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return photos;
	}

	/**
	 * Parse server (JSON) response which is photo JSONObject.
	 * 
	 * @param photoObj
	 *            is server response which is photo JSONObject
	 * @return Photo object binds with all data
	 * @see com.socmaps.entity.Photo
	 */
	public static Photo parsePhoto(JSONObject photoObj) {
		Photo photo = new Photo();

		try {
			if (!photoObj.isNull("id")) {
				photo.setId(photoObj.getString("id"));
			}
			if (!photoObj.isNull("description")) {
				photo.setDescription(photoObj.getString("description"));
			}
			if (!photoObj.isNull("title")) {
				photo.setTitle(photoObj.getString("title"));
			}
			if (!photoObj.isNull("permission")) {
				photo.setPermission(photoObj.getString("permission"));
			}

			if (!photoObj.isNull("permittedUsers")) {

				photo.setPermittedUsers(getListFromJSONArray(photoObj
						.getJSONArray("permittedUsers")));
			}
			if (!photoObj.isNull("permittedCircles")) {
				photo.setPermittedCircles(getListFromJSONArray(photoObj
						.getJSONArray("permittedCircles")));
			}

			if (!photoObj.isNull("imageThumb")) {
				photo.setImageThumb(photoObj.getString("imageThumb"));
			}

			if (!photoObj.isNull("imageMedium")) {
				photo.setImageMedium(photoObj.getString("imageMedium"));
			}

			if (!photoObj.isNull("imageLarge")) {
				photo.setImageLarge(photoObj.getString("imageLarge"));
			}

			if (!photoObj.isNull("owner")) {
			}
			if (!photoObj.isNull("location")) {
				JSONObject location = photoObj.getJSONObject("location");

				if (!location.isNull("lat")) {
					photo.setLatitude(location.getDouble("lat"));
				}
				if (!location.isNull("lng")) {
					photo.setLongitude(location.getDouble("lng"));
				}
				if (!location.isNull("address")) {
					photo.setAddress(location.getString("address"));
				}
			}

			if (!photoObj.isNull("createDate")) {
				photo.setCreateDate(getTimeEntityFromJsonObject(photoObj
						.getJSONObject("createDate")));
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return photo;
	}

	/**
	 * Parse server (JSON) response and returns ArrayList of GeoTag.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of GeoTag
	 * @see ArrayList
	 * @see com.socmaps.entity.GeoTag
	 */
	public static ArrayList<GeoTag> parseGeotags(String response) {

		ArrayList<GeoTag> geotags = new ArrayList<GeoTag>();
		JSONObject geotagObj;
		try {

			JSONArray arrayGeotags = new JSONArray(response);
			for (int i = 0; i < arrayGeotags.length(); i++) {

				geotagObj = arrayGeotags.getJSONObject(i);
				geotags.add(parseGeotag(geotagObj));
			}
		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return geotags;
	}

	/**
	 * Parse server (JSON) response which is geotag JSONObject.
	 * 
	 * @param geotagObj
	 *            is server response which is geotag JSONObject
	 * @return GeoTag object binds with all data
	 * @see com.socmaps.entity.GeoTag
	 */
	public static GeoTag parseGeotag(JSONObject geotagObj) {

		GeoTag geotag = new GeoTag();

		try {
			if (!geotagObj.isNull("id")) {
				geotag.setId(geotagObj.getString("id"));
			}

			if (!geotagObj.isNull("title")) {
				geotag.setTitle(geotagObj.getString("title"));
			}
			if (!geotagObj.isNull("category")) {
				geotag.setCategory(geotagObj.getString("category"));
			}
			if (!geotagObj.isNull("description")) {
				geotag.setDescription(geotagObj.getString("description"));
			}

			if (!geotagObj.isNull("photo")) {
				geotag.setPhoto(geotagObj.getString("photo"));
			}

			if (!geotagObj.isNull("createDate")) {
				geotag.setCreateDate(getTimeEntityFromJsonObject(geotagObj
						.getJSONObject("createDate")));
			}

			if (!geotagObj.isNull("owner")) {
				geotag.setOwner(parsePeople(geotagObj.getJSONObject("owner")));
			}

			if (!geotagObj.isNull("location")) {
				JSONObject location = geotagObj.getJSONObject("location");

				if (!location.isNull("lat")) {
					geotag.setLatitude(location.getDouble("lat"));
				}
				if (!location.isNull("lng")) {
					geotag.setLongitude(location.getDouble("lng"));
				}
				if (!location.isNull("address")) {
					geotag.setAddress(location.getString("address"));
				}
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return geotag;
	}

	/**
	 * Parse server (JSON) response and returns ArrayList of people.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of People
	 * @see ArrayList
	 * @see com.socmaps.entity.People
	 */
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
		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return peoples;
	}

	/**
	 * Parse server (JSON) response and returns ArrayList of SecondDegreePeople.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of SecondDegreePeople
	 * @see ArrayList
	 * @see com.socmaps.entity.SecondDegreePeople
	 */
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

		} catch (NullPointerException e) {
			return null;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;

		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}

		return secondDegreePeoples;
	}

	/**
	 * Parse server (JSON) response which is people JSONObject.
	 * 
	 * @param peopleJSONObj
	 *            is server response which is people JSONObject
	 * @return People object binds with all data
	 * @see com.socmaps.entity.People
	 */
	public static People parsePeople(JSONObject peopleJSONObj) {
		People people = new People();

		try {
			if (!peopleJSONObj.isNull("id")) {
				people.setId(peopleJSONObj.getString("id"));
			}

			if (!peopleJSONObj.isNull("email")) {
				people.setEmail(peopleJSONObj.getString("email"));
			}

			if (!peopleJSONObj.isNull("firstName"))
				people.setFirstName(peopleJSONObj.getString("firstName"));

			if (!peopleJSONObj.isNull("lastName"))
				people.setLastName(peopleJSONObj.getString("lastName"));

			if (!peopleJSONObj.isNull("username"))
				people.setUserName(peopleJSONObj.getString("username"));

			if (!peopleJSONObj.isNull("avatar")) {
				String avatar = peopleJSONObj.getString("avatar");
				if (avatar.contains("https")) {
					avatar = avatar.replace("https", "http");
				}
				if (avatar.contains("type=normal")) {
					avatar = avatar.replace("type=normal", "type=small");
				}
				if (avatar.contains("type=large")) {
					avatar = avatar.replace("type=large", "type=small");
				}

				people.setAvatar(avatar);

			}

			if (!peopleJSONObj.isNull("gender"))
				people.setGender(peopleJSONObj.getString("gender"));
			else
				people.setGender("");

			if (!peopleJSONObj.isNull("dateOfBirth")) {
				people.setDateOfBirth(peopleJSONObj
						.getJSONObject("dateOfBirth").getString("date"));
			}
			if (!peopleJSONObj.isNull("regMedia")) {
				people.setRegMedia(peopleJSONObj.getString("regMedia"));
			}
			if (!peopleJSONObj.isNull("workStatus")) {
				people.setWorkStatus(peopleJSONObj.getString("workStatus"));
			}
			if (!peopleJSONObj.isNull("relationshipStatus"))
				people.setRelationshipStatus(peopleJSONObj
						.getString("relationshipStatus"));
			else
				people.setRelationshipStatus("");

			if (!peopleJSONObj.isNull("bio")) {
				people.setBio(peopleJSONObj.getString("bio"));
			}
			if (!peopleJSONObj.isNull("interests")) {
				people.setInterests(peopleJSONObj.getString("interests"));
			}
			if (!peopleJSONObj.isNull("loginCount")) {
				people.setLogInCount(peopleJSONObj.getInt("loginCount"));
			}
			if (!peopleJSONObj.isNull("currentLocation")) {

				JSONObject jo = peopleJSONObj.getJSONObject("currentLocation");

				if (!jo.isNull("lat"))
					people.setLatitude(jo.getDouble("lat"));
				if (!jo.isNull("lng"))
					people.setLongitude(jo.getDouble("lng"));
			}
			if (!peopleJSONObj.isNull("address")) {

				try {
					if (!peopleJSONObj.getJSONObject("address")
							.isNull("street"))
						people.setStreetAddress(peopleJSONObj.getJSONObject(
								"address").getString("street"));

					if (!peopleJSONObj.getJSONObject("address").isNull("city"))
						people.setCity(peopleJSONObj.getJSONObject("address")
								.getString("city"));

					if (!peopleJSONObj.getJSONObject("address").isNull(
							"country"))
						people.setCountry(peopleJSONObj
								.getJSONObject("address").getString("country"));

					if (!peopleJSONObj.getJSONObject("address").isNull(
							"postCode"))
						people.setPostCode(peopleJSONObj.getJSONObject(
								"address").getString("postCode"));

					if (!peopleJSONObj.getJSONObject("address").isNull("state"))
						people.setState(peopleJSONObj.getJSONObject("address")
								.getString("state"));
				} catch (JSONException e) {
					// TODO: handle exception
				}

			}

			if (!peopleJSONObj.isNull("age")) {
				people.setAge(peopleJSONObj.getInt("age"));
			}

			if (!peopleJSONObj.isNull("distance")) {
				people.setDistance(peopleJSONObj.getDouble("distance"));
			}
			if (!peopleJSONObj.isNull("isFriend")) {
				people.setIsFrnd(peopleJSONObj.getBoolean("isFriend"));
			}
			if (!peopleJSONObj.isNull("status")) {
				people.setStatusMsg(peopleJSONObj.getString("status"));
			}
			if (!peopleJSONObj.isNull("coverPhoto")) {
				people.setCoverPhoto(peopleJSONObj.getString("coverPhoto"));
			}

			if (!peopleJSONObj.isNull("lastLogin")) {
				people.setLastLogIn(getTimeEntityFromJsonObject(peopleJSONObj
						.getJSONObject("lastLogin")));

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

			if (!peopleJSONObj.isNull("online")) {

				people.setOnline(peopleJSONObj.getBoolean("online"));
			}

		} catch (JSONException e) {
			// TODO: handle exception
			e.printStackTrace();
		}

		return people;
	}

	/**
	 * Parse server (JSON) response which is secondDegreePeople JSONObject.
	 * 
	 * @param peopleJSONObj
	 *            is server response which is secondDegreePeople JSONObject
	 * @return SecondDegreePeople object binds with all data
	 * @see com.socmaps.entity.SecondDegreePeople
	 */
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

			if (!peopleJSONObj.isNull("avatar")) {
				String avatar = peopleJSONObj.getString("avatar");
				if (avatar.contains("https")) {
					avatar = avatar.replace("https", "http");
				}
				if (avatar.contains("type=normal")) {
					avatar = avatar.replace("type=normal", "type=small");
				}
				if (avatar.contains("type=large")) {
					avatar = avatar.replace("type=large", "type=small");
				}

				secondDegreePeople.setAvatar(avatar);
			}

			if (!peopleJSONObj.isNull("lastSeenAt")) {

				secondDegreePeople.setLastSeenAt(peopleJSONObj
						.getString("lastSeenAt"));

			}

			if (!peopleJSONObj.isNull("currentLocation")) {

				JSONObject jo = peopleJSONObj.getJSONObject("currentLocation");

				if (!jo.isNull("lat"))
					secondDegreePeople.setLatitude(jo.getDouble("lat"));
				if (!jo.isNull("lng"))
					secondDegreePeople.setLongitude(jo.getDouble("lng"));
				if (!jo.isNull("address"))
					secondDegreePeople.setCurrentAddress(jo
							.getString("address"));

			}

			if (!peopleJSONObj.isNull("distance")) {
				secondDegreePeople.setDistance(peopleJSONObj
						.getDouble("distance"));
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

	/**
	 * Parse server (JSON) response which is circle JSONArray.
	 * 
	 * @param circleJSONArray
	 *            is server response which is circle JSONArray
	 * @return List of Circle
	 * @see List
	 * @see com.socmaps.entity.Circle
	 */
	public static List<Circle> getCircleList(JSONArray circleJSONArray)
			throws JSONException {
		List<Circle> circles = new ArrayList<Circle>();
		for (int i = 0; i < circleJSONArray.length(); i++) {

			JSONObject circleObj = circleJSONArray.getJSONObject(i);
			Circle circle = parseCircleEntity(circleObj);

			if (!circle.getName().equalsIgnoreCase("second_degree")) {
				Log.d("ServerResponseParse", circle.toString());
				circles.add(circle);
			}

		}
		return circles;
	}

	/**
	 * Parse server (JSON) response which is circle JSONArray with details.
	 * 
	 * @param ja
	 *            is server response which is circle JSONArray
	 * @return List of Circle
	 * @exception JSONException
	 * @see List
	 * @see com.socmaps.entity.Circle
	 */
	public static List<Circle> getCircleListWithDetails(JSONArray ja)
			throws JSONException {
		List<Circle> circles = new ArrayList<Circle>();
		for (int i = 0; i < ja.length(); i++) {

			JSONObject circleObj = ja.getJSONObject(i);
			Circle circle = parseCircleEntityDetails(circleObj);

			if (!circle.getName().equalsIgnoreCase("second_degree")) {
				Log.d("ServerResponseParse", circle.toString());
				circles.add(circle);
			}

		}
		return circles;
	}

	private static LatLng getLatLngFromJSON(JSONObject jo) throws JSONException {
		double lat = 0, lng = 0;
		if (!jo.isNull("lat"))
			lat = jo.getDouble("lat");
		if (!jo.isNull("lng"))
			lng = jo.getDouble("lng");
		return new LatLng((int) (lat * 1E6), (int) (lng * 1E6));
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

	/**
	 * Parse server (JSON) response and returns Event object.
	 * 
	 * @param result
	 *            would be String converted from server response (JSON file)
	 * @return Event object
	 * @see com.socmaps.entity.Event
	 */
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

	/**
	 * Parse server (JSON) response and returns ArrayList of event.
	 * 
	 * @param result
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of Event
	 * @see ArrayList
	 * @see com.socmaps.entity.Event
	 */
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
		}

		if (!jsonObject.isNull("title")) {
			event.setEventTitle(jsonObject.getString("title"));
		}

		if (!jsonObject.isNull("description")) {
			event.setDescription(jsonObject.getString("description"));
		}

		if (!jsonObject.isNull("eventShortSummary")) {
			event.setShortSummary(jsonObject.getString("eventShortSummary"));
		}

		if (!jsonObject.isNull("eventImage")) {
			event.setEventImageUrl(jsonObject.getString("eventImage"));
		}
		if (!jsonObject.isNull("owner")) {
			event.setOwner(jsonObject.getString("owner"));
		}
		if (!jsonObject.isNull("event_type")) {
			event.setEvent_type(jsonObject.getString("event_type"));
		}
		if (!jsonObject.isNull("my_response")) {
			event.setMyResponse(jsonObject.getString("my_response"));
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
		}

		if (!jsonObject.isNull("guestsCanInvite")) {
			event.setGuestCanInvite(jsonObject.getBoolean("guestsCanInvite"));
		}

		if (!jsonObject.isNull("is_invited")) {
			event.setInvited(jsonObject.getBoolean("is_invited"));
		}
		if (!jsonObject.isNull("location")) {

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

	/**
	 * Parse server (JSON) response and returns List of String.
	 * 
	 * @param jArray
	 *            is server response
	 * @return List of String
	 * @see List
	 * @see String
	 */
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

	/**
	 * Parse server (JSON) response and returns List of MeetupRequest.
	 * 
	 * @param result
	 *            would be String converted from server response (JSON file)
	 * @return List of MeetupRequest
	 * @see List
	 * @see com.socmaps.entity.MeetupRequest
	 */
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

		if (!jsonObject.isNull("location")) {

			JSONObject locationObj = jsonObject.getJSONObject("location");

			// meetupEntity.setLocation(getLatLngFromJSON(locationObj));

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

	/**
	 * Parse server (JSON) response and returns RSVP object
	 * 
	 * @param jObj
	 *            is server response which is RSVP JSONObject
	 * @return RSVP object binds with all data
	 * @see com.socmaps.entity.RSVP
	 */
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

	/**
	 * Parse server (JSON) response and returns FacebookErrorResponse object.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return FacebookErrorResponse object
	 * @see com.socmaps.entity.FacebookErrorResponse
	 */
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

	/**
	 * Parse server (JSON) response and returns Plan object.
	 * 
	 * @param result
	 *            would be String converted from server response (JSON file)
	 * @return Plan object
	 * @see com.socmaps.entity.Plan
	 */
	public static Plan parseGetPlanDetailsResult(String result) {

		Plan plan = new Plan();
		JSONObject jo;
		try {
			jo = new JSONObject(result);
			plan = parseIndividualPlan(jo, plan);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return plan;

	}

	/**
	 * Parse server (JSON) response and returns ArrayList of plan.
	 * 
	 * @param response
	 *            would be String converted from server response (JSON file)
	 * @return ArrayList of Plan
	 * @see ArrayList
	 * @see com.socmaps.entity.Plan
	 */
	public static ArrayList<Plan> parseGetPlanListResult(String result) {
		ArrayList<Plan> plans = new ArrayList<Plan>();

		try {
			JSONArray jArray = new JSONArray(result);
			for (int i = 0; i < jArray.length(); i++) {
				Plan plan = new Plan();
				parseIndividualPlan(jArray.getJSONObject(i), plan);
				plans.add(plan);
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return plans;
	}

	private static Plan parseIndividualPlan(JSONObject jsonObject, Plan plan)
			throws JSONException {
		// TODO Auto-generated method stub
		if (!jsonObject.isNull("id")) {
			plan.setPlanId(jsonObject.getString("id"));
		}

		if (!jsonObject.isNull("title")) {
			plan.setPlanTitle(jsonObject.getString("title"));
		}

		if (!jsonObject.isNull("description")) {
			plan.setDescription(jsonObject.getString("description"));
		}

		if (!jsonObject.isNull("image")) {
			plan.setPlanImageUrl(jsonObject.getString("image"));
		}

		if (!jsonObject.isNull("time")) {
			plan.setPlanTime(getTimeEntityFromJsonObject(jsonObject
					.getJSONObject("time")));
		}

		if (!jsonObject.isNull("createDate")) {
			plan.setCreateDate(getTimeEntityFromJsonObject(jsonObject
					.getJSONObject("createDate")));
		}

		if (!jsonObject.isNull("distance")) {
			plan.setDistance(jsonObject.getDouble("distance"));
		}

		if (!jsonObject.isNull("location")) {
			JSONObject jo = jsonObject.getJSONObject("location");

			if (!jo.isNull("lat"))
				plan.setLatitude(jo.getDouble("lat"));

			if (!jo.isNull("lng"))
				plan.setLongitude(jo.getDouble("lng"));

			if (!jo.isNull("address"))
				plan.setAddress(jo.getString("address"));
		}
		if (!jsonObject.isNull("guests")) {

			JSONObject guestObj = jsonObject.getJSONObject("guests");
			if (!guestObj.isNull("users")) {
				plan.setGuestList(getGuestList(guestObj.getJSONArray("users")));
			}

			if (!guestObj.isNull("circles")) {
				plan.setCircleList(getCircleList(guestObj
						.getJSONArray("circles")));
			}

		}

		if (!jsonObject.isNull("permission")) {
			plan.setPermission(jsonObject.getString("permission"));
		}

		if (!jsonObject.isNull("permittedUsers")) {
			plan.setPermittedUserList(getListFromJSONArray(jsonObject
					.getJSONArray("permittedUsers")));
		}
		if (!jsonObject.isNull("permittedCircles")) {
			plan.setPermittedCircleList(getListFromJSONArray(jsonObject
					.getJSONArray("permittedCircles")));
		}
		return plan;
	}

}
