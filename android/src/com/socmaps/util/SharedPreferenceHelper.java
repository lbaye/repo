package com.socmaps.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class SharedPreferenceHelper {

	private SharedPreferences appSharedPrefs;
	private Editor prefsEditor;
	public static final String REMEMBER = "remember";

	public SharedPreferenceHelper(Context context) {
		this.appSharedPrefs = context.getSharedPreferences(
				Constant.APP_SHARED_PREFS, Context.MODE_PRIVATE);
		this.prefsEditor = appSharedPrefs.edit();
	}

	public boolean getIsPeople() {
		return appSharedPrefs.getBoolean(Constant.PEOPLE, true);
	}

	public void saveIsPeople(boolean selection) {
		prefsEditor.putBoolean(Constant.PEOPLE, selection);
		prefsEditor.commit();
	}

	public boolean getIsPlace() {
		return appSharedPrefs.getBoolean(Constant.PLACE, true);
	}

	public void saveIsPlace(boolean selection) {
		prefsEditor.putBoolean(Constant.PLACE, selection);
		prefsEditor.commit();
	}

	public boolean getIsDeal() {
		return appSharedPrefs.getBoolean(Constant.DEAL, true);
	}

	public void saveIsDeal(boolean selection) {
		prefsEditor.putBoolean(Constant.DEAL, selection);
		prefsEditor.commit();
	}

}
