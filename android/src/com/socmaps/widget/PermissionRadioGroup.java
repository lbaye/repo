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

public class PermissionRadioGroup extends RelativeLayout implements
		RadioGroup.OnCheckedChangeListener {

	public static enum SelectedItem {
		PUBLIC, FRIENDS, NONE, CIRCLES, CUSTOM
	}

	Context context;
	PermissionRadioGroupListener permissionRadioGroupListener;
	RadioGroup rgPermission;
	RadioButton rbPublic, rbFriends, rbNone, rbCircles, rbCustom;
	SelectedItem preSelectedItem;

	public PermissionRadioGroup(Context context,
			PermissionRadioGroupListener permissionRadioGroupListener) {
		this(context, permissionRadioGroupListener, SelectedItem.NONE);
	}

	public PermissionRadioGroup(Context context,
			PermissionRadioGroupListener permissionRadioGroupListener,
			SelectedItem preSelectedItem) {
		super(context);
		this.permissionRadioGroupListener = permissionRadioGroupListener;
		this.context = context;
		this.preSelectedItem = preSelectedItem;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.radiogroup_layout_permission, this, true);

		initialize();
		setValue(this.preSelectedItem);

	}

	private void initialize() {

		rgPermission = (RadioGroup) findViewById(R.id.rgPermission);
		rgPermission.setOnCheckedChangeListener(this);

		rbFriends = (RadioButton) rgPermission.findViewById(R.id.rbFriends);
		rbCircles = (RadioButton) rgPermission.findViewById(R.id.rbCircles);
		rbPublic = (RadioButton) rgPermission.findViewById(R.id.rbPublic);
		rbCustom = (RadioButton) rgPermission.findViewById(R.id.rbCustom);
		rbNone = (RadioButton) rgPermission.findViewById(R.id.rbNone);

	}

	public void setValue(SelectedItem item) {
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
			case CIRCLES:
				rbCircles.setChecked(true);
				break;
			case CUSTOM:
				rbCustom.setChecked(true);
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

		SelectedItem selectedItem = SelectedItem.NONE;

		if (radio == rbPublic) {
			selectedItem = SelectedItem.PUBLIC;
		} else if (radio == rbFriends) {
			selectedItem = SelectedItem.FRIENDS;
		} else if (radio == rbNone) {
			selectedItem = SelectedItem.NONE;
		} else if (radio == rbCircles) {
			selectedItem = SelectedItem.CIRCLES;
		} else if (radio == rbCustom) {
			selectedItem = SelectedItem.CUSTOM;
		}

		permissionRadioGroupListener.onPermissionChanged(group, radio,
				selectedItem);
	}

}