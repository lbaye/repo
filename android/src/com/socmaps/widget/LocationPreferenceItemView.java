package com.socmaps.widget;

import com.socmaps.ui.R;

import android.content.Context;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.TextView;


/**
 * LocationPreferenceItemView class for generating location sharing list item.
 */
public class LocationPreferenceItemView extends LinearLayout implements
		View.OnClickListener, OnCheckedChangeListener {

	private String title;
	private int timeLimit;
	private int radius;
	private boolean isPermissionNeeded;
	private Context context;

	String itemId;
	private LinearLayout llHeaderPanel;
	private RelativeLayout rlTitleLayout;
	private View headerSeperator;
	private TextView tvItemTitle;

	private EditText etTimeLimitValue, etRadiusValue;
	private ImageView ivArrowRight;
	private LinearLayout llItemContents;
	private Button btnTimeLimitArrowLeft, btnTimeLimitArrowRight,
			btnRadiusArrowRight, btnRadiusArrowLeft;
	private RadioGroup rgPermissionNeeded;
	private RadioButton rbPermissionNeededOff, rbPermissionNeededOn;
	private boolean isToggle = true;
	private boolean hideHeader = false;
	private boolean hideTimeLimitPanel = false;
	private boolean hideRadiusPanel = false;
	private boolean hidePermissionPanel = true;
	
	private double latitude, longitude;

	private boolean isExpanded = false;

	private LinearLayout llTimeLimitPanel, llRadiusPanel, llPermissionPanel;

	private TextView tvTimeLimitTitle, tvRadiusTitle, tvPermissionNeededTitle;
	
	/**
	 * Constructs a view for location sharing list item based on parameters.
	 * 
	 * @param context Current active Context
	 * @param itemId which is associated with corresponding item
	 * @param title default title
	 * @param radius default value for radius
	 * @param radiusTitle default radius title
	 * @param latitude default latitude 
	 * @param longitude default longitude
	 * @see Context
	 */
	public LocationPreferenceItemView(Context context, String itemId,
			String title, int radius, String radiusTitle, double latitude, double longitude) {
		this(context, itemId, title, 0, radius, false, true, false, true,
				false, true);

		this.latitude = latitude;
		this.longitude = longitude;
		if (radiusTitle != null) {
			setRadiusTitle(radiusTitle);
		}

	}

	/**
	 * Constructs a view for location sharing list item based on parameters.
	 * 
	 * @param context Current active Context
	 * @param itemId which is associated with corresponding item
	 * @param title default title
	 * @param timeLimit default value for time limit
	 * @param radius default value for radius
	 * @param isPermissionNeeded true if visible this panel, false otherwise
	 */
	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius, boolean isPermissionNeeded) {
		this(context, itemId, title, timeLimit, radius, isPermissionNeeded,
				true, false);

	}

	/**
	 * Constructs a view for location sharing list item based on parameters.
	 * 
	 * @param context Current active Context.
	 * @param itemId which is associated with corresponding item
	 * @param title default title
	 * @param timeLimit default value for time limit
	 * @param radius default value for radius
	 * @param isPermissionNeeded true if visible this panel, false otherwise
	 * @param isToggle is true if we want to expand the panel, false otherwise 
	 * @param hideHeader true if we hide the header, false otherwise
	 */
	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius,
			boolean isPermissionNeeded, boolean isToggle, boolean hideHeader) {
		this(context, itemId, title, timeLimit, radius, isPermissionNeeded,
				isToggle, hideHeader, false, false, true, null);

	}

	/**
	 * Constructs a view for location sharing list item based on parameters.
	 * 
	 * @param context Current active Context.
	 * @param itemId which is associated with particular item
	 * @param title default title
	 * @param timeLimit default value for time limit
	 * @param radius default value for radius
	 * @param isPermissionNeeded true if visible this panel, false otherwise
	 * @param isToggle true if we want to expand the panel, false otherwise 
	 * @param hideHeader true if we hide the header, false otherwise
	 * @param hideTimeLimitPanel true if we want to hide the time limit panel, false otherwise
	 * @param hideRadiusPanel true if we want to hide the radius panel, false otherwise
	 * @param hidePermissionPanel true if we want to hide the permission panel, false otherwise
	 */
	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius,
			boolean isPermissionNeeded, boolean isToggle, boolean hideHeader,
			boolean hideTimeLimitPanel, boolean hideRadiusPanel,
			boolean hidePermissionPanel) {
		this(context, itemId, title, timeLimit, radius, isPermissionNeeded,
				isToggle, hideHeader, hideTimeLimitPanel, hideRadiusPanel,
				hidePermissionPanel, null);

	}

	/**
	 * Constructs a view for location sharing list item based on parameters.
	 * 
	 * @param context Current active Context.
	 * @param itemId which is associated with particular item
	 * @param title default title
	 * @param timeLimit default value for time limit
	 * @param radius default value for radius
	 * @param isPermissionNeeded true if visible this panel, false otherwise
	 * @param isToggle true if we want to expand the panel, false otherwise 
	 * @param hideHeader  true if we hide the header, false otherwise
	 * @param hideTimeLimitPanel true if we want to hide the time limit panel, false otherwise
	 * @param hideRadiusPanel true if we want to hide the radius panel, false otherwise
	 * @param hidePermissionPanel true if we want to hide the permission panel, false otherwise
	 * @param attrs This interface provides an efficient mechanism for retrieving data from compiled XML files
	 * @see AttributeSet
	 */
	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius,
			boolean isPermissionNeeded, boolean isToggle, boolean hideHeader,
			boolean hideTimeLimitPanel, boolean hideRadiusPanel,
			boolean hidePermissionPanel, AttributeSet attrs) {
		super(context, attrs);

		this.context = context;
		this.itemId = itemId;
		this.title = title;
		this.timeLimit = timeLimit;
		this.radius = radius;
		this.isPermissionNeeded = isPermissionNeeded;
		this.isToggle = isToggle;
		this.hideHeader = hideHeader;
		this.hideTimeLimitPanel = hideTimeLimitPanel;
		this.hideRadiusPanel = hideRadiusPanel;
		this.hidePermissionPanel = hidePermissionPanel;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.row_location_preference_item, this, true);

		init();
		setDefaultValues();

	}

	private void init() {

		llHeaderPanel = (LinearLayout) findViewById(R.id.llHeaderPanel);
		llHeaderPanel.setOnClickListener(this);

		rlTitleLayout = (RelativeLayout) findViewById(R.id.rlTitleLayout);
		headerSeperator = findViewById(R.id.headerSeperator);

		tvItemTitle = (TextView) findViewById(R.id.tvItemTitle);
		etTimeLimitValue = (EditText) findViewById(R.id.etTimeLimitValue);
		etRadiusValue = (EditText) findViewById(R.id.etRadiusValue);
		ivArrowRight = (ImageView) findViewById(R.id.ivArrowRight);
		llItemContents = (LinearLayout) findViewById(R.id.llItemContents);

		btnTimeLimitArrowLeft = (Button) findViewById(R.id.btnTimeLimitArrowLeft);
		btnTimeLimitArrowLeft.setOnClickListener(this);

		btnTimeLimitArrowRight = (Button) findViewById(R.id.btnTimeLimitArrowRight);
		btnTimeLimitArrowRight.setOnClickListener(this);

		btnRadiusArrowRight = (Button) findViewById(R.id.btnRadiusArrowRight);
		btnRadiusArrowRight.setOnClickListener(this);

		btnRadiusArrowLeft = (Button) findViewById(R.id.btnRadiusArrowLeft);
		btnRadiusArrowLeft.setOnClickListener(this);

		rgPermissionNeeded = (RadioGroup) findViewById(R.id.rgPermissionNeeded);
		rgPermissionNeeded.setOnCheckedChangeListener(this);
		rbPermissionNeededOff = (RadioButton) findViewById(R.id.rbPermissionNeededOff);
		rbPermissionNeededOn = (RadioButton) findViewById(R.id.rbPermissionNeededOn);

		llTimeLimitPanel = (LinearLayout) findViewById(R.id.llTimeLimitPanel);
		llRadiusPanel = (LinearLayout) findViewById(R.id.llRadiusPanel);
		llPermissionPanel = (LinearLayout) findViewById(R.id.llPermissionPanel);

		tvTimeLimitTitle = (TextView) findViewById(R.id.tvTimeLimitTitle);
		tvRadiusTitle = (TextView) findViewById(R.id.tvRadiusTitle);
		tvPermissionNeededTitle = (TextView) findViewById(R.id.tvPermissionNeededTitle);
	}

	private void setDefaultValues() {
		if (title != null) {
			tvItemTitle.setText(title);
		}

		etRadiusValue.setText("" + radius);
		etTimeLimitValue.setText("" + timeLimit);

		if (isPermissionNeeded) {
			rbPermissionNeededOn.setChecked(true);
		} else {
			rbPermissionNeededOff.setChecked(true);
		}

		if (hideHeader || !isToggle) {
			if (hideHeader) {
				llHeaderPanel.setVisibility(View.GONE);
			}

			llItemContents.setVisibility(View.VISIBLE);
		}

		if (hideTimeLimitPanel) {
			llTimeLimitPanel.setVisibility(View.GONE);
		}

		if (hideRadiusPanel) {
			llRadiusPanel.setVisibility(View.GONE);
		}

		if (hidePermissionPanel) {
			llPermissionPanel.setVisibility(View.GONE);
		}

	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		if (v == btnTimeLimitArrowLeft) {
			changeTimeLimitValue(false);
		} else if (v == btnTimeLimitArrowRight) {
			changeTimeLimitValue(true);
		} else if (v == btnRadiusArrowLeft) {
			changeRadiusValue(false);
		} else if (v == btnRadiusArrowRight) {
			changeRadiusValue(true);
		} else if (v == llHeaderPanel) {
			if (isToggle) {
				toggle();
			}

		}

	}

	private void changeRadiusValue(boolean isIncrease) {	
		try {
			radius = Integer
					.parseInt(etRadiusValue.getText().toString().trim());
		} catch (Exception e) {
			// TODO: handle exception
			radius = 0;
		}

		if (isIncrease) {
			radius += 1;
		} else {
			if (radius > 0) {
				radius -= 1;
			}

		}
		etRadiusValue.setText("" + radius);
	}

	private void changeTimeLimitValue(boolean isIncrease) {

		try {
			timeLimit = Integer.parseInt(etTimeLimitValue.getText().toString()
					.trim());
		} catch (Exception e) {
			// TODO: handle exception
			timeLimit = 0;
		}

		if (isIncrease) {
			timeLimit += 1;
		} else {
			if (timeLimit > 0) {
				timeLimit -= 1;
			}
		}
		etTimeLimitValue.setText("" + timeLimit);
	}

	
	/**
	 * Generates integer value of radius based on user changes.
	 * 
	 * @return integer 
	 */
	public int getRadius() {

		try {
			radius = Integer
					.parseInt(etRadiusValue.getText().toString().trim());
		} catch (Exception e) {
			// TODO: handle exception
			radius = 0;
		}

		return radius;
	}

	/**
	 * Generates integer value of time duration based on user changes.
	 * 
	 * @return integer
	 */
	public int getDuration() {
		try {
			timeLimit = Integer.parseInt(etTimeLimitValue.getText().toString()
					.trim());
		} catch (Exception e) {
			// TODO: handle exception
			timeLimit = 0;
		}
		return timeLimit;
	}

	public String getItemId() {
		return itemId;
	}
	
	public String getTitle()
	{
		return title;
	}
	
	public double getLatitude()
	{
		return latitude;
	}
	public double getLongitude() {
		return longitude;
	}

	public boolean getPermissionNeeded() {
		return isPermissionNeeded;
	}

	
	/**
	 * Reverse the expandable panel or view.
	 */
	public void toggle() {
		if (isExpanded) {
			llItemContents.setVisibility(View.GONE);

			ivArrowRight.setImageResource(R.drawable.icon_arrow_down);
			tvItemTitle.setTypeface(null, Typeface.NORMAL);
			headerSeperator.setVisibility(View.VISIBLE);

		} else {
			llItemContents.setVisibility(View.VISIBLE);

			ivArrowRight.setImageResource(R.drawable.icon_arrow_up);
			tvItemTitle.setTypeface(null, Typeface.BOLD);
			headerSeperator.setVisibility(View.GONE);
		}
		isExpanded = !isExpanded;
	}

	/**
	 * Some UI changes based on panel expand or collapse
	 */
	public void show() {
		llItemContents.setVisibility(View.VISIBLE);
		ivArrowRight.setImageResource(R.drawable.icon_arrow_up);
		tvItemTitle.setTypeface(null, Typeface.BOLD);
		headerSeperator.setVisibility(View.GONE);
		isExpanded = true;
	}

	
	/**
	 * Hide some content of location sharing panel's 
	 */
	public void hide() {
		llItemContents.setVisibility(View.GONE);
		ivArrowRight.setImageResource(R.drawable.icon_arrow_down);
		tvItemTitle.setTypeface(null, Typeface.NORMAL);
		headerSeperator.setVisibility(View.VISIBLE);
		isExpanded = false;
	}

	public void setTimeLimitTitle(String title) {
		if (title != null) {
			tvTimeLimitTitle.setText(title);
		}
	}

	public void setRadiusTitle(String title) {
		if (title != null) {
			tvRadiusTitle.setText(title);
		}
	}

	public void setPermissionTitle(String title) {
		if (title != null) {
			tvPermissionNeededTitle.setText(title);
		}
	}

	@Override
	public void onCheckedChanged(RadioGroup radioGroup, int checkedId) {
		// TODO Auto-generated method stub
		if (radioGroup == rgPermissionNeeded) {
			if (checkedId == R.id.rbPermissionNeededOff) {
				isPermissionNeeded = false;
			} else if (checkedId == R.id.rbPermissionNeededOn) {
				isPermissionNeeded = true;
			}
		}

	}

}
