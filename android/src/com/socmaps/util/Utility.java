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
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;

import com.google.android.maps.GeoPoint;
import com.socmaps.entity.Circle;
import com.socmaps.entity.Event;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.MessageEntity;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.PushData;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.entity.TimeEntity;

public class Utility {

	private static final double metricDivisor = 1000;
	private static final double imperialDivisor = 1760;

	public static String getFieldText(Object item) {
		if (item instanceof People) {

			People temp = ((People) item);
			String name = "";

			if (temp.getFirstName() != null) {
				name = temp.getFirstName();
			}

			if (temp.getLastName() != null) {
				name += " " + temp.getLastName();
			}
			return name.trim().toLowerCase();
		} else if (item instanceof SecondDegreePeople) {

			SecondDegreePeople temp = (SecondDegreePeople) item;
			String name = "";

			if (temp.getFirstName() != null) {
				name = temp.getFirstName();
			}

			if (temp.getLastName() != null) {
				name += " " + temp.getLastName();
			}
			return name.trim().toLowerCase();
		} else if (item instanceof Place) {
			Place temp = ((Place) item);
			return temp.getName().toString().toLowerCase();
		} else if (item instanceof Event) {
			Event temp = ((Event) item);
			return temp.getEventTitle().toString().toLowerCase();
		} else if (item instanceof GeoTag) {
			GeoTag temp = ((GeoTag) item);
			return temp.getTitle().toString().toLowerCase();
		} else if (item instanceof String)
			return item.toString();
		else
			return "";
	}

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
				final String valueText = getFieldText(value);

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
	
	

	public static String getFormatedDistance(double distance, String unit) {
		String result = "";

		if (unit.equalsIgnoreCase(Constant.UNIT_IMPERIAL)) {

			distance = toYard(distance);
			if (distance >= imperialDivisor)
				result = String.format("%.2f", distance / imperialDivisor)
						+ "miles";
			else
				// result=String.format("%.2f", distance)+"yards";
				result = (int) distance + "yd";

		} else {
			if (distance >= metricDivisor)
				result = String.format("%.2f", distance / metricDivisor) + "km";
			else
				// result=String.format("%.2f", distance)+"m";
				result = (int) distance + "m";
		}

		return result;
	}

	private static double toYard(double distance) {

		return distance * 1.09361;
	}

