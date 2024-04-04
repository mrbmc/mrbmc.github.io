MovieClip.prototype.rxCreateText = function (strName, iDepth, objStyle, iX, iY, iW, iH) {
	
	var arrArgs = new Array();
	arrArgs[0] = this;
	arrArgs[1] = getInteger(iDepth);
	arrArgs[2] = strName;
	arrArgs[3] = "";
	arrArgs[4] = null;
	arrArgs[5] = objStyle;
	arrArgs[7] = getFloat(iW);
	arrArgs[8] = getFloat(iH);
	
	var objTxtFld = _global.createText.apply(null,arrArgs);
	objTxtFld._x = iX;
	objTxtFld._y = iY;
	
	return objTxtFld;
}

_global.createText = function(tgt,depth,instanceName,str,fontSize,style,textWidth,textHeight)
{
	_global._createText(tgt, depth, instanceName, textWidth, textHeight);
	var objTextTarget = tgt[instanceName];

	if(!(style instanceof _global.styleText))
		style = new _global.styleText();

	if(getInteger(fontSize) > 0) {
		style.size = fontSize;
	}

	objTextTarget.rxSetStyle(style);
	if (str.length>0)
		objTextTarget.setText(str);

	return objTextTarget;
}

_global.isExecObject = function (obj) {

	if(exists(obj.fnRef) and exists(obj.mcRef)) {
		if(typeof(eval(obj.mcRef add "." add obj.fnRef))=="function") {
			return true;
		}
		else if((typeof(obj.mcRef)=="object" or typeof(obj.mcRef)=="movieclip") and typeof(obj.fnRef)=="function") {
			return true;
		}
		else
			return false;
	}
	
}

_global.compareExecObjects = function (objA, objB, bInverse)
{

	if(!(exists(objA) and exists(objB)))
		return false;
	
	if(isExecObject(objA) and isExecObject(objB)) {
		if(objA.mcRef == objB.mcRef and objA.fnRef == objA.fnRef)
			return true;
	}
	else if(typeof(objA)=="function" and typeof(objB)=="function") {
		if(objA == objB)
			return true;
	}
	else if(typeof(objA)=="string" and typeof(objB)=="string") {
		if(objA == objB)
			return true;
	}
	else if(typeof(objA)=="string" and typeof(objB)=="function") {
		if(eval(objA) == objB)
			return true;
	}
	else if(isExecObject(objA) and typeof(objB)=="function") {
		if(objA.fnRef == objB)
			return true;
	}
	else if(isExecObject(objA) and typeof(objB)=="string") {
		if(typeof(eval(objB))=="function") {
			if(objA.mcRef == eval(objB.substr(0,objB.lastIndexOf("."))) and objA.fnRef == eval(objB))
				return true;
		}
	}
	else if(!exists(bInverse))
		return compareExecObjects(objB, objA, true);
	
	return false;
}

Object.prototype.resolveFunctionCall = function (objCallBack) 
{
	var _fnRef,_mcRef;
	if((objCallBack instanceof Object) and !(objCallBack instanceof Array))
	{
		if(objCallBack.fnRef instanceof Function) {
			_fnRef=objCallBack.fnRef;
		}
		else if(eval(objCallBack.fnRef) instanceof Function) {
				_fnRef=eval(objCallBack.fnRef);
		}
		else if (objCallBack instanceof Function)
		{
			_fnRef = objCallBack;
		}
		else _fnRef=undefined;
			
		if((objCallBack.mcRef instanceof MovieClip) or (objCallBack.mcRef instanceof Object)) {
				_mcRef=objCallBack.mcRef;
		}
		else if((eval(objCallBack.mcRef) instanceof MovieClip) or (eval(objCallBack.mcRef) instanceof Object)) {
				_mcRef=eval(objCallBack.mcRef);
		}
		else _mcRef=this;
	}
	else if (eval(objCallBack) instanceof Function)
	{
		_fnRef = eval(objCallBack);
		_mcRef=this;
	}

	return {fnRef:_fnRef, mcRef:_mcRef}
}

