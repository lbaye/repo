package com.socmaps.util;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore.MediaColumns;
import android.util.Log;

public class Data {
	public static String getServerResponse(String serverUrl) {
		String responseString = null;
		URL url = null;

		try {
			url = new URL(serverUrl);

			Log.e("Request: ", serverUrl);

			URLConnection conn = url.openConnection();
			// Get the response
			BufferedReader rd = new BufferedReader(new InputStreamReader(
					conn.getInputStream()));
			StringBuffer sb = new StringBuffer();
			String line;
			while ((line = rd.readLine()) != null) {
				sb.append(line);
			}
			rd.close();

			responseString = sb.toString();
			Log.e("Response: ", responseString);

		} catch (Exception e) {
			Log.e("Server error", e.getMessage());
			// e.printStackTrace();
		}

		return responseString;
	}

	public static String upload(Uri imageUri, String serverUrl, Context c) {
		HttpURLConnection connection = null;
		DataOutputStream outputStream = null;
		String responseString = null;

		String lineEnd = "\r\n";
		String twoHyphens = "--";
		String boundary = "*****";

		int bytesRead, bytesAvailable, bufferSize;
		byte[] buffer;
		int maxBufferSize = 1 * 1024 * 1024;

		try {
			String[] filePathColumn = { MediaColumns.DATA };

			Cursor cursor = c.getContentResolver().query(imageUri,
					filePathColumn, null, null, null);
			cursor.moveToFirst();

			int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
			String filePath = cursor.getString(columnIndex);
			cursor.close();

			// Bitmap yourSelectedImage = BitmapFactory.decodeFile(filePath);

			// Bitmap bm=BitmapFactory.decodeFile(imageUri.getPath());
			FileInputStream fileInputStream = new FileInputStream(new File(
					filePath));

			URL url = new URL(serverUrl);
			connection = (HttpURLConnection) url.openConnection();

			// Allow Inputs & Outputs
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setUseCaches(false);

			// Enable POST method
			connection.setRequestMethod("POST");

			connection.setRequestProperty("Connection", "Keep-Alive");
			connection.setRequestProperty("Content-Type",
					"multipart/form-data;boundary=" + boundary);

			outputStream = new DataOutputStream(connection.getOutputStream());
			outputStream.writeBytes(twoHyphens + boundary + lineEnd);
			outputStream
					.writeBytes("Content-Disposition: form-data; name=\"original_image_bynary\";filename=\""
							+ filePath + "\"" + lineEnd);
			outputStream.writeBytes(lineEnd);

			bytesAvailable = fileInputStream.available();
			bufferSize = Math.min(bytesAvailable, maxBufferSize);
			buffer = new byte[bufferSize];

			// Read file
			bytesRead = fileInputStream.read(buffer, 0, bufferSize);

			while (bytesRead > 0) {
				outputStream.write(buffer, 0, bufferSize);
				bytesAvailable = fileInputStream.available();
				bufferSize = Math.min(bytesAvailable, maxBufferSize);
				bytesRead = fileInputStream.read(buffer, 0, bufferSize);
			}

			outputStream.writeBytes(lineEnd);
			outputStream.writeBytes(twoHyphens + boundary + twoHyphens
					+ lineEnd);

			BufferedReader rd = new BufferedReader(new InputStreamReader(
					connection.getInputStream()));
			StringBuffer sb = new StringBuffer();
			String line;
			while ((line = rd.readLine()) != null) {
				sb.append(line);
			}
			rd.close();

			responseString = sb.toString();
			fileInputStream.close();
			outputStream.flush();
			outputStream.close();
		} catch (Exception ex) {
			ex.printStackTrace();
			// Exception e=ex;
		}

		return responseString;

	}

	public static JSONObject getJSONfromURL(String url) {
		// initialize
		InputStream is = null;
		String result = "";
		JSONObject jArray = null;

		Log.e("URL: ", url);

		// http post
		try {
			HttpClient httpclient = new DefaultHttpClient();
			HttpPost httppost = new HttpPost(url);
			HttpResponse response = httpclient.execute(httppost);
			HttpEntity entity = response.getEntity();
			is = entity.getContent();

		} catch (Exception e) {
			Log.e("getJSONfromURL", "Error in http connection " + e.toString());
		}

		// convert response to string
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					is, "iso-8859-1"), 8);
			StringBuilder sb = new StringBuilder();
			String line = null;
			while ((line = reader.readLine()) != null) {
				sb.append(line + "\n");
			}
			is.close();
			result = sb.toString();
		} catch (Exception e) {
			Log.e("getJSONfromURL", "Error converting result " + e.toString());
		}

		Log.e("Response: ", result);
		// try parse the string to a JSON object
		try {
			jArray = new JSONObject(result);
		} catch (JSONException e) {
			Log.e("getJSONfromURL", "Error parsing data " + e.toString());
		}

		return jArray;
	}

	public static String createUrl(String serverUrl,
			HashMap<String, String> paramMap, String separator) {
		int paramCounter = 0;

		Iterator<String> myVeryOwnIterator = paramMap.keySet().iterator();
		while (myVeryOwnIterator.hasNext()) {
			String key = myVeryOwnIterator.next();
			String value = paramMap.get(key);

			if (paramCounter == 0) {
				serverUrl += separator + key + "=" + URLEncoder.encode(value);
			} else {
				serverUrl += "&" + key + "=" + URLEncoder.encode(value);
			}

			paramCounter++;
		}

		return serverUrl;
	}

}
