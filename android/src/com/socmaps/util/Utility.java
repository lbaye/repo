package com.socmaps.util;

import java.io.BufferedInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningServiceInfo;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.text.format.DateFormat;

public class Utility {
	
	
	public static String parseResponseString(String responseString)
	{
		try {
			JSONObject jo=new JSONObject(responseString);
			return jo.getString(Constant.responseKey);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		//return null;
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
		String EMAIL_PATTERN = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
		pattern = Pattern.compile(EMAIL_PATTERN);
		matcher = pattern.matcher(email);
		return matcher.matches();

	}

	public static String getdate() {
		SimpleDateFormat sdfDateTime = new SimpleDateFormat(
				"yyyy-MM-dd hh:mm:ss", Locale.US);
		String newtime = sdfDateTime
				.format(new Date(System.currentTimeMillis()));
		return newtime;
		// return "2012-01-04 11:49:32";
	}

	public static String getdate(String format) {
		// "yyyy-MM-dd" = "2012-07-30"
		SimpleDateFormat sdfDateTime = new SimpleDateFormat(format, Locale.US);
		String newtime = sdfDateTime
				.format(new Date(System.currentTimeMillis()));
		return newtime;
		// return "2012-01-04 11:49:32";
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

	public static String getAuthToken(Context context) {
		return PreferenceConnector.readString(context, "authToken", null);
	}

	
	public static String getEmail(Context context) {
		return PreferenceConnector.readString(context, "email", null);
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

	public static Bitmap resizeBitmap(Bitmap inputBitmap, int width, int height) {
		Bitmap scaledBitmap;

		int orgWidth = inputBitmap.getWidth();
		int orgHeight = inputBitmap.getHeight();

		int newWidth = width;
		int newHeight = height;
		
		if(width <= orgWidth || height <= orgHeight )
		{
			newHeight = orgHeight;
			newWidth = orgWidth;
		}
		else if (width > 0 && height > 0) {
			newHeight = height;
			newWidth = width;
		}
		else if (height == 0) {
			// fixed width, height should be variable
			newWidth = width;
			newHeight = (int) ((orgHeight / orgWidth) * newWidth);

		} else if (width == 0) {
			// fixed height, width should be variable
			newHeight = height;
			newWidth = (int) ((orgWidth / orgHeight) * newHeight);
		}
		

		scaledBitmap = Bitmap.createScaledBitmap(inputBitmap, newWidth,
				newHeight, false);

		return scaledBitmap;
	}
	
	
	public static Bitmap loadBitmapFromURL(String url)
	{
	    Bitmap bm = null;
	    InputStream is = null;
	    BufferedInputStream bis = null;
	    try 
	    {
	        URLConnection conn = new URL(url).openConnection();
	        conn.connect();
	        is = conn.getInputStream();
	        bis = new BufferedInputStream(is, 8192);
	        bm = BitmapFactory.decodeStream(bis);
	    }
	    catch (Exception e) 
	    {
	        e.printStackTrace();
	    }
	    finally {
	        if (bis != null) 
	        {
	            try 
	            {
	                bis.close();
	            }
	            catch (IOException e) 
	            {
	                e.printStackTrace();
	            }
	        }
	        if (is != null) 
	        {
	            try 
	            {
	                is.close();
	            }
	            catch (IOException e) 
	            {
	                e.printStackTrace();
	            }
	        }
	    }
	    return bm;
	}

	
	
	
	
}
