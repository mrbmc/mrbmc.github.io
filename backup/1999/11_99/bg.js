
//this script resizes a background image to fit the window, no matter how the user resizes their browser window.  It only works well with low-res, pixellated background images.  It's a DHTML script, compatible only with 4.0 browsers.  Not the most useful script, but neat.

NS4=(document.layers);
IE4=(document.all);
ver4=(NS4 || IE4);

scaleWidth = true;
scaleHeight = true;
imSRC = '"bg1.jpg"'; //this is the only part of the script to be changed

if (NS4) onload = setResize;

function setResize(){
	setTimeout('window.onresize=reDo;',500);
}

function reDo(){
    window.location.reload()
}

if (IE4) onresize = reDoIE;

function reDoIE(){
    imBG.width = document.body.clientWidth;
    imBG.height = document.body.clientHeight;
}


function makeIm() {

  winWid = (NS4) ? innerWidth : document.body.clientWidth;
  winHgt = (NS4) ? innerHeight : document.body.clientHeight;
  imStr = "<DIV ID=elBGim"
  + " STYLE='position:absolute;left:0;top:0;z-index:-1'>"
  + "<IMG NAME='imBG' BORDER=0 SRC="+imSRC;
  if (scaleWidth) imStr += " WIDTH="+winWid;
  if (scaleHeight) imStr += " HEIGHT="+winHgt;
  imStr += "></DIV>";

  document.write(imStr);

}

   function CSSfix()
    {
     if (document.self.CSSfix.initWindowWidth != window.innerWidth || 
document.self.CSSfix.initWindowHeight != window.innerHeight)
      {
       document.location = document.location;
      }
    }

   function CSSfixCheckIn()
    {
     if ((navigator.appName == 'Netscape') && 
(parseInt(navigator.appVersion) == 4))
      {
       if (typeof document.self == 'undefined')
        {
         document.self = new Object;
        }
       if (typeof document.self.self_scaleFont == 'undefined')
        {
         document.self.CSSfix = new Object;
         document.self.CSSfix.initWindowWidth = window.innerWidth;
         document.self.CSSfix.initWindowHeight = window.innerHeight;
        }
       window.onresize = CSSfix;
      }
    }


