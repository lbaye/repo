package com.socmaps.listrow;

import com.socmaps.entity.Event;

public interface ListItemClickListenerEvent {

	public void onItemClick(Event event);
	
	public void onArrowButtonClick(Event event);

	public void onRSVPSelection(Event event, String response);

	public void onShowOnMapButtonClick(Event event);
}
