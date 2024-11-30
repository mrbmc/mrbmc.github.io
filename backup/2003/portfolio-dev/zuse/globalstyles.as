_global.styleRectangle = function (obj) {
	this._rxtype = "rectangle";
	this.x = 0;
	this.y = 0;
	this.width = null;
	this.height = null;
	this.round = 0;
	this.lineWidth = 0;
	this.fillColor = 0xFFFFFF;
	this.lineColor = 0x000000;
	this.lineAlpha = 100;
	this.fillAlpha = 100;
	this.bevel = 0;
	this.inset = true;

	this.sync(obj);
}
_global.styleRectangle.prototype = new Object();

_global.styleText = function (obj) {
	this._rxtype = "text";
	this.html = false;
	this.multiline = false;
	this.embedFonts = true;
	this.selectable = false;

	/* text format properties */
	//this.align = "left";
	this.bold = true;
	this.font = "Arial Narrow";
	this.color = 0x000000;

	this._x = null;
	this._y = null;

	this.sync(obj);
}
_global.styleText.prototype = new Object();

Object.prototype.extractTextFormat = function () {

	var tempTextForm = ["align","blockIndent","bold","bullet","color","font","indent","italic","leading","leftMargin","rightMargin","size","tabStops","target","underline","url"];
	var objTextFormat = new TextFormat();

	var iChange=0;
	for(var i=0;i<tempTextForm.length;i++) {

		var each = tempTextForm[i];
		if(exists(this[each]))
		{
			iChange++;
			objTextFormat[each] = (this[each]=='true' || this[each]=='false' ? eval(this[each]) : this[each]);
		}
	}

	return {iChanged:iChange,objTextFormat:objTextFormat};
}

Object.prototype.extractTextFieldFormat = function () {

	var tempTxtF = ["_alpha","autoSize","background","backgroundColor","border","borderColor","bottomScroll","embedFonts","_height","hscroll","html","htmlText","length","maxChars","maxhscroll","maxscroll","menu","mouseWheelEnabled","multiline","_name","_parent","password","restrict","_rotation","scroll","selectable","tabEnabled","tabIndex","text","textColor","textHeight","textWidth","type","_url","variable","_visible","_width","wordWrap","_x","_xmouse","_xscale","_y"]

	var objExtractTFParams = {};

	for(var i=0;i<tempTxtF.length;i++)
	{
		
		var each = tempTxtF[i];
		if(exists(this[each]))
		{
			objExtractTFParams[each] = (each!='text' && this[each]=='true' || this[each]=='false' ? eval(this[each]) : this[each]);
		}
		
	}

	return objExtractTFParams;
}

TextField.prototype.rxSetStyle = function (objStyle) {

	var objExtractTFVars = objStyle.extractTextFieldFormat();

	var objExtractRes = objStyle.extractTextFormat();
	this.sync(objExtractTFVars);		if(exists(objExtractTFVars.text))
		this.htmlText = objExtractTFVars.text;		if(exists(objExtractTFVars.htmlText))		this.htmlText = objExtractTFVars.htmlText;
	
	if(objExtractRes.iChanged) {
		this.setTextFormat(objExtractRes.objTextFormat);
		this.setNewTextFormat(objExtractRes.objTextFormat);
	}

	if(exists(objStyle._x)) {
		this._x = objStyle._x;
	}

	if(exists(objStyle._y)) {
		this._y = objStyle._y;
	}

}
