MovieClip.prototype.rxForceFX = function (strParams, objExec, objProgress)
{
	if (exists(strParams))
	{
		this.rxResetInterpol();
		this.rxAddFX(strParams, objExec, objProgress);
	}
} /* end rxForceFX function */

MovieClip.prototype.rxAddFX = function (strParams, objExec, objProgress) {
	if (exists(strParams))
	{
		var objInterPol=ZeusGet("interpol");
		objInterPol.addEffect(this, strParams, objExec, objProgress);
	}
} /* end rxApplyFX function */


MovieClip.prototype.rxAddMorph = function (mcRef,iTime,bScaleToFit,iLoop,bFlip,objExec, objProgress) {
	//var objInterpol=ZeusGet("interpol");
	if(typeof(iTime)!="number") iTime=1000;
	if(typeof(iLoop)!="number" and iLoop!="forever") iLoop=0;

	if(typeof(bFlip)!="boolean") bFlip=false;

	if(typeof(mcRef)=="movieclip") {

		var objPoint={x:mcRef._x,y:mcRef._y};
		mcRef._parent.localToGlobal(objPoint);

		var objMyPoint={x:this._x,y:this._y};
		this._parent.localToGlobal(objMyPoint);

		var iXDiff=objPoint.x-objMyPoint.x;
		var iYDiff=objPoint.y-objMyPoint.y;

		if(bScaleToFit) {
			var objScaleTo=mcRef;
			var iOffsetX=0;
			var iOffsetY=0;
		}
		else {
			var objScaleTo=this.rxGetLimitedWithAspect(mcRef);
			var objOffset=objScaleTo.rxGetCenteredOffset(mcRef);
			var iOffsetX=objOffset._x;
			var iOffsetY=objOffset._y;
		}
			this.rxInterpolate({_x:this._x,_y:this._y,_width:this._width,_height:this._height},{_width:objScaleTo._width,_height:objScaleTo._height,_x:(this._x+iXDiff+iOffsetX),_y:(this._y+iYDiff+iOffsetY)}, iTime, iLoop, bFlip, objExec, objProgress);

	} /* end if mcRef == movieclip */
	else if(typeof(mcRef)=="object") {
		
	} /* end if mcRef == object */

} /* end rxAddMorph function */

Object.prototype.rxResetInterpol = function (objParams) {
	var objInterPol=ZeusGet("interpol");
	var arrRefIPH=objInterPol._rxARRINTERPOLHOLDER;
	var bIPRExst=false;
		for(var i=0;i<arrRefIPH.length;i++) {
			
			if(((this instanceof MovieClip) and String(arrRefIPH[i])==String(this)) or ((this instanceof Object) and arrRefIPH[i]==this)) {
				var iArrID=i;
				bIPRExst=true;
				break;
			} /* end if arrrefIPH == objRef */
		} /* end for i */
		delete(i);

		if(bIPRExst) {
			if(typeof(objParams)=="undefined") {
				(arrRefIPH[iArrID])._rxARRINTERPOLL.splice(0);
				arrRefIPH.splice(iArrID,1);

				return true;
			} // if undefined
			else if(typeof(objParams)=="object") {
				var arrRefInterpol=arrRefIPH[iArrID]._rxARRINTERPOLL;
				for(var i=0;i<arrRefInterpol.length;i++) {
					var objRefFrom=arrRefIPH[iArrID]._rxARRINTERPOLL[i]['from'];
					var objRefTo=arrRefIPH[iArrID]._rxARRINTERPOLL[i]['to'];
					for(var each in objParams) {
						delete(objRefFrom[each]);
						delete(objRefTo[each]);
					}//for each
				} /* end for i */
				delete(arrRefInterpol);
				delete(i);
				delete(objRefFrom);
				delete(objRefTo);
				delete(each);
				return true;
			} // else if objParams == object
			else if(typeof(objParams)=="string") {
				var arrStrSplit=objParams.split(",");
				var arrRefInterpol=arrRefIPH[iArrID]._rxARRINTERPOLL;
				for(var i=0;i<arrRefInterpol.length;i++) {
					var objRefFrom=arrRefIPH[iArrID]._rxARRINTERPOLL[i]['from'];
					var objRefTo=arrRefIPH[iArrID]._rxARRINTERPOLL[i]['to'];
					for(var iI=0;iI<arrStrSplit.length;iI++) {
						delete(objRefFrom[(arrStrSplit[iI])]);
						delete(objRefTo[(arrStrSplit[iI])]);
					} //for iI
				} //for i
				delete(arrStrSplit);
				delete(arrRefInterpol);
				delete(i);
				delete(objRefFrom);
				delete(objRefTo);
				delete(iI);
				return true;
			} // else if objParams == string
		} //if bIPRExst == true

		delete(arrRefIPH);
		delete(bIPRExst);
		return false;
} /* end rxResetInterpol */

