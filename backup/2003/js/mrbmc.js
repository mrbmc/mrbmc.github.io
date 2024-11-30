var scrollSpy = function () {
    var windowBottom = $(window).scrollTop() + window.innerHeight;
    $('[data-spy="scroll"]').each(function () {
        var me = $(this),
            top = me.offset().top,
            height = me.innerHeight(),
            b = ( (top+50) <= windowBottom);
        me.toggleClass('in', b);
    })
}
var pageinit = function() {
    if(typeof jQuery == "undefined") {
        return setTimeout(pageinit,50);
    }

    $('#nav-toggle').on('touchend click',function(){
        var c = document.getElementById('header').className,
            isOpen = (c.indexOf('in') >=0),
            newClass = isOpen ? c.replace(' in','') : c+" in";
        document.getElementById('header').className = newClass;
        return false;
    });

    $('html').on('click',function(){
        $('#header').removeClass('in');
    });

    $('[data-spy="load"]').each(function () {
        $(this).toggleClass('in');
    });

    $(window).scroll(scrollSpy);
    scrollSpy();

    window.onresize();

    return true;
}
var fontScaler = function (element) {
    var f = Math.max(18,Math.round(element.offsetWidth/40));
    element.style.fontSize = f + "px";
}

window.onresize = function(event) {
    var a = document.getElementsByClassName('text-scaled');
    for (var i = a.length - 1; i >= 0; i--) {
        fontScaler(a[i]);
    };
}

if(location.host.indexOf('localhost') < 0 && location.host.indexOf('stage') < 0){
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-4173628-4']);
    _gaq.push(['_trackPageview']);

    (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
}

pageinit();