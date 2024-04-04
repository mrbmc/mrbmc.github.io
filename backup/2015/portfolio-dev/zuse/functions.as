/* Included in Catalog.fla:functionsObj:Frame 1 */

bFirstLoad=true;

function setStandardMask()
{
	debugFunc("setStandardMask",arguments);
	catalogRef.mask.myMask._y = 0;
	catalogRef.mask.myMask._x = 0;
	catalogRef.mask.myMask._width = gCS.iSpreadViewPageWidth * 2;
	catalogRef.mask.myMask._height = gCS.iSpreadViewHeight;
}


function borderClick(skuID)
{
	debugFunc("borderClick",arguments);
	
	var obj = getBorderInfo(skuID);
	if (EventManager.sendEvent("eBorderClick","BorderID",skuID))
	{
		if (typeof(obj.jumppage) != "undefined") // border is a jump to page in catalog.
		{
			obj.integration=0;
			gotoPage(obj.jumppage)
		}
		EventManager.sendEvent("eProductDetails","BorderID",skuID);
	}
}

function onRequestBorderClick(args)
{
	debugFunc("onRequestBorderClick",arguments);
	borderClick(args["BorderID"]);
	return true;
}

function remove_zoom_image()
{
	debugFunc("remove_zoom_image",arguments);

	_root._quality = "HIGH";

	leftPage.removeMovieClip();
	rightPage.removeMovieClip();
	shadowPage.removeMovieClip();
	delete leftPage;
	delete rightPage;
	delete shadowPage;

}

/* Function: Spreadloaded
 * Description: called when a spread view page fully loads.
 */
function Spreadloaded()
{
	debugFunc("Spreadloaded",arguments);
	SetPageLoaded(gCS.iGoto,true);
	show_pages();
}

function finished_goto()
{
	debugFunc("finished_goto",arguments);

	bFirstLoad = false;
	bufferPages();

	//iCurrentSpread is officially the page desired.
	gCS.iCurrentSpread = gCS.iGoto//(gCS.iGoto<1) ? 1 :
	gCS.iPrevPage = gCS.iCurrentSpread;

	EventManager.sendEvent("ePostPageChange","current_page",gCS.iCurrentSpread);
	EventManager.sendEvent("ePageChange","current_page",gCS.iCurrentSpread);

	_fs('current_page',gCS.iCurrentSpread);

	spread_view_init();
	remove_wait();

	pageRef.page_0.removeMovieClip();
	eval("pageRef.page_" add (gCS.iTotalPages+1)).removeMovieClip();

	pageRef.shadow1._visible = (gCS.isBackCover() || gCS.isFrontCover()) ? false : true;
	pageRef.shadow1._alpha = gCS.iShadowDarkness;

	pageRef.shadow2._visible = (gCS.isBackCover() || gCS.isFrontCover()) ? false : true;
	pageRef.shadow2._alpha = gCS.iShadowDarkness;

}

function loadHighRes(page)
{
	debugFunc("loadHighRes",arguments);

	var pgURI = gCS.sUrl add gCS.loadPrefix add "p" add _root.pageIDs[page] add "_H.swf"
	var shell = eval(eval("pageRef.page_" add page));
	shell.hi.removeMovieClip();
	var loadtgt = shell.createEmptyMovieClip("hi",shell.getNextDepth());

	if (!GetHighResPageLoaded(page) && page>=1 && page<=gCS.iTotalPages)
	{
		loadtgt.rxLoadMovie(pgURI);
		//_dfs("loadtgt " add loadtgt)
	}
	else{
		fillRect(loadtgt,0,0,gCS.iSpreadViewPageWidth,gCS.iSpreadViewHeight,0,0,0xFFFFFFFF,100);
		loadedHigh(true)
	}
}

function loadedHigh(bDontProgress)
{
	debugFunc("loadedHigh",arguments);

	var page = gCS.iGoto + gCS.iHLoadCount;
	SetHighResPageLoaded(page,true);
	var pageobj=eval(pageRef add ".page_" add page);
	pageobj.hi._x=pageobj.lo._x;
	pageobj.hi._y=pageobj.lo._y;
	//_dfs("loadedHigh " add pageobj.hi add ":" add pageobj.hi._x)
	gCS.iHLoadCount++;

	if (bDontProgress || pageobj.hi._framesloaded==pageobj.hi._totalframes)
	{
		pageobj.hi.gotoAndStop(pageobj.hi._totalframes-1);
		endProg();
	}
	else
	{
		pageobj.hi.gotoAndPlay("Prog")
	}
}