Object.prototype.rxExecuteCallBack = function (objCallBack) 
{
	arguments.splice(0,1);

	if((objCallBack instanceof Object) and !(objCallBack instanceof Array))
	{
		var funcobj = this.resolveFunctionCall(objCallBack);
			
		if(exists(funcobj.mcRef) and exists(funcobj.fnRef)) 
		{
			if(exists(objCallBack.argsRef))
			{
				var arrTemp = new Array();
				for(var i=0;i<arguments.length;i++) {
					arrTemp[arrTemp.length] = arguments[i];
				}
				
				for(var i=0;i<objCallBack.argsRef.length;i++) {
					arrTemp[arrTemp.length] = objCallBack.argsRef[i];
				}
				
				return funcobj.fnRef.apply(funcobj.mcRef,arrTemp);
			}
			else 
			{
				return funcobj.fnRef.apply(funcobj.mcRef,arguments);
			}
		}
		else return false;
	}
	else if((objCallBack instanceof Array) and objCallBack.length>0) 
	{
		var arrReturn = new Array();
		for(var i=0;i<objCallBack.length;i++) {
			arrReturn[i] = (arguments.callee).apply(objCallBack[i],arguments);
		}
		return arrReturn;
	}
	return false;
}

Object.prototype.setTimeout = function(func, timeout) 
{
	arguments.splice(0,2);
	var funcobj = this.resolveFunctionCall(func);
	funcobj.argsRef = arguments;

	_global.timeoutCount++;
	_global["timeout"+_global.timeoutCount] = setInterval(_doSetTimeout, timeout, _global.timeoutCount, funcobj);
	return _global["timeout"+_global.timeoutCount];
}

_global._doSetTimeout = function(timeoutID, funcobj) 
{
	clearInterval(_global["timeout"+timeoutID]);
	delete(_global["timeout"+timeoutID]);
	rxExecuteCallBack(funcobj);
}

TextField.prototype.setText = function (str) {
	
	if(this.html == true) {
		this.htmlText = str;
	}
	else {
		this.text = str;
	}
}

TextField.prototype.getTextLength = function (str) {
	if(this.html == true)
		return String(this.htmlText).length;
	else
		return String(this.text).length;
}

TextField.prototype.getRXWidth = function () {
	if(this.border == true and this.autoSize == true) {
		var fReturn = this.textWidth + 4 + 1;
	}
	else if(this.border == true) {
		var fReturn = this._width + 1;
	}
	else
		var fReturn = this._width;
		
	return fReturn;
}

TextField.prototype.getRXHeight = function () {
	
	if(!this.getTextLength()>0) {
		this.setText("Z");
		var bTL = true;
	}
	
	var fTextH = this.textHeight + 4;
	var fTextRH = this._height;
	
	if(bTL==true)
		this.setText("");
	
	return Math.max(fTextH,fTextRH);
}

MovieClip.prototype.getRXWidth = function () {
	return ((this.getWidth instanceof Function) ? this.getWidth() : this._width);
}

MovieClip.prototype.getRXHeight = function () {
	return ((this.getHeight instanceof Function) ? this.getHeight() : this._height);
}

MovieClip.prototype.extractVisibleWidth = function () {
	var iRMax = 0;
	var iRMin = 0;
	var iW = 0;
	for(each in this) {
		var mcRef = this[each];
		if(typeof(mcRef)=="movieclip" and mcRef._name == each) {
			if(mcRef._alpha>0 and mcRef._visible==true) {
				
				var iMax = Math.max(mcRef._x, (mcRef._width + mcRef._x));
				var iMin = Math.min(mcRef._x, (mcRef._width + mcRef._x));
				
				var iRMax = Math.max(iRMax, iMax);
				var iRMin = Math.min(iRMin, iMin);
				iW = Math.abs(iRMin) + Math.abs(iRMax);
			}
		}
	}
	return iW;
}

