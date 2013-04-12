package com.socmaps.widget;

import android.widget.RadioButton;
import android.widget.RadioGroup;

public interface OnlineOfflineRadioGroupListener {

	public void onOnlineOfflineChanged(RadioGroup group, RadioButton radio, boolean isOffline);

	public void onAlluserFriendsOnlyChanged(RadioGroup group, RadioButton radio, boolean isAllUser);

}
