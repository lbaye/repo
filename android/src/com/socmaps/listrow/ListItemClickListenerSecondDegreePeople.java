package com.socmaps.listrow;

import com.socmaps.entity.SecondDegreePeople;

;

public interface ListItemClickListenerSecondDegreePeople {

	public void onItemClick(SecondDegreePeople people);

	public void onArrowButtonClick(SecondDegreePeople people);

	public void onInviteButtonClick(SecondDegreePeople people);

	public void onAddFriendButtonClick(SecondDegreePeople people);

	public void onBlockButtonClick(SecondDegreePeople people);

	public void onUnBlockButtonClick(SecondDegreePeople people);

	public void onShowOnMapButtonClick(SecondDegreePeople people);

	public void onSendMessageButtonClick(SecondDegreePeople people);

	public void onMeetupButtonClick(SecondDegreePeople people);
	
	public void onCheckChange(String itemId, boolean isChecked);

}
