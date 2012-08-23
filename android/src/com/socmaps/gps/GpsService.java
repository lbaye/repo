package com.socmaps.gps;

import android.content.Context;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;

public class GpsService {

	private Context context;
	private long minTime, minDistance;
	private LocationUpdateIndicator locationUpdateIndicator;
	private LocationManager locationManager;
	private String locationProvider;
	private DeviceLocationListener deviceLocationListener;
	public Location currentLocation = null;

	public GpsService(Context context, LocationUpdateIndicator locationUpdateIndicator) {
		this.context = context;
		this.locationUpdateIndicator = locationUpdateIndicator;
		minTime = 60000;
		minDistance = 2;
		locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		deviceLocationListener = new DeviceLocationListener();
	}

	public void StartListener() {
		if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
			locationProvider = LocationManager.GPS_PROVIDER;
			locationManager.requestLocationUpdates(locationProvider, minTime, minDistance,deviceLocationListener);
		}

		else if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
			locationProvider = LocationManager.NETWORK_PROVIDER;
			locationManager.requestLocationUpdates(locationProvider, minTime, minDistance,deviceLocationListener);
		} else {
			Criteria criteria = new Criteria();
			criteria.setAccuracy(Criteria.ACCURACY_FINE);
			criteria.setAccuracy(Criteria.ACCURACY_COARSE);
			criteria.setAltitudeRequired(false);
			criteria.setBearingRequired(false);
			criteria.setCostAllowed(false);
			criteria.setPowerRequirement(Criteria.POWER_HIGH);
			locationProvider = locationManager.getBestProvider(criteria, true);
			locationManager.requestLocationUpdates(locationProvider, minTime, minDistance,deviceLocationListener);
		}

	}

	public Location getLastLocation() {
		if (currentLocation == null)
			currentLocation = locationManager.getLastKnownLocation(locationProvider);
		return currentLocation;
	}

	public void stopListener() {
		locationManager.removeUpdates(deviceLocationListener);
	}

	class DeviceLocationListener implements LocationListener {
		@Override
		public void onLocationChanged(Location location) {
			if (location != null)
				currentLocation = location;
			else
				currentLocation = locationManager.getLastKnownLocation(locationProvider);
			locationUpdateIndicator.catchLocationUpdate(currentLocation);
		}

		@Override
		public void onProviderDisabled(String provider) {
			if (provider.equals(LocationManager.GPS_PROVIDER) && locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
				locationManager.removeUpdates(deviceLocationListener);
				locationProvider = LocationManager.NETWORK_PROVIDER;
				deviceLocationListener = this;
				locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, minTime, minDistance, deviceLocationListener);
			} else if (provider.equals(LocationManager.NETWORK_PROVIDER)&& locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
				locationManager.removeUpdates(deviceLocationListener);
				locationProvider = LocationManager.GPS_PROVIDER;
				deviceLocationListener = this;
				locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, minTime, minDistance, deviceLocationListener);
			} else {
				Criteria criteria = new Criteria();
				criteria.setAccuracy(Criteria.ACCURACY_FINE);
				criteria.setAccuracy(Criteria.ACCURACY_COARSE);
				criteria.setAltitudeRequired(false);
				criteria.setBearingRequired(false);
				criteria.setCostAllowed(true);
				criteria.setPowerRequirement(Criteria.POWER_HIGH);
				locationProvider = locationManager.getBestProvider(criteria,true);
				deviceLocationListener = this;
				locationManager.requestLocationUpdates(locationProvider, minTime, minDistance,deviceLocationListener);
			}
		}

		@Override
		public void onProviderEnabled(String provider) {
		}

		@Override
		public void onStatusChanged(String provider, int status, Bundle extras) {
		}
	}
}
