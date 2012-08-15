package com.socmaps.util;

import com.socmaps.ui.AccountSettingsActivity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;

public class DialogsAndToasts {

	
	public static void showNoInternetConnectionDialog(final Context c)
	{
		AlertDialog.Builder builder = new AlertDialog.Builder(c);
		builder.setTitle("Error!!");
		builder.setMessage("Sorry! No internet connection!!");
		builder.setCancelable(true)
				.setPositiveButton("Settings",
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int id) {
								((Activity)c).startActivity(new Intent(android.provider.Settings.ACTION_WIRELESS_SETTINGS));
							}
						}).setNegativeButton("Ok", new DialogInterface.OnClickListener() {
	                           public void onClick(DialogInterface dialog, int id) {
	                                dialog.cancel();
	                           }
	                       });
		AlertDialog alert = builder.create();
		alert.show();
	}
	
}
