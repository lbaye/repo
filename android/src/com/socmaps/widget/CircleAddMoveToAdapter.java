package com.socmaps.widget;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckedTextView;

import com.socmaps.entity.Circle;
import com.socmaps.ui.R;
import com.socmaps.util.Utility;

/**
 * CircleAddMoveToAdapter class for generating circle list item.
 *
 */
public class CircleAddMoveToAdapter extends ArrayAdapter<Circle> {

	Context context;
	private List<Circle> itemList = null;
	private List<String> selectedCircleList = null;

	/**
	 * Generates a Circle list which is corresponding to list item or row.
	 * 
	 * @param context
	 *            Current active Context
	 * @param layoutResourceId
	 *            Layout Id in Integer to inflate corresponding Layout
	 * @param itemList
	 *            is the List of Circles object
	 * @param selectedCircleList
	 *            List of String which are selected item (id) of circle list
	 * @see LayoutInflater
	 * @see Context
	 */
	public CircleAddMoveToAdapter(Context context, int layoutResourceId,
			List<Circle> itemList, List<String> selectedCircleList) {
		super(context, layoutResourceId, itemList);
		// TODO Auto-generated constructor stub
		this.context = context;
		this.itemList = itemList;
		this.selectedCircleList = selectedCircleList;

		Utility.log("itemList size: " + itemList.size(), "selectedCircleList: "
				+ selectedCircleList.size());
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		ItemHolder holder = null;

		if (v == null) {

			LayoutInflater inflater = (LayoutInflater) context
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

			v = inflater.inflate(R.layout.create_circle_list_item, null);

			holder = new ItemHolder();

			holder.itemTitle = (CheckedTextView) v
					.findViewById(R.id.circleNameTxt);

			v.setTag(holder);
		} else {
			holder = (ItemHolder) v.getTag();
		}

		Circle circle = itemList.get(position);

		holder.itemTitle.setText(circle.getName() + " ("
				+ circle.getFriendList().size() + ")");

		Utility.log("circle.getId() in getView() " + circle.getId(), "selecetdId: "
				+ selectedCircleList);

		return v;
	}

	private static class ItemHolder {
		public CheckedTextView itemTitle;

	}

}