function bufferPages(forcePurge)
{
	debugFunc("bufferPages",arguments);

	var PrevSpread = gCS.iPrevPage;
	var CurrentSpread = gCS.iGoto;

	var ran_on=new Array();

	//cycle the pages and remove any the we dont need.
	for (var i=PrevSpread-2;i<=(PrevSpread+3);i++)
	{
		if (
			(i < 1) ||
			(((i==CurrentSpread) ||
				(i==CurrentSpread+1)) && !forcePurge) ||
			(i > gCS.iTotalPages)
			)
			continue;
		else
		{
			var mc = eval(pageRef+".page_"+i);
			if (typeof(mc)!=undefined)
			{
				ran_on.push(i)
				mc.lo.unloadMovie();
				SetPageLoaded(rxMath.even(i),false);
				if (GetHighResPageLoaded(i))
				{
					mc.hi.unloadMovie();
					SetHighResPageLoaded(i,false);
				}
				mc.removeMovieClip();
			}
		}
	}
}


/* ------------------------------------------------------------
 * Name: zoomLoaded
 * Description: Magic function called from within closeup SWFs
 */

function zoomLoaded() {
	debugFunc("zoomLoaded",arguments);

	_root._quality = "BEST";
	EventManager.sendEvent("eZoomLoaded");
}

function fadeInZoom(bFadeShadow, objCallBack)
{

	if(leftPage._alpha == 0)
	{
		leftPage.rxForceFX("fadein,500", objCallBack);
		delete(objCallBack);
	}
	if(rightPage._alpha == 0)
	{
		rightPage.rxForceFX("fadein,500", objCallBack);
		delete(objCallBack);
	}
	if (shadowPage._alpha==0 && !gCS.isFrontCover() && !gCS.isBackCover() && bFadeShadow)
	{
		shadowPage.rxForceFX("fadein,500");
	}
	if (!bFadeShadow)
	{
		shadowPage._alpha=0;
	}
}

function loadPages(page)
{
	debugFunc("loadPages" ,arguments);

	//check that you're ready to flip
	var bResult = GetPageLoaded(gCS.iGoto);

	if (bResult)
		return show_pages();

	rxLoadManager.createGroup("page_loader");

	for (var i=0; i<=1; i++)
	{
		var pgURI = gCS.sUrl + gCS.loadPrefix + "p" + _root.pageIDs[page] + ".swf";
		gCS.iCurPageLevel++;

		eval(pageRef+".page_"+page+".lo").unloadMovie();
		eval(pageRef+".page_"+page+".hi").unloadMovie();
		eval(pageRef+".page_"+page).removeMovieClip();

		var shell = pageRef.createEmptyMovieClip("page_" + page,gCS.iCurPageLevel);
		shell._x=(i*gCS.iSpreadViewPageWidth);
		var loadtgt = shell.createEmptyMovieClip("lo",1);
		shell._alpha=0;

		if(page>=1 && page<=gCS.iTotalPages)
		{
			loadtgt.rxLoadMovie(pgURI,{},{},{strGroup:"page_loader",bWaitToInit:true});
		}
		else{
			loadtgt._parent._x = 2*gCS.iSpreadViewPageWidth;
			fillRect(loadtgt,0,0,gCS.iSpreadViewPageWidth,gCS.iSpreadViewHeight,0,0,0xFFFFFFFF,100);
		}
		page++;
	}

	rxLoadManager.rxSetGroupEvents("page_loader",this.Spreadloaded);
}

function enableBackNext()
{
	EventManager.sendEvent("eNextBackControlsToggle","direction","next","bHide",gCS.isBackCover());
	EventManager.sendEvent("eNextBackControlsToggle","direction","prev","bHide",gCS.isFrontCover());
}

function enableDogEars()
{
	catalogRef.dogEars._visible=true;
	catalogRef.dogEars.rightEar.page1._visible=gCS.isFrontCover();
	catalogRef.dogEars.rightEar._visible=!gCS.isBackCover();
	catalogRef.dogEars.leftEar._visible=!gCS.isFrontCover();
}

function disableDogEars()
{
	with( catalogRef.dogEars ){
		rightEar.gotoAndStop(1);
		leftEar.gotoAndStop(1);
		rightEar.ear._visible=false;
		leftEar.ear._visible=false;
		rightEar.pressed=false;
		leftEar.pressed=false;
		leftEar._visible=false;
		rightEar._visible=false;
		catalogRef.dogEars._visible=false;
	}
}

