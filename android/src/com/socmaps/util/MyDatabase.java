package com.socmaps.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Vector;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class MyDatabase {

	public class MyDatabaseHelper extends SQLiteOpenHelper {

		private static final String CREATE_TABLE_SOCIALMAPS = "create table "
				+ MyDatabase.TABLE_SOCIALMAPS
				+ " ( ID integer primary key autoincrement, " + "object BLOB, "
				+ "keyWord TEXT )";

		public MyDatabaseHelper(final Context context) {
			super(context, MyDatabase.DB_NAME, null, MyDatabase.DB_VERSION);
		}

		@Override
		public void onCreate(final SQLiteDatabase sqLiteDatabase) {

			sqLiteDatabase.execSQL(MyDatabaseHelper.CREATE_TABLE_SOCIALMAPS);

		}

		@Override
		public void onUpgrade(final SQLiteDatabase db, final int oldVersion,
				final int newVersion) {
			// TODO Auto-generated method stub

		}

	}

	private static final int DB_VERSION = 1;

	private static final String DB_NAME = "socialmaps";

	public static final String TABLE_SOCIALMAPS = "socialmapsTable";

	SQLiteDatabase db;

	MyDatabaseHelper dbOpenHelper;

	public MyDatabase(final Context context) {

		// TODO Auto-generated constructor stub
		dbOpenHelper = new MyDatabaseHelper(context);
		db = dbOpenHelper.getWritableDatabase();
	}

	public void deleteAllObjectRows() {
		db.delete(MyDatabase.TABLE_SOCIALMAPS, null, null);

		Log.w("data is deleted from  database ", "Deleted");
	}

	// public void deleteEntry(final int rowID) {
	//
	// db.delete(FavDatabase.TABLE_FAVCHECKIN, "cid = " + rowID, null);
	//
	// Log.w("data is deleted from  database ", "data is deleted " + rowID);
	// }

	// public void deleteEntryByString(final String rowID) {
	//
	// Log.d("Delete entity in Fav Database id ?>>? ", rowID);
	//
	// db.delete(MyDatabase.TABLE_SOCIALMAPS, "cid ='" + rowID + "'", null);
	//
	// Log.w("data is deleted from  database ", "data is deleted " + rowID);
	// }

	public Vector<Object> getAllObject() {

		final Vector<Object> set = new Vector<Object>();

		final Cursor cursor = db.query(MyDatabase.TABLE_SOCIALMAPS,
				new String[] { " ID,object,keyWord" }, null, null, null, null,
				null);

		if (cursor.moveToFirst()) {
			do {

				final Object q = new Object();

				// q.setImageName(cursor.getString(1));
				// q.setIsSendToMail(cursor.getString(2));

				set.add(q);

			} while (cursor.moveToNext());

		}
		if (cursor != null && !cursor.isClosed()) {
			cursor.close();
			// db.close();
		}
		return set;
	}

	public Vector<Object> getObjectByKeyWord(String keyWord) {

		final Vector<Object> set = new Vector<Object>();

		// final Cursor cursor = db.query(MyDatabase.TABLE_SOCIALMAPS,
		// new String[] { " ID,object,keyWord" }, null, null, null, null, null);

		final Cursor cursor = db.query(MyDatabase.TABLE_SOCIALMAPS,
				new String[] { " ID,object,keyWord" }, "keyWord IN (" + "'"
						+ keyWord + "')", null, null, null, null);

		if (cursor.moveToFirst()) {
			do {

				Object q = new Object();

				q = convertByteToObject(cursor.getBlob(1));

				// q.setImageName(cursor.getString(1));
				// q.setIsSendToMail(cursor.getString(2));

				set.add(q);

			} while (cursor.moveToNext());

		}
		if (cursor != null && !cursor.isClosed()) {
			cursor.close();
			// db.close();
		}
		return set;
	}

	// public void updateSendMailStatus(final BookZap q) {
	//
	// final ContentValues cv = new ContentValues();
	// final String pos = q.getImageName());
	//
	// cv.put("id_f", q.getId());
	// // cv.put("flagf", q.getFlagf());
	//
	// Log.d("data is updaetd to database 111", "data is updated" + q.getId());
	//
	// db.update(FavDatabase.TABLE_MAIL_SEND_STATUS, cv, "ID = " + pos, null);
	// Log.d("data is updaetd to database ", "data is updated" + q.getId());
	//
	// }

	public void updateObject(String imageName, String value) {

		final ContentValues cv = new ContentValues();
		final String pos = imageName;

		cv.put("isSend", value);
		// cv.put("flagf", q.getFlagf());
		// Log.d("data is updaetd to database 111", "data is updated" +
		// q.getId());

		db.update(MyDatabase.TABLE_SOCIALMAPS, cv, "imageName = '" + pos + "'",
				null);
		Log.d("data is updaetd to database ", "imageName:" + pos + " value is:"
				+ value);

	}

	public long insertObject(Object blobObject, String keyWord) {

		final ContentValues cv = new ContentValues();

		// Log.d("q.getId() in FavDatabase what?", q.getFullname());

		cv.put("object", convertObjectToByte(blobObject));
		cv.put("keyWord", keyWord.trim());

		final long pr = db.insertOrThrow(MyDatabase.TABLE_SOCIALMAPS, null, cv);

		// Log.w("data is added to database ", " ImageName: " + name +
		// " status: "
		// + status + pr);

		return pr;

	}

	public byte[] convertObjectToByte(Object obj) {
		ByteArrayOutputStream b = new ByteArrayOutputStream();
		ObjectOutputStream o;

		try {
			o = new ObjectOutputStream(b);
			o.writeObject(obj);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return b.toByteArray();
	}

	public Object convertByteToObject(byte[] bytes) {
		ByteArrayInputStream b = new ByteArrayInputStream(bytes);
		ObjectInputStream o;

		Object ob = null;

		try {
			o = new ObjectInputStream(b);

			ob = o.readObject();

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return ob;
	}

	public void closeAllResource() {

		if (db.isOpen()) {
			db.close();

			Log.w("I am in database !!!1", "closed db");

		}

	}

	/*
	 * public class Serializer { public static byte[] serialize(Object obj)
	 * throws IOException { ByteArrayOutputStream b = new
	 * ByteArrayOutputStream(); ObjectOutputStream o = new
	 * ObjectOutputStream(b); o.writeObject(obj); return b.toByteArray(); }
	 * 
	 * public static Object deserialize(byte[] bytes) throws IOException,
	 * ClassNotFoundException { ByteArrayInputStream b = new
	 * ByteArrayInputStream(bytes); ObjectInputStream o = new
	 * ObjectInputStream(b); return o.readObject(); } }
	 */
}
