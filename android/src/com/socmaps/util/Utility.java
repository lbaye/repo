package com.socmaps.util;

import java.io.BufferedInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningServiceInfo;
import android.content.ContentResolver;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Base64;
import android.util.Log;
import android.util.Pair;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.View.MeasureSpec;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapView;
import com.socmaps.entity.Circle;
import com.socmaps.entity.Event;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.MessageEntity;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.Plan;
import com.socmaps.entity.PushData;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.entity.TimeEntity;
import com.socmaps.images.ImageFetcher;
import com.socmaps.ui.R;
import com.socmaps.widget.ImageDownloadListener;

/**
 * Utility class for providing reusable methods
 */
public class Utility {

	private static final double metricDivisor = 1000;
	private static final double imperialDivisor = 1760;

	/**
	 * Returns title of an Object. Object should be instance of People, Place,
	 * SecondDegreePeople, MyInfo, Event or GeoTag
	 * 
	 * @param item
	 *            Object which is an instance of People, Place,
	 *            SecondDegreePeople, MyInfo, Event or GeoTag
	 * @return the title text
	 * @see String
	 */
	public static String getItemTitle(Object item) {
		if (item instanceof People) {

			People temp = ((People) item);
			String name = "";

			if (isValidString(temp.getUserName())) {
				name = temp.getUserName();
			} else {
				if (temp.getFirstName() != null) {
					name = temp.getFirstName();
				}

				if (temp.getLastName() != null) {
					name += " " + temp.getLastName();
				}
			}

			return name.trim();
		} else if (item instanceof SecondDegreePeople) {

			SecondDegreePeople temp = (SecondDegreePeople) item;
			String name = "";

			if (temp.getFirstName() != null) {
				name = temp.getFirstName();
			}

			if (temp.getLastName() != null) {
				name += " " + temp.getLastName();
			}
			return name.trim();
		} else if (item instanceof MyInfo) {

			MyInfo temp = (MyInfo) item;
			String name = "";

			if (temp.getFirstName() != null) {
				name = temp.getFirstName();
			}

			if (temp.getLastName() != null) {
				name += " " + temp.getLastName();
			}
			return name.trim();
		} else if (item instanceof Place) {
			Place temp = ((Place) item);
			return temp.getName().toString();
		} else if (item instanceof Event) {
			Event temp = ((Event) item);
			return temp.getEventTitle().toString();
		} else if (item instanceof GeoTag) {
			GeoTag temp = ((GeoTag) item);
			return temp.getTitle().toString();
		} else if (item instanceof String)
			return item.toString();
		else
			return "";
	}

	public static String getItemAddress(Object item) {
		String address = "";
		if (item instanceof People) {

			People people = ((People) item);
			address = people.getCurrentAddress();

		} else if (item instanceof SecondDegreePeople) {

			SecondDegreePeople secondDegreePeople = (SecondDegreePeople) item;
			address = secondDegreePeople.getCurrentAddress();

		} else if (item instanceof Place) {
			Place place = ((Place) item);
			address = place.getVicinity();
		} else if (item instanceof Event) {
			Event event = ((Event) item);
			address = event.getAddress();
		} else if (item instanceof GeoTag) {
			GeoTag geoTag = ((GeoTag) item);
			address = geoTag.getAddress();
		} else if (item instanceof String) {
			address = item.toString();
		}

		if (address != null) {
			address = address.trim();
		}
		return address;
	}
	
	public static String getItemImageUrl(Object item) {
		String imageUrl = "";
		if (item instanceof People) {

			People people = ((People) item);
			imageUrl = people.getAvatar();

		} else if (item instanceof SecondDegreePeople) {

			SecondDegreePeople secondDegreePeople = (SecondDegreePeople) item;
			imageUrl = secondDegreePeople.getAvatar();

		} else if (item instanceof Place) {
			Place place = ((Place) item);
			imageUrl = place.getIconUrl();
		} else if (item instanceof Event) {
			Event event = ((Event) item);
			imageUrl = event.getEventImageUrl();
		} else if (item instanceof GeoTag) {
			GeoTag geoTag = ((GeoTag) item);
			imageUrl = geoTag.getPhoto();
		} else if (item instanceof String) {
			imageUrl = item.toString();
		}

		if (imageUrl != null) {
			imageUrl = imageUrl.trim();
		}
		return imageUrl;
	}
	
	public static String getItemId(Object item) {
		String id = "";
		if (item instanceof People) {

			People people = ((People) item);
			id = people.getId();

		} else if (item instanceof SecondDegreePeople) {

			SecondDegreePeople secondDegreePeople = (SecondDegreePeople) item;
			id = secondDegreePeople.getRefId();

		} else if (item instanceof Place) {
			Place place = ((Place) item);
			id = place.getId();
		} else if (item instanceof Event) {
			Event event = ((Event) item);
			id = event.getEventId();
		} else if (item instanceof GeoTag) {
			GeoTag geoTag = ((GeoTag) item);
			id = geoTag.getId();
		} else if (item instanceof String) {
			id = item.toString();
		}

		if (id != null) {
			id = id.trim();
		}
		return id;
	}

	/**
	 * Returns a List of searched object based on Object's title(
	 * {@link #getItemTitle(Object)}). Object should be instance of People,
	 * Place, SecondDegreePeople, MyInfo, Event or GeoTag
	 * 
	 * @param masterList
	 *            List of object to be searched
	 * @param key
	 *            search key on which search would be performed.
	 * @return Searched result of List associated with the search key.
	 * @see #getItemTitle(Object)
	 * @see List
	 */
	public static List<Object> getSearchResult(List<Object> masterList,
			String key) {
		if (key == null || key.length() == 0) {
			return masterList;
		} else {
			String prefixString = key.toString().toLowerCase();
			final int count = masterList.size();
			final List<Object> newValues = new ArrayList<Object>();

			for (int i = 0; i < count; i++) {
				final Object value = masterList.get(i);
				final String valueText = getItemTitle(value).toLowerCase();

				// First match against the whole, non-splitted value
				if (valueText.startsWith(prefixString)) {
					newValues.add(value);
				} else {
					final String[] words = valueText.split(" ");
					final int wordCount = words.length;

					// Start at index 0, in case valueText starts with
					// space(s)
					for (int k = 0; k < wordCount; k++) {
						if (words[k].startsWith(prefixString)) {
							newValues.add(value);
							break;
						}
					}
				}
			}

			return newValues;
		}

	}

	/**
	 * Returns a list of circle with People whose name match with the search
	 * key.
	 * 
	 * @param masterList
	 *            Original circle list.
	 * @param orgFriendList
	 *            Original friend list.
	 * @param key
	 *            People name or search text.
	 * @return List of circles.
	 */
	public static List<Circle> getSearchResultFromCircle(
			List<Circle> masterList, List<People> orgFriendList, String key) {

		final List<Circle> newCircles = new ArrayList<Circle>();

		if (key == null || key.length() == 0) {
			return masterList;
		} else {
			String prefixString = key.toString().toLowerCase();
			final int count = masterList.size();

			for (int i = 0; i < masterList.size(); i++) {
				Circle circle = masterList.get(i);

				List<People> newFriendList = new ArrayList<People>();

				List<People> friends = circle.getFriendList();
				if (friends != null) {
					for (int j = 0; j < friends.size(); j++) {
						People people = friends.get(j);

						people = Utility.getPeopleById(people.getId(),
								orgFriendList);
						if (people != null) {
							final String valueText = getItemTitle(people);

							if (valueText.startsWith(prefixString)) {
								newFriendList.add(people);
							} else {
								final String[] words = valueText.split(" ");
								final int wordCount = words.length;

								// Start at index 0, in case valueText
								// starts with
								// space(s)
								for (int k = 0; k < wordCount; k++) {
									if (words[k].startsWith(prefixString)) {
										newFriendList.add(people);
										break;
									}
								}
							}
						}

					}

					if (newFriendList.size() > 0) {

						Circle circleNew = new Circle();

						circleNew.setName(circle.getName());
						circleNew.setId(circle.getId());
						circleNew.setFriendList(newFriendList);

						newCircles.add(circleNew);
					}

				}

			}

		}
		return newCircles;

	}

