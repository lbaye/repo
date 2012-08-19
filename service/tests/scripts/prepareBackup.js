/** primary key indexes **/
db.getCollection("meetups").ensureIndex({"_id": NumberInt(1) },[]);
db.getCollection("events").ensureIndex({"_id": NumberInt(1) },[]);
db.getCollection("places").ensureIndex({"_id": NumberInt(1) },[]);
db.getCollection("plans").ensureIndex({"_id": NumberInt(1) },[]);
db.getCollection("users").ensureIndex({ "_id": NumberInt(1) },[]);

/** geo spatial indexes */
db.getCollection("deals").ensureIndex({ "location": "2d" });
db.getCollection("users").ensureIndex({ "currentLocation": "2d" });



/** users records **/
db.getCollection("users").insert({
  "_id": ObjectId("5003dffe757df2010d000000"),
  "authToken": "6d16c898c3e9184cf35e65854376685a7f7USER1",
  "circles": [
    {
      "_id": ObjectId("5003dffe757df2010d000001"),
      "name": "friends",
      "type": "system",
      "friends": [
        "5003e8bc757df2020d000006"
      ]
    },
    {
      "_id": ObjectId("5003dffe757df2010d000002"),
      "name": "second_degree",
      "type": "system",
      "friends": [

      ]
    }
  ],
  "confirmationToken": "1ef89d46128886c9d37869886afd7d40ccc9dcfe",
  "createDate": ISODate("2012-07-16T09:33:50.0Z"),
  "dateOfBirth": ISODate("2012-02-14T18:00:00.0Z"),
  "email": "anisniit@gmail.com",
  "enabled": true,
  "firstName": "Anis",
  "friendRequest": [
    {
      "_id": ObjectId("5003e963757df2fd0c000000"),
      "userId": "5003e8bc757df2020d000000",
      "createDate": ISODate("2012-07-16T10:13:55.0Z")
    }
  ],
  "geoFence": {
    "lat": 96,
    "lng": 88,
    "radius": NumberInt(2)
  },
  "lastName": "Ahmad",
  "layersSettings": {
    "wikipedia": false,
    "tripadvisor": true,
    "foodspotting": true
  },
  "locationSettings": {
    "friends": true,
    "strangers": true,
    "max_time": NumberInt(60)
  },
  "notificationSettings": {
    "friend_requests": {
      "sm": false,
      "mail": true
    },
    "posts_by_friends": {
      "sm": true,
      "mail": true
    },
    "comments": {
      "sm": true,
      "mail": true
    },
    "messages": {
      "sm": true,
      "mail": true
    },
    "proximity_alerts": {
      "sm": true,
      "mail": true
    },
    "recommendations": {
      "sm": true,
      "mail": false
    }
  },
  "password": "11adbfbdfa6b4eee0b1454212733d3096a961c83",
  "platformSettings": {
    "fb": true,
    "4sq": true,
    "googlePlus": true,
    "gmail": true,
    "twitter": true,
    "yahoo": true,
    "badoo": true
  },
  "salt": "socialmaps",
  "settings": {
    "distance": NumberInt(0)
  },
  "sharingPreferenceSettings": {
    "firstName": "all",
    "lastName": "all",
    "email": "all",
    "dateOfBirth": "all",
    "bio": "all",
    "interests": "all",
    "workStatus": "all",
    "relationshipStatus": "all",
    "address": "all",
    "friendRequest": "all",
    "circles": "all",
    "newsfeed": "all",
    "avatar": "all",
    "username": "all",
    "name": "all",
    "gender": "all"
  },
  "currentLocation": {
     "lat": 91,
     "lng": 81
  },
  "visible": true,
  "updateDate": ISODate("2012-07-16T11:16:35.0Z")
});
db.getCollection("users").insert({
  "_id": ObjectId("5003e8bc757df2020d000006"),
  "authToken": "2cb110a54ba63027ddd041e01341e22c145USER2",
  "circles": [
    {
      "_id": ObjectId("5003e8bc757df2020d000001"),
      "name": "friends",
      "type": "system",
      "friends": [
        "5003dffe757df2010d000000"
      ]
    },
    {
      "_id": ObjectId("5003e8bc757df2020d000002"),
      "name": "second_degree",
      "type": "system",
      "friends": [

      ]
    }
  ],
  "confirmationToken": "802e6a0b70bd9dbff9a227baee101cbbf5cfe9c8",
  "createDate": ISODate("2012-07-16T10:11:08.0Z"),
  "email": "salayhin@gmail.com",
  "enabled": true,
  "firstName": "sirajus",
  "lastName": "saleyhin",
  "geoFence": {
    "lat": NumberInt(0),
    "lng": NumberInt(0),
    "radius": NumberInt(0)
  },
  "layersSettings": {
    "wikipedia": true,
    "tripadvisor": true,
    "foodspotting": true
  },
  "locationSettings": {
    "friends": true,
    "strangers": true,
    "max_time": NumberInt(60)
  },
  "notification": [
    {
      "_id": ObjectId("5003e963757df2fd0c000001"),
      "objectId": "5003e8bc757df2020d000000",
      "objectType": "FriendRequest"
    }
  ],
  "notificationSettings": {
    "friend_requests": {
      "sm": true,
      "mail": true
    },
    "posts_by_friends": {
      "sm": true,
      "mail": true
    },
    "comments": {
      "sm": true,
      "mail": true
    },
    "messages": {
      "sm": true,
      "mail": true
    },
    "proximity_alerts": {
      "sm": true,
      "mail": true
    },
    "recommendations": {
      "sm": true,
      "mail": true
    }
  },
  "password": "11adbfbdfa6b4eee0b1454212733d3096a961c83",
  "platformSettings": {
    "fb": true,
    "4sq": true,
    "googlePlus": true,
    "gmail": true,
    "twitter": true,
    "yahoo": true,
    "badoo": true
  },
  "salt": "socialmaps",
  "settings": {
    "distance": NumberInt(0)
  },
   "sharingPreferenceSettings": {
    "firstName": "all",
    "lastName": "all",
    "email": "all",
    "dateOfBirth": "all",
    "bio": "all",
    "interests": "all",
    "workStatus": "all",
    "relationshipStatus": "all",
    "address": "all",
    "friendRequest": "all",
    "circles": "all",
    "newsfeed": "all",
    "avatar": "all",
    "username": "all",
    "name": "all",
    "gender": "all"
  },
  "currentLocation": {
     "lat": 90,
     "lng": 80
  },
  "visible": true,
  "updateDate": ISODate("2012-07-16T10:24:40.0Z")
});
db.getCollection("users").insert({
  "_id": ObjectId("5003e8bc757df2020d000000"),
  "authToken": "2cb110a54ba63027ddd041e01342e22c145USER3",
  "circles": [
    {
      "_id": ObjectId("5003e8bc757df2020d000001"),
      "name": "friends",
      "type": "system",
      "friends": [

      ]
    },
    {
      "_id": ObjectId("5003e8bc757df2020d000003"),
      "name": "second_degree",
      "type": "system",
      "friends": [

      ]
    }
  ],
  "confirmationToken": "802e6a0b70bd9dbff9a227baee101cbbf5cfe9c5",
  "createDate": ISODate("2012-07-16T10:11:08.0Z"),
  "email": "emran.hasan@gmail.com",
  "enabled": true,
  "firstName": "emtran",
  "geoFence": {
    "lat": NumberInt(0),
    "lng": NumberInt(0),
    "radius": NumberInt(0)
  },
  "layersSettings": {
    "wikipedia": true,
    "tripadvisor": true,
    "foodspotting": true
  },
  "locationSettings": {
    "friends": true,
    "strangers": true,
    "max_time": NumberInt(60)
  },
  "notification": [
    {
      "_id": ObjectId("5003e963757df2fd0c000001"),
      "objectId": "5003e8bc757df2020d000000",
      "objectType": "FriendRequest"
    }
  ],
  "notificationSettings": {
    "friend_requests": {
      "sm": true,
      "mail": true
    },
    "posts_by_friends": {
      "sm": true,
      "mail": true
    },
    "comments": {
      "sm": true,
      "mail": true
    },
    "messages": {
      "sm": true,
      "mail": true
    },
    "proximity_alerts": {
      "sm": true,
      "mail": true
    },
    "recommendations": {
      "sm": true,
      "mail": true
    }
  },
  "password": "11adbfbdfa6b4eee0b1454212733d3096a961c83",
  "platformSettings": {
    "fb": true,
    "4sq": true,
    "googlePlus": true,
    "gmail": true,
    "twitter": true,
    "yahoo": true,
    "badoo": true
  },
  "salt": "socialmaps",
  "settings": {
    "distance": NumberInt(0)
  },
  "sharingPreferenceSettings": {
    "firstName": "all",
    "lastName": "all",
    "email": "all",
    "dateOfBirth": "all",
    "bio": "all",
    "interests": "all",
    "workStatus": "all",
    "relationshipStatus": "all",
    "address": "all",
    "friendRequest": "all",
    "circles": "all",
    "newsfeed": "all",
    "avatar": "all",
    "username": "all",
    "name": "all",
    "gender": "all"
  },
  "currentLocation": {
     "lat": 90.05,
     "lng": 80.05
  },
  "visible": true,
  "updateDate": ISODate("2012-07-16T10:24:40.0Z")
});

