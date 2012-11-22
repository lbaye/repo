package com.socmaps.ui;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.socmaps.entity.InformationSharingPreferences;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;
import com.socmaps.widget.ExpandablePanel;

public class InformationSharingSettingsActivity extends Activity implements
		OnClickListener {
	// ListView lvInformationSharing; For Customized ListView
	Button btnSave;
	Context context;
	Button btnUpdate, btnBack, btnNotification;
	ProgressDialog m_ProgressDialog;
	CheckBox chkFirstName, chkLastName, chkUserName, chkEmail,
			chkProfilePicture, chkDateOfBirth, chkBiography, chkStreetAddres,
			chkCity, chkZIPCode, chkCountry, chkService, chkRelationshipStatus;

	RadioGroup radioGroupNewsFeed, radioGroupProfilePic, radioGroupEmail,
			radioGroupName, radioGroupUserName, radioGroupGender,
			radioGroupDob, radioGroupBiography, radioGroupInterests,
			radioGroupAddress, radioGroupService, radioGroupRelationshipStatus;
	int firstName = 0, lastName = 0, userName = 0, email = 0,
			profilePicture = 0, dateOfBirth = 0, biography = 0,
			streetAddres = 0, city = 0, zIPCode = 0, country = 0, service = 0,
			relationshipStatus = 0;
	String responseString;
	int responseStatus = 0;

	ExpandablePanel newsFeedPanel, profilePicPanel, emailPanel, namePanel,
			userNamePanel, genderPanel, dobPanel, biographyPanel,
			interestPanel, addressPanel, servicePanel, relationShipStatusPanel;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.information_sharing_layout);
		
		initialize();
		
		
		
		
		setViewOnClickListener();
		setExpandListener();

	}
	
	

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (StaticValues.informationSharingPreferences == null) {
			startDialogAndBgThread();
		} else {
			setFieldValues(StaticValues.informationSharingPreferences);
		}
		
		Utility.updateNotificationBubbleCounter(btnNotification);
	}

	private void startDialogAndBgThread() {
		if (Utility.isConnectionAvailble(getApplicationContext())) {
			Thread thread = new Thread(null, getInformationSharingSettingsInfo,
					"Start update password");
			thread.start();
			m_ProgressDialog = ProgressDialog.show(this, getResources()
					.getString(R.string.please_wait_text), getResources()
					.getString(R.string.fetching_data_text), true);
		} else {
			DialogsAndToasts.showNoInternetConnectionDialog(context);
		}
	}

	private Runnable getInformationSharingSettingsInfo = new Runnable() {
		@Override
		public void run() {
			RestClient getAccountSettingsClient = new RestClient(
					Constant.informationSharingSettingsUrl);
			getAccountSettingsClient.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));
			try {
				getAccountSettingsClient.Execute(RestClient.RequestMethod.GET);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = getAccountSettingsClient.getResponse();
			responseStatus = getAccountSettingsClient.getResponseCode();
			runOnUiThread(returnResGetInformationSharingSettings);
		}
	};

	private Runnable returnResGetInformationSharingSettings = new Runnable() {
		@Override
		public void run() {
			m_ProgressDialog.dismiss();
			handleInformationSharingSettingsResponse(responseStatus,
					responseString);
		}
	};

	public void handleInformationSharingSettingsResponse(int status,
			String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			InformationSharingPreferences informationSharingPreferences = ServerResponseParser
					.parseInformationSettings(response);
			setFieldValues(informationSharingPreferences);
			StaticValues.informationSharingPreferences = informationSharingPreferences;
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();
			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();

			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;
		}
	}

	private void setFieldValues(
			InformationSharingPreferences informationSharingPreferences) {
		setRadioGroupValue(radioGroupNewsFeed,
				informationSharingPreferences.getNewsFeed());
		setRadioGroupValue(radioGroupProfilePic,
				informationSharingPreferences.getProfilePicture());

		setRadioGroupValue(radioGroupEmail,
				informationSharingPreferences.getEmail());
		setRadioGroupValue(radioGroupName,
				informationSharingPreferences.getName());

		setRadioGroupValue(radioGroupUserName,
				informationSharingPreferences.getUserName());
		setRadioGroupValue(radioGroupGender,
				informationSharingPreferences.getGender());

		setRadioGroupValue(radioGroupDob,
				informationSharingPreferences.getDateOfBirth());
		setRadioGroupValue(radioGroupBiography,
				informationSharingPreferences.getBiography());

		setRadioGroupValue(radioGroupInterests,
				informationSharingPreferences.getInterests());
		setRadioGroupValue(radioGroupAddress,
				informationSharingPreferences.getAddress());

		setRadioGroupValue(radioGroupService,
				informationSharingPreferences.getService());
		setRadioGroupValue(radioGroupRelationshipStatus,
				informationSharingPreferences.getRelationshipStatus());
	}

	private void setRadioGroupValue(RadioGroup rG, String status) {
		if ("all".equals(status)) {
			((RadioButton) rG.findViewById(R.id.radioAllUsers))
					.setChecked(true);
		} else if ("friends".equals(status)) {
			((RadioButton) rG.findViewById(R.id.radioFriendsOnly))
					.setChecked(true);
		} else if ("circles".equals(status)) {
			((RadioButton) rG.findViewById(R.id.radioCirclesOnly))
					.setChecked(true);
		} else if ("none".equals(status)) {
			((RadioButton) rG.findViewById(R.id.radioNoOne)).setChecked(true);
		} else if ("custom".equals(status)) {
			((RadioButton) rG.findViewById(R.id.radioCustom)).setChecked(true);
		}
		// else
		// {
		// ((RadioButton)rG.findViewById(R.id.radioAllUsers)).setChecked(true);
		// }
	}

	private void initialize() {
		context = InformationSharingSettingsActivity.this;
		btnBack = (Button) findViewById(R.id.btnBack);
		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnUpdate = (Button) findViewById(R.id.btnUpdate);

		radioGroupNewsFeed = (RadioGroup) findViewById(R.id.radioGroupNewsFeed);
		radioGroupProfilePic = (RadioGroup) findViewById(R.id.radioGroupProfilePic);

		radioGroupEmail = (RadioGroup) findViewById(R.id.radioGroupEmail);
		radioGroupName = (RadioGroup) findViewById(R.id.radioGroupName);

		radioGroupUserName = (RadioGroup) findViewById(R.id.radioGroupUserName);
		radioGroupGender = (RadioGroup) findViewById(R.id.radioGroupGender);

		radioGroupDob = (RadioGroup) findViewById(R.id.radioGroupDob);
		radioGroupBiography = (RadioGroup) findViewById(R.id.radioGroupBiography);

		radioGroupInterests = (RadioGroup) findViewById(R.id.radioGroupInterests);
		radioGroupAddress = (RadioGroup) findViewById(R.id.radioGroupAddress);

		radioGroupService = (RadioGroup) findViewById(R.id.radioGroupService);
		radioGroupRelationshipStatus = (RadioGroup) findViewById(R.id.radioGroupRelationshipStatus);

		newsFeedPanel = (ExpandablePanel) findViewById(R.id.newsFeedContainer);
		profilePicPanel = (ExpandablePanel) findViewById(R.id.profilePicContainer);
		emailPanel = (ExpandablePanel) findViewById(R.id.emailContainer);
		namePanel = (ExpandablePanel) findViewById(R.id.nameContainer);
		userNamePanel = (ExpandablePanel) findViewById(R.id.userNameContainer);
		genderPanel = (ExpandablePanel) findViewById(R.id.genderContainer);
		dobPanel = (ExpandablePanel) findViewById(R.id.dobContainer);
		biographyPanel = (ExpandablePanel) findViewById(R.id.biographyContainer);
		interestPanel = (ExpandablePanel) findViewById(R.id.interestsContainer);
		addressPanel = (ExpandablePanel) findViewById(R.id.addressContainer);
		servicePanel = (ExpandablePanel) findViewById(R.id.serviceContainer);
		relationShipStatusPanel = (ExpandablePanel) findViewById(R.id.relationshipStatusContainer);

	}

	private void setViewOnClickListener() {
		// TODO Auto-generated method stub

		btnBack.setOnClickListener(this);
		btnNotification.setOnClickListener(this);
		btnUpdate.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnBack) {
			finish();
		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(getApplicationContext(),
					NotificationActivity.class);
			startActivity(notificationIntent);
		} else if (v == btnUpdate) {
			updateAllValues();
		}
	}

	private void updateAllValues() {
		Thread thread = new Thread(null,
				updateInformationSettingsOptionsThread,
				"Start update platforms");
		thread.start();

		m_ProgressDialog = ProgressDialog.show(this,
				getResources().getString(R.string.please_wait_text),
				getResources().getString(R.string.updating_data_text), true);
		m_ProgressDialog.show();
	}

	private Runnable updateInformationSettingsOptionsThread = new Runnable() {
		@Override
		public void run() {
			sendDataToServer();
		}
	};

	private void sendDataToServer() {
		RestClient client = new RestClient(
				Constant.informationSharingSettingsUrl);

		client.AddHeader(Constant.authTokenParam, Utility.getAuthToken(context));

		client.AddParam("newsfeed", getRadioStatusAsString(radioGroupNewsFeed));
		client.AddParam("avatar", getRadioStatusAsString(radioGroupProfilePic));

		client.AddParam("email", getRadioStatusAsString(radioGroupEmail));
		client.AddParam("name", getRadioStatusAsString(radioGroupName));

		client.AddParam("username", getRadioStatusAsString(radioGroupUserName));
		client.AddParam("gender", getRadioStatusAsString(radioGroupGender));

		client.AddParam("dateOfBirth", getRadioStatusAsString(radioGroupDob));
		client.AddParam("bio", getRadioStatusAsString(radioGroupBiography));

		client.AddParam("interests",
				getRadioStatusAsString(radioGroupInterests));
		client.AddParam("address", getRadioStatusAsString(radioGroupAddress));

		client.AddParam("workStatus", getRadioStatusAsString(radioGroupService));
		client.AddParam("relationshipStatus",
				getRadioStatusAsString(radioGroupRelationshipStatus));

		try {
			client.Execute(RestClient.RequestMethod.PUT);
		} catch (Exception e) {
			e.printStackTrace();
		}

		responseString = client.getResponse();

		responseStatus = client.getResponseCode();

		runOnUiThread(returnRes);
	}

	private String getRadioStatusAsString(RadioGroup rG) {
		int checkedRadioButton = rG.getCheckedRadioButtonId();
		String status = "";
		switch (checkedRadioButton) {
		case R.id.radioAllUsers:
			status = "all";
			break;
		case R.id.radioFriendsOnly:
			status = "friends";
			break;
		case R.id.radioNoOne:
			status = "none";
			break;
		case R.id.radioCirclesOnly:
			status = "circles";
			break;
		case R.id.radioCustom:
			status = "custom";
			break;
		}
		return status;
	}

	private Runnable returnRes = new Runnable() {
		@Override
		public void run() {
			handleResponse(responseStatus, responseString);
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponse(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			Toast.makeText(getApplicationContext(),
					"Information saved successfully!!", Toast.LENGTH_SHORT)
					.show();
			StaticValues.informationSharingPreferences = ServerResponseParser
					.parseInformationSettings(response);
			break;

		case Constant.STATUS_BADREQUEST:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();
			break;

		case Constant.STATUS_NOTFOUND:
			Toast.makeText(getApplicationContext(),
					Utility.parseResponseString(response), Toast.LENGTH_LONG)
					.show();
			break;
		default:
			Toast.makeText(getApplicationContext(),
					"An unknown error occured.", Toast.LENGTH_LONG).show();
			break;
		}
	}

	private void setExpandListener() {
		// TODO Auto-generated method stub
		newsFeedPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconNewsfeed);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextNewsfeed);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconNewsfeed);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextNewsfeed);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		profilePicPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconProfilePic);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextProfilePic);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconProfilePic);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextProfilePic);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		emailPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconEmail);
				button.setImageResource(R.drawable.icon_arrow_down);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextEmail);
				text.setTypeface(null, Typeface.NORMAL);
			}

			@Override
			public void onExpand(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconEmail);
				button.setImageResource(R.drawable.icon_arrow_up);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextEmail);
				text.setTypeface(null, Typeface.BOLD);
			}
		});

		namePanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconName);
				button.setImageResource(R.drawable.icon_arrow_down);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextName);
				text.setTypeface(null, Typeface.NORMAL);
			}

			@Override
			public void onExpand(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconName);
				button.setImageResource(R.drawable.icon_arrow_up);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextName);
				text.setTypeface(null, Typeface.BOLD);
			}
		});

		userNamePanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconUserName);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextUserName);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconUserName);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextUserName);
						text.setTypeface(null, Typeface.BOLD);
					}
				});
		genderPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconGender);
				button.setImageResource(R.drawable.icon_arrow_down);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextGender);
				text.setTypeface(null, Typeface.NORMAL);
			}

			@Override
			public void onExpand(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconGender);
				button.setImageResource(R.drawable.icon_arrow_up);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextGender);
				text.setTypeface(null, Typeface.BOLD);
			}
		});
		dobPanel.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
			@Override
			public void onCollapse(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconDob);
				button.setImageResource(R.drawable.icon_arrow_down);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextDob);
				text.setTypeface(null, Typeface.NORMAL);
			}

			@Override
			public void onExpand(View handle, View content) {
				ImageView button = (ImageView) handle
						.findViewById(R.id.toggleIconDob);
				button.setImageResource(R.drawable.icon_arrow_up);

				LinearLayout container = (LinearLayout) content;
				TextView text = (TextView) container
						.findViewById(R.id.toptextDob);
				text.setTypeface(null, Typeface.BOLD);
			}
		});
		biographyPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconBiography);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextBiography);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconBiography);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextBiography);
						text.setTypeface(null, Typeface.BOLD);
					}
				});
		interestPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconInterests);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextInterests);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconInterests);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextInterests);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		addressPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconAddress);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextAddress);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconAddress);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextAddress);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		servicePanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconService);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextService);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconService);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextService);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

		relationShipStatusPanel
				.setOnExpandListener(new ExpandablePanel.OnExpandListener() {
					@Override
					public void onCollapse(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconRelationshipStatus);
						button.setImageResource(R.drawable.icon_arrow_down);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextRelationshipStatus);
						text.setTypeface(null, Typeface.NORMAL);
					}

					@Override
					public void onExpand(View handle, View content) {
						ImageView button = (ImageView) handle
								.findViewById(R.id.toggleIconRelationshipStatus);
						button.setImageResource(R.drawable.icon_arrow_up);

						LinearLayout container = (LinearLayout) content;
						TextView text = (TextView) container
								.findViewById(R.id.toptextRelationshipStatus);
						text.setTypeface(null, Typeface.BOLD);
					}
				});

	}

}
