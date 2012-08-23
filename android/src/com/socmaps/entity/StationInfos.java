package com.socmaps.entity;

import java.util.ArrayList;

public class StationInfos {

	public static ArrayList<StationContent> stationinfolist = new ArrayList<StationContent>();
	
	public static ArrayList<StationContent> getStationInfoList()
	{
		stationinfolist.clear();
		Initialization();
		return stationinfolist;
	}
	
	public static void Initialization()
	{
		StationContent temp;
		
		temp = new StationContent(23.790116, 90.422437, "Grand Bluewave Hotel Johor Bahru", "Grand Bluewave Hotel 9r Jalan Bukit Meldrum");
		stationinfolist.add(temp);
		
		temp = new StationContent(23.790666, 90.415957, "Car Park", "Plaza Angsana Jalan Skudai");
		stationinfolist.add(temp);
		
		temp = new StationContent(23.790469, 90.413425, "Car Park", "Sutera Mall Jalan Sutera Tanjung 8/4, Skudai, 81300 Skudai, Malaysia");
		stationinfolist.add(temp);
		
		temp = new StationContent(23.789959, 90.416214, "Car Park", "Skudai Parade Jalan Skudai, Skudai, 81300 Skudai, Malaysia");
		stationinfolist.add(temp);
		
		
	}
}