/** events records **/
db.getCollection("events").insert({
   "_id": ObjectId("5020cb1c757df2ff12000000"),
   "title": "Test Event",
   "description": "Desc of event",
   "type": "event",
   "location": {
     "lat": 90.5,
     "lng": 80.87,
     "title": "Test Event"
  },
   "time": ISODate("2012-08-09T20: 20: 00.0Z"),
   "permission": "private",
   "owner": ObjectId("5003dffe757df2010d000000"),
   "createDate": ISODate("2012-08-07T08: 00: 28.0Z")
});
db.getCollection("events").insert({
   "_id": ObjectId("5020cb1c757df2ff12000002"),
   "title": "Another Test Event",
   "description": "Desc of event",
   "type": "event",
   "location": {
     "lat": 90.51,
     "lng": 80.88,
     "title": "Test Event"
  },
   "time": ISODate("2012-08-09T20: 20: 00.0Z"),
   "permission": "public",
   "owner": ObjectId("5003dffe757df2010d000000"),
   "createDate": ISODate("2012-09-07T08: 00: 28.0Z")
});
db.getCollection("events").insert({
   "_id": ObjectId("5003e8bc757df2020d000006"),
   "title": "Test Event another user",
   "description": "Desc of event",
   "location": {
     "lat": 90.5,
     "lng": 80.87,
     "title": "Test Event"
  },
   "time": ISODate("2012-08-09T20: 20: 00.0Z"),
   "permission": "public",
   "owner": ObjectId("5003e8bc757df2020d000006"),
   "createDate": ISODate("2012-08-07T08: 00: 28.0Z")
});


