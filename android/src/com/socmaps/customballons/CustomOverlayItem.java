/***
 * Copyright (c) 2011 readyState Software Ltd
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

package com.socmaps.customballons;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.OverlayItem;
import com.socmaps.entity.AccountSettingsEntity;
import com.socmaps.entity.OtherUserEntity;

public class CustomOverlayItem extends OverlayItem {


	private OtherUserEntity user;
	
	
	/*public CustomOverlayItem(OtherUserEntity ou) {
		super(new GeoPoint((int)(ou.getCurrentLat()),(int)(ou.getCurrentLng())), "test", "test");
		
		
		this.user=ou;
	}*/

	public CustomOverlayItem(GeoPoint point, String title, String snipet, OtherUserEntity ou) {
		super(point,title,snipet);
		
		
		this.user=ou;
	}
	public String getImageURL() {
		return user.getAvatar();
	}

	public void setImageURL(String imageURL) {
		this.user.setAvatar(imageURL);
	}
	
	public OtherUserEntity getUser() {
		return user;
	}

	public void setUser(OtherUserEntity ou) {
		this.user = ou;
	}
	
	
}
