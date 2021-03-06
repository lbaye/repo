/**
 * 
 */
package com.socmaps.widget;

/**
 * @author hasan.mahadi
 *
 */

import java.util.List;

import android.app.Dialog;
import android.content.Context;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;

import com.socmaps.entity.Place;
import com.socmaps.ui.R;


/**
 * NearByPlacesPicker generates a custom dialog to display near by place list item.
 *
 */
public class NearByPlacesPicker extends Dialog implements OnItemClickListener,
		View.OnClickListener {
	Button btnCancel, btnOk;

	NearByPlacesPickerListener nearByPlacesPickerListener;
	Context context;
	String pickerName;

	List<Place> placeList;

	Place selectedPlace;

	ListView listView; 
	
	/**
	 * Initialization of NearByPlacesPicker using those specified parameters. 
	 * 
	 * @param context Currently active Context 
	 * @param nearByPlacesPickerListener An intance of NearByPlacesPickerListener. 
	 * @param pickerName As String which indicates a text that Near To Me. 
	 * @param placeList An array list of type Place which is the list of places those are near to my place. 
	 */

	public NearByPlacesPicker(Context context,
			NearByPlacesPickerListener nearByPlacesPickerListener,
			String pickerName, List<Place> placeList) {
		this(context, nearByPlacesPickerListener, pickerName, placeList, null);
	} 
	
	/**
	 * Initialization of NearByPlacesPicker using those specified parameters. 
	 * 
	 * @param context Currently active Context 
	 * @param nearByPlacesPickerListener An intance of NearByPlacesPickerListener. 
	 * @param pickerName As String which indicates a text that Near To Me. 
	 * @param placeList An array list of type Place which is the list of places those are near to my place.  
	 * @param selectedPlace An object of type Place which indicates the pre-selected item. 
	 * @see #initialize() 
	 * @see #generateList()
	 */

	public NearByPlacesPicker(Context context,
			NearByPlacesPickerListener nearByPlacesPickerListener,
			String pickerName, List<Place> placeList, Place selectedPlace) {
		super(context);
		this.nearByPlacesPickerListener = nearByPlacesPickerListener;
		this.context = context;
		this.pickerName = pickerName;
		this.placeList = placeList;
		this.selectedPlace = selectedPlace;

		/** It will hide the title */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.nearby_places_picker_dialog);

		initialize();
		generateList();

	}

	private void initialize() {

		btnCancel = (Button) findViewById(R.id.btnCancel);
		btnCancel.setOnClickListener(this);

		btnOk = (Button) findViewById(R.id.btnOk);
		btnOk.setOnClickListener(this);

		listView = (ListView) findViewById(R.id.listView);

	}

	@Override
	public void onClick(View v) {
		if (v == btnCancel) {
			dismiss();
		}
		if (v == btnOk) {

			nearByPlacesPickerListener.onPlaceSelect(pickerName, selectedPlace);
			dismiss();
		}

	}

	private void generateList() {

		if (placeList != null) {
			NearByPlacesAdapter nearByPlacesAdapter = new NearByPlacesAdapter(
					context, R.layout.row_list_item_single_select, placeList);

			listView.setAdapter(nearByPlacesAdapter);

			listView.setOnItemClickListener(this);
		}

	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int index, long arg3) {
		// TODO Auto-generated method stub
		selectedPlace = placeList.get(index);
	}

}