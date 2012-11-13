package com.socmaps.listrow;

import com.socmaps.entity.Place;

public interface ListItemClickListenerPlace { 
	
	public void onItemClick(Place place);
	
	public void onArrowButtonClick(Place place);
	
	public void onReviewButtonClick(Place place); 
	
	public void onShowOnMapButtonClick(Place place);

}
