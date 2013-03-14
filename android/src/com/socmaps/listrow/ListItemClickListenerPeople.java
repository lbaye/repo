package com.socmaps.listrow;

import com.socmaps.entity.People;

public interface ListItemClickListenerPeople {

	public void onItemClick(People people);

	public void onArrowButtonClick(People people);

	public void onInviteButtonClick(People people);

	public void onAddFriendButtonClick(People people);

	public void onBlockButtonClick(People people);

	public void onUnBlockButtonClick(People people);

	public void onShowOnMapButtonClick(Object people);

	public void onSendMessageButtonClick(People people);

	public void onMeetupButtonClick(People people);
	
	public void onCheckChange(String itemId, boolean isChecked);

}
