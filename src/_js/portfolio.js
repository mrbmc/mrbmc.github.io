var DEBUG = (document.location.hostname == "localhost" || document.location.href.includes('debug')),
    VERBOSE = false && DEBUG,
    last_known_scroll_position = 0,
    ticking = false;

function wrapElement (el, wrapper) {
    el.parentNode.insertBefore(wrapper, el);
    wrapper.appendChild(el);
}


window.addEventListener('keydown', function(e) {
    console.log('onkeydown',e);
    galleryKeyPress(e);
});
window.addEventListener('popstate',function(e){
    galleryPopstate(e);
});


window.addEventListener('load', function(e) {
    console.log('project.window.load',e);
    var zoomies = document.querySelectorAll('.canzoom');
    Object.entries(zoomies).forEach(([key, zoomy]) => {
        console.log(`${key}: ${zoomy}`)
        zoomy.addEventListener('click', function(e) {
            console.log('zoomie clicked!',this);
            toggleClass(this,'zoom');
        });
    });


    galleryLoad(e);
});