	/**
	 * Converts a distance with specified unit and returns as text that may be
	 * used to display on screen.
	 * 
	 * @param distance
	 *            in meter
	 * @param unit
	 *            metric or imperial
	 * @return Formated distance
	 * @see String
	 */
	public static String getFormatedDistance(double distance, String unit) {
		String result = "";

		if (unit.equalsIgnoreCase(Constant.UNIT_IMPERIAL)) {

			distance = toYard(distance);
			if (distance >= imperialDivisor)
				result = String.format("%.2f", distance / imperialDivisor)
						+ "miles";
			else
				result = (int) distance + "yd";

		} else {
			if (distance >= metricDivisor)
				result = String.format("%.2f", distance / metricDivisor) + "km";
			else
				result = (int) distance + "m";
		}

		return result;
	}

	private static double toYard(double distance) {

		return distance * 1.09361;
	}

	/**
	 * Converts a UTC time to local time and return as Date.
	 * 
	 * @param timeEntity
	 *            UTC time as TimeEntity
	 * @return Converted local time
	 * @see com.socmaps.entity.TimeEntity
	 * @see Date
	 */
	public static Date getLocalTimeFromUTC(TimeEntity timeEntity) {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat(
				"yyyy-MM-dd HH:mm:ss");
		simpleDateFormat.setTimeZone(TimeZone.getTimeZone(timeEntity
				.getTimeZone()));
		try {
			return simpleDateFormat.parse(timeEntity.getDateTimeValue());
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Converts a TimeEntity to formated text to display Event's date and time.
	 * 
	 * @param timeEntity
	 *            UTC time of Event as TimeEntity
	 * @return formated time of the event.
	 * @see com.socmaps.entity.TimeEntity
	 * @see String
	 */
	public static String getFormattedDisplayDateEventList(TimeEntity timeEntity) {
		Date targetDate = getLocalTimeFromUTC(timeEntity);
		return eventListTimeFormater.format(targetDate);
	}

	/**
	 * Returns current date of the system.
	 * 
	 * @return system date
	 * @see Date
	 */
	public static Date getCurrentDate() {
		Calendar c = Calendar.getInstance();
		return c.getTime();
	}

	/**
	 * Returns Time zone offset of the system as String. Value would vary from
	 * "-12:00" to "+13:00"
	 * 
	 * @return Offset
	 * @see String
	 */
	public static String getTimezoneOffset() {
		String offsetString = "";

		TimeZone tz = TimeZone.getDefault();
		int offset = tz.getRawOffset() / (1000 * 60);

		if (offset > 0) {
			offsetString += "+";
		} else {
			offsetString += "-";
			offset = offset * -1;
		}

		int hour = (offset / 60);
		if (hour < 10) {
			offsetString += "0" + hour;
		} else {
			offsetString += hour;
		}

		int minute = (offset % 60);

		if (minute < 10) {
			offsetString += "0" + minute;
		} else {
			offsetString += minute;
		}

		Log.i("timezone offset", offsetString);

		return offsetString;
	}

	private static SimpleDateFormat todayTimeFormater = new SimpleDateFormat(
			"HH:mm");

	private static SimpleDateFormat otherTimeFormater = new SimpleDateFormat(
			"MMM dd, yyyy");

	private static SimpleDateFormat withinSevenDaysTimeFormater = new SimpleDateFormat(
			"E, MMM dd, yyyy");

	private static SimpleDateFormat eventListTimeFormater = new SimpleDateFormat(
			"EEEE, MMMM dd, yyyy HH:mm");

	/**
	 * Converts a TimeEntity to formated text to display date and time.
	 * 
	 * @param timeEntity
	 *            UTC time as TimeEntity
	 * @return formated time.
	 * @see com.socmaps.entity.TimeEntity
	 * @see String
	 */
	public static String getFormattedDisplayDate(TimeEntity timeEntity) {

		Date targetDate = getLocalTimeFromUTC(timeEntity);
		Date now = getCurrentDate();

		Log.e("targetdate in local format", targetDate.toString());
		Log.e("current in local format", now.toString());

		if (today(targetDate, now)) {
			return "Today at " + todayTimeFormater.format(targetDate);
		} else if (dateIsOlderThan7Days(targetDate, now)) {
			return withinSevenDaysTimeFormater.format(targetDate);
		} else {
			return otherTimeFormater.format(targetDate);
		}
	}

	/**
	 * Converts a TimeEntity to formated text to display date and time on Map
	 * view annotations.
	 * 
	 * @param timeEntity
	 *            UTC time as TimeEntity
	 * @return formated time.
	 * @see com.socmaps.entity.TimeEntity
	 * @see String
	 */
	public static String getFormattedDisplayDateForMap(TimeEntity timeEntity) {

		Date targetDate = getLocalTimeFromUTC(timeEntity);
		Date now = getCurrentDate();

		Log.e("targetdate in local format", targetDate.toString());
		Log.e("current in local format", now.toString());

		if (today(targetDate, now)) {
			return "at " + todayTimeFormater.format(targetDate);
		} else {
			return "on " + otherTimeFormater.format(targetDate);
		}
	}

	private static boolean today(Date thatDate, Date thisDate) {
		return thisDate.getDate() == thatDate.getDate()
				&& thisDate.getMonth() == thatDate.getMonth()
				&& thisDate.getYear() == thatDate.getYear();
	}

	private static boolean dateIsOlderThan7Days(Date targetDate, Date now) {
		Date sevenDaysBefore = new Date(now.getYear(), now.getMonth(),
				now.getDate() - 7);
		return sevenDaysBefore.before(targetDate);
	}

	/**
	 * Returns formated text of a given distance that may be used to display on
	 * screen.
	 * 
	 * @param distance
	 *            in metric or imperial
	 * @return Formated distance
	 * @see String
	 */
	public static String getFormatedDistance(double distance) {
		return String.format("%.2f", distance);
	}

	/**
	 * Returns the JSONString from a server response associated with "result"
	 * 
	 * @param responseString
	 *            response string from server
	 * @return JSONString
	 */
	public static String getJSONStringFromServerResponse(String responseString) {
		try {
			JSONObject jo = new JSONObject(responseString);
			return jo.getString(Constant.responseKey);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Determines if Internet connection is available or not on the device.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return true if Internet connection is available, false otherwise.
	 * @see Context
	 */
	public static boolean isConnectionAvailble(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnectedOrConnecting()) {
			return true;
		}
		return false;
	}

	/**
	 * Determines a service is running or not with a given name.
	 * 
	 * @param serviceName
	 *            name of the service.
	 * @param context
	 *            Active context
	 * @return true if service is running, false otherwise
	 * @see Context
	 */
	public static boolean isServiceRunning(String serviceName, Context context) {
		final ActivityManager activityManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		final List<RunningServiceInfo> services = activityManager
				.getRunningServices(Integer.MAX_VALUE);

		for (RunningServiceInfo runningServiceInfo : services) {
			if (runningServiceInfo.service.getClassName().equals(serviceName)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Returns the MD5 Hash value of a given string.
	 * 
	 * @param string
	 *            String that needed to be converted
	 * @return MD5 Hash value
	 * @exception NoSuchAlgorithmException
	 *                returns empty string.
	 */
	public static String toMD5Hash(String string) {
		try {
			// Create MD5 Hash
			MessageDigest digest = java.security.MessageDigest
					.getInstance("MD5");
			digest.update(string.getBytes());
			byte messageDigest[] = digest.digest();

			// Create Hex String
			StringBuffer hexString = new StringBuffer();
			for (int i = 0; i < messageDigest.length; i++) {
				String h = Integer.toHexString(0xFF & messageDigest[i]);
				while (h.length() < 2) {
					h = "0" + h;
				}
				hexString.append(h);
			}
			return hexString.toString();

		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return "";
	}

	/**
	 * Determines if this Email id is valid or not
	 * 
	 * @param email
	 *            Email id to check.
	 * @return true if valid, false otherwise
	 */
	public static boolean isValidEmailID(String email) {

		if (email == null || email.trim().equals("")) {
			return false;
		}

		Pattern pattern;
		Matcher matcher;
		String EMAIL_PATTERN = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
		pattern = Pattern.compile(EMAIL_PATTERN);
		matcher = pattern.matcher(email);
		return matcher.matches();

	}

	/**
	 * returns the system date as String.
	 * 
	 * @return System date as String with "yyyy-MM-dd HH:mm:ss" format.
	 * @see String
	 * @see SimpleDateFormat
	 */
	public static String getdate() {
		SimpleDateFormat sdfDateTime = new SimpleDateFormat(
				"yyyy-MM-dd HH:mm:ss", Locale.US);
		String newtime = sdfDateTime
				.format(new Date(System.currentTimeMillis()));
		return newtime;
	}

	/**
	 * Returns the current UNIX Timestamp.
	 * 
	 * @return UNIX Timestamp of the system.
	 */
	public static long getUnixTimestamp() {
		long unixTime = System.currentTimeMillis() / 1000L;

		return unixTime;
	}

	/**
	 * returns the system date as String.
	 * 
	 * @return System date as String with specified format.
	 * @see String
	 * @see SimpleDateFormat
	 */
	public static String getdate(String format) {
		// "yyyy-MM-dd"
		SimpleDateFormat sdfDateTime = new SimpleDateFormat(format, Locale.US);
		String newtime = sdfDateTime
				.format(new Date(System.currentTimeMillis()));
		return newtime;

	}

	/**
	 * Parses Date of Birth obtained from Facebook and returns DOB as
	 * "yyyy-MM-dd" format.
	 * 
	 * @param fbdob
	 *            Date of birth obtained from Facebook in "MM/dd/yyyy" format
	 * @return Formated date of birth in "yyyy-MM-dd" format.
	 */
	public static String parseFbDob(String fbdob) {

		String[] dobArray = fbdob.split("/");

		String dobFormatted = dobArray[2] + "-" + dobArray[0] + "-"
				+ dobArray[1];

		return dobFormatted;
	}

	/**
	 * Calculates age and returns age as year.
	 * 
	 * @param year
	 *            Year of the Date of Birth in "yyyy" format.
	 * @param month
	 *            Month of the Date of Birth in "MM" format.
	 * @param day
	 *            Day of the Date of Birth in "dd" format.
	 * @return Age in years.
	 */
	public static int calculateAge(int year, int month, int day) {

		Calendar birthCal = new GregorianCalendar(year, month, day);
		Calendar nowCal = new GregorianCalendar();
		int age = nowCal.get(Calendar.YEAR) - birthCal.get(Calendar.YEAR);

		boolean isMonthGreater = birthCal.get(Calendar.MONTH) >= nowCal
				.get(Calendar.MONTH);

		boolean isMonthSameButDayGreater = birthCal.get(Calendar.MONTH) == nowCal
				.get(Calendar.MONTH)
				&& birthCal.get(Calendar.DAY_OF_MONTH) > nowCal
						.get(Calendar.DAY_OF_MONTH);

		if (isMonthGreater || isMonthSameButDayGreater) {
			age = age - 1;
		}
		return age;
	}

	/**
	 * Returns timestamp difference between a given date-time and system
	 * date-time.
	 * 
	 * @param dateTimeString
	 *            Date-time in "yyyy-MM-dd HH:mm:ss" format.
	 * @return Timestamp difference
	 */
	public static long getTimeDifference(String dateTimeString) {

		long timeDifference = 0;

		try {
			String FORMAT_DATETIME = "yyyy-MM-dd HH:mm:ss";
			SimpleDateFormat sdf = new SimpleDateFormat(FORMAT_DATETIME);
			Date date;
			date = sdf.parse(dateTimeString);

			timeDifference = (date.getTime() / 1000L) - getUnixTimestamp();

		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return timeDifference;
	}

	/**
	 * Calculates age and returns age as year.
	 * 
	 * @param dob
	 *            Date of Birth in "yyyy-MM-dd" format.
	 * @return Age in years.
	 */
	public static int calculateAge(String dob) {

		int yearDOB = Integer.parseInt(dob.substring(0, 4));
		int monthDOB = Integer.parseInt(dob.substring(5, 7));
		int dayDOB = Integer.parseInt(dob.substring(8, 10));

		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy");
		java.util.Date date = new java.util.Date();
		int thisYear = Integer.parseInt(dateFormat.format(date));

		dateFormat = new SimpleDateFormat("MM");
		date = new java.util.Date();
		int thisMonth = Integer.parseInt(dateFormat.format(date));

		dateFormat = new SimpleDateFormat("dd");
		date = new java.util.Date();
		int thisDay = Integer.parseInt(dateFormat.format(date));

		int age = thisYear - yearDOB;

		if (thisMonth < monthDOB) {
			age = age - 1;
		}

		if (thisMonth == monthDOB && thisDay < dayDOB) {
			age = age - 1;
		}

		return age;
	}

	/**
	 * Converts a date string to Calendar.
	 * 
	 * @param dateString
	 *            in "yyyy-MM-dd HH:mm:ss" format.
	 * @return Calendar object converted from dateString
	 * @see Calendar
	 */
	public static Calendar stringToCalendar(String dateString) {

		try {
			String FORMAT_DATETIME = "yyyy-MM-dd HH:mm:ss";
			SimpleDateFormat sdf = new SimpleDateFormat(FORMAT_DATETIME);
			Date date;
			date = sdf.parse(dateString);
			Calendar cal = Calendar.getInstance();
			cal.setTime(date);

			return cal;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return null;
	}

	/**
	 * Saves the user's login credentials in Shared Preferences.
	 * 
	 * @param email
	 *            User's email id.
	 * @param password
	 *            User's password.
	 * @param context
	 *            Currently active context.
	 * @see SharedPreferences
	 * @see Context
	 */
	public static void storeLoginInfo(String email, String password,
			Context context) {
		PreferenceConnector.writeString(context, "email", email);
		PreferenceConnector.writeString(context, "password", password);
		PreferenceConnector.writeBoolean(context, "isRememberd", true);

	}

	/**
	 * Saves user's information obtained from server in Shared Preferences.
	 * 
	 * @param id
	 *            User ID generated by server.
	 * @param authToken
	 *            User Auth-Token generated from server.
	 * @param userData
	 *            User information obtained from server during login, a valid
	 *            JSON String.
	 * @param context
	 *            Currently active context.
	 * @see SharedPreferences
	 * @see Context
	 */
	public static void storeSession(String id, String authToken,
			String userData, Context context) {
		PreferenceConnector.writeString(context, "id", id);
		PreferenceConnector.writeString(context, "authToken", authToken);
		PreferenceConnector.writeString(context, "userData", userData);
		PreferenceConnector.writeBoolean(context, "isLoggedInKey", true);
	}

	/**
	 * Removes active user's information saved in SharedPreferences
	 * 
	 * @param context
	 *            Currently active Context
	 * @see SharedPreferences
	 * @see Context
	 */
	public static void destroySession(Context context) {
		PreferenceConnector.writeString(context, "id", null);
		PreferenceConnector.writeString(context, "authToken", null);
		PreferenceConnector.writeString(context, "userData", null);
		PreferenceConnector.writeBoolean(context, "isLoggedInKey", false);
	}

	/**
	 * Determines if any user is currently logged in into the application.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return true if logged in, false otherwise.
	 * @see Context
	 */
	public static boolean isLoggedIn(Context context) {
		return PreferenceConnector.readBoolean(context, "isLoggedInKey", false);
	}

	/**
	 * Determines if active user choose to remember login credentials.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return true if choose to remember, false otherwise.
	 * @see Context
	 */
	public static boolean isRememberedLoginInfo(Context context) {
		return PreferenceConnector.readBoolean(context, "isRememberd", false);
	}

	/**
	 * Determines if user already authenticated for beta version.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return true if authenticated, false otherwise.
	 * @see Context
	 */
	public static boolean isBetaAuthenticated(Context context) {
		return PreferenceConnector.readBoolean(context, "isBetaAuth", false);
	}

	/**
	 * Saves beta version authentication status.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param status
	 *            true if authenticated, false otherwise.
	 * @see Context
	 */
	public static void setBetaAuthenticationStatus(Context context,
			boolean status) {
		PreferenceConnector.writeBoolean(context, "isBetaAuth", status);
	}

	/**
	 * Returns the Auth-Token of currently logged in user.
	 * 
	 * @param context
	 *            Currently active Context
	 * @return Auth-Token of the active user.
	 * @see Context
	 */
	public static String getAuthToken(Context context) {
		return PreferenceConnector.readString(context, "authToken", null);
	}

	/**
	 * Returns currently logged in user's information.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return User's information obtained from server as JSON.
	 * @see Context
	 */
	public static String getUserData(Context context) {
		return PreferenceConnector.readString(context, "userData", null);
	}

	/**
	 * Returns currently logged in user's ID.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return User's ID obtained from server.
	 * @see Context
	 */
	public static String getUserId(Context context) {
		return PreferenceConnector.readString(context, "id", null);
	}

	/**
	 * Returns currently logged in user's Email ID.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return User's Email ID used to register and login.
	 * @see Context
	 */
	public static String getEmail(Context context) {
		return PreferenceConnector.readString(context, "email", null);
	}

	/**
	 * Returns currently logged in user's password.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return User's password used to register and login.
	 * @see Context
	 */
	public static String getPassword(Context context) {
		return PreferenceConnector.readString(context, "password", null);
	}

	/**
	 * Saves user's password in Shared Preferences.
	 * 
	 * @param password
	 *            User's password used to register and login.
	 * @param context
	 *            Currently active Context.
	 * @see Context
	 * @see SharedPreferences
	 */
	public static void setPassword(String password, Context context) {
		PreferenceConnector.writeString(context, "password", password);

	}

	/**
	 * Saves user's profile image in Shared Preferences if user logged in
	 * through Facebook
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param avatarString
	 *            User's profile image encoded to Base64
	 * @see SharedPreferences
	 * @see Context
	 * @see Base64
	 */
	public static void setFacebookImage(Context context, String avatarString) {
		PreferenceConnector.writeString(context, "fbavatar", avatarString);
	}

	/**
	 * Returns user's profile image if logged-in through Facebook.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return Base64 encoded user's profile image.
	 * @see Context
	 * @see Base64
	 */
	public static String getFacebookImage(Context context) {
		return PreferenceConnector.readString(context, "fbavatar", null);
	}

	/**
	 * Saves if Facebook invitation dialog for application is already displayed
	 * to user or not in Shared Preferences.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param flag
	 *            true if yes, false otherwise.
	 * @see Context
	 * @see SharedPreferences
	 */
	public static void setFacebookInvitationDisplayStatus(Context context,
			boolean flag) {
		PreferenceConnector
				.writeBoolean(context, "fbinvitedisplaystatus", flag);
	}

	/**
	 * Determines if Facebook invitation dialog for application is already
	 * displayed to user or not.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @return true if yes, false otherwise.
	 * @see Context
	 */
	public static boolean getFacebookInvitationDisplayStatus(Context context) {
		return PreferenceConnector.readBoolean(context,
				"fbinvitedisplaystatus", false);
	}
	
	
	
	
	public static void setFacebookSessionExpireTime(Context context, long time) {
		PreferenceConnector.writeLong(context, "fbSessionExpire", time);
	}


	public static long getFacebookSessionExpireTime(Context context) {
		return PreferenceConnector.readLong(context, "fbSessionExpire", -1);
	}

	/**
	 * Converts an image Uri and returns as Bitmap image.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param uri
	 *            Image Uri.
	 * @param THUMBNAIL_SIZE
	 *            Desired size of the Bitmap image.
	 * @return Bitmap image obtained from Uri.
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @see Uri
	 * @see Bitmap
	 * @see BitmapFactory
	 */
	public static Bitmap getThumbnail(Context context, Uri uri,
			int THUMBNAIL_SIZE) throws FileNotFoundException, IOException {
		InputStream input = context.getContentResolver().openInputStream(uri);

		BitmapFactory.Options onlyBoundsOptions = new BitmapFactory.Options();
		onlyBoundsOptions.inJustDecodeBounds = true;
		onlyBoundsOptions.inDither = true;// optional
		onlyBoundsOptions.inPreferredConfig = Bitmap.Config.ARGB_8888;// optional
		BitmapFactory.decodeStream(input, null, onlyBoundsOptions);
		input.close();
		if ((onlyBoundsOptions.outWidth == -1)
				|| (onlyBoundsOptions.outHeight == -1))
			return null;

		int originalSize = (onlyBoundsOptions.outHeight > onlyBoundsOptions.outWidth) ? onlyBoundsOptions.outHeight
				: onlyBoundsOptions.outWidth;

		double ratio = (originalSize > THUMBNAIL_SIZE) ? (originalSize / THUMBNAIL_SIZE)
				: 1.0;

		BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
		bitmapOptions.inSampleSize = getPowerOfTwoForSampleRatio(ratio);
		bitmapOptions.inDither = true;// optional
		bitmapOptions.inPreferredConfig = Bitmap.Config.ARGB_8888;// optional
		input = context.getContentResolver().openInputStream(uri);
		Bitmap bitmap = BitmapFactory.decodeStream(input, null, bitmapOptions);
		input.close();
		return bitmap;
	}

	private static int getPowerOfTwoForSampleRatio(double ratio) {
		int k = Integer.highestOneBit((int) Math.floor(ratio));
		if (k == 0)
			return 1;
		else
			return k;
	}

	/**
	 * Resizes a Bitmap image to desired size.
	 * 
	 * @param inputBitmap
	 *            Bitmap image that needed to be scaled.
	 * @param width
	 *            Desired new width.
	 * @param height
	 *            Desired new height.
	 * @return Bitmap image sacled with desired height and width.
	 * @see Bitmap
	 */
	public static Bitmap resizeBitmap(Bitmap inputBitmap, int width, int height) {
		if (width == 0) {
			width = Constant.thumbWidth;
		}
		if (height == 0) {
			height = Constant.thumbHeight;
		}

		return Bitmap.createScaledBitmap(inputBitmap, width, height, true);
	}

	/**
	 * Resizes a Bitmap image to desired size.
	 * 
	 * @param inputBitmap
	 *            Bitmap image that needed to be scaled.
	 * @param width
	 *            Desired new width.
	 * @param height
	 *            Desired new height.
	 * @param keepAspectRatio
	 *            true if aspect ratio should be maintained, false otherwise
	 * @return Bitmap image sacled with desired height and width.
	 * @see Bitmap
	 */
	public static Bitmap resizeBitmap(Bitmap inputBitmap, int width,
			int height, boolean keepAspectRatio) {

		int orgHeight = inputBitmap.getHeight();
		int orgWidth = inputBitmap.getWidth();

		if (keepAspectRatio == false) {
			return resizeBitmap(inputBitmap, width, height);
		} else {

			if (height == 0 && width == 0) {
				return null;
			} else if (height == 0) {
				// define new height
				height = (width * orgHeight) / orgWidth;
			} else if (width == 0) {
				// define new width
				width = (height * orgWidth) / orgHeight;
			} else {

			}

			return Bitmap.createScaledBitmap(inputBitmap, width, height, true);
		}

	}

	/**
	 * Returns Bitmap image from a URL.
	 * 
	 * @param url
	 *            URL of the image.
	 * @return Bitmap image from URL
	 * @see Bitmap
	 * @see BitmapFactory
	 */
	public static Bitmap loadBitmapFromURL(String url) {
		Bitmap bm = null;
		InputStream is = null;
		BufferedInputStream bis = null;
		try {
			URLConnection conn = new URL(url).openConnection();
			conn.connect();
			is = conn.getInputStream();
			bis = new BufferedInputStream(is, 8192);
			bm = BitmapFactory.decodeStream(bis);
		} catch (FileNotFoundException e) {

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (bis != null) {
				try {
					bis.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return bm;
	}

	/**
	 * Returns Drawable from a URL.
	 * 
	 * @param url
	 *            URL of the image.
	 * @return Drawable from the URL.
	 * @throws IOException
	 * @see Drawable
	 */
	public static Drawable drawableFromUrl(String url) throws IOException {
		Bitmap x;

		HttpURLConnection connection = (HttpURLConnection) new URL(url)
				.openConnection();
		connection.connect();
		InputStream input = connection.getInputStream();

		x = BitmapFactory.decodeStream(input);
		return new BitmapDrawable(x);
	}

	/**
	 * Concates List of String items and returns as String.
	 * 
	 * @param items
	 *            List of String items
	 * @param conjunction
	 *            Concatenation string between items.
	 * @return String after concatenation.
	 * @see List
	 * @see String
	 */
	public static String joinString(List<String> items, String conjunction) {
		StringBuilder sb = new StringBuilder();
		boolean first = true;
		for (String item : items) {
			if (first)
				first = false;
			else
				sb.append(conjunction);
			sb.append(item);
		}
		return sb.toString();
	}

	/**
	 * Returns a list of IDs of people who are selected in List of People and
	 * Circle.
	 * 
	 * @param selectedCircles
	 *            Selected Circle list
	 * @param selectedFriends
	 *            Selected People list.
	 * @return List of IDs as String.
	 * @see List
	 * @see String
	 * @see People
	 * @see Circle
	 */
	public static List<String> getPeopleListFromFriendsAndCircles(
			HashMap<String, Boolean> selectedCircles,
			HashMap<String, Boolean> selectedFriends) {
		List<String> mergedList = new ArrayList<String>();

		// set invited people value
		Set set = selectedFriends.entrySet();
		Iterator iterator = set.iterator();
		while (iterator.hasNext()) {
			Map.Entry me = (Map.Entry) iterator.next();
			String key = (String) me.getKey();
			boolean isSelected = (Boolean) me.getValue();

			if (isSelected) {
				if (!mergedList.contains(key)) {
					mergedList.add(key);
				}
			}

		}

		List<Circle> circles = StaticValues.myInfo.getCircleList();
		if (circles != null) {
			for (int i = 0; i < circles.size(); i++) {
				String circleId = circles.get(i).getId();
				boolean isChecked = selectedCircles.get(circleId);
				if (isChecked) {

					List<People> friendList = circles.get(i).getFriendList();
					if (friendList != null) {
						for (int j = 0; j < friendList.size(); j++) {
							String friendId = friendList.get(j).getId();
							if (!mergedList.contains(friendId)) {
								mergedList.add(friendId);
							}
						}
					}
				}
			}
		}

		return mergedList;
	}

	/**
	 * Retrieves IDs from HashMap that are set true and returns as a List
	 * 
	 * @param map
	 *            HashMap of IDs with corresponding boolean value.
	 * @return List of IDs as String
	 * @see HashMap
	 * @see List
	 * @see String
	 */
	public static List<String> getListFromHashMap(HashMap<String, Boolean> map) {
		List<String> list = new ArrayList<String>();

		// set invited people value
		Set set = map.entrySet();
		Iterator iterator = set.iterator();
		while (iterator.hasNext()) {
			Map.Entry me = (Map.Entry) iterator.next();
			String key = (String) me.getKey();
			boolean isSelected = (Boolean) me.getValue();

			if (isSelected) {
				if (!list.contains(key)) {
					list.add(key);
				}
			}

		}

		return list;
	}

	/**
	 * Retrieves address for a corresponding Location object.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param location
	 *            Location object.
	 * @param handler
	 *            Handler to fire appropriate event after address retrieved
	 *            successfully.
	 * @see Location
	 * @see Handler
	 * @see Context
	 */
	public static void getAddressFromLocation(final Context context,
			final Location location, final Handler handler) {
		Thread thread = new Thread() {
			@Override
			public void run() {
				Geocoder geocoder = new Geocoder(context, Locale.getDefault());
				String result = null;
				try {
					List<Address> list = geocoder.getFromLocation(
							location.getLatitude(), location.getLongitude(), 1);
					if (list != null && list.size() > 0) {
						Address address = list.get(0);
						// sending back first address line and locality
						result = address.getAddressLine(0) + ", "
								+ address.getLocality();
					}
				} catch (IOException e) {
					Log.e("GEOCODER", "Impossible to connect to Geocoder", e);
				} finally {
					Message msg = Message.obtain();
					msg.setTarget(handler);
					if (result != null) {
						msg.what = 1;
						Bundle bundle = new Bundle();
						bundle.putString("address", result);
						msg.setData(bundle);
					} else
						msg.what = 0;
					msg.sendToTarget();
				}
			}
		};
		thread.start();
	}

	/**
	 * Retrieves address for corresponding Latitude and Longitude.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param lat
	 *            Latitude of the location.
	 * @param lng
	 *            Longitude of the location.
	 * @param handler
	 *            Handler to fire appropriate event after address retrieved
	 *            successfully.
	 * @see Handler
	 * @see Context
	 */
	public static void getAddressFromLocation(final Context context,
			final double lat, final double lng, final Handler handler) {
		Thread thread = new Thread() {
			@Override
			public void run() {
				Geocoder geocoder = new Geocoder(context, Locale.getDefault());
				String result = null;
				try {
					List<Address> list = geocoder.getFromLocation(lat, lng, 1);
					if (list != null && list.size() > 0) {
						Address address = list.get(0);
						// sending back first address line and locality
						result = address.getAddressLine(0) + ", "
								+ address.getLocality();
					}
				} catch (IOException e) {
					Log.e("GEOCODER", "Impossible to connect to Geocoder", e);
				} finally {
					Message msg = Message.obtain();
					msg.setTarget(handler);
					if (result != null) {
						msg.what = 1;
						Bundle bundle = new Bundle();
						bundle.putString("address", result);
						msg.setData(bundle);
					} else
						msg.what = 0;
					msg.sendToTarget();
				}
			}
		};
		thread.start();
	}

	/**
	 * Retrieves address for corresponding Latitude and Longitude using Google
	 * Geo-location service.
	 * 
	 * @param lat
	 *            Latitude of the location.
	 * @param lng
	 *            Longitude of the location.
	 * @param handler
	 *            Handler to fire appropriate event after address retrieved
	 *            successfully.
	 * @see Handler
	 */
	public static void getAddressByCoordinate(final double lat,
			final double lng, final Handler handler) {
		Thread thread = new Thread() {
			@Override
			public void run() {

				String result = null;

				String serverUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat
						+ "," + lng + "&sensor=true";
				
				Log.i("ReverseGeo:url",serverUrl);

				RestClient client = new RestClient(serverUrl);

				try {
					client.Execute(RestClient.RequestMethod.GET);
				} catch (Exception e) {
					e.printStackTrace();
				}

				result = client.getResponse();
				int responseStatus = client.getResponseCode();

				
				Message msg = Message.obtain();
				msg.setTarget(handler);
				if (result != null) {

					Log.i("ReverseGeo:response",result);
					String address = null;
					String name = null;

					try {
						
						
						
						JSONObject jObj = new JSONObject(result);

						if (!jObj.isNull("results")) {
							JSONArray jArray = jObj.getJSONArray("results");
							if (jArray.length() > 0) {
								JSONObject addObj = jArray.getJSONObject(0);
								if (!addObj.isNull("formatted_address")) {
									address = addObj.getString("formatted_address");
								}
							}
						}

						/*if (!jObj.isNull("name")) {
							name = jObj.getString("name");
						}*/

						
						msg.what = 1;
						Bundle bundle = new Bundle();
						if(isValidString(address))
						{
							bundle.putString("address", address.trim());
						}
						else
						{
							bundle.putString("address", "");
						}
						if(isValidString(name))
						{
							bundle.putString("name", name.trim());
						}
						else
						{
							bundle.putString("name", "");
						}
						
						msg.setData(bundle);

					} catch (JSONException e) {
						// TODO Auto-generated catch block
						msg.what = 0;
						e.printStackTrace();
					}

				} else {
					msg.what = 0;
				}

				msg.sendToTarget();
			}
		};

		thread.start();
	}
	/*public static void getAddressByCoordinate(final double lat,
			final double lng, final Handler handler) {
		Thread thread = new Thread() {
			@Override
			public void run() {

				String result = null;

				String serverUrl = "http://www.google.com/maps/geo?q=" + lat
						+ "," + lng + "&output=json";

				RestClient client = new RestClient(serverUrl);

				try {
					client.Execute(RestClient.RequestMethod.POST);
				} catch (Exception e) {
					e.printStackTrace();
				}

				result = client.getResponse();
				int responseStatus = client.getResponseCode();

				Message msg = Message.obtain();
				msg.setTarget(handler);
				if (result != null) {

					String address = null;
					String name = null;

					try {
						JSONObject jObj = new JSONObject(result);

						if (!jObj.isNull("Placemark")) {
							JSONArray jArray = jObj.getJSONArray("Placemark");
							if (jArray.length() > 0) {
								JSONObject addObj = jArray.getJSONObject(0);
								if (!addObj.isNull("address")) {
									address = addObj.getString("address");
								}
							}
						}

						if (!jObj.isNull("name")) {
							name = jObj.getString("name");
						}

						
						msg.what = 1;
						Bundle bundle = new Bundle();
						if(isValidString(address))
						{
							bundle.putString("address", address.trim());
						}
						else
						{
							bundle.putString("address", "");
						}
						if(isValidString(name))
						{
							bundle.putString("name", name.trim());
						}
						else
						{
							bundle.putString("name", "");
						}
						
						msg.setData(bundle);

					} catch (JSONException e) {
						// TODO Auto-generated catch block
						msg.what = 0;
						e.printStackTrace();
					}

				} else {
					msg.what = 0;
				}

				msg.sendToTarget();
			}
		};

		thread.start();
	}*/

	/**
	 * Forcefully hide the soft keyboard if opened.
	 * 
	 * @param context
	 *            Currently active Context
	 * @see Context
	 */
	public static void hideKeyboardContext(Context context) {

		try {
			InputMethodManager inputManager = (InputMethodManager) context
					.getSystemService(Context.INPUT_METHOD_SERVICE);
			inputManager.hideSoftInputFromWindow(((Activity) context)
					.getCurrentFocus().getWindowToken(),
					InputMethodManager.HIDE_NOT_ALWAYS);
		} catch (Exception e) {
			// TODO: handle exception
			Log.e("hideKeyboardContext", e.toString());
		}

	}

	/**
	 * Forcefully hide the soft keyboard if opened.
	 * 
	 * @param activity
	 *            Activity on which keyboard is opened.
	 * @see Activity
	 */
	public static void hideKeyboard(Activity activity) {
		try {
			activity.getWindow().setSoftInputMode(
					WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		} catch (Exception e) {
			// TODO: handle exception
			Log.e("hideKeyboard", e.toString());
		}

	}

	/**
	 * Removes all children from a view.
	 * 
	 * @param view
	 *            Parent view.
	 * @see View
	 */
	public static void removeAllChildrenFromView(View view) {
		if (view.getBackground() != null) {
			view.getBackground().setCallback(null);
		}
		if (view instanceof ViewGroup) {
			for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
				removeAllChildrenFromView(((ViewGroup) view).getChildAt(i));
			}
			((ViewGroup) view).removeAllViews();
		}
	}

	/**
	 * Returns the number of messages for a corresponding status.
	 * 
	 * @param messageList
	 *            List of MessageEntity.
	 * @param status
	 *            Message status for counting. Status options are "read" and
	 *            "unread".
	 * @return Number of messages for corresponding status.
	 * @see MessageEntity
	 */
	public static int getMessageCount(List<MessageEntity> messageList,
			String status) {
		int count = 0;

		if (status == null) {
			return messageList.size();
		} else {
			for (int i = 0; i < messageList.size(); i++) {
				if (messageList.get(i).getStatus() != null) {
					if (messageList.get(i).getStatus().equalsIgnoreCase(status)) {
						count++;
					}
				}
			}
			return count;
		}
	}

	/**
	 * Generates a List of Circle IDs for a specific People.
	 * 
	 * @param peopleId
	 *            ID of the people.
	 * @param circles
	 *            List of circles to check.
	 * @return List of IDs of Circle as String if the people is associated with
	 *         the Circle.
	 * @see List
	 */
	public static List<String> getCircleIdsForPeople(String peopleId,
			List<Circle> circles) {
		List<String> circleIds = new ArrayList<String>();

		for (Circle circle : circles) {
			List<People> peoples = circle.getFriendList();
			for (People people : peoples) {
				if (peopleId.equals(people.getId())) {
					circleIds.add(circle.getId());
					break;
				}
			}
		}

		return circleIds;
	}

	/**
	 * Returns the People object for a corresponding people id.
	 * 
	 * @param peopleId
	 *            Id of the people.
	 * @return People object, or null if not found.
	 * @see People
	 */
	public static People getPeopleById(String peopleId) {

		if (StaticValues.myInfo != null) {
			List<People> friendList = StaticValues.myInfo.getFriendList();
			for (People peopleItem : friendList) {
				if (peopleItem.getId().equals(peopleId)) {
					return peopleItem;
				}
			}
		}

		return null;
	}

	/**
	 * Returns the People object for a corresponding people id from a List of
	 * People.
	 * 
	 * @param peopleId
	 *            Id of the People.
	 * @param peopleList
	 *            List of People from which People object should be retrieved.
	 * @return People object, or null if not found in the List
	 * @see List
	 * @see People
	 */
	public static People getPeopleById(String peopleId, List<People> peopleList) {

		if (peopleList != null) {
			for (int i = 0; i < peopleList.size(); i++) {
				People people = peopleList.get(i);
				if (people.getId().equals(peopleId)) {
					return people;
				}
			}
		}

		return null;
	}

	/**
	 * Determines a String contains any character or not.
	 * 
	 * @param value
	 *            String which needs to be validated.
	 * @return true if it contains at least one character, false otherwise.
	 * @see String
	 */
	public static boolean isValidString(String value) {
		if (value != null)
			if (!value.equals(""))
				return true;
		return false;
	}

	/**
	 * Calculate distance between two GeoPoints.
	 * 
	 * @param p1
	 *            Source LatLng
	 * @param p2
	 *            Destination LatLng
	 * @return Distance in meter
	 * @see LatLng
	 */
//	public static double calculateDistance(LatLng p1, LatLng p2) {
//		double lat1 = p1.latitude;
//		double lng1 = p1.longitude;
//		double lat2 = p2.latitude;
//		double lng2 = p2.longitude;
//
//		return calculateDistance(lat1, lng1, lat2, lng2);
//	}

	public static double calculateDistance(LatLng p1, LatLng p2) {
		double lat1 = p1.latitude;
		double lng1 = p1.longitude;
		double lat2 = p2.latitude;
		double lng2 = p2.longitude;

		return calculateDistance(lat1, lng1, lat2, lng2);
	}

	/**
	 * calculate distance between two locations.
	 * 
	 * @param sourceLat
	 *            Latitude of the source
	 * @param sourceLng
	 *            Longitude of the source
	 * @param destLat
	 *            Latitude of the destination
	 * @param destLng
	 *            Longitude of the destination
	 * @return Distance in meter
	 */
	public static double calculateDistance(double sourceLat, double sourceLng,
			double destLat, double destLng) {
		float[] dist = new float[1];
		Location.distanceBetween(sourceLat, sourceLng, destLat, destLng, dist);
		return dist[0];
	}

	/**
	 * Updates the notification number of activities obtained from GCM.
	 * 
	 * @param pushData
	 *            PushData containing notification number
	 * @see PushData
	 */
	public static void updateNotificationCountFromPush(PushData pushData) {
		if (pushData != null) {
			if (StaticValues.myInfo != null) {
				StaticValues.myInfo.getNotificationCount().setTotalCount(
						pushData.getBadge());
				String tabCounts = pushData.getTabCounts().trim();

				Log.i("tabCounts on parser", tabCounts);

				if (!tabCounts.equals("")) {

					String[] tabCountsArray = tabCounts.split("[|]");

					if (tabCountsArray.length == 3) {
						Log.i("if tabCountsArray.length", tabCountsArray.length
								+ "");
						StaticValues.myInfo.getNotificationCount()
								.setMessageCount(
										Integer.parseInt(tabCountsArray[0]));

						Log.i("messageCount", tabCountsArray[0]);

						StaticValues.myInfo.getNotificationCount()
								.setFriendRequestCount(
										Integer.parseInt(tabCountsArray[1]));
						StaticValues.myInfo.getNotificationCount()
								.setNotificationCount(
										Integer.parseInt(tabCountsArray[2]));
					} else {
						Log.i("else tabCountsArray.length",
								tabCountsArray.length + "");
					}
				}
			}
		}
	}

	/**
	 * Updates the notification number of bubble counter placed at the top of
	 * activity.
	 * 
	 * @param btnNotification
	 *            Bubble view that contains the notification number.
	 */
	public static void updateNotificationBubbleCounter(Button btnNotification) {
		// TODO Auto-generated method stub
		if (StaticValues.myInfo != null && btnNotification != null) {

			if (StaticValues.myInfo.getNotificationCount().getTotalCount() >= 0)

				btnNotification.setText(""
						+ StaticValues.myInfo.getNotificationCount()
								.getTotalCount());
		}
	}

	/**
	 * Returns the Bitmap image for corresponding image Uri. Basically used for
	 * sampling an image to save memory.
	 * 
	 * @param selectedImage
	 *            Uri of the image.
	 * @param contentResolver
	 *            Corresponding ContentResolver
	 * @return Bitmap image from the Uri, or null if not found.
	 * @see Uri
	 * @see Bitmap
	 * @see BitmapFactory
	 * @see ContentResolver
	 * @throws FileNotFoundException
	 */
	public static Bitmap decodeUri(Uri selectedImage,
			ContentResolver contentResolver) throws FileNotFoundException {

		// Decode image size
		BitmapFactory.Options o = new BitmapFactory.Options();
		o.inJustDecodeBounds = true;
		BitmapFactory.decodeStream(
				contentResolver.openInputStream(selectedImage), null, o);

		// The new size we want to scale to
		final int REQUIRED_SIZE = 160;

		// Find the correct scale value. It should be the power of 2.
		int width_tmp = o.outWidth, height_tmp = o.outHeight;
		int scale = 1;
		while (true) {
			if (width_tmp / 2 < REQUIRED_SIZE || height_tmp / 2 < REQUIRED_SIZE) {
				break;
			}
			width_tmp /= 2;
			height_tmp /= 2;
			scale *= 2;
		}

		// Decode with inSampleSize
		BitmapFactory.Options o2 = new BitmapFactory.Options();
		o2.inSampleSize = scale;
		return BitmapFactory.decodeStream(
				contentResolver.openInputStream(selectedImage), null, o2);

	}

	public static Bitmap generateMarker(LinearLayout markerLayout, Object item,
			ImageFetcher imageFetcher, ImageDownloadListener imageDownloadListener) {

		Bitmap bitmap;

		try {
			// we need to enable the drawing cache
			markerLayout.setDrawingCacheEnabled(true);

			ImageView avatar = (ImageView) markerLayout
					.findViewById(R.id.avatar);
			ImageView ivOnline = (ImageView) markerLayout
					.findViewById(R.id.ivOnline);

			String avatarUrl = null;
			ivOnline.setVisibility(View.GONE);

			if (item instanceof People) {

				People user = (People) item;
				avatarUrl = user.getAvatar();

				ivOnline.setVisibility(View.VISIBLE);
				if (user.isOnline()) {
					ivOnline.setImageResource(R.drawable.online);
				} else {
					ivOnline.setImageResource(R.drawable.offline);
				}

			} else if (item instanceof Place) {

				Place place = (Place) item;

				avatarUrl = place.getIconUrl();

			} else if (item instanceof SecondDegreePeople) {

				SecondDegreePeople user = (SecondDegreePeople) item;

				avatarUrl = user.getAvatar();

			} else if (item instanceof Event) {
				avatar.setImageResource(R.drawable.icon_event);

			} else if (item instanceof GeoTag) {

				avatar.setImageResource(R.drawable.icon);
			}

			if (isValidString(avatarUrl)) {
				Log.i("Utility:generateMarker", "Attempt 1: "+avatarUrl);
				imageFetcher.loadImage(avatarUrl, avatar,imageDownloadListener, Utility.getItemId(item));
			}


			// this is the important code
			// Without it the view will have a dimension of 0,0 and the bitmap
			// will be null
			markerLayout.measure(
					MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
					MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED));
			markerLayout.layout(0, 0, markerLayout.getMeasuredWidth(),
					markerLayout.getMeasuredHeight());

			// we need to build our drawing cache
			markerLayout.buildDrawingCache(true);

			// not null? then we are ready to capture our bitmap image
			if (markerLayout.getDrawingCache() != null) {

				bitmap = Bitmap.createBitmap(markerLayout.getDrawingCache());
				if (bitmap != null) {
					markerLayout.setDrawingCacheEnabled(false);
					return bitmap;
				}

			} else {
				Log.e("CustomMapMarkers",
						"Item * generateMarker *** getDrawingCache is null");
			}

		}

		catch (OutOfMemoryError e) {
			Log.i("generateMarker", "OutOfMemory");
		} catch (Exception e) {
			// TODO: handle exception
		}
		return null;
	}
	
	public static Bitmap generateMarker(LinearLayout markerLayout, Object item, Drawable profilePic) {

		Bitmap bitmap;

		try {
			// we need to enable the drawing cache
			markerLayout.setDrawingCacheEnabled(true);

			ImageView avatar = (ImageView) markerLayout
					.findViewById(R.id.avatar);
			ImageView ivOnline = (ImageView) markerLayout
					.findViewById(R.id.ivOnline);

			String avatarUrl = null;
			ivOnline.setVisibility(View.GONE);

			if (item instanceof People) {

				People user = (People) item;
				avatarUrl = user.getAvatar();

				ivOnline.setVisibility(View.VISIBLE);
				if (user.isOnline()) {
					ivOnline.setImageResource(R.drawable.online);
				} else {
					ivOnline.setImageResource(R.drawable.offline);
				}

			} else if (item instanceof Place) {

				Place place = (Place) item;

				avatarUrl = place.getIconUrl();

			} else if (item instanceof SecondDegreePeople) {

				SecondDegreePeople user = (SecondDegreePeople) item;

				avatarUrl = user.getAvatar();

			} else if (item instanceof Event) {
				avatar.setImageResource(R.drawable.icon_event);

			} else if (item instanceof GeoTag) {

				avatar.setImageResource(R.drawable.icon);
			}

			if (isValidString(avatarUrl)) {
				avatar.setImageDrawable(profilePic);
			}


			// this is the important code
			// Without it the view will have a dimension of 0,0 and the bitmap
			// will be null
			markerLayout.measure(
					MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
					MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED));
			markerLayout.layout(0, 0, markerLayout.getMeasuredWidth(),
					markerLayout.getMeasuredHeight());

			// we need to build our drawing cache
			markerLayout.buildDrawingCache(true);

			// not null? then we are ready to capture our bitmap image
			if (markerLayout.getDrawingCache() != null) {

				bitmap = Bitmap.createBitmap(markerLayout.getDrawingCache());
				if (bitmap != null) {
					markerLayout.setDrawingCacheEnabled(false);
					return bitmap;
				}

			} else {
				Log.e("CustomMapMarkers",
						"Item * generateMarker *** getDrawingCache is null");
			}

		}

		catch (OutOfMemoryError e) {
			Log.i("generateMarker", "OutOfMemory");
		} catch (Exception e) {
			// TODO: handle exception
		}
		return null;
	}

	public static Drawable generateMarker(String value, LinearLayout markerLayout) {

		Bitmap viewCapture = null;
		Drawable drawOverlay = null;

		// we need to enable the drawing cache
		markerLayout.setDrawingCacheEnabled(true);

		// this is the important code
		// Without it the view will have a dimension of 0,0 and the bitmap
		// will be null
		markerLayout.measure(
				MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
				MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED));
		markerLayout.layout(0, 0, markerLayout.getMeasuredWidth(),
				markerLayout.getMeasuredHeight());

		// we need to build our drawing cache
		markerLayout.buildDrawingCache(true);

		/*
		 * try { Thread.sleep(50); } catch (InterruptedException e) { // TODO
		 * Auto-generated catch block e.printStackTrace(); }
		 */

		// not null? then we are ready to capture our bitmap image
		if (markerLayout.getDrawingCache() != null) {
			viewCapture = Bitmap.createBitmap(markerLayout.getDrawingCache());

			// if the view capture is not null we should turn off the
			// drawing cache
			// and then create our marker drawable with the view capture
			if (viewCapture != null) {
				markerLayout.setDrawingCacheEnabled(false);
				drawOverlay = new BitmapDrawable(viewCapture);
				return drawOverlay;
			}
		} else {
			Log.d("CustomMapMarkers",
					"Item * generateMarker *** getDrawingCache is null");
		}

		return null;
	}

	public static boolean isLocationVisibleOnMap(GoogleMap mapView,
			LatLng markerPoint) {

		LatLngBounds bounds = mapView.getProjection().getVisibleRegion().latLngBounds;

		if (bounds.contains(markerPoint)) {
			return true;
		}

		return false;

	}

	public static Pair<Pair<Double, Double>, Pair<Double, Double>> getMapCorners(
			MapView mapView) {
		GeoPoint center = mapView.getMapCenter();
		int latitudeSpan = mapView.getLatitudeSpan();
		int longtitudeSpan = mapView.getLongitudeSpan();

		double topRightLat = (center.getLatitudeE6() + (latitudeSpan / 2.0d)) / 1.0E6;
		double topRightLon = (center.getLongitudeE6() + (longtitudeSpan / 2.0d)) / 1.0E6;

		double bottomLeftLat = (center.getLatitudeE6() - (latitudeSpan / 2.0d)) / 1.0E6;
		double bottomLeftLon = (center.getLongitudeE6() - (longtitudeSpan / 2.0d)) / 1.0E6;

		return new Pair<Pair<Double, Double>, Pair<Double, Double>>(
				new Pair<Double, Double>(topRightLat, topRightLon),
				new Pair<Double, Double>(bottomLeftLat, bottomLeftLon));
	}

	public static Pair<GeoPoint, GeoPoint> getMapCornerPoints(MapView mapView) {
		GeoPoint topLeft = mapView.getProjection().fromPixels(
				mapView.getLeft(), mapView.getTop());
		GeoPoint bottomRight = mapView.getProjection().fromPixels(
				mapView.getRight(), mapView.getBottom());

		return new Pair<GeoPoint, GeoPoint>(topLeft, bottomRight);
	}

	public static LatLng getLatLngFromObject(Object item) {
		LatLng latLng = null;
		if (item instanceof People) {

			People user = (People) item;

			latLng = new LatLng(user.getCurrentLat(), user.getCurrentLng());
		} else if (item instanceof Place) {

			Place place = (Place) item;

			latLng = new LatLng(place.getLatitude(), place.getLongitude());

		} else if (item instanceof SecondDegreePeople) {

			SecondDegreePeople user = (SecondDegreePeople) item;

			latLng = new LatLng(user.getCurrentLat(), user.getCurrentLng());

		} else if (item instanceof Event) {
			Event event = (Event) item;
			latLng = new LatLng(event.getLatitude(), event.getLongitude());

		} else if (item instanceof GeoTag) {

			GeoTag geoTag = (GeoTag) item;

			latLng = new LatLng(geoTag.getLatitude(), geoTag.getLongitude());
		}else if (item instanceof Plan) {

			Plan plan = (Plan) item;

			latLng = new LatLng(plan.getLatitude(), plan.getLatitude());
		}

		return latLng;
	}

	
	public static boolean isFacebookSessionValid(Context context)
	{
		if(StaticValues.myInfo.getRegMedia().equals(Constant.sourceFacebook))
		{
			long expireTime = Utility.getFacebookSessionExpireTime(context);
			if(expireTime > Utility.getUnixTimestamp())
			{
				//session expired, auto sign-out
				return true;
			}
		}
		
		
		return false;
	}
}
