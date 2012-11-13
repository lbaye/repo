package com.socmaps.widget;

import com.socmaps.entity.Place;

public interface NearByPlacesPickerListener {

	public void onPlaceSelect(String pickerName, Place selectedPlace);
}
