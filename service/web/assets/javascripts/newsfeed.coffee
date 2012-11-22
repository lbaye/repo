class NewsfeedApp

    constructor: (@$) ->
        @bindButtonsEvents()
        @initCurrentState()

    setBaseUrl: (@baseUrl) -> 
    getBaseUrl: -> @baseUrl

    setAuthToken: (@authToken) ->
    getAuthToken: -> @authToken

    initCurrentState: ->
        that = @
        @$('\\*[data-liked="true"]').each ->
            el = that.$(@)
            that.disableButton el


    bindButtonsEvents: ->
        that = @
        @$('.link_like').click -> that.tapOnLike(that.$(@))
        @$('.link_comment').click -> that.tapOnComment(that.$(@))
        @$('.link_close').live 'click', -> that.tapOnCloseLikesPanel(that.$(@))

    tapOnLike: (el) ->
        if @isDisabled(el)
            @showMessage 'success', 'You have already liked it!'
        else
            @likeThis(el)

        @loadLikes(el)

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
        @sendRequestTo(uri).
            success (r) -> that.processServerResponse(el, r)

        @incrementCount @$(el), 1
        @disableButton @$(el)

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
        el.text((existingCount + count) + ' Likes');

    isDisabled: (el) ->
        el.attr('data-ui-enabled') == 'false' || el.hasClass('disabled')

    disableButton: (el) ->
        el.css('data-ui-enabled', 'false').removeClass('enabled').addClass('disabled')

    enableButton: (el) ->
        el.css('data-ui-enabled', 'true').removeClass('disabled').addClass('enabled')


window.appInst = new NewsfeedApp(jQuery)