function SetCatShadow(page)
{
	debugFunc("SetCatShadow",arguments);

	if (gCS.isBackCover(page))
	{
		catalogRef.catShad.setUpShadow(gCS.iSpreadViewPageWidth,gCS.iSpreadViewHeight)
		catalogRef.catShad._x=gCS.iLeftPagePixelPosition-10;
	}
	else if (gCS.isFrontCover(page))
	{
		catalogRef.catShad.setUpShadow(gCS.iSpreadViewPageWidth,gCS.iSpreadViewHeight)
		catalogRef.catShad._x=gCS.iRightPagePixelPosition-10;
	}
	else
	{
		catalogRef.catShad.setUpShadow(gCS.iSpreadViewPageWidth*2,gCS.iSpreadViewHeight)
		catalogRef.catShad._x=gCS.iLeftPagePixelPosition-10;
	}
}

function prepare_interface(bShowWait)
{
	debugFunc("prepare_interface",arguments);

	EventManager.sendEvent("eNextBackControlsToggle","direction","next","bHide",true);
	EventManager.sendEvent("eNextBackControlsToggle","direction","prev","bHide",true);

	catalogRef.mask.holder.brdrs.removeBorders()

	disableDogEars();
}

function removeHighRes()
{
	debugFunc("removeHighRes",arguments);

	var j = i = (gCS.iCurrentSpread<=1 ? 1 : gCS.iCurrentSpread);
	if (j != gCS.iTotalPages)
		j++;
	for (;i<=j;i++)
	{
		if (i < 1 || i > gCS.iTotalPages)
			continue;
		if (GetHighResPageLoaded(i)) {
			eval(eval("pageRef.page_" add i)).unloadMovie()
		}
		SetHighResPageLoaded(i,false);
	}
}

clamp = function(n,nMin,nMax)
{
	return Math.max(nMin,Math.min(n,nMax));
}

/* Function: gotoPage
 * Description: initiates a page flip
 */
function gotoPage(iNext)
{
	debugFunc("gotoPage",arguments);

	gCS.iCurrentSpread = iNext = clamp(parseInt(iNext),1,gCS.iTotalPages);

	if (gCS.sCurViewMode!='spread_view' && gCS.sCurViewMode!='singlepage')
	{
		EventManager.sendEvent("eSpreadViewRequest");
		return;
	}

	//send event verify that its ok to flip
	if (!EventManager.sendEvent("ePrePageChange","current_page",gCS.iCurrentSpread,"newpage",iNext))
		return;

	disableGUI();
	EventManager.sendEvent("eStartBusy")

	if (gCS.sCurViewMode=='singlepage')
	{
		single_page_goto_page();
	}
	else
	{
		gCS.iGoto = (iNext<1) ? 1 : rxMath.even(iNext);
		loadPages(gCS.iGoto);
	}
}

function show_pages()
{
	debugFunc('show_pages',arguments);

	if (gCS.isBackCover())
		if (gCS.bLowBandWidth && gCS.iCurrentSpread!=gCS.iGoto)
			removeHighRes();

	toggleViewControls('spreadButton');

	//this is so shadow appear nicely when flipping to/from covers
	if (gCS.isFrontCover(gCS.iGoto) || gCS.isBackCover(gCS.iGoto))
	{
		if (gCS.isFrontCover(gCS.iPrevPage) || gCS.isBackCover(gCS.iPrevPage))
			catalogRef.catShad._visible=false;
		else
			SetCatShadow(gCS.iGoto);
	}

	if (bFirstLoad || gCS.iPrevPage == gCS.iGoto || gCS.sPrevViewMode == "thumbnail_view" || !gCS.bAnimateFlip)
	{
		displaySpreadViewNoAnim();
	}
	else if(gCS.iGoto < gCS.iPrevPage)
	{
		startPageFlip("left2Right");
	}
	else
	{
		startPageFlip("right2Left");
	}
	gCS.sPrevViewMode =  gCS.sCurViewMode;
}

function remove_wait()
{
	debugFunc("remove_wait",arguments);

	//close the please wait animation.
	EventManager.sendEvent("eDoneBusy");
	enableGUI();
}


function GetHighResPageLoaded(pageNum)
{
	debugFunc("GetHighResPageLoaded",arguments);

	if (!gCS.highResPageLoaded)
	{
		gCS.highResPageLoaded=new Object();
		gCS.highResPageLoaded.toString = PageLoadedToString;
	}

	return gCS.highResPageLoaded[page]
}

