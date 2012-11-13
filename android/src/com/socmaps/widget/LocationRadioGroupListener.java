package com.socmaps.widget;

import android.widget.RadioButton;
import android.widget.RadioGroup;

public interface LocationRadioGroupListener {

	public void onLocationSelectionChanged(RadioGroup group, RadioButton radio,
			LocationRadioGroup.SelectedItem selectedItem);
}
