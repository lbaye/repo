package com.socmaps.util;

import com.google.android.gms.maps.model.LatLng;
import com.socmaps.entity.InformationSharingPreferences;
import com.socmaps.entity.LayersPreferences;
import com.socmaps.entity.MeetupRequest;
import com.socmaps.entity.MyInfo;
import com.socmaps.entity.NotificationPreferences;
import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.PlatformsPreferences;
import com.socmaps.entity.SearchResult;

/**
 * StaticValues class for providing some data which is reusable.
 *
 */
public class StaticValues {

	public static MyInfo myInfo = null;
	public static LayersPreferences layersPreferences = null;
	public static PlatformsPreferences platformsPreferences = null;
	public static NotificationPreferences notificationPreferences = null;
	public static InformationSharingPreferences informationSharingPreferences = null;

	public static SearchResult searchResult = null;

	public static Place selectedPlace = null;
	public static People selectedPeople = null;
	public static LatLng myPoint = null;

	public static MeetupRequest selectedMeetupRequest = null;

	public static Object highlightAnnotationItem;
	public static boolean isHighlightAnnotation;

	public static boolean PEOPLE_SELECT_ALL_USERS = false;

}
