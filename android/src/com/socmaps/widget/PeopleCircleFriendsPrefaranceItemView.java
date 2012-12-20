package com.socmaps.widget;

import java.util.List;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.PeopleCircleActivity;
import com.socmaps.ui.R;
import com.socmaps.util.Constant;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * PeopleCircleFriendsPrefaranceItemView class for displaying friends list item
 * corresponding circle.
 */
public class PeopleCircleFriendsPrefaranceItemView extends LinearLayout
		implements View.OnClickListener {

	private Context context;

	private LinearLayout llHeaderPanel;

	private View headerSeperator;
	private TextView first_name_text, address_text, distance_text;

	private ImageView map_image_btn, people_icon_image, cover_image_view;
	private LinearLayout llItemContents;

	private Button btnMessagePeopleCicleFriend, btnAddMoveToCircle;
	ImageView ivSource;

	private boolean isToggle = true;
	private boolean hideHeader = false;

	public boolean isExpanded = false;

	private People people;

	private ImageDownloader imageDownloader;

	/**
	 * Initialization of PeopleCircleFriendsPrefaranceItemView constructor using
	 * those specified parameters.
	 * 
	 * @param context
	 *            Currently active Context.
	 * @param circle
	 *            An object of type Circle which holds the details information
	 *            of that particular circle.
	 * @param imageDownloader
	 *            An instance of ImageDownloader which is used to download image
	 *            from a specific uri.
	 * 
	 * @see #init()
	 * @see #setDefaultValues()
	 */

	public PeopleCircleFriendsPrefaranceItemView(Context context,
			People people, ImageDownloader imageDownloader) {
		super(context, null);

		this.context = context;
		this.people = people;
		this.imageDownloader = imageDownloader;

		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.row_in_row_people_circle_preference_item,
				this, true);

		init();
		setDefaultValues();

	}

	private void init() {

		llHeaderPanel = (LinearLayout) findViewById(R.id.llHeaderPanel);
		llHeaderPanel.setOnClickListener(this);

		llItemContents = (LinearLayout) findViewById(R.id.llItemContents);
		headerSeperator = findViewById(R.id.headerSeperator);

		first_name_text = (TextView) findViewById(R.id.first_name_text);
		address_text = (TextView) findViewById(R.id.address_text);
		distance_text = (TextView) findViewById(R.id.distance_text);

		btnMessagePeopleCicleFriend = (Button) findViewById(R.id.btnMessagePeopleCicleFriend);
		btnMessagePeopleCicleFriend.setOnClickListener(this);

		btnAddMoveToCircle = (Button) findViewById(R.id.btnAddMoveToCircle);
		btnAddMoveToCircle.setOnClickListener(this);
		ivSource = (ImageView) findViewById(R.id.ivSource);

		map_image_btn = (ImageView) findViewById(R.id.map_image_btn);
		map_image_btn.setOnClickListener(this);

		people_icon_image = (ImageView) findViewById(R.id.people_icon_image);
		cover_image_view = (ImageView) findViewById(R.id.cover_image_view);

	}

	private void setDefaultValues() {

		if (people != null) {

			Log.i("Peple PeopleCircleFriendsPrefaranceItemView::::::::::::::::",
					"FirstName: " + people.getFirstName()
							+ people.getLastName() + " Address: "
							+ people.getCurrentAddress() + " Avater:"
							+ people.getAvatar() + " cov pic: "
							+ people.getCoverPhoto() + " RegMedia: "
							+ people.getRegMedia());

			first_name_text.setText(Utility.getFieldText(people));

			if (people.getCurrentAddress() != null) {
				address_text.setText(people.getCurrentAddress());
			}

			distance_text
					.setText(Utility.getFormatedDistance(people.getDistance(),
							StaticValues.myInfo.getSettings().getUnit()));

			if (people.getRegMedia() != null) {

				if (people.getRegMedia().equalsIgnoreCase(
						Constant.sourceFacebook)) {
					ivSource.setImageResource(R.drawable.facebookicon);
				}
			}

			if (people.getAvatar() != null) {
				people_icon_image.setImageResource(R.drawable.img_blank);
				imageDownloader.download(people.getAvatar(), people_icon_image);
			}

			if (people.getCoverPhoto() != null
					&& !people.getCoverPhoto().equals("")) {
				cover_image_view.setImageResource(R.drawable.img_blank);
				imageDownloader.download(people.getCoverPhoto(),
						cover_image_view);
			} else
				cover_image_view.setImageResource(R.drawable.cover_pic_people);

		}

		if (hideHeader || !isToggle) {
			if (hideHeader) {
				llHeaderPanel.setVisibility(View.GONE);
			}

			llItemContents.setVisibility(View.VISIBLE);
		}

	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		switch (v.getId()) {

		case R.id.btnAddMoveToCircle:

			List<String> selectedCircleList = null;

			String id = people.getId();

			List<Circle> circleList = StaticValues.myInfo.getCircleList();

			if (id != null) {
				selectedCircleList = Utility.getCircleIdsForPeople(id,
						circleList);
			}

			CircleAddMoveToPicker createCirclePicker = new CircleAddMoveToPicker(
					context, new CircleAddMoveToPickerHandler(), "CIRCLE LIST",
					circleList, selectedCircleList, people);

			createCirclePicker.show();
			break;

		case R.id.btnMessagePeopleCicleFriend:
			break;

		case R.id.map_image_btn:
			StaticValues.isHighlightAnnotation = true;
			StaticValues.highlightAnnotationItem = people;

			if (PeopleCircleActivity.getIns() != null) {

				PeopleCircleActivity.getIns().finish();
			}

			break;

		default:
			break;

		}

	}

	/**
	 * This method is used to toggle the Expandable view. Basically the method
	 * performs for graphical change.
	 */

	private void toggle() {
		if (isExpanded) {
			llItemContents.setVisibility(View.GONE);

			headerSeperator.setVisibility(View.VISIBLE);

		} else {
			llItemContents.setVisibility(View.VISIBLE);

			headerSeperator.setVisibility(View.GONE);
		}
		isExpanded = !isExpanded;
	}

	// Listener
	private class CircleAddMoveToPickerHandler implements
			CircleAddMoveToPickerListener {

		@Override
		public void onCircleSelect(String pickerName, Circle selectedCircle) {
			// TODO Auto-generated method stub
			if (selectedCircle != null) {

				Log.w("CircleAddMoveToPickerHandler in onCircleSelect >>>",
						selectedCircle.toString());

			}
		}

	}

	protected void hideMessageDialogKeybord(EditText msgEditText) {
		// TODO Auto-generated method stub

		InputMethodManager mgr = (InputMethodManager) context
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		mgr.hideSoftInputFromWindow(msgEditText.getWindowToken(), 0);

	}

}
