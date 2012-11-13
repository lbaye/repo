package com.socmaps.widget;

import java.util.List;

public interface PeoplePickerListener {

	public void onSelect(String pickerName, List<String> selectedFriendList,
			List<String> selectedCircleList,
			List<String> selectedCircleFriendList,
			List<String> selectedFriendListAll);
}