/** meetup records **/
db.getCollection("meetups").insert({
  "_id": ObjectId("5003e8bc757df2020d0f0000"),
  "title": "Test Meetup",
  "description": "A message here",
  "duration": "1 hour",
  "guests": [
    "5003e8bc757df2020d000006",
    "5003e8bc757df2020d000000"
  ],
  "location": {
    "lat": 90.5,
    "lng": 80.87,
    "title": "Test Meetup"
  },
  "time": ISODate("2012-08-09T20:20:00.0Z"),
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "public",
  "permittedUsers": [],
  "permittedCircles": [],
  "createDate": ISODate("2012-08-09T08:12:42.0Z")
});
db.getCollection("meetups").insert({
  "_id": ObjectId("5003e8bc757df2020d0f0001"),
  "title": "Another Test Meetup",
  "description": "A message here",
  "duration": "1 hour",
  "guests": [
    "5003e8bc757df2020d000006",
    "5003e8bc757df2020d000000"
  ],
  "location": {
    "lat": 90.5,
    "lng": 80.87,
    "title": "Test Meetup"
  },
  "time": ISODate("2012-08-09T20:20:00.0Z"),
  "owner": ObjectId("5003e8bc757df2020d000006"),
  "permission": "custom",
  "permittedUsers": [
    "5003e8bc757df2020d000000",
    "5003dffe757df2010d000000"
  ],
  "permittedCircles": [
    "5003e8bc757df2020d000001"
  ],
  "createDate": ISODate("2012-08-09T08:12:42.0Z")
});
db.getCollection("meetups").insert({
  "_id": ObjectId("5003e8bc757df2020d0f0033"),
  "title": "Test Meetup",
  "description": "A message here",
  "duration": "1 hour",
  "guests": [
    "5003e8bc757df2020d000006",
    "5003e8bc757df2020d000000"
  ],
  "location": {
    "lat": 90.5,
    "lng": 80.87,
    "title": "Test Meetup"
  },
  "time": ISODate("2012-08-09T20:20:00.0Z"),
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "private",
  "permittedUsers": [],
  "permittedCircles": [],
  "createDate": ISODate("2012-08-09T08:12:42.0Z")
});

