package com.socmaps.widget;

import android.widget.RadioButton;
import android.widget.RadioGroup;

public interface PermissionRadioGroupListener {

	public void onPermissionChanged(RadioGroup group, RadioButton radio,
			PermissionRadioGroup.SelectedItem selectedItem);
}