function GetPageLoaded(pageNum)
{
	debugFunc("GetPageLoaded",arguments);

	if (typeof(gCS.pageLoaded) != "object")
	{
		gCS.pageLoaded=new Object();
		gCS.pageLoaded.toString = PageLoadedToString;
	}
	var page=(pageNum<=1 ? 1 : pageNum);
	return gCS.pageLoaded[page]
}

function PageLoadedToString()
{
	var buff = "pages { "
	for (i in this)
	{
		if (this[i] == true)
			buff+= i + ","
	}
	buff = buff.substr(0,buff.length-1) + " }";
	return buff;
}

function SetHighResPageLoaded(pageNum,bVal)
{
	debugFunc("SetHighResPageLoaded",arguments);

	if (!gCS.highResPageLoaded)
	{
		gCS.highResPageLoaded=new Object();
		gCS.highResPageLoaded.toString = PageLoadedToString;
	}
	var page=(pageNum<=1 ? 1 : pageNum);
	gCS.highResPageLoaded[page]=bVal
}

function SetPageLoaded(pageNum,bVal)
{
	debugFunc("SetPageLoaded",arguments);

	if (typeof(gCS.pageLoaded) != "object")
	{
		gCS.pageLoaded=new Object();
		gCS.pageLoaded.toString = PageLoadedToString;
	}
	var page=(pageNum<=1 ? 1 : pageNum);
	gCS.pageLoaded[page]=bVal
}

function handle_low_res()
{
	debugFunc("handle_low_res",arguments);

	if (gCS.bLowBandWidth)
	{
		gCS.iHLoadCount = 0;
		loadHighRes(gCS.iGoto);
	}
	else
	{
		finished_goto();
	}
}

function endProg()
{
	debugFunc("endProg",arguments);

	if (gCS.iHLoadCount == 2)
	{
		finished_goto();
	}
	else
	{
		loadHighRes(gCS.iGoto+1)
	}
}

function TopScrollBarClick(args)
{
	debugFunc("onScrollBarClick",arguments);
	var page = parseInt(args["page"]);

	var pageRaw = page < 1 ? 1 : Math.min(page,gCS.iTotalPages)

	if(gCS.sCurViewMode != "thumbnail_view" && gCS.iCurrentSpread != pageRaw)
		gotoPage(pageRaw);

	return true;
}

function NextSpread (args)
{
	debugFunc("NextSpread",arguments);

	if (gCS.sCurViewMode != "thumbnail_view")
	{
		if(gCS.sCurViewMode=="singlepage") {
			var d = (gCS.iCurrentSpread>=1) ? gCS.iCurrentSpread+1 : 2;
			gotoPage(d);
		}
		else if (!gCS.isBackCover()) {
			var d = Math.min((gCS.iCurrentSpread + 2)-(gCS.iCurrentSpread % 2), gCS.iTotalPages);
			gotoPage(d);
		}
	}

	return true;
}

function PrevSpread (args)
{
	debugFunc("PrevSpread",arguments);

	if (gCS.sCurViewMode != "thumbnail_view")
	{
		if(gCS.sCurViewMode=="singlepage"){
			var d = gCS.iCurrentSpread-1;
			gotoPage(d);
		}
		else if (!gCS.isFrontCover()) {
			var d = gCS.iCurrentSpread-2
			gotoPage(d);
		}
	}

	return true;
}

_global.getZoomViewWidth = function()
{
	var iNumOfPages = ((gCS.sCurViewMode=="singlepage" || gCS.isFrontCover() || gCS.isBackCover()) ? 1 : 2);
	return Math.min(gCS.iZoomViewWidth, gCS.iZoomPageWidth*iNumOfPages);
}

_global.getZoomViewHeight = function()
{
	return Math.min(gCS.iZoomViewHeight, gCS.iZoomPageHeight);
}