Object.prototype.rxDeleteAllStates = function () {
	delete(this._rxARRSTATEHOLDER);
} /* end rxDeleteAllStates function */

Object.prototype.rxDeleteState = function (strName) {
	if(typeof(strName)=="string" and typeof(this._rxARRSTATEHOLDER[strName])=="object") {
		delete(this._rxARRSTATEHOLDER[strName]);
		return true;
	} else return false;
} /* end rxDeleteState function */

Object.prototype.rxSaveState = function (strName,objParams) {
	this.rxCreateIfNot("_rxARRSTATEHOLDER","array",false);
	this._rxARRSTATEHOLDER[strName]=new Object();
	var objRef=this._rxARRSTATEHOLDER[strName];
	if(typeof(objParams)=="object") {
		for(var each in objParams) {
				objRef[each]=objParams[each];
		}//for
	}
	else if(typeof(objParams)=="string") {
		var arr=objParams.split(",");
		for(var i=0;i<arr.length;i++) {
			objRef[arr[i]]=this[arr[i]];
		} /* end for i */
	} /* end else if */
	else {
		objRef._x=this._x;
		objRef._y=this._y;
		objRef._xscale=this._xscale;
		objRef._yscale=this._yscale;
		objRef._width=this._width;
		objRef._height=this._height;
		objRef._alpha=this._alpha;
		objRef._currentframe=this._currentframe;
		objRef._visible=this._visible;
		objRef._rotation=this._rotation;
	}
	delete(objRef);
	delete(each);
} /* end rxSaveState function */

Object.prototype.rxGetState = function (strName,objParams) {
	if(typeof(this._rxARRSTATEHOLDER)=="undefined") return false;
	var objRef=this._rxARRSTATEHOLDER[strName];
	if(typeof(objRef)=="undefined") return false;
	var objReturn=new Object();
	if(typeof(objParams)=="object") {
		for(var strEach in objParams) {
				objReturn[strEach]=objRef[strEach];
		}//for
	}
	else if(typeof(objParams)=="string") {
		var arrParamNames=objParams.split(",");
		for(var i=0;i<arrParamNames.length;i++) {
			objReturn[arrParamNames[i]]=objRef[arrParamNames[i]];
		} //for
	} //else if
	else {
		for(var each in objRef) {
			objReturn[each]=objRef[each];
		} //for
	}//else
	delete(objRef);
	delete(i);
	delete(strEach);
	return objReturn;
} /* end rxGetState function */

Object.prototype.rxApplyState = function (objParams,strParams) {
	if(typeof(this._rxARRSTATEHOLDER)=="undefined") return false;
	if(typeof(objParams)=="string") {
		if(typeof(this._rxARRSTATEHOLDER[objParams])=="object" and typeof(strParams)=="string") {
			var objRef=this._rxARRSTATEHOLDER[objParams];
			var arrParams=strParams.split(",");
			for(var i=0;i<arrParams.length;i++) {
				this[arrParams[i]]=objRef[arrParams[i]];
			} /* end for i */
		}
		else if(typeof(this._rxARRSTATEHOLDER[objParams])=="object") {
			var objRef=this._rxARRSTATEHOLDER[objParams];
			for(var each in objRef) {
				this[each]=objRef[each];
			}//for
			delete(each);
			delete(objRef);
			delete(objParams);
		}
		else return false;
	}//if typeof string
	else if(typeof(objParams)=="object") {
			for(var each in objParams) {
				this[each]=objParams;
			}//for
			delete(each);
			delete(objParams);
	}//else if typeof object
	else return false;
} /* end rxApplyState function */