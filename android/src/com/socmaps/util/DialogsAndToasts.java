package com.socmaps.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.view.Window;

import com.socmaps.ui.R;

/**
 * DialogsAndToasts generates custom dialog and toast.
 * 
 */
public class DialogsAndToasts {

	/**
	 * Shows appropriate Dialog if Internet connection is unavailable.
	 * 
	 * @param context
	 *            Currently active Context
	 */
	public static void showNoInternetConnectionDialog(final Context context) {
		AlertDialog.Builder builder = new AlertDialog.Builder(context);
		builder.setTitle("Error!!");
		builder.setMessage("Sorry! No internet connection!!");
		builder.setCancelable(true)
				.setPositiveButton("Settings",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								((Activity) context)
										.startActivity(new Intent(
												android.provider.Settings.ACTION_WIRELESS_SETTINGS));
							}
						})
				.setNegativeButton("Ok", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int id) {
						dialog.cancel();
					}
				});
		AlertDialog alert = builder.create();
		alert.show();
	}



	/**
	 * Generate Dialog with custom layout.
	 * 
	 * @param context
	 *            Currently active Context
	 * @param layoutResId
	 *            Resource ID of the layout
	 * @return Dialog with custom layout
	 */
	public static Dialog showExtendedInfoDialog(Context context, int layoutResId) {

		Dialog dialog = new Dialog(context, R.style.CustomDialogTheme);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(layoutResId);

		dialog.setCancelable(true);

		return dialog;
	}

	/**
	 * Create custom Dialog for sending message.
	 * 
	 * @param context
	 *            Currently active Context
	 * @return Custom Dialog for sending message
	 */
	public static Dialog showSendMessage(final Context context) {
		Dialog dialog = new Dialog(context);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(R.layout.send_message_dialog_layout);

		dialog.setCancelable(true);

		return dialog;
	}

	/**
	 * Create custom Dialog for sending friend request.
	 * 
	 * @param context
	 *            Currently active Context
	 * @return Custom Dialog for sending friend request
	 */
	public static Dialog showAddFrnd(final Context context) {
		Dialog dialog = new Dialog(context);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(R.layout.send_friend_request_dialog_layout);

		dialog.setCancelable(true);

		return dialog;
	}

}
