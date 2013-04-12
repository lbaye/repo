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
import android.widget.Toast;

import com.socmaps.util.Constant.ALLUSER_FRIENDS;
import com.socmaps.util.Constant.Permission;
import com.socmaps.ui.ListViewActivity;
import com.socmaps.ui.R;

/**
 * PermissionRadioGroupLess class for generating radio group (view).
 * 
 */
public class AlluserFriendsOnlyRadioGroup extends RelativeLayout implements RadioGroup.OnCheckedChangeListener {

	Context context;
	OnlineOfflineRadioGroupListener onlineOfflineRadioGroupListener;
	RadioGroup rgPermission;
	RadioButton rbAllUser, rbFriendsOnly;
	ALLUSER_FRIENDS preSelectedItem;

	/**
	 * Initialization of PermissionRadioGroupLess constructor using those
	 * specified parameters.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param permissionRadioGroupListener
	 *            An instance of PermissionRadioGroupListener.
	 */

	public AlluserFriendsOnlyRadioGroup(Context context, OnlineOfflineRadioGroupListener onlineOfflineRadioGroupListener) {
		this(context, onlineOfflineRadioGroupListener, ALLUSER_FRIENDS.ALLUSER);
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

	public AlluserFriendsOnlyRadioGroup(Context context, OnlineOfflineRadioGroupListener onlineOfflineRadioGroupListener, ALLUSER_FRIENDS alluserFriendsOnly) {
		super(context);
		this.onlineOfflineRadioGroupListener = onlineOfflineRadioGroupListener;
		this.context = context;
		this.preSelectedItem = alluserFriendsOnly;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.radiogroup_layout_alluser_friendsonly, this, true);

		initialize();
		setValue(this.preSelectedItem);

	}

	private void initialize() {

		rgPermission = (RadioGroup) findViewById(R.id.rgPermission);
		rgPermission.setOnCheckedChangeListener(this);
		
		rbAllUser = (RadioButton) rgPermission.findViewById(R.id.rbAllUser);
		rbFriendsOnly = (RadioButton) rgPermission.findViewById(R.id.rbFriendsOnly);
		
		if((Activity)context instanceof ListViewActivity){
			
			//Toast.makeText(context, "I am from ListViewActivity", Toast.LENGTH_SHORT).show();
			rbAllUser.setTextColor(Color.BLACK);
			rbFriendsOnly.setTextColor(Color.BLACK);
		}

		

	}

	/**
	 * This method sets the value of item.
	 * 
	 * @param item
	 *            An instance of Permission which can be either Public, Friends
	 *            or None.
	 */

	public void setValue(ALLUSER_FRIENDS item) {
		if (item != null) {
			switch (item) {
			case ALLUSER:
				rbAllUser.setChecked(true);
				break;
			case FRIENDSONLY:
				rbFriendsOnly.setChecked(true);
				break;

			default:
				rbAllUser.setChecked(true);
				break;
			}
		}
	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		// TODO Auto-generated method stub
		RadioButton radio = (RadioButton) group.findViewById(checkedId);

		ALLUSER_FRIENDS selectedItem = ALLUSER_FRIENDS.ALLUSER;

		if (radio == rbAllUser) {
			selectedItem = ALLUSER_FRIENDS.ALLUSER;
			onlineOfflineRadioGroupListener.onAlluserFriendsOnlyChanged(group, radio, true);
		} else if (radio == rbFriendsOnly) {
			selectedItem = ALLUSER_FRIENDS.FRIENDSONLY;
			onlineOfflineRadioGroupListener.onAlluserFriendsOnlyChanged(group, radio, false);
		}

		
	}

}