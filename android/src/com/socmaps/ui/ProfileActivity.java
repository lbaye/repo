package com.socmaps.ui;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.readystatesoftware.mapviewballoons.R;
import com.socmaps.entity.MyInfo;
import com.socmaps.images.ImageLoader;
import com.socmaps.util.Constant;
import com.socmaps.util.DialogsAndToasts;
import com.socmaps.util.RestClient;
import com.socmaps.util.ServerResponseParser;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

public class ProfileActivity extends Activity implements OnClickListener {
	Context context;

	Button btnBack, btnNotification;

	ImageView ivProfilePic, ivCoverPic, ivRegMedia;
	ImageView btnEditProfilePic, btnEditCoverPic, btnEditStatus,
			btnNavigateToMap, btnEvent;
	TextView tvName, tvStatusMessage, tvAddress, tvTime, tvDistance, tvAge,
			tvCity, tvCompany, tvRelationshipStatus;

	LinearLayout age_layout, relationship_layout, living_in_layout,
			work_at_layout, layEditCoverPic, layEditStatus, layEditProfilePic; 
	
	RelativeLayout relativeLayoutForGeoTag, relativeLayoutForUploadPhoto;

	int responseStatus = 0;
	String responseString = "";

	ImageLoader imageLoader;
	private String flag = ""; // UNIT or INFO
	private ProgressDialog m_ProgressDialog = null;

	public final static int REQUEST_CODE_CAMERA = 700;
	public final static int REQUEST_CODE_GALLERY = 701;
	boolean isCoverPic = true;

	int requestCode;
	Bitmap avatar, coverPic;
	String dob = "";
	Calendar now = Calendar.getInstance();

