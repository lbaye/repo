/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import java.util.ArrayList;
import java.util.List;

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.socmaps.entity.People;
import com.socmaps.entity.Place;
import com.socmaps.entity.SecondDegreePeople;
import com.socmaps.images.singly.RemoteImageCache;
import com.socmaps.ui.R;
import com.socmaps.util.StaticValues;
import com.socmaps.util.Utility;

/**
 * NearByPlacesPicker generates a custom dialog to display near by place list
 * item.
 * 
 */
public class SearchResultDialog extends Dialog implements OnItemClickListener, View.OnClickListener {
	private Button btnCancel;

	SearchResultDialogListener searchResultDialogListener;
	private Context context;
	private String pickerName;

	private ArrayList<Object> objcetList;

	private Object selectedObject;

	private ListView listView;

	public RemoteImageCache remoteImageCache;

	public SearchResultDialog(Context context, SearchResultDialogListener searchResultDialogListener, String pickerName, List<Object> objcetList) {
		super(context);
		this.searchResultDialogListener = searchResultDialogListener;
		this.context = context;
		this.pickerName = pickerName;
		this.objcetList = (ArrayList<Object>) objcetList;
		remoteImageCache = new RemoteImageCache(context, 20, null, 50);

		/** It will hide the title */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.search_result_dialog);

		initialize();
		generateList();

	}

	private void initialize() {

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

		listView = (ListView) findViewById(R.id.listView);

	}

	@Override
	public void onClick(View v) {

		if (v == btnCancel) {
			dismiss();
		}

	}

	private void generateList() {

		if (objcetList != null) {

			ListAdapter myListAdapter = new ListAdapter(context, objcetList);

			listView.setAdapter(myListAdapter);

			listView.setOnItemClickListener(this);
		}

	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int index, long arg3) {
		// TODO Auto-generated method stub
		selectedObject = objcetList.get(index);

		searchResultDialogListener.onPlaceSelect(pickerName, selectedObject);
		dismiss();

		remoteImageCache.shutdown();

		System.gc();
	}

	private class ListAdapter extends BaseAdapter {
		Context mContext;
		final ArrayList<Object> mItems;

		public ListAdapter(Context context, ArrayList<Object> items) {
			// TODO Auto-generated constructor stub
			mContext = context;
			mItems = items;

		}

		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			return mItems.size();
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			// TODO Auto-generated method stub
			ViewHolder myViewHolder;
			if (convertView == null) {
				convertView = LayoutInflater.from(mContext).inflate(R.layout.search_item, null);
				myViewHolder = new ViewHolder();
				myViewHolder.txt_name = (TextView) convertView.findViewById(R.id.name_text);
				myViewHolder.tvStatus = (TextView) convertView.findViewById(R.id.status_text);
				myViewHolder.age = (TextView) convertView.findViewById(R.id.age_text);
				myViewHolder.distance = (TextView) convertView.findViewById(R.id.distance_text);

				myViewHolder.ivOnline = (ImageView) convertView.findViewById(R.id.ivOnline);
				myViewHolder.avatar = (ImageView) convertView.findViewById(R.id.balloon_item_image);

				convertView.setTag(myViewHolder);
			} else {
				myViewHolder = (ViewHolder) convertView.getTag();

			}

			if (mItems.get(position) instanceof People) {

				People people = (People) mItems.get(position);

				myViewHolder.txt_name.setText(Utility.getItemTitle(people));

				if (Utility.isValidString(people.getStatusMsg())) {
					myViewHolder.tvStatus.setText(people.getStatusMsg());
					myViewHolder.tvStatus.setVisibility(View.VISIBLE);
				} else
					myViewHolder.tvStatus.setVisibility(View.GONE);

				int ageValue = people.getAge();
				if (ageValue != 0) {
					myViewHolder.age.setText("-Age: " + ageValue);
					myViewHolder.age.setVisibility(View.VISIBLE);
				} else
					myViewHolder.age.setVisibility(View.GONE);

				double distanceValue = Utility.calculateDistanceFromCurrentLocation(people.getPoint());
				myViewHolder.distance.setText(Utility.getFormatedDistance(distanceValue, StaticValues.myInfo.getSettings().getUnit()) + " away");

				myViewHolder.ivOnline.setVisibility(View.VISIBLE);
				if (people.isOnline()) {
					myViewHolder.ivOnline.setImageResource(R.drawable.online);
				}else{
					myViewHolder.ivOnline.setImageResource(R.drawable.offline);
				}

				myViewHolder.avatar.setImageResource(R.drawable.img_blank);
				String avatarUrl = people.getAvatar();
				if (Utility.isValidString(avatarUrl)) {
					Utility.setImage(people.getId(), avatarUrl, myViewHolder.avatar, remoteImageCache);
				}

			} else if (mItems.get(position) instanceof Place) {

				Place place = (Place) mItems.get(position);

				String title = place.getName();
				if (title != null && !title.equals("")) {
					myViewHolder.txt_name.setText(title);
				}

				String iconUrl = place.getIconUrl();
				if (Utility.isValidString(iconUrl)) {
					Utility.setImage(place.getId(), iconUrl, myViewHolder.avatar, remoteImageCache);

				}

				double distanceValue = Utility.calculateDistanceFromCurrentLocation(place.getPoint());
				myViewHolder.distance.setText(Utility.getFormatedDistance(distanceValue, StaticValues.myInfo.getSettings().getUnit()) + " away");

				String address = place.getVicinity();
				if (address != null && !address.equals("")) {
					myViewHolder.tvStatus.setText(address);
				}

				myViewHolder.ivOnline.setVisibility(View.INVISIBLE);

			} else if (mItems.get(position) instanceof SecondDegreePeople) {

				SecondDegreePeople secondDegreePeople = (SecondDegreePeople) mItems.get(position);

				myViewHolder.txt_name.setText(Utility.getItemTitle(secondDegreePeople));

				String sName = secondDegreePeople.getCurrentAddress();
				if (sName != null && !sName.equals("")) {
					myViewHolder.tvStatus.setText(sName);
				} else {
					myViewHolder.tvStatus.setVisibility(View.GONE);
				}

				// int ageValue = secondDegreePeople.getAge();
				// if (ageValue != 0) {
				// myViewHolder.age.setText("-Age: " + ageValue);
				// myViewHolder.age.setVisibility(View.VISIBLE);
				// } else
				// myViewHolder.age.setVisibility(View.GONE);

				double distanceValue = Utility.calculateDistanceFromCurrentLocation(secondDegreePeople.getPoint());
				myViewHolder.distance.setText(Utility.getFormatedDistance(distanceValue, StaticValues.myInfo.getSettings().getUnit()) + " away");

				myViewHolder.avatar.setImageResource(R.drawable.img_blank);
				String avatarUrl = secondDegreePeople.getAvatar();
				if (Utility.isValidString(avatarUrl)) {
					Utility.setImage(secondDegreePeople.getRefId(), avatarUrl, myViewHolder.avatar, remoteImageCache);
				}

				myViewHolder.ivOnline.setVisibility(View.INVISIBLE);

			}

			return convertView;
		}

		 class ViewHolder {
			TextView txt_name;
			TextView tvStatus;
			TextView age;
			TextView distance;
			ImageView ivOnline;
			ImageView avatar;
		}
	}

}