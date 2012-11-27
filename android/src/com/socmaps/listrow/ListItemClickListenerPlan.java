package com.socmaps.listrow;

import com.socmaps.entity.Plan;

public interface ListItemClickListenerPlan { 
	
	public void onItemClick(Plan plan);

	public void onArrowButtonClick(Plan plan);

	public void onShowOnMapButtonClick(Plan plan); 
	
	public void onShowEditButtonClick(Plan plan); 
	
	public void onShowDeleteButtonClick(Plan plan);

}
