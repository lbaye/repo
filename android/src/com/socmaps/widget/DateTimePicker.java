/**
 * Copyright 2010 Lukasz Szmit <devmail@szmit.eu>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package com.socmaps.widget;

import java.util.Calendar;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.DatePicker.OnDateChangedListener;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TimePicker;
import android.widget.TimePicker.OnTimeChangedListener;
import android.widget.ViewSwitcher;

import com.socmaps.ui.R;

/**
 * DateTimePicker class  provides different format date and time.
 */
public class DateTimePicker extends RelativeLayout implements
		View.OnClickListener, OnDateChangedListener, OnTimeChangedListener {

	// DatePicker reference
	private DatePicker datePicker;
	// TimePicker reference
	private TimePicker timePicker;
	// ViewSwitcher reference
	private ViewSwitcher viewSwitcher;
	// Calendar reference
	private Calendar mCalendar;

	// Constructor start
	
	/**
	 * Generates a DateTimePicker object with context.
	 * 
	 * @param context Current active Context
	 * @see Context
	 */
	public DateTimePicker(Context context) {
		this(context, null);
	}

	/**
	 * Contract a DateTimePicker object with context and AttributeSet.
	 * 
	 * @param context Current active Context
	 * @param attrs is The AttributeSet
	 * @see AttributeSet
	 */
	public DateTimePicker(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	/**
	 * Contract a DateTimePicker object with context,AttributeSet and default style.
	 *  
	 * @param context Current active Context
	 * @param attrs is The AttributeSet
	 * @param defStyle in Integer
	 */
	public DateTimePicker(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.datetimepicker, this, true);

		// Inflate the date and time picker views
		final LinearLayout datePickerView = (LinearLayout) inflater.inflate(
				R.layout.datepicker, null);
		final LinearLayout timePickerView = (LinearLayout) inflater.inflate(
				R.layout.timepicker, null);

		// Grab a Calendar instance
		mCalendar = Calendar.getInstance();
		// Grab the ViewSwitcher so we can attach our picker views to it
		viewSwitcher = (ViewSwitcher) this.findViewById(R.id.DateTimePickerVS);

		// Init date picker
		datePicker = (DatePicker) datePickerView.findViewById(R.id.DatePicker);
		datePicker.init(mCalendar.get(Calendar.YEAR),
				mCalendar.get(Calendar.MONTH),
				mCalendar.get(Calendar.DAY_OF_MONTH), this);

		// Init time picker
		timePicker = (TimePicker) timePickerView.findViewById(R.id.TimePicker);

		timePicker.setCurrentHour(mCalendar.get(Calendar.HOUR_OF_DAY));
		timePicker.setCurrentMinute(mCalendar.get(Calendar.MINUTE));
		timePicker.setOnTimeChangedListener(this);

		// Handle button clicks
		((Button) findViewById(R.id.SwitchToTime)).setOnClickListener(this); // shows
																				// the
																				// time
																				// picker
		((Button) findViewById(R.id.SwitchToDate)).setOnClickListener(this); // shows
																				// the
																				// date
																				// picker

		// Populate ViewSwitcher
		viewSwitcher.addView(datePickerView, 0);
		viewSwitcher.addView(timePickerView, 1);
	}

	// Constructor end

	// Called every time the user changes DatePicker values
	@Override
	public void onDateChanged(DatePicker view, int year, int monthOfYear,
			int dayOfMonth) {
		// Update the internal Calendar instance
		mCalendar.set(year, monthOfYear, dayOfMonth,
				mCalendar.get(Calendar.HOUR_OF_DAY),
				mCalendar.get(Calendar.MINUTE));
	}

	// Called every time the user changes TimePicker values
	@Override
	public void onTimeChanged(TimePicker view, int hourOfDay, int minute) {
		// Update the internal Calendar instance
		mCalendar.set(mCalendar.get(Calendar.YEAR),
				mCalendar.get(Calendar.MONTH),
				mCalendar.get(Calendar.DAY_OF_MONTH), hourOfDay, minute);
	}

	// Handle button clicks
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.SwitchToDate:
			v.setEnabled(false);
			findViewById(R.id.SwitchToTime).setEnabled(true);
			viewSwitcher.showPrevious();
			break;

		case R.id.SwitchToTime:
			v.setEnabled(false);
			findViewById(R.id.SwitchToDate).setEnabled(true);
			viewSwitcher.showNext();
			break;
		}
	}

	// Convenience wrapper for internal Calendar instance
	
	/**
	 * Returns Hour of the day as integer associated to the parameter.
	 *  
	 * @param field in Integer
 	 * @return Integer 
	 */
	public int get(final int field) {

		if (field == Calendar.HOUR_OF_DAY) {
			return mCalendar.get(field) - 1;
		}

		return mCalendar.get(field);
	}

	// Reset DatePicker, TimePicker and internal Calendar instance
	
	/**
	 *  Reset DatePicker, TimePicker and internal Calendar instance
	 */
	public void reset() {
		final Calendar c = Calendar.getInstance();
		updateDate(c.get(Calendar.YEAR), c.get(Calendar.MONTH),
				c.get(Calendar.DAY_OF_MONTH));
		updateTime(c.get(Calendar.HOUR_OF_DAY), c.get(Calendar.MINUTE));
	}

	// Convenience wrapper for internal Calendar instance
	
	
	private long getDateTimeMillis() {
		return mCalendar.getTimeInMillis();
	}

	// Convenience wrapper for internal TimePicker instance
	
	/**
	 * Returns a format time as corresponding parameter.
	 * 
	 * @param is24HourView is true if we want to see 24 hour time format, false otherwise
	 */
	public void setIs24HourView(boolean is24HourView) {
		timePicker.setIs24HourView(is24HourView);
	}

	// Convenience wrapper for internal TimePicker instance
	
	/**
	 * Returns true if timePicker is 24 hour format, false otherwise.
	 * 
	 * @return boolean 
	 */
	public boolean is24HourView() {
		return timePicker.is24HourView();
	}

	// Convenience wrapper for internal DatePicker instance
	
	/**
	 * Returns a update date as our requirements associated with parameters.
	 * 
	 * @param year in integer 
	 * @param monthOfYear in integer
	 * @param dayOfMonth in integer day of month
	 */
	public void updateDate(int year, int monthOfYear, int dayOfMonth) {
		datePicker.updateDate(year, monthOfYear, dayOfMonth);
	}

	// Convenience wrapper for internal TimePicker instance
	/**
	 * Returns a update Time as our requirements associated with parameters.
	 * 
	 * @param currentHour in integer 
	 * @param currentMinute in integer
	 */
	public void updateTime(int currentHour, int currentMinute) {
		timePicker.setCurrentHour(currentHour);
		timePicker.setCurrentMinute(currentMinute);
	}
}