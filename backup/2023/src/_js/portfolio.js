var $projectIndex = 0,
    // list_template = {},
    detail_template = {},
    $portfolioFilter = "",
    imgs = [],
    iGallery = {};

/* ------------------------------------------------------------
HELPERS
------------------------------------------------------------ */
// function onLoadIndex( data ) {
//     if(DEBUG) console.log('onLoadIndex:',arguments);

//     $portfolio = data;

//     var pathname = window.location.hash.split('#/').pop();
//     console.log('pathname',pathname);
//     if (pathname != "portfolio" && pathname != "") {
//         gotoProject(pathname);
//     }
//     document.getElementById('item-list').innerHTML = list_template($portfolio);
// }

/* ------------------------------------------------------------
NAVIGATION FUNCTIONS
------------------------------------------------------------ */

function onProjectLoaded ( data ){
    if(DEBUG) window.console.log('onProjectLoaded:', arguments);

    var project = $portfolio[$projectIndex];
    for (var prop in data) {
        project[prop] = data[prop];
    }
    project['content'] = parseMarkdown(data['content']);
    project['summary'] = parseMarkdown(data['summary']);

    document.getElementById('item-detail').innerHTML = detail_template(project);
    document.getElementById('scrollhint').addEventListener('click',onClickScrollhint,false);
    document.getElementById('item-list').classList.add('mini');
    window.document.title = project.title + " | Brian McConnell";


    //set up the gallery
    imgs = [];
    Array.from(document.getElementById('main').getElementsByTagName('img')).forEach(function (img, index, arr){
        imgs.push({
            'index': index,
            'id': index,
            'url_h':img.getAttribute('src'),
            'url_t':img.getAttribute('src')
        });
        img.addEventListener('click', function (e) {
            e.preventDefault();
            iGallery.openPhoto({'index':index});
        })
    });

    iGallery = new Gallery('projectGallery',imgs);
    toggleClass(iGallery.el,'in',false);

    //animate the opening
    window.scroll({top:0,left:0,behavior:"smooth"});

    onScroll();
    onResize();

    //Google Analytics
    if(typeof ga != "undefined")
        ga('send', 'pageview', '/portfolio/#/' + project.slug);
    $portfolioFilter = (project.slug === $portfolioFilter) ? "" : project.slug;

}

// Open a project
function gotoProject(_project) {
    if(DEBUG) window.console.log('gotoProject:', _project);

    var index = 0,
        increment = (_project=="+") ? 1 : -1,
        i,
        d,
        project = {};

    //if the argument is an integer, fetch the data by the index no.
    if ((_project*1) == _project) {
        index = parseInt(_project, 10);
        history.pushState({}, $portfolio[index]['title'] + " | Brian McConnell", "/portfolio/#/" + $portfolio[index]['slug']);

    //if the argument is incremental you go to the sibling project
    } else if (_project === "+" || _project === "-") {
        for (i in $portfolio) {
            if ($portfolio.hasOwnProperty(i) && $portfolio[i].slug === $portfolioFilter) {
                index = parseInt(i, 10) + increment;
                index = Math.contain(index,0,($portfolio.length - 1));

                while($portfolio.hasOwnProperty(index) && $portfolio[index].visible != true) {
                    index += increment;
                    index = Math.contain(index,0,($portfolio.length - 1));
                }
            }
        }
        history.pushState({}, $portfolio[index]['title'] + " | Brian McConnell", "/portfolio/#/" + $portfolio[index]['slug']);

    //else fetch the project by the name
    } else {
        for (i in $portfolio) {
            if ($portfolio.hasOwnProperty(i) && $portfolio[i].slug === _project && !$portfolio[i].privacy) {
                index = parseInt(i, 10);
                break;
            }
        }
    }

    $projectIndex = index;
    project = $portfolio[index];

    loadYAML("/portfolio/projects/" + project.slug + ".yaml", onProjectLoaded);

    return project;
}

//Close the project
function $closeProject() {
    if(DEBUG) console.log('closeProject',arguments);
    document.getElementById('item-detail').innerHTML = "";
    document.getElementById('item-list').classList.remove("mini");
    window.document.title = "Portfolio | Brian McConnell";
// TODO
    // $('.project').removeClass('active');

}

/* ------------------------------------------------------------
EVENT HANDLERS
------------------------------------------------------------ */

window.onpopstate = function(e) {
    if(DEBUG) window.console.log('onPopState',e);

    var pathname = window.location.hash.split('#/').pop();

    if (pathname != "portfolio" && pathname != "") {
        return gotoProject(pathname);
    } else {
        return $closeProject();
    }
}

var onPageLoad = function() {
    "use strict";
    if(DEBUG) console.log('portfolio.window.load',arguments);

    // list_template = Handlebars.templates["project_list.hbs"];
    detail_template = Handlebars.templates["project_detail.hbs"];

    window.addEventListener('keydown', function(evt){
        if(DEBUG) console.log('keydown',evt);
        evt = evt || window.event;
        switch(evt.keyCode) {
            case 27://escape
                evt.preventDefault();
                if(!iGallery.el.classList.contains('in'))
                    $closeProject();
                break;
            case 37://left arrow
                if(!iGallery.el.classList.contains('in'))
                    gotoProject("-");
                break;
            case 39://right arrow
                if(!iGallery.el.classList.contains('in'))
                    gotoProject("+");
                break;
            default:
        }
    });

    // loadJSON("/portfolio/portfolio.json", onLoadIndex);
    // onLoadIndex($portfolio);

    var pathname = window.location.hash.split('#/').pop();
    if (pathname != "portfolio" && pathname != "") {
        gotoProject(pathname);
    }

};
