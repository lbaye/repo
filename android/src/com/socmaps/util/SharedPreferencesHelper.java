package com.socmaps.util;

import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.content.SharedPreferences;

public class SharedPreferencesHelper {
	// private static final String PREF_FILE = "Settings";

	private static Map<Context, SharedPreferencesHelper> instances = new HashMap<Context, SharedPreferencesHelper>();

	private SharedPreferences settings;
	private SharedPreferences.Editor editor;

	private SharedPreferencesHelper(Context context) {
		settings = context.getSharedPreferences(Constant.APP_SHARED_PREFS,
				Context.MODE_PRIVATE);
		editor = settings.edit();
	}

	public static SharedPreferencesHelper getInstance(Context context) {
		if (!instances.containsKey(context))
			instances.put(context, new SharedPreferencesHelper(context));
		return instances.get(context);
	}

	public String getString(String key, String defValue) {
		return settings.getString(key, defValue);
	}

	public SharedPreferencesHelper setString(String key, String value) {
		editor.putString(key, value);
		editor.commit();

		return this;
	}

	public int getInt(String key, int defValue) {
		return settings.getInt(key, defValue);
	}

	public SharedPreferencesHelper setInt(String key, int value) {
		editor.putInt(key, value);
		editor.commit();

		return this;
	}

	public boolean getBoolean(String key, boolean defValue) {
		return settings.getBoolean(key, defValue);
	}

	public SharedPreferencesHelper setBoolean(String key, boolean value) {
		editor.putBoolean(key, value);
		editor.commit();

		return this;
	}

}
