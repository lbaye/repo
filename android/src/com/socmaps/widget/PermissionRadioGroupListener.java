package com.socmaps.widget;

import com.socmaps.util.Constant;

import android.widget.RadioButton;
import android.widget.RadioGroup;

public interface PermissionRadioGroupListener {

	public void onPermissionChanged(RadioGroup group, RadioButton radio,
			Constant.Permission selectedItem);
	
	
}
