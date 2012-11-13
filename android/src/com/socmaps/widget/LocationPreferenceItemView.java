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

	public boolean isExpanded = false;

	private LinearLayout llTimeLimitPanel, llRadiusPanel, llPermissionPanel;

	private TextView tvTimeLimitTitle, tvRadiusTitle, tvPermissionNeededTitle;

	public LocationPreferenceItemView(Context context, String itemId,
			String title, int radius, String radiusTitle) {
		this(context, itemId, title, 0, radius, false, true, false, true,
				false, true);

		if (radiusTitle != null) {
			setRadiusTitle(radiusTitle);
		}

	}

	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius, boolean isPermissionNeeded) {
		this(context, itemId, title, timeLimit, radius, isPermissionNeeded,
				true, false);

	}

	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius,
			boolean isPermissionNeeded, boolean isToggle, boolean hideHeader) {
		this(context, itemId, title, timeLimit, radius, isPermissionNeeded,
				isToggle, hideHeader, false, false, true, null);

	}

	public LocationPreferenceItemView(Context context, String itemId,
			String title, int timeLimit, int radius,
			boolean isPermissionNeeded, boolean isToggle, boolean hideHeader,
			boolean hideTimeLimitPanel, boolean hideRadiusPanel,
			boolean hidePermissionPanel) {
		this(context, itemId, title, timeLimit, radius, isPermissionNeeded,
				isToggle, hideHeader, hideTimeLimitPanel, hideRadiusPanel,
				hidePermissionPanel, null);

	}

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
		// Integer.parseInt(tvRadiusValue.getText().toString().trim());
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
		// Integer.parseInt(tvTimeLimitValue.getText().toString().trim());

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

	public int getTimeLimit() {
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

	public boolean getPermissionNeeded() {
		return isPermissionNeeded;
	}

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

	public void show() {
		llItemContents.setVisibility(View.VISIBLE);
		ivArrowRight.setImageResource(R.drawable.icon_arrow_up);
		tvItemTitle.setTypeface(null, Typeface.BOLD);
		headerSeperator.setVisibility(View.GONE);
		isExpanded = true;
	}

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
