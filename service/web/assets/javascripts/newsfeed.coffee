class NewsfeedApp

    constructor: (@$) ->
        @bindButtonsEvents()
        @initCurrentState()

    setBaseUrl: (@baseUrl) ->
    getBaseUrl: -> @baseUrl

    setAuthToken: (@authToken) ->
    getAuthToken: -> @authToken

    initCurrentState: ->
        @disableLikeButtons()
        @disableUnlikeButtons()

    disableLikeButtons: ->
        that = @
        @$('\\*[data-liked="true"]').each ->
            el = that.$(@)

            if el.hasClass('link_like')
                el.hide()

    disableUnlikeButtons: ->
        that = @
        @$('\\*[data-liked="false"]').each ->
            el = that.$(@)

            if el.hasClass('link_unlike')
                el.hide()

    bindButtonsEvents: ->
        that = @
        @$('.link_like').live 'click', -> that.tapOnLike(that.$(@))
        @$('.link_unlike').live 'click', -> that.tapOnUnLike(that.$(@))
        @$('.link_comment').live 'click', -> that.tapOnComment(that.$(@))
        @$('.link_close').live 'click', -> that.tapOnCloseLikesPanel(that.$(@))
        @$('.link_likes').live 'click', -> that.tapOnLikesList(that.$(@))
        @$(window.document).bind 'mousedown', (e) -> false

    tapOnLikesList: (el) ->
        @loadLikes(el)

    tapOnLike: (el) ->
        if @isDisabled(el)
            @showMessage 'success', 'You have already liked it!'
        else
            @likeThis(el)

    tapOnUnLike: (el) ->
        @showMessage 'success', 'You have unliked it'

    tapOnComment: (el) ->
        alert 'Comment'

    tapOnCloseLikesPanel: (el) ->
        @$('#' + el.attr('data-objectid') + '_' + el.attr('data-type')).hide();

    loadLikes: (el) ->
        that = @
        listEl = @$('#' + el.attr('data-likes'))
        objectId = el.attr('data-objectid')

        @sendRequestTo('/newsfeed/' + objectId + '/likes.html', 'GET').
            success (r) -> that.$('#' + objectId + '_likes').html(r).show()

    likeThis: (el) ->
        that = @
        uri = '/newsfeed/' + el.attr('data-objectid') + '/like'
        @sendRequestTo(uri).success((r) -> that.processServerResponse(el, r))

        @incrementCount @$(el).parent().find('.link_likes'), 1
        @disableLikeButton @$(el)

    processServerResponse: (el, response) ->
        @showMessage 'success', response.message
        if 'false' == response.status
            @incrementCount(el, -1)

    sendRequestTo: (uri, method = 'PUT') ->
        url = @getBaseUrl() + uri
        @$.ajax
            url: url
            type: method
            headers:
                'Auth-Token': @getAuthToken()

    showMessage: (type, message) ->
        that = @
        el = @getMessagePanel()
        el.removeClass(type).addClass(type);
        el.html message
        el.show()

        clearTimeout(@timer) unless @timer == null
        @timer = setTimeout(
            -> that.hideMessage()
        , 4000
        )

    hideMessage: ->
        @getMessagePanel().hide()

    getMessagePanel: ->
        elId = '__noticePanel'
        if @$('#' + elId).length == 0
            @$('body').append('<div style="display:none" class="notice-panel" id="' + elId + '"></div>')

        @$('#' + elId)

    incrementCount: (el, count) ->
        label = el.text()
        existingCount = parseInt(label.trim().split(/\s*/)[0], 10)
        newCount = existingCount + count

        label = ' Likes'
        label = ' Like' if newCount <= 1
        el.text(newCount + label)

    isDisabled: (el) ->
        el.attr('data-ui-enabled') == 'false' || el.hasClass('disabled')

    disableLikeButton: (el) ->
        el.removeClass('enabled').addClass('disabled').hide()
        el.parent().find('.link_unlike').removeClass('disabled').addClass('enabled').show()

    enableButton: (el) ->
        el.css('data-ui-enabled', 'true').removeClass('disabled').addClass('enabled')


window.appInst = new NewsfeedApp(jQuery)