package com.socmaps.ui;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.TextView;

import com.socmaps.entity.Information;

/**
 * InformationAdapter class responsible for generating list view.
 * 
 */
public class InformationAdapter extends ArrayAdapter<Information> {
	Context context;
	int layoutResourceId;
	Information data[] = null;

	static class InformationHolder {
		TextView tvTitle;
		CheckBox chkInfoSharingSettings;
	}

	/**
	 * This is the constructor which is used to refer & to assign values. Super
	 * method is used to give a call to a method of the superclass in the base
	 * class.
	 * 
	 * @param context
	 *            which is current state of the application/object.
	 * @param layoutResourceId
	 *            as Integer which is the id of layout resource.
	 * @param data
	 *            as the array list of type Information.
	 */

	public InformationAdapter(Context context, int layoutResourceId,
			Information[] data) {
		super(context, layoutResourceId, data);
		this.layoutResourceId = layoutResourceId;
		this.context = context;
		this.data = data;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = convertView;
		InformationHolder holder = null;

		if (row == null) {
			LayoutInflater inflater = ((Activity) context).getLayoutInflater();
			row = inflater.inflate(layoutResourceId, parent, false);

			holder = new InformationHolder();
			holder.chkInfoSharingSettings = (CheckBox) row
					.findViewById(R.id.chkInfoSharingSettings);
			holder.tvTitle = (TextView) row.findViewById(R.id.tvTitle);

			row.setTag(holder);
		} else {
			holder = (InformationHolder) row.getTag();
		}

		Information information = data[position];
		holder.tvTitle.setText(information.title);
		holder.chkInfoSharingSettings.setChecked(information.isSet);

		return row;
	}
}
