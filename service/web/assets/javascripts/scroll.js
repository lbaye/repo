$(document).ready(function () {

    var container = $('.content');
    var target = container.attr("target");
    var baseUrl = container.attr("baseUrl");
    var authToken = container.attr("authToken");
    var moreDiv = $('.more');

    if (parseInt($('.content ul li').length) < 6) {
        moreDiv.hide();
        $('.joinDate').show();
    }

    moreDiv.click(function () {
        var success = function (res) {
            try {
                var old_num = $('.content ul li').length;
                $(res).insertBefore($('.content ul li.joinDate'));
                var new_num = $('.content ul li').length;

                if ((new_num - old_num) < 5) {
                    moreDiv.hide();
                    $('.joinDate').show();
                } else {
                    $('.more span').show();
                    $('.more img').hide();
                }

                window.appInst.initCurrentState();
            } catch (e) {
                alert(e);
            }
        };

        var hideText = function () {
            $('.more span').hide();
            $('.more img').show();
        };

        var offset = $('.content ul li.events').last().attr('offset');
        container.attr("scroll", "no");
        $.ajax({
            type:'get',
            url:baseUrl + "/" + target + "/newsfeed.html?authToken=" + authToken,
            data:{offset:offset},
            beforeSend:hideText,
            success:success
        });
    });
});
