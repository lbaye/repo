package com.socmaps.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

/**
 * PreferenceConnector class is communicator for storing some data in
 * SharedPreferences.
 * 
 */
public class PreferenceConnector {
	public static final String PREF_NAME = "SM_PREFERENCES";
	public static final int MODE = Context.MODE_PRIVATE;

	/**
	 * Save a boolean value against a key in SharedPreferences.
	 * 
	 * @param context
	 *            Currently active context
	 * @param key
	 *            Name of the key to save value
	 * @param value
	 *            Value that needs to be saved
	 */
	public static void writeBoolean(Context context, String key, boolean value) {
		getEditor(context).putBoolean(key, value).commit();
	}

	/**
	 * Returns a boolean value from SharedPreferences against a key
	 * 
	 * @param context
	 *            Currently active Context
	 * @param key
	 *            Name of the key
	 * @param defValue
	 *            Default value if not found in SharedPreferences
	 * @return true or false
	 */
	public static boolean readBoolean(Context context, String key,
			boolean defValue) {
		return getPreferences(context).getBoolean(key, defValue);
	}

	/**
	 * Save a integer value against a key in SharedPreferences.
	 * 
	 * @param context
	 *            Currently active context
	 * @param key
	 *            Name of the key to save value
	 * @param value
	 *            Value that needs to be saved
	 */
	public static void writeInteger(Context context, String key, int value) {
		getEditor(context).putInt(key, value).commit();
	}

	/**
	 * Returns a integer value from SharedPreferences against a key.
	 * 
	 * @param context
	 *            Currently active Context
	 * @param key
	 *            Name of the key
	 * @param defValue
	 *            Default value if not found in SharedPreferences
	 * @return Integer
	 */
	public static int readInteger(Context context, String key, int defValue) {
		return getPreferences(context).getInt(key, defValue);
	}

	/**
	 * Save a String value against a key in SharedPreferences.
	 * 
	 * @param context
	 *            Currently active context
	 * @param key
	 *            Name of the key to save value
	 * @param value
	 *            Value that needs to be saved
	 */
	public static void writeString(Context context, String key, String value) {
		getEditor(context).putString(key, value).commit();
	}

	/**
	 * Returns a String value from SharedPreferences against a key.
	 * 
	 * @param context
	 *            Currently active Context
	 * @param key
	 *            Name of the key
	 * @param defValue
	 *            Default value if not found in SharedPreferences
	 * @return String
	 */
	public static String readString(Context context, String key, String defValue) {
		return getPreferences(context).getString(key, defValue);
	}

	/**
	 * Save a float value against a key in SharedPreferences.
	 * 
	 * @param context
	 *            Currently active context
	 * @param key
	 *            Name of the key to save value
	 * @param value
	 *            Value that needs to be saved
	 */
	public static void writeFloat(Context context, String key, float value) {
		getEditor(context).putFloat(key, value).commit();
	}

	/**
	 * Returns a float value from SharedPreferences against a key.
	 * 
	 * @param context
	 *            Currently active Context
	 * @param key
	 *            Name of the key
	 * @param defValue
	 *            Default value if not found in SharedPreferences
	 * @return Float
	 */
	public static float readFloat(Context context, String key, float defValue) {
		return getPreferences(context).getFloat(key, defValue);
	}

	/**
	 * Save a long value against a key in SharedPreferences.
	 * 
	 * @param context
	 *            Currently active context
	 * @param key
	 *            Name of the key to save value
	 * @param value
	 *            Value that needs to be saved
	 */
	public static void writeLong(Context context, String key, long value) {
		getEditor(context).putLong(key, value).commit();
	}

	/**
	 * Returns a long value from SharedPreferences against a key.
	 * 
	 * @param context
	 *            Currently active Context
	 * @param key
	 *            Name of the key
	 * @param defValue
	 *            Default value if not found in SharedPreferences
	 * @return Long
	 */
	public static long readLong(Context context, String key, long defValue) {
		return getPreferences(context).getLong(key, defValue);
	}

	/**
	 * Returns the instance of the SharedPreferences
	 * 
	 * @param context
	 *            Currently active Context
	 * @return Instance of SharedPreferences
	 */
	public static SharedPreferences getPreferences(Context context) {
		return context.getSharedPreferences(PREF_NAME, MODE);
	}

	/**
	 * Returns the Editor of the SharedPreferences
	 * 
	 * @param context
	 *            Currently active Context
	 * @return Editor of the SharedPreferences
	 */
	public static Editor getEditor(Context context) {
		return getPreferences(context).edit();
	}
}
