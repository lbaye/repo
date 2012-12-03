package com.socmaps.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.view.Window;

import com.socmaps.ui.LoginActivity;
import com.socmaps.ui.R;

public class DialogsAndToasts {

	public static void showNoInternetConnectionDialog(final Context c) {
		AlertDialog.Builder builder = new AlertDialog.Builder(c);
		builder.setTitle("Error!!");
		builder.setMessage("Sorry! No internet connection!!");
		builder.setCancelable(true)
				.setPositiveButton("Settings",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int id) {
								((Activity) c)
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

	public static Dialog showExtendedInfoDialog(Context c, int layoutResId) {
		
		Dialog dialog = new Dialog(c,R.style.CustomDialogTheme);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(layoutResId);

		dialog.setCancelable(true);

		return dialog;
	}

	public static Dialog showSendMessage(final Context c) {
		Dialog dialog = new Dialog(c);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(R.layout.send_message_dialog_layout);

		dialog.setCancelable(true);

		return dialog;
	}

	public static Dialog showAddFrnd(final Context c) {
		Dialog dialog = new Dialog(c);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(R.layout.send_friend_request_dialog_layout);

		dialog.setCancelable(true);

		return dialog;
	}

}
