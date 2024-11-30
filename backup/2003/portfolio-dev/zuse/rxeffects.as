var objInterPol=ZeusGet("interpol");

/***********BLANK**************/
var effectBlank = function (mcRef, objExec, objProgress, iTime) {
    if(typeof(iTime)=="undefined") var iTime = 1000;
    else iTime = int(parseInt(iTime));
    mcRef.rxInterpolate({},{},iTime,0,false,objExec, objProgress);
}
objInterPol.registerEffect("blank",effectBlank);

/***********FADEIN**************/
var effectFadeIn = function (mcRef, objExec, objProgress, iTime) {
	if(typeof(iTime)=="undefined") var iTime = 1000;
	mcRef.rxInterpolate({_alpha:mcRef._alpha},{_alpha:100},iTime,0,false,objExec, objProgress);
}
objInterPol.registerEffect("fadein",effectFadeIn);

/************FADEOUT*************/
var effectFadeOut = function (mcRef, objExec, objProgress, iTime) {
	if(typeof(iTime)=="undefined") var iTime = 1000;
	else iTime = int(iTime);
	mcRef.rxInterpolate({_alpha:mcRef._alpha},{_alpha:0},iTime,0,false,objExec, objProgress);
}
objInterPol.registerEffect("fadeout",effectFadeOut);

/***********BLINK**************/
var effectBlink = function (mcRef, objExec, objProgress, iTime, iHowMany) {
  if(typeof(iTime)=="undefined") var iTime = 1000;
  else iTime = int(parseInt(iTime));
  if(iHowMany=="forever") iHowMany = "forever";
	else if(typeof(iHowMany)=="undefined") iHowMany = 0;
  else iHowMany = int(parseInt(iHowMany));

  mcRef.rxInterpolate({_alpha:mcRef._alpha}, {_alpha:0}, iTime, iHowMany * 2 - 1, true, objExec, objProgress);
}
objInterPol.registerEffect("blink",effectBlink);

/***********BLINK**************/
var effectBlinkIn = function (mcRef, objExec, objProgress, iTime, iHowMany) {
  if(typeof(iTime)=="undefined") var iTime = 1000;
  else iTime = int(parseInt(iTime));
  if(iHowMany=="forever") iHowMany = "forever";
	else if(typeof(iHowMany)=="undefined") iHowMany = 0;
  else iHowMany = int(parseInt(iHowMany));

  mcRef.rxInterpolate({_alpha:mcRef._alpha}, {_alpha:0}, iTime, iHowMany * 2, true, objExec, objProgress);
}
objInterPol.registerEffect("blinkin",effectBlinkIn);

/***********SCALE**************/
var effectScale = function (mcRef, objExec, objProgress, iTime, iPerc) {
    if(typeof(iTime)=="undefined") var iTime = 1000;
    else iTime = int(parseInt(iTime));
    if(typeof(iPerc)!="undefined") {
    	iPerc = parseFloat(iPerc);
    	var iWScale = mcRef._width * (iPerc / 100);
    	var iHScale = mcRef._height * (iPerc / 100);
   		mcRef.rxInterpolate({_width:mcRef._width,_height:mcRef._height},{_width:iWScale,_height:iHScale},iTime,0,false,objExec, objProgress);
    }
}
objInterPol.registerEffect("scale",effectScale);