package com.socmaps.widget;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckedTextView;

import com.socmaps.entity.Place;
import com.socmaps.ui.R;

public class NearByPlacesAdapter extends ArrayAdapter<Place> {

	Context context;
	int layoutResourceId;
	List<Place> itemList = null;

	public NearByPlacesAdapter(Context context, int layoutResourceId,
			List<Place> itemList) {
		super(context, layoutResourceId, itemList);
		// TODO Auto-generated constructor stub
		this.context = context;
		this.layoutResourceId = layoutResourceId;
		this.itemList = itemList;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = convertView;
		ItemHolder holder = null;

		if (row == null) {
			LayoutInflater inflater = ((Activity) context).getLayoutInflater();
			row = inflater.inflate(layoutResourceId, parent, false);

			holder = new ItemHolder();

			holder.itemTitle = (CheckedTextView) row
					.findViewById(R.id.itemTitle);

			row.setTag(holder);
		} else {
			holder = (ItemHolder) row.getTag();
		}

		Place place = itemList.get(position);
		holder.itemTitle.setText(place.getName());

		return row;
	}

	static class ItemHolder {
		CheckedTextView itemTitle;
	}

}
