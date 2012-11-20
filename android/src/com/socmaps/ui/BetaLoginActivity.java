package com.socmaps.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

import com.socmaps.util.Constant;
import com.socmaps.util.Utility;

public class BetaLoginActivity extends Activity implements OnClickListener {
	EditText etPassword;
	Button btnLogin;
	Button btnWebsiteLinkBeta;
	Context context;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.beta_login_layout);

		initialize();

	}

	private void initialize() {

		context = BetaLoginActivity.this;
		etPassword = (EditText) findViewById(R.id.etPassword);
		btnLogin = (Button) findViewById(R.id.btnLogin);
		btnLogin.setOnClickListener(this);
		btnWebsiteLinkBeta = (Button) findViewById(R.id.btnWebsiteLinkBeta);
		btnWebsiteLinkBeta.setOnClickListener(this);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub

		if (v == btnLogin) {
			if (etPassword.getText().toString().length() == 0) {
				etPassword.setError("Password cannot be empty");
			} else {

				if (etPassword.getText().toString()
						.equals(Constant.betaPassword)) {
					Intent intent = new Intent(context, LoginActivity.class);

					// save shared pref
					Utility.setBetaAuthenticationStatus(context, true);

					startActivity(intent);
					finish();
				} else {
					etPassword
							.setError("Password does not match. Please try again.");
				}
			}
		} else if (v == btnWebsiteLinkBeta) {
			Intent browserIntent = new Intent(Intent.ACTION_VIEW,
					Uri.parse(Constant.socialmapsWebUrl));
			startActivity(browserIntent);
		}

	}

}
