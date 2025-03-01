var DEBUG = (document.location.hostname == "localhost" || document.location.href.includes('debug')),
    VERBOSE = false && DEBUG,
    last_known_scroll_position = 0,
    ticking = false;

function wrapElement (el, wrapper) {
    el.parentNode.insertBefore(wrapper, el);
    wrapper.appendChild(el);
}

function parseSrcset(srcset) {
  return srcset.split(',').map(item => {
    const parts = item.trim().split(' ');
    return {
      url: parts[0],
      width: parts[1] ? parseInt(parts[1], 10) : null,
      density: parts[1] && parts[1].includes('x') ? parseFloat(parts[1]) : null,
    };
  });
}

function initMosaics() {
  var mosaics = document.getElementsByClassName('grid well');
  for (const mos of mosaics) {
    var imgs = mos.getElementsByTagName('img');
    console.log('mosaics',imgs)
    for (const img of imgs) {
      img.addEventListener('click',function(e){
        var newImg = document.createElement('img');
        var allSrc = parseSrcset(this.srcset);
            newImg.setAttribute('src',allSrc.pop().url);

        document.getElementById('lightbox').innerHTML = "";
        document.getElementById('lightbox').append(newImg);
        document.getElementById('lightbox').classList.add('in');
      })
    }
  }
  document.getElementById('lightbox').addEventListener('click',()=>{
    document.getElementById('lightbox').classList.remove('in');
  })
}

window.addEventListener('keydown', function(e) {
    console.log('onkeydown',e);

    switch(e.keyCode) {
        case 27://escape
          document.getElementById('lightbox').classList.remove("in");
          break;
        default:
    }
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
            // toggleClass(this,'zoom');
            this.classList.toggle('zoom');
        });
    });

    initMosaics();

});