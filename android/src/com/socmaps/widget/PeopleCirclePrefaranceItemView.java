package com.socmaps.widget;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.graphics.Typeface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.Circle;
import com.socmaps.entity.People;
import com.socmaps.images.ImageDownloader;
import com.socmaps.ui.PeopleCircleActivity;
import com.socmaps.ui.R;
import com.socmaps.util.BackProcess;
import com.socmaps.util.BackProcess.REQUEST_TYPE;
import com.socmaps.util.BackProcessCallback;
import com.socmaps.util.Constant;
import com.socmaps.util.RestClient;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;


/**
 * PeopleCirclePrefaranceItemView class for displaying circle list item
 */
public class PeopleCirclePrefaranceItemView extends LinearLayout implements
		View.OnClickListener {

	private Context context;

	String itemId;
	private LinearLayout llHeaderPanel;
	private RelativeLayout rlTitleLayout;
	private View headerSeperator;
	private TextView tvItemTitle;

	private ImageView ivArrowRight;
	private LinearLayout llItemContents;

	private boolean isToggle = true;
	private boolean hideHeader = false;

	public boolean isExpanded = false;

	LinearLayout llCirclePanel, llCircleFriendsList;

	private Circle circle;

	private ImageDownloader imageDownloader;

	private Button btnDeleteCircle, btnRenameCircle;

	private String circleName = "";

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
	 * @see #init()
	 * @see #setDefaultValues()
	 * @see #generateCircleFriendsView()
	 */

	public PeopleCirclePrefaranceItemView(Context context, Circle circle,
			ImageDownloader imageDownloader) {
		super(context, null);

		this.context = context;
		this.circle = circle;
		this.imageDownloader = imageDownloader;
		// Get LayoutInflater instance
		final LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// Inflate myself
		inflater.inflate(R.layout.row_people_circle_preference_item, this, true);

		init();
		setDefaultValues();
		generateCircleFriendsView();

	}

	private void init() {

		llHeaderPanel = (LinearLayout) findViewById(R.id.llHeaderPanel);
		llHeaderPanel.setOnClickListener(this);

		rlTitleLayout = (RelativeLayout) findViewById(R.id.rlTitleLayout);
		headerSeperator = findViewById(R.id.headerSeperator);

		tvItemTitle = (TextView) findViewById(R.id.tvItemTitle);

		ivArrowRight = (ImageView) findViewById(R.id.ivArrowRight);
		llItemContents = (LinearLayout) findViewById(R.id.llItemContents);

		llCircleFriendsList = (LinearLayout) findViewById(R.id.llCircleFriendsList);

		btnDeleteCircle = (Button) findViewById(R.id.btnDeleteCircle);
		btnDeleteCircle.setOnClickListener(this);

		btnRenameCircle = (Button) findViewById(R.id.btnRenameCircle);
		btnRenameCircle.setOnClickListener(this);
	}

	private void setDefaultValues() {

		if (circle != null) {

			tvItemTitle.setText(circle.getName() + " ("
					+ circle.getFriendList().size() + ")");

			circleName = circle.getName();

			if (circle.getName().equalsIgnoreCase("friends")) {

				btnDeleteCircle.setVisibility(View.INVISIBLE);

				btnRenameCircle.setVisibility(View.INVISIBLE);
			}

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

		if (v == llHeaderPanel) {
			if (isToggle) {
				toggle();
			}

		}

		if (v == btnDeleteCircle) {
			callDeleteCircleAPI();

		}

		if (v == btnRenameCircle) {

			showTextInputDialog(circleName, circleName);
		}

	}

	/**
	 * This method is used to toggle the Expandable view. Basically the method
	 * performs for graphical change.
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

	private void generateCircleFriendsView() {

		List<People> friendList = circle.getFriendList();

		Log.w("circle.getFriendList() is", "CircleName: " + circle.getName()
				+ " : " + friendList.size() + " ????");

		llCircleFriendsList.removeAllViews();

		for (People peopleItem : friendList) {

			People people = Utility.getPeopleById(peopleItem.getId());

			Log.w("PeopleCirclePrefaranceItemView peopleItem.getId() in for loop >>>>>>>>>>>>>>",
					peopleItem.getId());

			if (people != null) {

				Log.w("PeopleCirclePrefaranceItemView people >>>>>>>>>>>>>>",
						"Name: " + people.getFirstName() + people.getLastName()
								+ " Address: " + people.getCurrentAddress()
								+ " Avater: " + people.getAvatar());

				llCircleFriendsList
						.addView(new PeopleCircleFriendsPrefaranceItemView(
								context, people, imageDownloader));
			}
		}

	}

	private void callDeleteCircleAPI() {

		String url = Constant.smCircleUrl + "/" + circle.getId();

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.DELETE, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.DELETE);

	}

	private void callRenameCircleAPI() {

		String url = Constant.smCircleUrl + "/" + circle.getId() + "/rename";

		ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();

		params.add(new BasicNameValuePair("name", circleName));

		BackProcess backProcess = new BackProcess(context, params, url,
				REQUEST_TYPE.RENAME, true, getResources().getString(
						R.string.please_wait_text), getResources().getString(
						R.string.sending_request_text),
				new BackProcessCallBackListener(), true);

		backProcess.execute(RestClient.RequestMethod.PUT);
	}

	private class BackProcessCallBackListener implements BackProcessCallback {

		@Override
		public void onFinish(int status, String result, int type) {

			// TODO Auto-generated method stub
			Log.w("Got places response from server callback process >> :",
					status + ":" + result);
			switch (status) {
			case Constant.STATUS_SUCCESS:

				if (type == REQUEST_TYPE.DELETE.ordinal()) {
					Toast.makeText(context, "Successfully deleted circle.",
							Toast.LENGTH_SHORT).show();

					try {
						for (int i = 0; i < StaticValues.myInfo.getCircleList()
								.size(); i++) {

							if (circle.getId().equalsIgnoreCase(
									StaticValues.myInfo.getCircleList().get(i)
											.getId())) {

								StaticValues.myInfo.getCircleList().remove(i);
								break;
							}
						}

					} catch (Exception e) {
						// TODO: handle exception
					}

					// Refresh Circle list
					if (PeopleCircleActivity.getIns() != null) {
						PeopleCircleActivity.getIns().generateCircleView();
					}
				} else if (type == REQUEST_TYPE.RENAME.ordinal()) {

					Toast.makeText(context, "Circle renamed Successfully.",
							Toast.LENGTH_SHORT).show();

					try {
						for (int i = 0; i < StaticValues.myInfo.getCircleList()
								.size(); i++) {

							if (circle.getId().equalsIgnoreCase(
									StaticValues.myInfo.getCircleList().get(i)
											.getId())) {

								StaticValues.myInfo.getCircleList().get(i)
										.setName(circleName);
								break;
							}
						}

					} catch (Exception e) {
						// TODO: handle exception
					}

					// Refresh Circle list
					if (PeopleCircleActivity.getIns() != null) {
						PeopleCircleActivity.getIns().generateCircleView();
					}

				}

				break;
			case Constant.STATUS_SUCCESS_NODATA:
				Toast.makeText(context, "No place found.", Toast.LENGTH_SHORT)
						.show();
				break;
			default:
				Toast.makeText(context,
						"An unknown error occured. Please try again!!",
						Toast.LENGTH_SHORT).show();
				break;

			}

		}

	}

	/**
	 * The method is used to set & show some specified text.
	 * 
	 * @param text
	 *            As String which will be set on the text view.
	 * @param hint
	 *            As String which will be used as hint.
	 * @see #callRenameCircleAPI
	 */

	// TODO Auto-generated method stub
	public void showTextInputDialog(final String text, String hint) {

		// custom dialog
		final Dialog dialog = new Dialog(context, R.style.CustomDialogTheme);
		dialog.setContentView(R.layout.input_text_dialog_layout);

		dialog.setOnDismissListener(new OnDismissListener() {

			@Override
			public void onDismiss(DialogInterface dialog) {
				// TODO Auto-generated method stub
				Utility.hideKeyboard((Activity) context);
			}
		});

		final EditText etInputText = (EditText) dialog
				.findViewById(R.id.etInputText);

		if (text != null && !text.trim().equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		Button btnCancel = (Button) dialog.findViewById(R.id.btnCancel);
		// if button is clicked, close the custom dialog
		btnCancel.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				dialog.dismiss();

			}
		});

		Button btnOk = (Button) dialog.findViewById(R.id.btnOk);
		// if button is clicked, close the custom dialog
		btnOk.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				String inputText = etInputText.getText().toString().trim();

				Log.w("showTextInputDialog into", "btnOk: " + inputText);

				if (!inputText.equalsIgnoreCase("")) {

					circleName = inputText;

					callRenameCircleAPI();

					dialog.dismiss();
				} else {

					Toast.makeText(context, "Please input circle name", 1000)
							.show();
				}

			}
		});

		dialog.show();
	}

}
