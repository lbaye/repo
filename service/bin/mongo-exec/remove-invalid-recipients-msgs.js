var msg = db.messages.find();
var noRcpts = [];

msg.forEach(function(m) {
  if (m.recipients != null) {
    m.recipients.forEach(function(r) {
        var u = db.users.findOne({_id: r});

        if (u == null) {
	  noRcpts.push(m.content);
          db.messages.remove({_id: m._id});
        }

    });
  }
});

return noRcpts;