	public static Date getLocalTimeFromUTC(TimeEntity te) {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat(
				"yyyy-MM-dd HH:mm:ss");
		// simpleDateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
		simpleDateFormat.setTimeZone(TimeZone.getTimeZone(te.getTimeZone()));
		try {
			return simpleDateFormat.parse(te.getDateTimeValue());
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	public static String getFormattedDisplayDateEventList(TimeEntity te) {
		Date targetDate = getLocalTimeFromUTC(te);
		return eventListTimeFormater.format(targetDate);
	}

	public static Date getCurrentDate() {
		Calendar c = Calendar.getInstance();
		return c.getTime();
	}

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

	public static String getFormattedDisplayDate(TimeEntity te) {

		Date targetDate = getLocalTimeFromUTC(te);
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

	public static String getFormattedDisplayDateForMap(TimeEntity te) {

		Date targetDate = getLocalTimeFromUTC(te);
		Date now = getCurrentDate();

		Log.e("targetdate in local format", targetDate.toString());
		Log.e("current in local format", now.toString());

		if (today(targetDate, now)) {
			return "at " + todayTimeFormater.format(targetDate);
		} /*
		 * else if (dateIsOlderThan7Days(targetDate, now)) { return
		 * "on "+withinSevenDaysTimeFormater.format(targetDate); }
		 */else {
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

	public static String getFormatedDistance(double distance) {
		return String.format("%.2f", distance);
	}

	public static String parseResponseString(String responseString) {
		try {
			JSONObject jo = new JSONObject(responseString);
			return jo.getString(Constant.responseKey);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		// return null;
	}

	public static boolean isConnectionAvailble(Context ctx) {
		ConnectivityManager cm = (ConnectivityManager) ctx
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnectedOrConnecting()) {
			return true;
		}
		return false;
	}

	public static boolean isServiceRunning(String serviceClassName,
			Context context) {
		final ActivityManager activityManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		final List<RunningServiceInfo> services = activityManager
				.getRunningServices(Integer.MAX_VALUE);

		for (RunningServiceInfo runningServiceInfo : services) {
			if (runningServiceInfo.service.getClassName().equals(
					serviceClassName)) {
				return true;
			}
		}
		return false;
	}

	public static String MD5_Hash(String s) {
		try {
			// Create MD5 Hash
			MessageDigest digest = java.security.MessageDigest
					.getInstance("MD5");
			digest.update(s.getBytes());
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

	public static boolean isValidEmailID(String email) {

		if (email == null || email.trim().equals("")) {
			return false;
		}

		Pattern pattern;
		Matcher matcher;
		String EMAIL_PATTERN = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$"; 
//		String EMAIL_PATTERN = 
//				"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
//						+ "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
		pattern = Pattern.compile(EMAIL_PATTERN);
		matcher = pattern.matcher(email);
		return matcher.matches();

	}

	public static String getdate() {
		SimpleDateFormat sdfDateTime = new SimpleDateFormat(
				"yyyy-MM-dd HH:mm:ss", Locale.US);
		String newtime = sdfDateTime
				.format(new Date(System.currentTimeMillis()));
		return newtime;
		// return "2012-01-04 11:49:32";
	}

	public static long getUnixTimestamp() {
		long unixTime = System.currentTimeMillis() / 1000L;

		return unixTime;
	}

	public static String getdate(String format) {
		// "yyyy-MM-dd" = "2012-07-30"
		SimpleDateFormat sdfDateTime = new SimpleDateFormat(format, Locale.US);
		String newtime = sdfDateTime
				.format(new Date(System.currentTimeMillis()));
		return newtime;
		// return "2012-01-04 11:49:32";
	}

	public static String parseFbDob(String fbdob) {

		String[] dobArray = fbdob.split("/");

		String dobFormatted = dobArray[2] + "-" + dobArray[0] + "-"
				+ dobArray[1];

		return dobFormatted;
	}

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

	public static int calculateAge(String dob) {
		// String dob = "1984-09-20";

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

	public static Calendar stringToCalendar(String strDate) {

		try {
			String FORMAT_DATETIME = "yyyy-MM-dd HH:mm:ss";
			SimpleDateFormat sdf = new SimpleDateFormat(FORMAT_DATETIME);
			Date date;
			date = sdf.parse(strDate);
			Calendar cal = Calendar.getInstance();
			cal.setTime(date);

			return cal;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return null;
	}

	public static void storePreferences(String email, String password,
			boolean isLoggedInKey, Context context) {
		PreferenceConnector.writeString(context, "email", email);
		PreferenceConnector.writeString(context, "password", password);
		PreferenceConnector.writeBoolean(context, "isLoggedInKey",
				isLoggedInKey);
	}

	public static void storeSession(String id, String authToken, Context context) {
		PreferenceConnector.writeString(context, "id", id);
		PreferenceConnector.writeString(context, "authToken", authToken);
	}

	public static boolean isLoggedIn(Context context) {
		return PreferenceConnector.readBoolean(context, "isLoggedInKey", false);
	}

	public static boolean isBetaAuthenticated(Context context) {
		return PreferenceConnector.readBoolean(context, "isBetaAuth", false);
	}

	public static void setBetaAuthenticationStatus(Context context,
			boolean status) {
		PreferenceConnector.writeBoolean(context, "isBetaAuth", status);
	}

	public static String getAuthToken(Context context) {
		return PreferenceConnector.readString(context, "authToken", null);
	}

	public static String getUserId(Context context) {
		return PreferenceConnector.readString(context, "id", null);
	}

	public static String getEmail(Context context) {
		return PreferenceConnector.readString(context, "email", null);
	}

	public static String getPassword(Context context) {
		return PreferenceConnector.readString(context, "password", null);
	}

	public static void setPassword(String password, Context context) {
		PreferenceConnector.writeString(context, "password", password);

	}

	public static void setFacebookImage(Context context, String avatarString) {
		PreferenceConnector.writeString(context, "fbavatar", avatarString);
	}

	public static String getFacebookImage(Context context) {
		return PreferenceConnector.readString(context, "fbavatar", null);
	}

	public static void setFacebookInvitationDisplayStatus(Context context,
			boolean flag) {
		PreferenceConnector
				.writeBoolean(context, "fbinvitedisplaystatus", flag);
	}

	public static boolean getFacebookInvitationDisplayStatus(Context context) {
		return PreferenceConnector.readBoolean(context,
				"fbinvitedisplaystatus", false);
	}

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

	/*
	 * public static Bitmap resizeBitmap(Bitmap inputBitmap, int width, int
	 * height) { Bitmap scaledBitmap;
	 * 
	 * int orgWidth = inputBitmap.getWidth(); int orgHeight =
	 * inputBitmap.getHeight();
	 * 
	 * int newWidth = width; int newHeight = height;
	 * 
	 * if (width <= orgWidth || height <= orgHeight) { newHeight = orgHeight;
	 * newWidth = orgWidth; } else if (width > 0 && height > 0) { newHeight =
	 * height; newWidth = width; } else if (height == 0) { // fixed width,
	 * height should be variable newWidth = width; newHeight = (int) ((orgHeight
	 * / orgWidth) * newWidth);
	 * 
	 * } else if (width == 0) { // fixed height, width should be variable
	 * newHeight = height; newWidth = (int) ((orgWidth / orgHeight) *
	 * newHeight); }
	 * 
	 * scaledBitmap = Bitmap.createScaledBitmap(inputBitmap, newWidth,
	 * newHeight, false);
	 * 
	 * return scaledBitmap; }
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
	
	public static Bitmap resizeBitmap(Bitmap inputBitmap, int width, int height, boolean keepAspectRatio) {
		
		int orgHeight = inputBitmap.getHeight();
		int orgWidth = inputBitmap.getWidth();
		
		if(keepAspectRatio == false)
		{
			return resizeBitmap(inputBitmap, width, height);
		}
		else
		{
			
			if(height == 0 && width == 0)
			{
				return null;
			}
			else if(height == 0)
			{
				//define new height
				height = (width*orgHeight)/orgWidth;
			}
			else if(width == 0)
			{
				//define new width
				width = (height*orgWidth)/orgHeight;
			}
			else
			{
				
			}
			
			

			return Bitmap.createScaledBitmap(inputBitmap, width, height, true);
		}
		
	}

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

	public static Drawable drawableFromUrl(String url) throws IOException {
		Bitmap x;

		HttpURLConnection connection = (HttpURLConnection) new URL(url)
				.openConnection();
		connection.connect();
		InputStream input = connection.getInputStream();

		x = BitmapFactory.decodeStream(input);
		return new BitmapDrawable(x);
	}

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
					// Log.e("IsCheckedCircle", circleId);

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

	public static void getAddressByCoordinate(final double lat,
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

					// Log.e("Address response", result);

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
						bundle.putString("address", address.trim());
						bundle.putString("name", name.trim());
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

	public static void hideKeyboardContext(Context con) {

		try {
			InputMethodManager inputManager = (InputMethodManager) con
					.getSystemService(Context.INPUT_METHOD_SERVICE);
			inputManager.hideSoftInputFromWindow(((Activity) con)
					.getCurrentFocus().getWindowToken(),
					InputMethodManager.HIDE_NOT_ALWAYS);
		} catch (Exception e) {
			// TODO: handle exception
			Log.e("hideKeyboardContext", e.toString());
		}

	}

	public static void hideKeyboard(Activity activity) {
		try {
			activity.getWindow().setSoftInputMode(
					WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		} catch (Exception e) {
			// TODO: handle exception
			Log.e("hideKeyboard", e.toString());
		}

	}

	public static void unbindDrawables(View view) {
		if (view.getBackground() != null) {
			view.getBackground().setCallback(null);
		}
		if (view instanceof ViewGroup) {
			for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
				unbindDrawables(((ViewGroup) view).getChildAt(i));
			}
			((ViewGroup) view).removeAllViews();
		}
	}

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

	public static People getPeopleById(String peopleId) {

		List<People> friendList = StaticValues.myInfo.getFriendList();
		for (People peopleItem : friendList) {
			if (peopleItem.getId().equals(peopleId)) {
				return peopleItem;
			}
		}

		return null;
	}
	
	public static boolean isValidString(String value) {
		if (value != null)
			if (!value.equals(""))
				return true;
		return false;
	}
	
	public static double calculateDistance(GeoPoint p1, GeoPoint p2) {
	    double lat1 = ((double)p1.getLatitudeE6()) / 1e6;
	    double lng1 = ((double)p1.getLongitudeE6()) / 1e6;
	    double lat2 = ((double)p2.getLatitudeE6()) / 1e6;
	    double lng2 = ((double)p2.getLongitudeE6()) / 1e6;
	    
	    return calculateDistance(lat1, lng1, lat2, lng2);
	}
	
	public static double calculateDistance(double sourceLat, double sourceLng, double destLat, double destLng) {
	    float [] dist = new float[1];
	    Location.distanceBetween(sourceLat, sourceLng, destLat, destLng, dist);
	    return (double)dist[0];
	}
	
	public static void updateNotificationCountFromPush(PushData pushData)
	{
		if(pushData!=null)
		{
			if(StaticValues.myInfo!=null)
			{
				StaticValues.myInfo.getNotificationCount().setTotalCount(pushData.getBadge());
				String tabCounts = pushData.getTabCounts();
				if(!tabCounts.equals(""))
				{
					String[] tabCountsArray = tabCounts.split("|");
					if(tabCountsArray.length == 3)
					{
						StaticValues.myInfo.getNotificationCount().setMessageCount(Integer.parseInt(tabCountsArray[0]));
						StaticValues.myInfo.getNotificationCount().setFriendRequestCount(Integer.parseInt(tabCountsArray[1]));
						StaticValues.myInfo.getNotificationCount().setNotificationCount(Integer.parseInt(tabCountsArray[2]));
					}
				}
			}
		}
	}

}
