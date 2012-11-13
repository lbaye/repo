package com.socmaps.gps;

import android.content.Context;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;

public class GpsService {

	private Context context;
	private long minTime, minDistance;
	private ILocationUpdateIndicator iLocationUpdateIndicator;
	private LocationManager locationManager;
	private String locationProvider;
	private DeviceLocationListener deviceLocationListener;
	private Location currentLocation = null;

	public GpsService(Context context,
			ILocationUpdateIndicator iLocationUpdateIndicator) {
		this.context = context;
		this.iLocationUpdateIndicator = iLocationUpdateIndicator;
		minTime = 10000;
		minDistance = 15;
		locationManager = (LocationManager) context
				.getSystemService(Context.LOCATION_SERVICE);
		deviceLocationListener = new DeviceLocationListener();
	}

	public void StartListener() {

		if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
				|| locationManager
						.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
			Log.e("Location service", "Enabled");

			Criteria criteria = getCriteria();
			locationProvider = locationManager.getBestProvider(criteria, true);

			if (locationProvider != null) {
				if (locationProvider
						.equalsIgnoreCase(LocationManager.GPS_PROVIDER)
						|| locationProvider
								.equalsIgnoreCase(LocationManager.NETWORK_PROVIDER)) {
					locationManager.requestLocationUpdates(locationProvider,
							minTime, minDistance, deviceLocationListener);
				}
			}
		} else {
			Log.e("Location service", "Disabled");
		}

		/*
		 * if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
		 * { locationProvider = LocationManager.GPS_PROVIDER;
		 * locationManager.requestLocationUpdates(locationProvider, minTime,
		 * minDistance,deviceLocationListener); }
		 * 
		 * else if
		 * (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER))
		 * { locationProvider = LocationManager.NETWORK_PROVIDER;
		 * locationManager.requestLocationUpdates(locationProvider, minTime,
		 * minDistance,deviceLocationListener); } else { Criteria criteria =
		 * getCriteria(); locationProvider =
		 * locationManager.getBestProvider(criteria, true);
		 * //locationManager.requestLocationUpdates(locationProvider, minTime,
		 * minDistance,deviceLocationListener); }
		 */
	}

	public Location getLastLocation() {
		if (currentLocation == null && locationProvider != null)
			currentLocation = locationManager
					.getLastKnownLocation(locationProvider);
		return currentLocation;
	}

	public void stopListener() {
		locationManager.removeUpdates(deviceLocationListener);
	}

	private Criteria getCriteria() {
		Criteria criteria = new Criteria();
		criteria.setAccuracy(Criteria.ACCURACY_FINE);
		criteria.setAccuracy(Criteria.ACCURACY_COARSE);
		criteria.setAltitudeRequired(false);
		criteria.setBearingRequired(false);
		criteria.setCostAllowed(false);
		criteria.setPowerRequirement(Criteria.POWER_HIGH);
		return criteria;
	}

	class DeviceLocationListener implements LocationListener {
		@Override
		public void onLocationChanged(Location location) {

			if (location != null) {
				if (isBetterLocation(location, currentLocation))
					currentLocation = location;
			} else
				currentLocation = locationManager
						.getLastKnownLocation(locationProvider);
			iLocationUpdateIndicator.catchLocationUpdate(currentLocation);
		}

		@Override
		public void onProviderDisabled(String provider) {
			if (provider.equals(LocationManager.GPS_PROVIDER)
					&& locationManager
							.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
				locationManager.removeUpdates(deviceLocationListener);
				locationProvider = LocationManager.NETWORK_PROVIDER;
				deviceLocationListener = this;
				locationManager.requestLocationUpdates(
						LocationManager.NETWORK_PROVIDER, minTime, minDistance,
						deviceLocationListener);
			} else if (provider.equals(LocationManager.NETWORK_PROVIDER)
					&& locationManager
							.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
				locationManager.removeUpdates(deviceLocationListener);
				locationProvider = LocationManager.GPS_PROVIDER;
				deviceLocationListener = this;
				locationManager.requestLocationUpdates(
						LocationManager.GPS_PROVIDER, minTime, minDistance,
						deviceLocationListener);
			} else {
				Criteria criteria = getCriteria();
				locationProvider = locationManager.getBestProvider(criteria,
						true);
				deviceLocationListener = this;
				locationManager.requestLocationUpdates(locationProvider,
						minTime, minDistance, deviceLocationListener);
			}
		}

		@Override
		public void onProviderEnabled(String provider) {
		}

		@Override
		public void onStatusChanged(String provider, int status, Bundle extras) {
		}
	}

	private static final int TWO_MINUTES = 1000 * 60 * 2;

	/**
	 * Determines whether one Location reading is better than the current
	 * Location fix
	 * 
	 * @param location
	 *            The new Location that you want to evaluate
	 * @param currentBestLocation
	 *            The current Location fix, to which you want to compare the new
	 *            one
	 */
	protected boolean isBetterLocation(Location location,
			Location currentBestLocation) {
		if (currentBestLocation == null) {
			// A new location is always better than no location
			return true;
		}

		// Check whether the new location fix is newer or older
		long timeDelta = location.getTime() - currentBestLocation.getTime();
		boolean isSignificantlyNewer = timeDelta > TWO_MINUTES;
		boolean isSignificantlyOlder = timeDelta < -TWO_MINUTES;
		boolean isNewer = timeDelta > 0;

		// If it's been more than two minutes since the current location, use
		// the new location
		// because the user has likely moved
		if (isSignificantlyNewer) {
			return true;
			// If the new location is more than two minutes older, it must be
			// worse
		} else if (isSignificantlyOlder) {
			return false;
		}

		// Check whether the new location fix is more or less accurate
		int accuracyDelta = (int) (location.getAccuracy() - currentBestLocation
				.getAccuracy());
		boolean isLessAccurate = accuracyDelta > 0;
		boolean isMoreAccurate = accuracyDelta < 0;
		boolean isSignificantlyLessAccurate = accuracyDelta > 200;

		// Check if the old and new location are from the same provider
		boolean isFromSameProvider = isSameProvider(location.getProvider(),
				currentBestLocation.getProvider());

		// Determine location quality using a combination of timeliness and
		// accuracy
		if (isMoreAccurate) {
			return true;
		} else if (isNewer && !isLessAccurate) {
			return true;
		} else if (isNewer && !isSignificantlyLessAccurate
				&& isFromSameProvider) {
			return true;
		}
		return false;
	}

	/** Checks whether two providers are the same */
	private boolean isSameProvider(String provider1, String provider2) {
		if (provider1 == null) {
			return provider2 == null;
		}
		return provider1.equals(provider2);
	}
}
