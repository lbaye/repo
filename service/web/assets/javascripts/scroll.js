$(document).ready(function () {

    var container = $('.content');
    var userId = container.attr("userId");
    var baseUrl = container.attr("baseUrl");
    var authToken = container.attr("authToken");

    $('.more').click(function () {
        var success = function (res) {
            $('.content ul').append(res);
            var new_num = parseInt($('.events').length);
            var old_num = parseInt(container.attr('count'));
            container.attr("count", new_num);

            if (new_num < (old_num + 4)) {
                $('.more').hide();
            } else {
                $('.more span').show();
                $('.more img').hide();
            }
        }

        var hideText = function(){
            $('.more span').hide();
            $('.more img').show();
        }

        var offset = parseInt($('.events').length);
        container.attr("scroll", "no");
        $.ajax({
            type:'get',
            url:baseUrl + "/" + userId + "/newsfeed.html?authToken=" + authToken,
            data:{offset:offset},
            beforeSend: hideText,
            success:success
        });

    });

});
