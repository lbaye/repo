/**
 * 
 */
package com.socmaps.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.util.ArrayList;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.protocol.HTTP;

import android.util.Log;

/**
 * @author hasan.mahadi
 * 
 */
public class RestClient {

	private ArrayList<NameValuePair> params;
	private ArrayList<NameValuePair> headers;

	private String url;

	private int responseCode;
	private String message;

	private String response;

	public static enum RequestMethod {
		GET, POST, PUT, DELETE
	}

	public int timeoutConnection = 20000;// in milliseconds, 20 seconds
	public int timeoutSocket = 20000; // in milliseconds, 20 seconds 
	
	
	
	/**
	 * Returns Response of web service as String. When a user asked for an web service & if it is executed, it'll return it's response. 
	 * 
	 * @return  response of web service.
	 * @see String.
	 */

	public String getResponse() {
		return response;
	} 
	
	/**
	 * Returns Error message as String. When a user asked for an web service & if it fails, it'll return it's error message.
	 * 
	 * @return  error message of web service. 
	 * @see String.
	 */

	public String getErrorMessage() {
		return message;
	} 
	
	/**
	 * Returns Response code(Status Code) as Integer. When a user asked for an web service & executes it & based on the result, it'll return an Integer value which indicates it's status. 
	 * 
	 * @return  Status Code.
	 * @see Integer.
	 */

	public int getResponseCode() {
		return responseCode;
	} 
	
	/** 
	 * Initialization of RestClient constructor with specific URL.
	 * 
	 * @param String 
	 */

	public RestClient(String url) {
		this.url = url;
		params = new ArrayList<NameValuePair>();
		headers = new ArrayList<NameValuePair>();
	} 
	
	/**
	 * AddParam method is used to store key-value pair. When we'll send our data/information to web service, that data will go as key-value pair. 
	 * each key will have a specific value. 
	 * 
	 * @param name as String which indicates key. 
	 * @param value as String which indicates the value of that particular key. 
	 * @see #BasicNameValuePair(name, value).
	 */

	public void AddParam(String name, String value) {
		params.add(new BasicNameValuePair(name, value));
	} 
	
	/**
	 * AddParams method is used to store an array list. On that Array List, entries are stored as Key-Value pair. 
	 * 
	 * @param param which is an ArrayList of NameValuePair.  
	 */
	
	public void AddParams(ArrayList<NameValuePair> param) {
		params = param;
	} 
	
	/**
	 * AddHeader method is used to store key-value pair. When we'll send our data/information to web service,  Basically on that time, we used to 
	 * send our own Authentication Token value using key-value pair through this method. 
	 * 
	 * @param name as String which indicates key. 
	 * @param value as String which indicates the value of that particular key. 
	 * @see #BasicNameValuePair(name, value).
	 */

	public void AddHeader(String name, String value) {
		headers.add(new BasicNameValuePair(name, value));
	} 
	
	/**
	 * Execute method is used to execute our web service based on our priority or demand. "Get" is used for retrieving data from server, "Post: is used 
	 * for sending data to server, "Put" is used for if there is any cases of Edit while "Delete" is used for deletion of something from web server. 
	 * 
	 * @param GET or POST or PUT or DELETE. it's depends based on service call. 
	 * @see #HttpGet(url + combinedParams), #executeRequest(request, url), addHeader(), getName(), getValue(), setEntity() methods 
	 * @see Exception 
	 */

	public void Execute(RequestMethod method) throws Exception {
		switch (method) {
		case GET: {
			// add parameters
			String combinedParams = "";
			if (!params.isEmpty()) {
				combinedParams += "?";
				for (NameValuePair p : params) {
					String paramString = p.getName() + "="
							+ URLEncoder.encode(p.getValue(), "UTF-8");
					if (combinedParams.length() > 1) {
						combinedParams += "&" + paramString;
					} else {
						combinedParams += paramString;
					}
				}
			}

			HttpGet request = new HttpGet(url + combinedParams);

			// add headers
			for (NameValuePair h : headers) {
				request.addHeader(h.getName(), h.getValue());
			}

			executeRequest(request, url);
			break;
		}
		case POST: {
			HttpPost request = new HttpPost(url);

			// add headers
			for (NameValuePair h : headers) {
				request.addHeader(h.getName(), h.getValue());
			}

			if (!params.isEmpty()) {
				request.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
			}

			executeRequest(request, url);
			break;
		}

		case PUT: {
			HttpPut request = new HttpPut(url);

			// add headers
			for (NameValuePair h : headers) {
				request.addHeader(h.getName(), h.getValue());
			}

			if (!params.isEmpty()) {
				request.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
			}

			executeRequest(request, url);
			break;
		}

		case DELETE: {
			HttpDelete request = new HttpDelete(url);

			// add headers
			for (NameValuePair h : headers) {
				request.addHeader(h.getName(), h.getValue());
			}

			if (!params.isEmpty()) {
				// request.setEntity(new UrlEncodedFormEntity(params,
				// HTTP.UTF_8));
			}

			executeRequest(request, url);
			break;
		}
		}
	}

	private void executeRequest(HttpUriRequest request, String url) {
		BasicHttpParams httpParams = new BasicHttpParams();
		// HttpConnectionParams.setConnectionTimeout(httpParams,
		// timeoutConnection);
		// HttpConnectionParams.setSoTimeout(httpParams, timeoutSocket);
		// HttpClient client = new DefaultHttpClient(httpParams);

		HttpClient client = new DefaultHttpClient();

		HttpResponse httpResponse;

		try {
			httpResponse = client.execute(request);
			responseCode = httpResponse.getStatusLine().getStatusCode();
			message = httpResponse.getStatusLine().getReasonPhrase();

			// httpResponse.getHeaders(name)

			HttpEntity entity = httpResponse.getEntity();

			if (entity != null) {

				InputStream instream = entity.getContent();
				response = convertStreamToString(instream);

				// Closing the input stream will trigger connection release
				instream.close();
			}

		} catch (ClientProtocolException e) {
			Log.e("REST Client", "protocol:" + e.getMessage());
			client.getConnectionManager().shutdown();
			e.printStackTrace();
		} catch (IOException e) {
			Log.e("REST Client", "" + e.getMessage());
			client.getConnectionManager().shutdown();
			e.printStackTrace();
		}
	}

	private static String convertStreamToString(InputStream is) {

		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder sb = new StringBuilder();

		String line = null;
		try {
			while ((line = reader.readLine()) != null) {
				sb.append(line + "\n");
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return sb.toString();
	} 
	
	/**
	 * This method defines the maximum times in seconds to make a connection with server to deal further steps. If we unable to make 
	 * a connection within this time, then the Http connection will automatically discard.   
	 * 
	 * @param timeInSeconds as Integer. 
	 */

	public void setConnectionTimeout(int timeInSeconds) {
		timeoutConnection = timeInSeconds * 1000;
	} 
	
	/**
	 * This method defines the maximum time in seconds to be able for data transfer between sockets.     
	 * 
	 * @param timeInSeconds as Integer. 
	 */

	public void setSocketTimeout(int timeInSeconds) {
		timeoutSocket = timeInSeconds * 1000;
	}

}