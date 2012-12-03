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
import com.socmaps.util.Constant.Permission;
import com.socmaps.ui.R;

public class PermissionRadioGroupLess extends RelativeLayout implements
		RadioGroup.OnCheckedChangeListener {

	/*public static enum Permission {
		NULL, PUBLIC, FRIENDS, NONE, CIRCLES, CUSTOM
	}*/

	Context context;
	PermissionRadioGroupListener permissionRadioGroupListener;
	RadioGroup rgPermission;
	RadioButton rbPublic, rbFriends, rbNone;
	Permission preSelectedItem;

	public PermissionRadioGroupLess(Context context,
			PermissionRadioGroupListener permissionRadioGroupListener) {
		this(context, permissionRadioGroupListener, Permission.NONE);
	}

	public PermissionRadioGroupLess(Context context,
			PermissionRadioGroupListener permissionRadioGroupListener,
			Permission preSelectedItem) {
		super(context);
		this.permissionRadioGroupListener = permissionRadioGroupListener;
		this.context = context;
		this.preSelectedItem = preSelectedItem;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.radiogroup_layout_permission_less, this, true);

		initialize();
		setValue(this.preSelectedItem);

	}

	private void initialize() {

		rgPermission = (RadioGroup) findViewById(R.id.rgPermission);
		rgPermission.setOnCheckedChangeListener(this);

		rbFriends = (RadioButton) rgPermission.findViewById(R.id.rbFriends);		
		rbPublic = (RadioButton) rgPermission.findViewById(R.id.rbPublic);
		rbNone = (RadioButton) rgPermission.findViewById(R.id.rbNone);

	}

	public void setValue(Permission item) {
		if (item != null) {
			switch (item) {
			case PUBLIC:
				rbPublic.setChecked(true);
				break;
			case FRIENDS:
				rbFriends.setChecked(true);
				break;
			case NONE:
				rbNone.setChecked(true);
				break;			
			default:
				rbNone.setChecked(true);
				break;
			}
		}
	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		// TODO Auto-generated method stub
		RadioButton radio = (RadioButton) group.findViewById(checkedId);

		Permission selectedItem = Permission.NONE;

		if (radio == rbPublic) {
			selectedItem = Permission.PUBLIC;
		} else if (radio == rbFriends) {
			selectedItem = Permission.FRIENDS;
		} else if (radio == rbNone) {
			selectedItem = Permission.NONE;
		} 
		

		permissionRadioGroupListener.onPermissionChanged(group, radio,
				selectedItem);
	}

}