/** plans records **/
db.getCollection("plans").insert({
  "_id": ObjectId("5003e8bc757df2020d0f0060"),
  "title": "Test Plan",
  "location": {
    "lat": 90.5,
    "lng": 80.87,
    "title": "Test Planned place"
  },
  "time": ISODate("2012-08-09T20:20:00.0Z"),
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "public",
  "permittedUsers": [],
  "permittedCircles": [],
  "createDate": ISODate("2012-08-09T08:12:42.0Z")
});
db.getCollection("plans").insert({
  "_id": ObjectId("5003e8bc757df2020d0f0068"),
  "title": "Private Plan",
  "location": {
    "lat": 90.5,
    "lng": 80.87,
    "title": "Test Planned place"
  },
  "time": ISODate("2012-08-09T20:20:00.0Z"),
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "private",
  "permittedUsers": [],
  "permittedCircles": [],
  "createDate": ISODate("2012-08-09T08:12:42.0Z")
});
db.getCollection("plans").insert({
  "_id": ObjectId("5003e8bc757df2020d0f0061"),
  "title": "Test Plan 2",
  "location": {
    "lat": 90.5,
    "lng": 80.87,
    "title": "Test Plan 2"
  },
  "time": ISODate("2012-08-09T20:20:00.0Z"),
  "owner": ObjectId("5003e8bc757df2020d000006"),
  "permission": "custom",
  "permittedUsers": [
    "5003e8bc757df2020d000000",
    "5003dffe757df2010d000000"
  ],
  "permittedCircles": [
    "5003e8bc757df2020d000001"
  ],
  "createDate": ISODate("2012-08-09T08:12:42.0Z")
});

/** places records **/
db.getCollection("places").insert({
  "_id": ObjectId("5003e750757df2000d000000"),
  "title": "My Office 2",
  "type": "place",
  "location": {
    "lat": 80,
    "lng": 56.977,
    "title": "My Office 2",
    "address": "Lalmatia, Dhaka"
  },
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "public",
  "permittedUsers": [],
  "permittedCircles": [],
  "createDate": ISODate("2012-07-16T10:05:04.0Z")
});
db.getCollection("places").insert({
  "_id": ObjectId("5003e750757df2000d000001"),
  "title": "My Office 3",
  "type": "place",
  "location": {
    "lat": 80,
    "lng": 56.977,
    "title": "My Office 2",
    "address": "Lalmatia, Dhaka"
  },
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "private",
  "permittedUsers": [],
  "permittedCircles": [],
  "createDate": ISODate("2012-07-16T10:05:04.0Z")
});
db.getCollection("places").insert({
  "_id": ObjectId("5003e6f9757df23405000002"),
  "createDate": ISODate("2012-07-16T10:03:37.0Z"),
  "location": {
    "lat": 20.8674,
    "lng": 56.977,
    "title": "My Home",
    "address": "Lalmatia, Dhaka"
  },
  "owner": ObjectId("5003e8bc757df2020d000006"),
  "title": "My Home",
  "type": "place",
  "permission": "public",
  "permittedUsers": [],
  "permittedCircles": [],
  "updateDate": ISODate("2012-07-16T10:07:11.0Z")
});

