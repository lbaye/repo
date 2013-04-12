/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;

import com.socmaps.util.Constant.OnlineOffline;
import com.socmaps.util.Constant.Permission;
import com.socmaps.ui.ListViewActivity;
import com.socmaps.ui.R;

/**
 * PermissionRadioGroupLess class for generating radio group (view).
 * 
 */
public class OnlineOfflineRadioGroup extends RelativeLayout implements RadioGroup.OnCheckedChangeListener {

	Context context;
	OnlineOfflineRadioGroupListener onlineOfflineRadioGroupListener;
	RadioGroup rgPermission;
	RadioButton rbOnline, rbOffline;
	OnlineOffline preSelectedItem;

	/**
	 * Initialization of PermissionRadioGroupLess constructor using those
	 * specified parameters.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param permissionRadioGroupListener
	 *            An instance of PermissionRadioGroupListener.
	 */

	public OnlineOfflineRadioGroup(Context context, OnlineOfflineRadioGroupListener onlineOfflineRadioGroupListener) {
		this(context, onlineOfflineRadioGroupListener, OnlineOffline.ONLINE);
	}

	/**
	 * Initialization of PermissionRadioGroupLess constructor using those
	 * specified parameters.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param permissionRadioGroupListener
	 *            An instance of PermissionRadioGroupListener.
	 * @param preSelectedItem
	 *            Check if there is any item that is pre-selected.
	 * @see #initialize()
	 * @see #setValue(Permission)
	 */

	public OnlineOfflineRadioGroup(Context context, OnlineOfflineRadioGroupListener onlineOfflineRadioGroupListener, OnlineOffline onlineOffline) {
		super(context);
		this.onlineOfflineRadioGroupListener = onlineOfflineRadioGroupListener;
		this.context = context;
		this.preSelectedItem = onlineOffline;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.radiogroup_layout_online_offline, this, true);

		initialize();
		setValue(this.preSelectedItem);

	}

	private void initialize() {

		rgPermission = (RadioGroup) findViewById(R.id.rgPermission);
		rgPermission.setOnCheckedChangeListener(this);

		rbOnline = (RadioButton) rgPermission.findViewById(R.id.rbOnline);
		rbOffline = (RadioButton) rgPermission.findViewById(R.id.rbOffline);
		
		if((Activity)context instanceof ListViewActivity){
			
			//Toast.makeText(context, "I am from ListViewActivity", Toast.LENGTH_SHORT).show();
			rbOnline.setTextColor(Color.BLACK);
			rbOffline.setTextColor(Color.BLACK);
		}

	}

	/**
	 * This method sets the value of item.
	 * 
	 * @param item
	 *            An instance of Permission which can be either Public, Friends
	 *            or None.
	 */

	public void setValue(OnlineOffline item) {
		if (item != null) {
			switch (item) {
			case ONLINE:
				rbOnline.setChecked(true);
				break;
			case OFFLINE:
				rbOffline.setChecked(true);
				break;

			default:
				rbOffline.setChecked(true);
				break;
			}
		}
	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		// TODO Auto-generated method stub
		RadioButton radio = (RadioButton) group.findViewById(checkedId);

		OnlineOffline selectedItem = OnlineOffline.ONLINE;

		if (radio == rbOnline) {
			selectedItem = OnlineOffline.ONLINE;
			onlineOfflineRadioGroupListener.onOnlineOfflineChanged(group, radio, false);
		} else if (radio == rbOffline) {
			selectedItem = OnlineOffline.OFFLINE;
			onlineOfflineRadioGroupListener.onOnlineOfflineChanged(group, radio, true);
		}

		
	}

}