$(window).scroll(function () {

    var container = $('.content');
    var userId = container.attr("userId");
    var baseUrl = container.attr("baseUrl");
    var authToken = container.attr("authToken");

    var enableScroll = function () {
        container.attr("scroll", "yes");
    }

    var success = function (res) {
        $('.content ul').append(res);
        $('img.lazy').lazyload();
        var new_num = parseInt($('.events').length);
        var old_num = parseInt(container.attr('count'));
        container.attr("count", new_num);
        if (new_num > (old_num + 4)) {
            window.setTimeout(enableScroll, 2000);
        }
    }
    var scroll_attr = container.attr("scroll");
    var turnOff = container.attr("turnOff");

    if ($(window).scrollTop() == $(document).height() - $(window).height()) {

        if (scroll_attr == "yes") {
            var offset = parseInt($('.events').length);
            container.attr("scroll", "no");
            $.ajax({
                type:'get',
                url:baseUrl + "/" + userId + "/newsfeed.html?authToken=" + authToken,
                data:{offset: offset},
                success:success
            });
        }
    }
});