	String strRelationshipStatus;
	String status, age, city, workStatus;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.profile_info_layout);

		initialize();

		// onLoad();
		setDefaultValues();

	}

	@Override
	public void onAttachedToWindow() {
		super.onAttachedToWindow();
		Window window = getWindow();
		// Eliminates color banding
		window.setFormat(PixelFormat.RGBA_8888);
	}

	private void initialize() {

		context = ProfileActivity.this;

		imageLoader = new ImageLoader(context);

		btnBack = (Button) findViewById(R.id.btnBack);
		btnBack.setOnClickListener(this);

		btnNotification = (Button) findViewById(R.id.btnNotification);
		btnNotification.setOnClickListener(this);

		ivProfilePic = (ImageView) findViewById(R.id.ivProfilePic);
		ivCoverPic = (ImageView) findViewById(R.id.ivCoverPic);
		ivRegMedia = (ImageView) findViewById(R.id.ivRegMedia);

		btnEditProfilePic = (ImageView) findViewById(R.id.btnEditProfilePic);
		btnEditProfilePic.setOnClickListener(this);

		btnEditCoverPic = (ImageView) findViewById(R.id.btnEditCoverPic);
		btnEditCoverPic.setOnClickListener(this);

		btnEditStatus = (ImageView) findViewById(R.id.btnEditStatus);
		btnEditStatus.setOnClickListener(this);

		btnNavigateToMap = (ImageView) findViewById(R.id.btnNavigateToMap);
		btnNavigateToMap.setOnClickListener(this);

		btnEvent = (ImageView) findViewById(R.id.btnEvent);
		btnEvent.setOnClickListener(this);

		tvName = (TextView) findViewById(R.id.tvName);
		tvStatusMessage = (TextView) findViewById(R.id.tvStatusMessage);
		tvAddress = (TextView) findViewById(R.id.tvAddress);
		tvTime = (TextView) findViewById(R.id.tvTime);
		tvDistance = (TextView) findViewById(R.id.tvDistance);
		tvAge = (TextView) findViewById(R.id.tvAge);

		tvCity = (TextView) findViewById(R.id.tvCity);
		tvCompany = (TextView) findViewById(R.id.tvCompany);

		age_layout = (LinearLayout) findViewById(R.id.age_layout);
		relationship_layout = (LinearLayout) findViewById(R.id.relationship_layout);
		living_in_layout = (LinearLayout) findViewById(R.id.living_in_layout);
		work_at_layout = (LinearLayout) findViewById(R.id.work_at_layout);
		layEditCoverPic = (LinearLayout) findViewById(R.id.layEditCoverPic);
		layEditStatus = (LinearLayout) findViewById(R.id.layEditStatus);
		layEditProfilePic = (LinearLayout) findViewById(R.id.layEditProfilePic); 
		
		relativeLayoutForGeoTag = (RelativeLayout) findViewById(R.id.relativeLayoutForGeoTag); 
		relativeLayoutForUploadPhoto = (RelativeLayout) findViewById(R.id.relativeLayoutForUploadPhoto); 

		age_layout.setOnClickListener(this);
		relationship_layout.setOnClickListener(this);
		living_in_layout.setOnClickListener(this);
		work_at_layout.setOnClickListener(this);
		layEditCoverPic.setOnClickListener(this);
		layEditStatus.setOnClickListener(this);
		layEditProfilePic.setOnClickListener(this); 
		
		relativeLayoutForGeoTag.setOnClickListener(this); 
		relativeLayoutForUploadPhoto.setOnClickListener(this);

		tvRelationshipStatus = (TextView) findViewById(R.id.tvRelationshipStatus);

	}

	public void setDefaultValues() {

		if (StaticValues.myInfo != null) {

			status = StaticValues.myInfo.getStatusMsg();
			age = StaticValues.myInfo.getAge() + "";
			city = StaticValues.myInfo.getCity();
			workStatus = StaticValues.myInfo.getWorkStatus();
			
			imageLoader.clearCache();

			if (StaticValues.myInfo.getAvatar() != null) {
				/*
				 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory
				 * .decodeResource(getResources(), R.drawable.thumb));
				 * 
				 * BitmapManager.INSTANCE.loadBitmap(myInfo.getAvatar(),
				 * ivProfilePic, 60, 60);
				 */

				imageLoader.DisplayImage(StaticValues.myInfo.getAvatar(),
						ivProfilePic, R.drawable.thumb);
			}

			if (StaticValues.myInfo.getCoverPhoto() != null) {
				/*
				 * BitmapManager.INSTANCE.setPlaceholder(BitmapFactory
				 * .decodeResource(getResources(),
				 * R.drawable.cover_pic_default));
				 * 
				 * BitmapManager.INSTANCE.loadBitmap(myInfo.getCoverPhoto(),
				 * ivCoverPic, 320, 150);
				 */

				imageLoader.DisplayImage(StaticValues.myInfo.getCoverPhoto(),
						ivCoverPic, R.drawable.cover_pic_default);
			}
			if (StaticValues.myInfo.getRegMedia() != null) {
				if (StaticValues.myInfo.getRegMedia().equals("fb")) {
					ivRegMedia.setVisibility(View.VISIBLE);
				}
			}

			String name = "";
			if (StaticValues.myInfo.getFirstName() != null) {
				name = StaticValues.myInfo.getFirstName() + " ";
			}
			if (StaticValues.myInfo.getLastName() != null) {
				name += StaticValues.myInfo.getLastName();
			}
			tvName.setText(name);

			if (StaticValues.myInfo.getStatusMsg() != null
					&& !StaticValues.myInfo.getStatusMsg().equals("")) {
				tvStatusMessage.setText(StaticValues.myInfo.getStatusMsg());
			}

			if (StaticValues.myInfo.getStreetAddress() != null) {
				tvAddress.setText(StaticValues.myInfo.getStreetAddress());
			} else {
				tvAddress.setText("");
			}

			if (StaticValues.myInfo.getLastLogInDate() != null) {
				tvTime.setText(Utility
						.getFormattedDisplayDate(StaticValues.myInfo
								.getLastLoginTime()));
			}

			Log.w("Date of birth in setDefaultValues",
					StaticValues.myInfo.getAge() + " got it");

			if (StaticValues.myInfo.getAge() > 0) {

				tvAge.setText(StaticValues.myInfo.getAge() + " years");
			}

			if (StaticValues.myInfo.getRelationshipStatus() != null) {
				tvRelationshipStatus.setText(StaticValues.myInfo
						.getRelationshipStatus());
			}

			// if (myInfo.getRelationshipStatus() != null) {
			//
			// if (myInfo.getRelationshipStatus().equalsIgnoreCase("single")) {
			// spRelationshipStatus.setSelection(1);
			// } else if (myInfo.getRelationshipStatus().equalsIgnoreCase(
			// "married")) {
			// spRelationshipStatus.setSelection(2);
			// } else if (myInfo.getRelationshipStatus().equalsIgnoreCase(
			// "complicated")) {
			// spRelationshipStatus.setSelection(3);
			// }
			//
			// a
			//
			// }

			if (StaticValues.myInfo.getCity() != null) {
				tvCity.setText(StaticValues.myInfo.getCity());
			}

			if (StaticValues.myInfo.getWorkStatus() != null) {
				tvCompany.setText(StaticValues.myInfo.getWorkStatus());
			}

		}

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if (v == btnNavigateToMap) {

			/*
			 * AppStaticStorages.selectedMeetupRequest = meetupRequestEntity;
			 * Intent intent = new Intent(context, ShowItemOnMap.class);
			 * intent.putExtra("FLAG", Constant.FLAG_PEOPLE);
			 * startActivity(intent);
			 */
		} else if (v == btnEvent) {
			Intent i = new Intent(context, EventListActivity.class);
			startActivity(i);
		} else if (v == btnBack) {

			// finish();

			showDialogToUpdateInfo();

		} else if (v == btnNotification) {
			Intent notificationIntent = new Intent(context,
					NotificationActivity.class);
			startActivity(notificationIntent);
		}

		if (v.getId() == R.id.btnEditProfilePic) {

			isCoverPic = false;

			uploadIconFromGalaryOrCamara();

		}

		switch (v.getId()) {

		case R.id.age_layout:
			showDatePicker();
			break;

		case R.id.relationship_layout:
			spinnerShowRelationshipOption();
			break;

		case R.id.living_in_layout:
			showTextInputDialog(R.id.living_in_layout, city,
					getString(R.string.cityLabel));
			break;

		case R.id.work_at_layout:
			showTextInputDialog(R.id.work_at_layout, workStatus,
					getString(R.string.servicelabel));
			break;

		case R.id.btnEditStatus:
			showTextInputDialog(R.id.btnEditStatus, status,
					getString(R.string.status));
			break;

		case R.id.layEditStatus:
			showTextInputDialog(R.id.btnEditStatus, status,
					getString(R.string.status));
			break;

		case R.id.btnEditCoverPic:
			isCoverPic = true;
			uploadIconFromGalaryOrCamara();
			break;

		case R.id.layEditCoverPic:
			isCoverPic = true;
			uploadIconFromGalaryOrCamara();
			break;

		case R.id.layEditProfilePic:
			isCoverPic = false;
			uploadIconFromGalaryOrCamara();
			break; 
			
		case R.id.relativeLayoutForGeoTag: 
			geoTagFunction();
			break; 
			
		case R.id.relativeLayoutForUploadPhoto: 
			uploadPhoto(); 
			break;

		default:
			break;
		}

	}

	public void spinnerShowRelationshipOption() {
		AlertDialog dialog;

		final String str[] = getResources().getStringArray(
				R.array.relationshipOptions);

		final String[] relArray = new String[str.length - 1];

		for (int i = 0; i < str.length; i++) {
			if (i > 0) {
				relArray[i - 1] = str[i];
			}
		}

		// final String str[] = { "Single", "Married", "Complicated" };

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		// builder.setTitle("Select...");
		builder.setItems(relArray, new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int position) {
				// here you can use like this... str[position]

				// Toast.makeText(context, str[position], 1000).show();
				tvRelationshipStatus.setText(relArray[position]);

			}

		});
		dialog = builder.create();
		dialog.show();

	}

	private void showDialogToUpdateInfo() {
		// TODO Auto-generated method stub
		final AlertDialog.Builder aBuilder = new AlertDialog.Builder(context);
		aBuilder.setTitle("Save changes");
		aBuilder.setIcon(R.drawable.icon_alert);
		aBuilder.setMessage("Do you want save changes before exit from Profile?");

		aBuilder.setPositiveButton(getString(R.string.yesLabel),
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(final DialogInterface dialog,
							final int which) {

						updateSettings();
						dialog.dismiss();
					}

				});

		aBuilder.setNegativeButton(getString(R.string.noLabel),
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(final DialogInterface dialog,
							final int which) {
						dialog.dismiss();
						ProfileActivity.this.finish();
					}

				});

		aBuilder.show();
	}

	private void showDatePicker() {
		// TODO Auto-generated method stub

		String date = StaticValues.myInfo.getDateOfBirth().split("\\s+")[0];

		Log.w("Date of birth in showDatePicker after spliting \\s", date);

		int selectedYear = 0;
		int selectedMonth = 0;
		int selectedDay = 0;

		try {
			String[] splits = date.split("-");
			selectedYear = Integer.parseInt(splits[0]);
			selectedMonth = Integer.parseInt(splits[1]);
			selectedDay = Integer.parseInt(splits[2]);
		} catch (Exception e) {
			// TODO: handle exception
			selectedYear = now.get(Calendar.YEAR);
			selectedMonth = now.get(Calendar.MONTH) + 1;
			selectedDay = now.get(Calendar.DATE);
		}

		DatePickerDialog datePickerDialog = new DatePickerDialog(
				ProfileActivity.this, new OnDateSetListener() {
					@Override
					public void onDateSet(DatePicker arg0, int arg1, int arg2,
							int arg3) {
						StringBuilder sb = new StringBuilder();
						String month, day;
						if (arg2 < 9) {
							month = "0".concat(Integer.toString(arg2 + 1));
						} else {
							month = Integer.toString(arg2 + 1);
						}
						if (arg3 < 9) {
							day = "0".concat(Integer.toString(arg3));
						} else {
							day = Integer.toString(arg3);
						}
						sb.append(arg1).append("-").append(month).append("-")
								.append(day);
						dob = sb.toString();

						Log.d("dob", dob);

						// tvAge.setText(dob);

						age = Utility.calculateAge(sb.toString()) + " years";
						tvAge.setText(age);

					}

				}, selectedYear, selectedMonth - 1, selectedDay);

		// now.get(Calendar.YEAR), now.get(Calendar.MONTH),
		// now.get(Calendar.DATE));

		datePickerDialog.show();
	}

	/*
	 * calculate user age in years
	 */
	/*
	 * public int calculateAge(String dateOfB) {
	 * 
	 * String dateOfBirth = dateOfB;// "12-15-1982";
	 * 
	 * DateFormat dateFormat = new SimpleDateFormat("MM-dd-yyyy");
	 * 
	 * String currentDate = dateFormat.format(new Date());
	 * 
	 * // String currentDate = "10-18-2012"; int age = 0; int factor = 0;
	 * 
	 * try { Calendar cal1 = new GregorianCalendar(); Calendar cal2 = new
	 * GregorianCalendar();
	 * 
	 * Date date1 = new SimpleDateFormat("MM-dd-yyyy").parse(dateOfBirth); Date
	 * date2 = new SimpleDateFormat("MM-dd-yyyy").parse(currentDate);
	 * cal1.setTime(date1); cal2.setTime(date2); if
	 * (cal2.get(Calendar.DAY_OF_YEAR) < cal1.get(Calendar.DAY_OF_YEAR)) {
	 * factor = -1; } age = cal2.get(Calendar.YEAR) - cal1.get(Calendar.YEAR) +
	 * factor; System.out.println("Your age is: " + age); } catch
	 * (ParseException e) { System.out.println(e); }
	 * 
	 * return age; }
	 */

	private void uploadIconFromGalaryOrCamara() {
		// TODO Auto-generated method stub
		final CharSequence[] items = { "Gallery", "Camera" };
		AlertDialog.Builder builder = new AlertDialog.Builder(
				ProfileActivity.this);
		builder.setTitle("Select");
		builder.setItems(items, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int item) {
				Toast.makeText(getApplicationContext(), items[item],
						Toast.LENGTH_SHORT).show();
				if (items[item].equals("Gallery")) {
					requestCode = ProfileActivity.REQUEST_CODE_GALLERY;
				} else {
					requestCode = ProfileActivity.REQUEST_CODE_CAMERA;
				}
				onOptionItemSelected(requestCode);
			}

		});
		AlertDialog alert = builder.create();
		alert.show();
	}

	public boolean onOptionItemSelected(int requestCode) {
		switch (requestCode) {
		case ProfileActivity.REQUEST_CODE_GALLERY:
			Intent intent = new Intent();
			intent.setType("image/*");
			intent.setAction(Intent.ACTION_GET_CONTENT);
			startActivityForResult(
					Intent.createChooser(intent, "Select Picture"), requestCode);
			break;
		case ProfileActivity.REQUEST_CODE_CAMERA:
			Intent cameraIntent = new Intent(
					android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(cameraIntent, requestCode);
			break;
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == ProfileActivity.REQUEST_CODE_CAMERA) {
			if (resultCode == RESULT_OK) {

				if (isCoverPic) {

					if (coverPic != null) {
						coverPic.recycle();
					}

					// coverPic = (Bitmap) data.getExtras().get("data");
					coverPic = Utility.resizeBitmap((Bitmap) data.getExtras()
							.get("data"), Constant.profileCoverWidth,
							Constant.profileCoverHeight);

					ivCoverPic.setImageBitmap(coverPic);

				} else {

					if (avatar != null) {
						avatar.recycle();
					}

					// avatar = (Bitmap) data.getExtras().get("data");
					avatar = Utility.resizeBitmap((Bitmap) data.getExtras()
							.get("data"), Constant.thumbWidth,
							Constant.thumbHeight);

					ivProfilePic.setImageBitmap(avatar);

				}

			}

			if (resultCode == RESULT_CANCELED) {
				return;
			}

		} else if (requestCode == ProfileActivity.REQUEST_CODE_GALLERY) {
			if (resultCode == RESULT_OK) {
				// imageUri = data.getData();
				try {

					if (isCoverPic) {

						// avatar =
						// MediaStore.Images.Media.getBitmap(this.getContentResolver(),
						// data.getData());
						if (coverPic != null) {
							coverPic.recycle();
						}
						coverPic = Utility.resizeBitmap(
								MediaStore.Images.Media.getBitmap(
										this.getContentResolver(),
										data.getData()),
								Constant.profileCoverWidth,
								Constant.profileCoverHeight);
						ivCoverPic.setImageBitmap(coverPic);

					} else {

						// avatar =
						// MediaStore.Images.Media.getBitmap(this.getContentResolver(),
						// data.getData());
						if (avatar != null) {
							avatar.recycle();
						}
						avatar = Utility.resizeBitmap(
								MediaStore.Images.Media.getBitmap(
										this.getContentResolver(),
										data.getData()), Constant.thumbWidth,
								Constant.thumbHeight);
						ivProfilePic.setImageBitmap(avatar);

					}

				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch(OutOfMemoryError e) {
					
					Log.e("Gallery image", "OutOfMemoryError");
					Toast.makeText(context, getString(R.string.errorMessageGallery), Toast.LENGTH_SHORT).show();
					e.printStackTrace();
				}catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
				// ivProfilePicture.setImageURI(imageUri);
			}
		}
	}

	// TODO Auto-generated method stub
	public void showTextInputDialog(final int id, final String text, String hint) {

		Log.w("showTextInputDialog into", "id: " + id + " text:" + text);

		// custom dialog
		final Dialog dialog = new Dialog(context, R.style.CustomDialogTheme);
		dialog.setContentView(R.layout.input_text_dialog_layout);

		dialog.setOnDismissListener(new OnDismissListener() {

			@Override
			public void onDismiss(DialogInterface dialog) {
				// TODO Auto-generated method stub
				Utility.hideKeyboard(ProfileActivity.this);
			}
		});

		final EditText etInputText = (EditText) dialog
				.findViewById(R.id.etInputText);

		etInputText.setHint(hint);
		if (text != null && !text.trim().equalsIgnoreCase("")) {
			etInputText.setText(text);
		}

		// TextView tvTitle = (TextView) dialog.findViewById(R.id.tvTitle);

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

					switch (id) {

					case R.id.living_in_layout:
						city = inputText;
						tvCity.setText(inputText);
						break;

					case R.id.work_at_layout:
						workStatus = inputText;
						tvCompany.setText(inputText);
						break;
					case R.id.btnEditStatus:
						status = inputText;
						tvStatusMessage.setText(inputText);
						break;

					default:
						break;
					}
					// Utility.hideKeyboard(EventNewActivity.this);
					dialog.dismiss();
				}

			}
		});

		// String title = "";
		// String hint = "";
		// String text = "";
		//
		// switch (type) {
		// case 1:
		// title = "Enter name:";
		// hint = "Name";
		// text = eventName;
		// break;
		// case 2:
		// title = "Enter summary:";
		// hint = "Summary";
		// text = eventSummary;
		// break;
		// case 3:
		// title = "Enter description:";
		// hint = "Description";
		// text = eventDescription;
		// break;
		// default:
		// break;
		// }
		//
		// tvTitle.setText(title);
		// etInputText.setHint(hint);
		// if (!text.equalsIgnoreCase("")) {
		// etInputText.setText(text);
		// }

		dialog.show();
	}

	public void updateSettings() {
		boolean flag = true;

		// if (!Utility.isValidEmailID(etEmail.getText().toString().trim())) {
		// flag = false;
		// etEmail.setError("Invalid Email Id");
		// } else if (etFirstName.getText().toString().trim().equals("")) {
		// flag = false;
		// etFirstName.setError("First Name can not be empty.");
		// } else if (etLastName.getText().toString().trim().equals("")) {
		// flag = false;
		// etLastName.setError("Last Name can not be empty.");
		// }

		/*
		 * else if (etUserName.getText().toString().trim().equals("")) { flag =
		 * false; etUserName.setError("User Name can not be empty."); }
		 */

		if (flag) {
			if (Utility.isConnectionAvailble(getApplicationContext())) {

				Thread thread = new Thread(null, updatePersonalInfo,
						"Start update password");
				thread.start();
				m_ProgressDialog = ProgressDialog.show(this, getResources()
						.getString(R.string.please_wait_text), getResources()
						.getString(R.string.updating_data_text), true);

			} else {

				DialogsAndToasts.showNoInternetConnectionDialog(context);
			}
		}
	}

	private Runnable updatePersonalInfo = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			sendDataToServer();
		}

		private void sendDataToServer() {
			flag = "INFO";
			String avatarString = "";
			String coverPicString = "";

			RestClient client = new RestClient(Constant.smAccountSettingsUrl);

			client.AddHeader(Constant.authTokenParam,
					Utility.getAuthToken(context));

			if (status != null) {
				client.AddParam("status", status);
			}

			Log.w("Date of birth in addParam  >>>>>>>", dob);
			if (dob != null) {
				if (!dob.equals("")) {
					client.AddParam("dateOfBirth", dob);
				}
			}

			if (tvRelationshipStatus != null) {
				client.AddParam("relationshipStatus", tvRelationshipStatus
						.getText().toString().trim());
			}

			if (city != null) {
				client.AddParam("city", city);
			}

			if (workStatus != null) {
				client.AddParam("workStatus", workStatus);
			}

			/*
			 * Profile pic upload to Server
			 */

			if (avatar != null) {

				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();

				// Bitmap resizedAvatar =
				// Utility.resizeBitmap(avatar,Constant.thumbWidth,
				// Constant.thumbHeight);
				// resizedAvatar.compress(Bitmap.CompressFormat.PNG,
				// 60,full_stream);
				avatar.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				avatarString = Base64
						.encodeToString(full_bytes, Base64.DEFAULT);

				client.AddParam("avatar", avatarString);

				// avatar.recycle();
			}

			/*
			 * Cover pic upload to Server
			 */

			if (coverPic != null) {

				ByteArrayOutputStream full_stream = new ByteArrayOutputStream();
				coverPic.compress(Bitmap.CompressFormat.PNG, 60, full_stream);

				byte[] full_bytes = full_stream.toByteArray();
				coverPicString = Base64.encodeToString(full_bytes,
						Base64.DEFAULT);

				Log.w("Cover Pic >>>>>>>>", coverPicString);

				client.AddParam("coverPhoto", coverPicString);

				// avatar.recycle();
			}

			try {
				client.Execute(RestClient.RequestMethod.PUT);
			} catch (Exception e) {
				e.printStackTrace();
			}

			responseString = client.getResponse();

			responseStatus = client.getResponseCode();

			runOnUiThread(returnRes);
		}
	};

	private Runnable returnRes = new Runnable() {

		@Override
		public void run() {
			handleResponseSavePersonalInfo(responseStatus, responseString);
			m_ProgressDialog.dismiss();
		}
	};

	public void handleResponseSavePersonalInfo(int status, String response) {
		Log.d("Registration", status + ":" + response);
		switch (status) {
		case Constant.STATUS_SUCCESS:
			// Log.d("Login", status+":"+response);
			Toast.makeText(getApplicationContext(),
					"Profile changed successfully.", Toast.LENGTH_SHORT).show();

			MyInfo myInfo = ServerResponseParser.parseUserProfileInfo(response,
					false);

			if (myInfo != null) {
				StaticValues.myInfo.setStatusMsg(myInfo.getStatusMsg());
				StaticValues.myInfo.setAvatar(myInfo.getAvatar());
				StaticValues.myInfo.setCoverPhoto(myInfo.getCoverPhoto());
				StaticValues.myInfo.setAge(myInfo.getAge());
				StaticValues.myInfo.setDateOfBirth(myInfo.getDateOfBirth());
				StaticValues.myInfo.setRelationshipStatus(myInfo
						.getRelationshipStatus());
				StaticValues.myInfo.setCity(myInfo.getCity());
				StaticValues.myInfo.setWorkStatus(myInfo.getWorkStatus());
			}

			ProfileActivity.this.finish();
			// updateLocalValue(response);
			if (flag.equals("INFO"))
				// personalInfoPanel.togglePanel();
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
	
	private void geoTagFunction() 
	{
		//Toast.makeText(getApplicationContext(), "Coming Soon", Toast.LENGTH_SHORT).show(); 
		
		Intent intentForGeoTag = new Intent(context, GeoTagActivity.class); 
		startActivity(intentForGeoTag);
	} 
	
	private void uploadPhoto()
	{
		/*Intent intentForUploadPhoto = new Intent(context, UploadPhotoActivity.class);
		startActivity(intentForUploadPhoto);*/ 
		
		Toast.makeText(context, "Coming Soon", Toast.LENGTH_SHORT).show();
	}
	
	

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();

		if (avatar != null) {
			avatar.recycle();
		}
		if (coverPic != null) {
			coverPic.recycle();
		}

		System.gc();
	}

	/*
	 * private void onLoad() {
	 * if(Utility.isConnectionAvailble(getApplicationContext())) {
	 * tempURLString=Constant.profileInfoUrl;
	 * responseString=Data.getServerResponse(tempURLString); Log.d("response",
	 * responseString); responseObject=Data.parseResponse(responseString);
	 * responseDataString=responseObject.getData(); Log.d("responseData",
	 * responseDataString);
	 * 
	 * try { JSONObject jsonObject = new JSONObject(responseDataString);
	 * profileInfoObject=new ProfileInfo(); profileInfoObject.setBio(
	 * jsonObject.getString("bio"));
	 * profileInfoObject.setCity(jsonObject.getString("city"));
	 * profileInfoObject.setCountry(jsonObject.getString("country"));
	 * profileInfoObject.setDateOfBirth(jsonObject.getString("dob"));
	 * profileInfoObject.setEmail(jsonObject.getString("email"));
	 * profileInfoObject.setFirstName(jsonObject.getString("first_name"));
	 * profileInfoObject.setLastName(jsonObject.getString("last_name"));
	 * profileInfoObject.setPostCode(jsonObject.getString("post_code"));
	 * profileInfoObject.setProfilePic(jsonObject.getString("profile_pic"));
	 * profileInfoObject.setRegMedia(jsonObject.getString("reg_media"));
	 * profileInfoObject
	 * .setRelationshipStatus(jsonObject.getString("relationship_status"));
	 * profileInfoObject.setService(jsonObject.getString("service"));
	 * profileInfoObject.setSmID(jsonObject.getInt("sm_id"));
	 * profileInfoObject.setStreetAddress
	 * (jsonObject.getString("street_address"));
	 * 
	 * tvName.setText(profileInfoObject.getFirstName().concat("".concat(
	 * profileInfoObject.getLastName())));
	 * tvAge.setText(Integer.toString(Utility
	 * .calculateAge(profileInfoObject.getDateOfBirth())));
	 * tvLivesIn.setText(profileInfoObject
	 * .getCity().concat(", ".concat(profileInfoObject.getCountry())));
	 * tvWork.setText(profileInfoObject.getService()); try {
	 * ivProfilePicture.setImageBitmap
	 * (BitmapFactory.decodeStream((InputStream)new
	 * URL(profileInfoObject.getProfilePic()).getContent())); } catch
	 * (MalformedURLException e) { e.printStackTrace(); } catch (IOException e)
	 * { e.printStackTrace(); }
	 * 
	 * if(profileInfoObject.getRegMedia().equals("fb")) {
	 * ivRegistationMedium.setImageResource(R.drawable.facebookicon); } else {
	 * ivRegistationMedium.setImageResource(R.drawable.ic_launcher); } } catch
	 * (JSONException e) { e.printStackTrace(); } } else {
	 * Toast.makeText(getApplicationContext(),
	 * "Internet Connection Unavailable", Toast.LENGTH_SHORT).show(); } }
	 */

}
