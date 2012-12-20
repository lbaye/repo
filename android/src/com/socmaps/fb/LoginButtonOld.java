/*
 * Copyright 2010 Facebook, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.socmaps.fb;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.socmaps.fb.SessionEvents.AuthListener;
import com.socmaps.fb.SessionEvents.LogoutListener;

public class LoginButtonOld extends Button {

	private Facebook mFb;
	private Handler mHandler;
	private SessionListener mSessionListener = new SessionListener();
	private String[] mPermissions;
	private Activity mActivity;
	private int mActivityCode;

	private String loginLabel = "Login";
	private String logoutLabel = "Logout";

	public LoginButtonOld(Context context) {
		super(context);
	}

	public LoginButtonOld(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public LoginButtonOld(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public void init(final Activity activity, final int activityCode,
			final Facebook fb) {
		init(activity, activityCode, fb, new String[] {}, loginLabel,
				logoutLabel);
	}

	public void init(final Activity activity, final int activityCode,
			final Facebook fb, final String[] permissions, String loginLabel,
			String logoutLabel) {
		mActivity = activity;
		mActivityCode = activityCode;
		mFb = fb;
		mPermissions = permissions;
		mHandler = new Handler();
		this.loginLabel = loginLabel;
		this.logoutLabel = logoutLabel;

		drawableStateChanged();

		SessionEvents.addAuthListener(mSessionListener);
		SessionEvents.addLogoutListener(mSessionListener);
		setOnClickListener(new ButtonOnClickListener());
	}

	private final class ButtonOnClickListener implements OnClickListener {
		/*
		 * Source Tag: login_tag
		 */
		// @Override
		public void onClick(View arg0) {
			if (mFb.isSessionValid()) {

				Log.e("LoginButton", "isSessionValid = true");

				SessionEvents.onLogoutBegin();
				AsyncFacebookRunner asyncRunner = new AsyncFacebookRunner(mFb);
				asyncRunner.logout(getContext(), new LogoutRequestListener());
			} else {
				Log.e("LoginButton", "isSessionValid = false");
				mFb.authorize(mActivity, mPermissions, mActivityCode,
						new LoginDialogListener());
			}
		}
	}

	private final class LoginDialogListener implements DialogListener {
		// @Override
		public void onComplete(Bundle values) {
			Log.e("LoginDialogListener", "onComplete");
			SessionEvents.onLoginSuccess();
		}

		// @Override
		public void onFacebookError(FacebookError error) {
			Log.e("LoginDialogListener", "onFacebookError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		public void onError(DialogError error) {
			Log.e("LoginDialogListener", "onError");
			SessionEvents.onLoginError(error.getMessage());
		}

		// @Override
		public void onCancel() {
			Log.e("LoginDialogListener", "onCancel");
			SessionEvents.onLoginError("Action Canceled");
		}
	}

	private class LogoutRequestListener extends BaseRequestListener {
		// @Override
		public void onComplete(String response, final Object state) {
			/*
			 * callback should be run in the original thread, not the background
			 * thread
			 */
			mHandler.post(new Runnable() {
				// @Override
				public void run() {
					SessionEvents.onLogoutFinish();
				}
			});
		}
	}

	private class SessionListener implements AuthListener, LogoutListener {

		// @Override
		public void onAuthSucceed() {
			setText(logoutLabel);
			SessionStore.save(mFb, getContext());
		}

		// @Override
		public void onAuthFail(String error) {
		}

		// @Override
		public void onLogoutBegin() {
		}

		// @Override
		public void onLogoutFinish() {
			SessionStore.clear(getContext());
			setText(loginLabel);
		}
	}

}