MovieClip.prototype.extractVisibleHeight = function () {
	var iRMax = 0;
	var iRMin = 0;
	var iH = 0;
	for(each in this) {
		var mcRef = this[each];
		if(typeof(mcRef)=="movieclip" and mcRef._name == each) {
			if(mcRef._alpha>0 and mcRef._visible==true) {
				
				var iMax = Math.max(mcRef._y, (mcRef._height + mcRef._y));
				var iMin = Math.min(mcRef._y, (mcRef._height + mcRef._y));
				
				var iRMax = Math.max(iRMax, iMax);
				var iRMin = Math.min(iRMin, iMin);
				iH = Math.abs(iRMin) + Math.abs(iRMax);
			}
		}
	}
	return iH;
}

Object.prototype.getFloat = function (fNum) {
	return (isNaN(parseFloat(fNum)) ? 0 : parseFloat(fNum));
}

Object.prototype.getInteger = function (iNum) {
	return int(parseInt(iNum));
}

Object.prototype.getBoolean = function (bVal) {
	return (bVal=='true' || bVal=='false' ?  eval(bVal) : bVal);
}

Object.prototype.exists = function (obj) {
		return (typeof(obj)!="undefined" and typeof(obj)!="null");
}

Object.prototype.setIfExists = function (attr, objData, fPerc) {
	if(exists(objData))
	{
		if(exists(fPerc) and this[attr]!=objData)
		{
			if(objData.substr(0,2)=="0x" or (objData==getFloat(objData) and String(attr).toLowerCase().indexOf("color")!=-1))
			{
				this[attr] = interpolateColor(this[attr], int(objData), fPerc);
			}
			else if(typeof(objData) == "number" and typeof(this[attr]) == "number") {
				this[attr] = this[attr] + ((getFloat(objData) - this[attr]) / 100) * fPerc;
			}
			else
				this[attr] = objData;
		}
		else
			this[attr] = objData;
	}
}

Object.prototype.getPath = function(path){
	
	var arr = path.split(".");
	var obj = this;
	for(var i=0;i<arr.length;i++) {
		obj = obj[arr[i]];
	}
	return obj;
}

/* Synchronizes this's parameters to the one passed */
Object.prototype.sync = function (obj, fPerc) {
	if(!exists(obj)) return;
//	if(_global.arrarat2) _dfs("there")
	if(typeof(obj)=="object") {
		for(var each in obj) {
			if(typeof(obj[each])=="object") {
				if(typeof(this[each])!="object") {
					this[each] = obj[each].getInstance();
				}
				this[each].sync(obj[each], fPerc);
			}
			else {
				this.setIfExists(each,obj[each], fPerc);
			}
		}
	}
	else if(typeof(obj)=="string")
	{
		var arr = obj.split("||");
		trace(arr.length);
		for(var i=0;i<arr.length;i++)
		{
			trace(arr[i]);
			var arr2 = String(arr[i]).split("=");
			var strPath = arr2[0];
			var objValue = arr2[1];
			var arr3 = strPath.split(".");
			var obj = this;
			for(var iI=0;iI<arr3.length-1;iI++)
			{
				if(typeof(obj[arr3[iI]])=="object") {
					obj = obj[arr3[iI]];
				}
				else {
					obj[arr3[iI]] = new Object();
					obj = obj[arr3[iI]];
				}
			}

			if(exists(fPerc) and exists(obj[arr3[arr3.length-1]])) {

				if(objValue.substr(0,2)=="0x" or (objValue==getFloat(objValue) and String(arr3[arr3.length-1]).toLowerCase().indexOf("color")))
				{
					obj[arr3[arr3.length-1]] = interpolateColor(int(obj[arr3[arr3.length-1]]), int(objValue), fPerc);
				}
				else if(objValue==getFloat(objValue))
				{
					var objVal = obj[arr3[arr3.length-1]];
					
					if(fPerc!=100) {
						obj[arr3[arr3.length-1]] = objVal + ((objValue - objVal) / 100) * fPerc;
					}
					else {
						obj[arr3[arr3.length-1]] = objValue;
					}
				}
			}
			else {
				obj[arr3[arr3.length-1]] = objValue;
			}
		}
	}
	
}

//_global.arrarat
Object.prototype.getInstance = function () {
	return {};
}

/* Makes a copy of an object */
Object.prototype.copy = function () {
	var objTemp = this.getInstance();
	for(var each in this) {
		if(typeof(this[each])=="object") {
			objTemp[each] = this[each].copy();
		}
		else
			objTemp[each] = this[each];
	}
	return objTemp;
}

