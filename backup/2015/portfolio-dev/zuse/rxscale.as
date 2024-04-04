Object.prototype.rxGetLimitedWithAspect = function (mcRef) {
var iMcRWidth = mcRef.rxExtractWidth();var iMcRHeight = mcRef.rxExtractHeight();var iW=this._width;
var iH=this._height;

if(iMcRHeight<iMcRWidth) {
	iW=(iW/iH)*iMcRHeight;
	iH=iMcRHeight;
}
else if(iMcRWidth<iMcRHeight) {
	iH=(iH/iW)*iMcRWidth;
	iW=iMcRWidth;
}
else if(iMcRWidth==iMcRHeight) {
	iH=(iH/iW)*iMcRWidth;
	iW=iMcRWidth;
}

/* pass 2 */
if(iW>iMcRWidth) {
	iH=(iH/iW)*iMcRWidth;
	iW=iMcRWidth;
}
else if(iH>iMcRHeight) {
	iW=(iW/iH)*iMcRHeight;
	iH=iMcRHeight;
}

return {_width:iW,_height:iH};

}
ASSetPropFlags(MovieClip.prototype,"rxGetLimitedWithAspect",1);

MovieClip.prototype.rxGetAspectRatio = function () {
	return this._width/this._height;
}
ASSetPropFlags(MovieClip.prototype,"rxGetAspectRatio",1);

Object.prototype.rxExtractWidth = function () {
	if(typeof(this._width)=="number") {
		return this._width;
	}
	else if(typeof(this.width)=="number") {
		return this.width;
	}
	else if(typeof(this.w)=="number") {
		return this.w;
	}

	return false;
}
ASSetPropFlags(Object.prototype,"rxExtractWidth",1);

Object.prototype.rxExtractHeight = function () {
	if(typeof(this._height)=="number") {
		return this._height;
	}
	else if(typeof(this.height)=="number") {
		return this.height;
	}
	else if(typeof(this.h)=="number") {
		return this.h;
	}

	return false;
}
ASSetPropFlags(Object.prototype,"rxExtractHeight",1);

Object.prototype.rxGetCenteredOffset = function (mcRef) {
	var iW=mcRef.rxExtractWidth();
	var iH=mcRef.rxExtractHeight();

	return {_x:((iW-this._width)/2),_y:((iH-this._height)/2)};
}
ASSetPropFlags(Object.prototype,"rxGetCenteredOffset",1);