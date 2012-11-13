package com.socmaps.widget;

import java.util.List;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckedTextView;

import com.socmaps.entity.Circle;
import com.socmaps.ui.R;

public class CircleAddMoveToAdapter extends ArrayAdapter<Circle> {

	Context context;
	private int layoutResourceId;
	private List<Circle> itemList = null;
	private List<String> selectedCircleList = null;

	public CircleAddMoveToAdapter(Context context, int layoutResourceId,
			List<Circle> itemList, List<String> selectedCircleList) {
		super(context, layoutResourceId, itemList);
		// TODO Auto-generated constructor stub
		this.context = context;
		this.layoutResourceId = layoutResourceId;
		this.itemList = itemList;
		this.selectedCircleList = selectedCircleList;

		Log.w("itemList size: " + itemList.size(), "selectedCircleList: "
				+ selectedCircleList.size());
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		ItemHolder holder = null;

		if (v == null) {

			LayoutInflater inflater = (LayoutInflater) context
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

			// v = inflater.inflate(layoutResourceId, null);

			v = inflater.inflate(R.layout.create_circle_list_item, null);

			holder = new ItemHolder();

			holder.itemTitle = (CheckedTextView) v
					.findViewById(R.id.circleNameTxt);

			// holder.title = (TextView) v.findViewById(R.id.tvTitle);

			// holder.checkBox = (CheckBox) v
			// .findViewById(R.id.chkInfoSharingSettings);

			v.setTag(holder);
		} else {
			holder = (ItemHolder) v.getTag();
		}

		Circle circle = itemList.get(position);

		holder.itemTitle.setText(circle.getName() + " ("
				+ circle.getFriendList().size() + ")");

		// holder.title.setText(circle.getName() + " ("
		// + circle.getFriendList().size() + ")");

		Log.i("circle.getId() in getView() " + circle.getId(), "selecetdId: "
				+ selectedCircleList);

		// if (selectedCircleList.contains(circle.getId())) {
		//
		// holder.itemTitle.setChecked(true);
		//
		// // holder.checkBox.setChecked(true);
		//
		// Log.w("circle.getId() in if condition " + circle.getId(),
		// "selecetdId: " + circle.getId());
		//
		// } else {
		// holder.itemTitle.setChecked(false);
		// }

		return v;
	}

	private static class ItemHolder {
		public CheckedTextView itemTitle;

		// public TextView title;
		// public CheckBox checkBox;

	}

}
