Object.prototype.rxCreateLoadManager = function(strName)
{
	this[strName] = new Object();
	_global.rxLoadManager = this[strName];

	rxLoadManager.createGroup = function (strGroup) {
		this[strGroup]=new Array();
	}

	rxLoadManager.rxCallLoad = function (mcPath,strUrl) {
		if(eval(mcPath) instanceof MovieClip) {
			eval(mcPath).loadMovie(strUrl);
		} else if(mcPath instanceof XML) {
			mcPath.load(strUrl);
		}
	}

	rxLoadManager.rxCheckDupes = function (strGroup,strUrl) {
		for(var i=0;i<this[strGroup].length;i++) {
			if(this[strGroup][i].strState=="loading" and String(this[strGroup][i].strUrl).toLowerCase()==String(strUrl).toLowerCase()) {
				return true;
			}
		}
		return false;
	}

	rxLoadManager.rxExecuteDupes = function (strGroup,strUrl) {
		if(typeof(strGroup)!="string" || strGroup.length==0)
			 return false;
		//_dfs("Dumping group "+strGroup);
		for(var i=0;i<this[strGroup].length;i++) {
			//_dfs(i+") "+this[strGroup][i].strState+"   ("+this[strGroup][i].mcRef.getBytesLoaded()+"/"+this[strGroup][i].mcRef.getBytesTotal()+") "+this[strGroup][i].strURL);
			if(this[strGroup][i].strState=="dup" and String(this[strGroup][i].strUrl).toLowerCase()==String(strUrl).toLowerCase()) {
				var obj2Load=this[strGroup][i];
				obj2Load.strState="loading";
				this.rxCallLoad(obj2Load.mcRef,strUrl);
				obj2Load.iInterval = setInterval(this.rxProcessLoadInterval,50,obj2Load,this);
			}
		}
		return true;
	}

	rxLoadManager.rxLoadObject = function (mcPath,strUrl,objLoaded,objProgress,objAddtlArgs) {
		var objClipData=new Object();

		objClipData.mcRef=mcPath;
		objClipData.strUrl=strUrl;
		objClipData.objLoaded=objLoaded;
		objClipData.strState="loading";
		objClipData.objProgress=objProgress;
		objClipData.objAddtlArgs=objAddtlArgs;

		if (typeof(objClipData.objAddtlArgs.strGroup)=="string")
		{
			if (typeof(this[objClipData.objAddtlArgs.strGroup])=="object")
			{
				if(this.rxCheckDupes(objClipData.objAddtlArgs.strGroup,strUrl))
					objClipData.strState="dup";
				this.rxAddToGroup(objClipData.objAddtlArgs.strGroup,objClipData);
			}
			else
				systemError("Group " add objClipData.objAddtlArgs.strGroup add " does not exist when loading object. " add objClipData.mcRef);
		}

		if(objClipData.strState=="loading")
		{
			this.rxCallLoad(mcPath,strUrl);
			objClipData.iInterval = setInterval(this.rxProcessLoadInterval,50,objClipData,this);
		}
	}

	rxLoadManager.rxSetGroupEvents = function (strGroup,objLoaded,objProgress,objAddtlArgs) {
		this[strGroup].objLoaded = objLoaded;
		this[strGroup].objProgress = objProgress;
		this[strGroup].iInterval = setInterval(this.rxProcessGroupInterval,50,this[strGroup]);
	}

	rxLoadManager.rxAddToGroup = function (strGroup,objClipData) {
		this[strGroup][this[strGroup].length]=objClipData;
	}

	rxLoadManager.rxProcessLoadInterval = function (objClipData,refLoadManager) {
		var iBT=int(objClipData.mcRef.getBytesTotal());
		var iLT=int(objClipData.mcRef.getBytesLoaded());
		if(iBT>0 and iLT>0) {
			rxExecuteCallBack(objClipData.objProgress,iBT,iLT);
			var bInited=((objClipData.objAddtlArgs.bWaitToInit==true and objClipData.mcRef._rxinited==true) or (typeof(objClipData.objAddtlArgs.bWaitToInit)=="undefined" or objClipData.objAddtlArgs.bWaitToInit==false));						if(String(objClipData.strUrl).substr(-3).toLowerCase()=="jpg") {
				if(objClipData.mcRef._width>0 and objClipData.mcRef._height>0) {
					var bIfJPGWait2Show = true;
				}
				else
					var bIfJPGWait2Show = false;
			}
			else
				var bIfJPGWait2Show = true;				
			if(iLT==iBT and bInited and bIfJPGWait2Show) {
				objClipData.strState="done";
				refLoadManager.rxExecuteDupes(objClipData.objAddtlArgs.strGroup,objClipData.strUrl);
				clearInterval(objClipData.iInterval);
				rxExecuteCallBack(objClipData.objLoaded,iBT,iLT);
			}
		}
	}

	rxLoadManager.rxProcessGroupInterval = function (arrGroup,refLoadManager) {
		var iBT=0;
		var iLT=0;
		var iAllDone=0;
		for(var i=0;i<arrGroup.length;i++) {
			iBT+=arrGroup[i].mcRef.getBytesTotal();
			iLT+=arrGroup[i].mcRef.getBytesLoaded();
			if(arrGroup[i].strState=="done") iAllDone+=1;
		}

		if(iBT>0 and iLT>0) {
				rxExecuteCallBack(arrGroup.objProgress,iBT,iLT);
				if(arrGroup.length==iAllDone) {
					clearInterval(arrGroup.iInterval);
					rxExecuteCallBack(arrGroup.objLoaded,iBT,iLT);
				}
		}
	}

} /* end rxCreateLoadManager */
ASSetPropFlags(Object.prototype,"rxCreateLoadManager",7);

MovieClip.prototype.rxSetInited = function ()
{
    this._rxinited=true;
}
ASSetPropFlags(MovieClip.prototype,"rxSetInited",7);

MovieClip.prototype.rxLoadMovie = function  (strUrl,objLoaded,objProgress,objAddtlArgs) {
	rxLoadManager.rxLoadObject(this,strUrl,objLoaded,objProgress,objAddtlArgs);
	return true;
}

XML.prototype.rxLoadXML = function  (strUrl,objLoaded,objProgress,objAddtlArgs) {
	rxLoadManager.rxLoadObject(this,strUrl,objLoaded,objProgress,objAddtlArgs);
	return true;
}

this.rxCreateLoadManager("rxLM");