// Generated by CoffeeScript 1.4.0
(function() {
  var NewsfeedApp;

  NewsfeedApp = (function() {

    function NewsfeedApp($) {
      this.$ = $;
      this.bindButtonsEvents();
      this.initCurrentState();
    }

    NewsfeedApp.prototype.setBaseUrl = function(baseUrl) {
      this.baseUrl = baseUrl;
    };

    NewsfeedApp.prototype.getBaseUrl = function() {
      return this.baseUrl;
    };

    NewsfeedApp.prototype.setAuthToken = function(authToken) {
      this.authToken = authToken;
    };

    NewsfeedApp.prototype.getAuthToken = function() {
      return this.authToken;
    };

    NewsfeedApp.prototype.initCurrentState = function() {
      var that;
      that = this;
      return this.$('\\*[data-liked="true"]').each(function() {
        var el;
        el = that.$(this);
        return that.disableButton(el);
      });
    };

    NewsfeedApp.prototype.bindButtonsEvents = function() {
      var that;
      that = this;
      this.$('.link_like').click(function() {
        return that.tapOnLike(that.$(this));
      });
      this.$('.link_comment').click(function() {
        return that.tapOnComment(that.$(this));
      });
      return this.$('.link_close').live('click', function() {
        return that.tapOnCloseLikesPanel(that.$(this));
      });
    };

    NewsfeedApp.prototype.tapOnLike = function(el) {
      if (this.isDisabled(el)) {
        this.showMessage('success', 'You have already liked it!');
        return this.loadLikes(el);
      } else {
        return this.likeThis(el);
      }
    };

    NewsfeedApp.prototype.tapOnComment = function(el) {
      return alert('Comment');
    };

    NewsfeedApp.prototype.tapOnCloseLikesPanel = function(el) {
      return this.$('#' + el.attr('data-objectid') + '_' + el.attr('data-type')).hide();
    };

    NewsfeedApp.prototype.loadLikes = function(el) {
      var listEl, objectId, that;
      that = this;
      listEl = this.$('#' + el.attr('data-likes'));
      objectId = el.attr('data-objectid');
      return this.sendRequestTo('/newsfeed/' + objectId + '/likes.html', 'GET').success(function(r) {
        return that.$('#' + objectId + '_likes').html(r).show();
      });
    };

    NewsfeedApp.prototype.likeThis = function(el) {
      var that, uri;
      that = this;
      uri = '/newsfeed/' + el.attr('data-objectid') + '/like';
      this.sendRequestTo(uri).success(function(r) {
        return that.processServerResponse(el, r);
      }).complete(function(r) {
        return that.loadLikes(el);
      });
      this.incrementCount(this.$(el), 1);
      return this.disableButton(this.$(el));
    };

    NewsfeedApp.prototype.processServerResponse = function(el, response) {
      this.showMessage('success', response.message);
      if ('false' === response.status) {
        return this.incrementCount(el, -1);
      }
    };

    NewsfeedApp.prototype.sendRequestTo = function(uri, method) {
      var url;
      if (method == null) {
        method = 'PUT';
      }
      url = this.getBaseUrl() + uri;
      return this.$.ajax({
        url: url,
        type: method,
        headers: {
          'Auth-Token': this.getAuthToken()
        }
      });
    };

    NewsfeedApp.prototype.showMessage = function(type, message) {
      var el, that;
      that = this;
      el = this.getMessagePanel();
      el.removeClass(type).addClass(type);
      el.html(message);
      el.show();
      if (this.timer !== null) {
        clearTimeout(this.timer);
      }
      return this.timer = setTimeout(function() {
        return that.hideMessage();
      }, 4000);
    };

    NewsfeedApp.prototype.hideMessage = function() {
      return this.getMessagePanel().hide();
    };

    NewsfeedApp.prototype.getMessagePanel = function() {
      var elId;
      elId = '__noticePanel';
      if (this.$('#' + elId).length === 0) {
        this.$('body').append('<div style="display:none" class="notice-panel" id="' + elId + '"></div>');
      }
      return this.$('#' + elId);
    };

    NewsfeedApp.prototype.incrementCount = function(el, count) {
      var existingCount, label;
      label = el.text();
      existingCount = parseInt(label.trim().split(/\s*/)[0], 10);
      return el.text((existingCount + count) + ' Likes');
    };

    NewsfeedApp.prototype.isDisabled = function(el) {
      return el.attr('data-ui-enabled') === 'false' || el.hasClass('disabled');
    };

    NewsfeedApp.prototype.disableButton = function(el) {
      return el.css('data-ui-enabled', 'false').removeClass('enabled').addClass('disabled');
    };

    NewsfeedApp.prototype.enableButton = function(el) {
      return el.css('data-ui-enabled', 'true').removeClass('disabled').addClass('enabled');
    };

    return NewsfeedApp;

  })();

  window.appInst = new NewsfeedApp(jQuery);

}).call(this);