Array.prototype.push = function(e) {
	this[this.length] = e;
}

Array.prototype.copy = function() {
	return this.slice();
}

Array.prototype.indexOf = function (searchElement, startIndex:Number):Number {
	// Works just like String.indexOf . 
	// Returns the index of the first occurance of 'searchElement' after the 'startIndex'.
	// If none are found, returns '-1'.
	if (startIndex == undefined) {
		var startIndex:Number = 0;
	}
	for (var index:Number = startIndex; index < this.length; index++) {
		if (this[index] == searchElement){
			return(index);
		}
	}
	return(-1);
}


/* CREATES AN OBJECT IF IT DOESNT EXIST, OTHERWISE RETURNS ITS REFERENCE */
Object.prototype.rxCreateIfNot = function (strName, strType, bHide) 
{
    switch(strType) {
    case "array":
    if(!(this[strName] instanceof Array)) {
        this[strName]=new Array();
    } /* end if */
    break;
    case "object":
    if(!(this[strName] instanceof Object)) {
        this[strName]=new Object();
    } /* end if */
    break;
    } /* end switch */

    if(bHide) ASSetPropFlags(this,strName,1);
    return this[strName];
}

TextField.prototype.rxTrimEnd = function () {
        if(this.textWidth<=this._width) {
                return false;
        } /* end if */
        strTxt=this.text;
        for(var i=strTxt.length;i>=0;i--) {
                this.text=strTxt.substr(0,i) add "...";
                if(this.textWidth<=this._width) {
                        this.text=strTxt.substr(0,i-1) add "...";
                        return this.text;
                } /* end if */
        } /* end for i */
} /* end rxTrimEnd function */

String.prototype.trim = function()
{
   var j, strlen, k;
   //   -----------
   //   From Begin
   //   -----------
   strlen = this.length;
   j = 0;
   while (this.charAt(j) == " ")
   {
	  j++
   }
   if(j)
   {
	  this = substring(this,j+1, strlen)
	  if(j == strlen) return this;
   }
   //   -------------
   //   From the end
   //   -------------
   var k = this.length - 1;
   while(this.charAt(k) == " ")
   {
	  k--
   }
   this = substring(this,1,k+1)
   return this;
}

String.prototype.multiply = function (iTimes) {
	var str = this;
	for(var i=0;i<(iTimes-1);i++) {
		this = this add str;
	}
	return this;
}

openModal = function (mcRef, bkmode, bkgdAlpha)
{
//openModal has to be in zeus so that swapdepth will work correctly.
//bkmode="block" - blocks all mouse events
//bkmode="close" - a click will close modal
	
	if (this.modalDepth>0)
		return;

	if (typeof(bkgdAlpha)=="undefined")
		bkgdAlpha=30;
	var disable = this.createEmptyMovieClip("modalDisableWindow", this.getNextDepth()+100);
	
	var objStyle = new _global.styleRectangle();
	objStyle.width = gCS.embedWidth;
	objStyle.height = gCS.embedHeight;
	objStyle.height = gCS.embedHeight;
	objStyle.fillColor = 0x00FFFFFF;
	objStyle.fillAlpha = bkgdAlpha;
	
	disable.drawFilledRectangle(objStyle);
	
	disable.onRelease = disable.onRollOver = disable.onRollOut = function() {return true;}
	if (bkmode=="block")
		disable.onPress = function() { return true; }
	else
		disable.onPress = function() { EventManager.sendEvent("eCloseModal", "mcref", mcRef); closeModal(); }
	disable.useHandCursor=false;
	
	this.modalDepth=mcRef.getDepth();
	disable.mcRef=mcRef;
	mcRef.swapDepths(disable.getDepth()+1);
}

closeModal = function ()
{
//closeModal has to be in zeus so that swapdepth will work correctly.
	if (this.modalDepth==0)
		return;
	
	var disable = this.modalDisableWindow;
	
	disable.mcRef.swapDepths(this.modalDepth);
	this.modalDepth=0;

	disable.removeMovieClip();
}

