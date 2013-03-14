package com.socmaps.widget;

import android.graphics.Bitmap;

public interface ImageDownloadListener {

	public void onDownloadComplete(String itemId, Bitmap bitmap,
			String imageUrl);
}
