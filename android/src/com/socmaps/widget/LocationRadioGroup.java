/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;

import com.socmaps.ui.R;


/**
 * LocationRadioGroup class for selecting a particular location.
 */
public class LocationRadioGroup extends RelativeLayout implements
		RadioGroup.OnCheckedChangeListener {

	public static enum SelectedItem {
		CURRENT_LOCATION, MY_PLACES, NEAR_TO_ME, POINT_ON_MAP
	}

	Context context;
	LocationRadioGroupListener locationRadioGroupListener;
	RadioGroup rgLocation;
	RadioButton rbCurrentLocation, rbMyPlaces, rbNearToMe, rbPointOnMap;

	SelectedItem preSelectedItem;

	boolean isFirstTime = true;

	
	/**
	 * Constructs a view to select a particular location
	 * 
	 * @param context Current active Context
	 * @param locationRadioGroupListener which is used for a specific action when radio button change
	 */
	public LocationRadioGroup(Context context,
			LocationRadioGroupListener locationRadioGroupListener) {
		this(context, locationRadioGroupListener, null);
	}

	/**
	 * Constructs a view to select a particular location
	 * 
	 * @param context Current active Context
	 * @param locationRadioGroupListener which is used for a specific action when radio button change
	 * @param preSelectedItem is the item of location to track which item selected
	 */
	public LocationRadioGroup(Context context,
			LocationRadioGroupListener locationRadioGroupListener,
			SelectedItem preSelectedItem) {
		super(context);
		this.locationRadioGroupListener = locationRadioGroupListener;
		this.context = context;
		this.preSelectedItem = preSelectedItem;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.radiogroup_layout_location, this, true);

		initialize();
		setValue(this.preSelectedItem);

	}

	private void initialize() {

		rgLocation = (RadioGroup) findViewById(R.id.rgLocation);
		rgLocation.setOnCheckedChangeListener(this);

		rbCurrentLocation = (RadioButton) rgLocation
				.findViewById(R.id.rbCurrentLocation);
		rbMyPlaces = (RadioButton) rgLocation.findViewById(R.id.rbMyPlaces);
		rbNearToMe = (RadioButton) rgLocation.findViewById(R.id.rbNearToMe);
		rbPointOnMap = (RadioButton) rgLocation.findViewById(R.id.rbPointOnMap);

	}

	/**
	 * Set location depends on user choice.
	 * 
	 * @param item to set the radio button checked 
	 */
	public void setValue(SelectedItem item) {
		if (item != null) {
			switch (item) {
			case CURRENT_LOCATION:
				rbCurrentLocation.setChecked(true);
				break;
			case MY_PLACES:
				rbMyPlaces.setChecked(true);
				break;
			case NEAR_TO_ME:
				rbNearToMe.setChecked(true);
				break;
			case POINT_ON_MAP:
				rbPointOnMap.setChecked(true);
				break;
			default:
				break;
			}
		}

	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		// TODO Auto-generated method stub
		RadioButton radio = (RadioButton) group.findViewById(checkedId);

		SelectedItem selectedItem = null;

		if (radio == rbCurrentLocation) {
			selectedItem = SelectedItem.CURRENT_LOCATION;
		} else if (radio == rbMyPlaces) {
			selectedItem = SelectedItem.MY_PLACES;
		} else if (radio == rbNearToMe) {
			selectedItem = SelectedItem.NEAR_TO_ME;
		} else if (radio == rbPointOnMap) {
			selectedItem = SelectedItem.POINT_ON_MAP;
		}

		if (isFirstTime && selectedItem == SelectedItem.POINT_ON_MAP) {
			
		} else {
			locationRadioGroupListener.onLocationSelectionChanged(group, radio,
					selectedItem);
		}
		isFirstTime = false;
	}

}