function load_zoom_image(sTarget)
{
	debugFunc('load_zoom_image',arguments);

	_fs("zoom_view"); //for metrics

	var iNumOfPages = ((gCS.isFrontCover() || gCS.isBackCover()) ? 1 : 2);
	var loadPage = (gCS.isFrontCover() ? 1 : gCS.iCurrentSpread);
	eval(sTarget)._visible = true;

	if(!leftPage)
		leftPage = eval(sTarget).createEmptyMovieClip("zoomImgLeft",eval(sTarget).getNextDepth());
	if(!rightPage)
		rightPage = eval(sTarget).createEmptyMovieClip("zoomImgRight",eval(sTarget).getNextDepth());

	leftPage._alpha = 0;
	rightPage._alpha = 0;
	leftPage._x = 0;
	rightPage._x = (iNumOfPages==2) ? gCS.iZoomPageWidth : 0;

	rxLoadManager.createGroup("zoom_loader");

	var swfurl_left = gCS.sUrl add "gassets/closeup/swf/p" add _root.pageIDs[(loadPage)] add ".swf"
	leftPage.rxLoadMovie(swfurl_left,{},{},{strGroup:"zoom_loader",bWaitToInit:true});
	if(iNumOfPages==2)
	{
		var swfurl_right = gCS.sUrl add "gassets/closeup/swf/p" add _root.pageIDs[(loadPage+1)] add ".swf"
		rightPage.rxLoadMovie(swfurl_right,{},{},{strGroup:"zoom_loader",bWaitToInit:true});
	}

	if(!shadowPage) {
		shadowPage = eval(sTarget).createEmptyMovieClip("closeupShadow",eval(sTarget).getNextDepth());
		shadowPage._alpha = 0;
		shadowPage.rxLoadMovie(gCS.sUrl add "gassets/closeup/swf/Shadow.swf",{},{},{strGroup:"zoom_loader"});
	}

	rxLoadManager.rxSetGroupEvents("zoom_loader",this.zoomLoaded);

	return true;
}

function toggleViewControls(but)
{
	debugFunc("toggleViewControls",arguments);

	EventManager.sendEvent("eToggleViewControls","but",but);
}


function handle_goto_request(args)
{
	debugFunc("handle_goto_request",arguments);

	var spread = args["spread"]

	if (typeof(spread) != "undefined")
		gotoPage(spread);
	return true;
}

function onTellUs()
{
	_fs("tell_us","");
	return true;
}

function onEmail()
{
	_fs("email")
	return true;
}

//Handler for product page preview
function onDoneCreating(args)
{
	
	debugFunc("onDoneCreating",arguments);
	if (typeof(_root.BorderClickGID) != "undefined" && _root.BorderClickGID!=0)
	{
		EventManager.sendEvent("eRequestBorderClick","BorderID",_root.BorderClickGID)
		_root.BorderClickGID=0;
	}

	return true;
}

function onChangeRes(args)
{
	var res=args["res"];
	if (res!=(gCS.bHighRes ? "high" : "low"))
		_fs("change_res",res)
	return true;
}

setStandardMask();

#include "views.as"
#include "flip.as"

#include "closeup_view.as"
#include "arrow_zoom_view.as"
#include "magnify_view.as"
#include "single_page_view.as"
#include "spread_view.as"

////------------------------------------------------------------------------------------

function setCurrentView(viewMode, callback)
{
	debugFunc("setCurrentView",arguments)

	if (gCS.sCurViewMode == viewMode)
		return false;

	if (!EventManager.sendEvent("ePreViewChange", "curView", gCS.sCurViewMode, "nextView", viewMode))
		return false;

	gCS.sPrevViewMode = gCS.sCurViewMode;
	gCS.sCurViewMode = viewMode;

	disableGUI();
	rxExecuteCallBack(close_view_callback);
	delete close_view_callback;
	ExtensionManager.WaitForReady(callBack)
	return true;
}


function finishViewChange(callback)
{
	enableBackNext();
	enableGUI();
	EventManager.sendEvent("eChangedToView","prevView",gCS.sPrevViewMode,"curView",gCS.sCurViewMode);
	close_view_callback=callback;
}

////------------------------------------------------------------------------------------

EventManager.registerEvent("TopScrollBarClick",		"eTopScrollBarClick",_target);
EventManager.registerEvent("NextSpread",			"eNextSpreadRequest",_target);
EventManager.registerEvent("PrevSpread",			"ePrevSpreadRequest",_target);

EventManager.registerEvent("handle_goto_request",	"eGotoRequest",_target);
EventManager.registerEvent("onTellUs", 				"eTellUsRequest", _target);
EventManager.registerEvent("onEmail", 				"eEmailRequest", _target);
EventManager.registerEvent("onRequestBorderClick",	"eRequestBorderClick", _target);
EventManager.registerEvent("onChangeRes",			"eChangeResRequest", _target);

EventManager.registerEvent("onDoneCreating","eDoneCreatingBorders", _target);





stop();
