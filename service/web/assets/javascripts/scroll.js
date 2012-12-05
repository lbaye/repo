$(window).scroll(function () {

    var body = $('.content');
    var userId = body.attr("userId");
    var baseUrl = body.attr("baseUrl");
    var authToken = body.attr("authToken");

    var enableScroll = function () {
        body.attr("scroll", "yes");
    }

    var success = function (res) {
        $('.content ul').append(res);
        $('img.lazy').lazyload();
        var new_num = parseInt($('.events').length);
        var old_num = parseInt(body.attr('count'));
        body.attr("count", new_num);
        if (new_num > (old_num + 4)) {
            window.setTimeout(enableScroll, 2000);
        }
    }
    var body_attr = body.attr("scroll");
    var turnOff = body.attr("turnOff");

    if ($(window).scrollTop() == $(document).height() - $(window).height()) {

        if (body_attr == "yes") {
            var elem = parseInt($('.events').length);
            body.attr("scroll", "no");
            $.ajax({
                type:'get',
                url:baseUrl + "/" + userId + "/newsfeed.html?authToken=" + authToken,
                data:{offset:elem},
                success:success
            });
        }
    }
});