/** Geotags records **/
db.getCollection("places").insert({
  "_id": ObjectId("5003e6f9757df23405000008"),
  "createDate": ISODate("2012-07-16T10:03:37.0Z"),
  "location": {
    "lat": 20.8674,
    "lng": 56.977,
    "title": "My Home",
    "address": "Lalmatia, Dhaka"
  },
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "public",
  "permittedUsers": [],
  "permittedCircles": [],
  "title": "My Home",
  "type": "geotag",
  "updateDate": ISODate("2012-07-16T10:07:11.0Z")
});
db.getCollection("places").insert({
  "_id": ObjectId("5003e6f9757df23405000009"),
  "createDate": ISODate("2012-07-16T10:03:37.0Z"),
  "location": {
    "lat": 20.8674,
    "lng": 56.977,
    "title": "My Home",
    "address": "Lalmatia, Dhaka"
  },
  "owner": ObjectId("5003dffe757df2010d000000"),
  "permission": "private",
  "permittedUsers": [],
  "permittedCircles": [],
  "title": "My Private Home",
  "type": "geotag",
  "updateDate": ISODate("2012-07-16T10:07:11.0Z")
});
db.getCollection("places").insert({
  "_id": ObjectId("5003e6f9757df23405000099"),
  "createDate": ISODate("2012-07-16T10:03:37.0Z"),
  "location": {
    "lat": 20.8674,
    "lng": 56.977,
    "title": "My Home",
    "address": "Lalmatia, Dhaka"
  },
  "owner": ObjectId("5003dffe757df2010d000006"),
  "permission": "public",
  "permittedUsers": [],
  "permittedCircles": [],
  "title": "My Home",
  "type": "geotag",
  "updateDate": ISODate("2012-07-16T10:07:11.0Z")
});

/** deals records **/
db.getCollection("deals").insert({
  "_id": ObjectId("500ed567757df23105000001"),
  "title": "A football club in Dhaka",
  "description": "I have not tried removing the extends Base, but I'm curious as to why that would affect the outcome of the query. Base is an Abstract class I made just to handle some simple operations common to all models. I'm able to run other queries against ODM with stellar success.",
  "link": "http://www.bracbank.com/",
  "maplink": "https://maps.google.com/maps?f=d&source=s_d&saddr=Dhaka,+Bangladesh&daddr=&hl=en&geocode=CZUgR70GmSI1FeHIaQEd54BjBSmBawKHsLhVNzHCBFndu2Oljw&sll=23.709924,90.407138&sspn=0.021847,0.040555&vpsrc=6&mra=mift&ie=UTF8&t=m&z=15&iwloc=ddw0",
  "category": "sports",
  "location": {
    "lng": 80.05,
    "lat": 90.05
  },
  "createDate": ISODate("2012-07-24T17:03:35.0Z")
});
db.getCollection("deals").insert({
  "_id": ObjectId("500ed64a757df2c00b000001"),
  "createDate": ISODate("2012-07-24T17:03:35.0Z"),
  "title": "A cafe in Dhaka",
  "description": "I have not tried removing the extends Base, but I'm curious as to why that would affect the outcome of the query. Base is an Abstract class I made just to handle some simple operations common to all models. I'm able to run other queries against ODM with stellar success.",
  "link": "http://www.bracbank.com/",
  "maplink": "https://maps.google.com/maps?f=d&source=s_d&saddr=Dhaka,+Bangladesh&daddr=&hl=en&geocode=CZUgR70GmSI1FeHIaQEd54BjBSmBawKHsLhVNzHCBFndu2Oljw&sll=23.709924,90.407138&sspn=0.021847,0.040555&vpsrc=6&mra=mift&ie=UTF8&t=m&z=15&iwloc=ddw0",
  "category": "cafe",
  "location": {
    "lng": 80.1,
    "lat": 90.1
  }
});