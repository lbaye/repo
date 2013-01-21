db.users.update({username: ''}, {$set: {username: null}}, {multi: 1});

var users = db.users.find({username: ''});
var un = [];

users.forEach(function(u) {
  un.push(u.username);
});

return un;