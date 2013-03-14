package com.socmaps.widget;

import java.util.Comparator;

import com.google.android.gms.maps.model.LatLng;
import com.socmaps.entity.Event;
import com.socmaps.entity.GeoTag;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.util.Utility;

public class ListComparator implements Comparator<Object> {

	private LatLng refLatLng;
	public enum COMPARATOR {TEXT,DISTANCE};
	
	private COMPARATOR comparatorType;

	public ListComparator() {
		comparatorType = COMPARATOR.DISTANCE;
	}

	public ListComparator(LatLng refLatLng) {
		super();
		this.refLatLng = refLatLng;
	}

	public void setLatLng(LatLng refLatLng) {
		this.refLatLng = refLatLng;
	}
	
	public void setType(COMPARATOR comparatorType)
	{
		this.comparatorType = comparatorType;
	}

	@Override
	public int compare(Object first, Object last) {
		
		if(comparatorType == COMPARATOR.TEXT)
		{
			String firstString = Utility.getItemTitle(first);
			String secondString = Utility.getItemTitle(last);
			return firstString.compareToIgnoreCase(secondString);
		}
		else
		{
			double firstDistance = getDistance(first);
			double lastDistance = getDistance(last);

			if (firstDistance > lastDistance)
				return 1;
			else if (firstDistance == lastDistance)
				return 0;
			else
				return -1;
		}
		
		
	}



	private double getDistance(Object object) {

		if (refLatLng != null) {
			LatLng itemPostion = Utility.getLatLngFromObject(object);
			if (itemPostion == null) {
				return 50000000;
			}
			return Utility.calculateDistance(refLatLng, itemPostion);
		} else {
			if (object instanceof People)
				return ((People) object).getDistance();
			else if (object instanceof Place)
				return ((Place) object).getDistance();
			else if (object instanceof SecondDegreePeople)
				return ((SecondDegreePeople) object).getDistance();
			else if (object instanceof Event)
				return ((Event) object).getDistance();
			else if (object instanceof GeoTag)
				return ((GeoTag) object).getDistance();

		}

		return 0;
	}

}