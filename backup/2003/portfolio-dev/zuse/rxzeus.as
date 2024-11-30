Object.prototype.rxCreateZeus = function (strName,iDepth) {
var mcRef=this.createEmptyMovieClip(strName,iDepth);
mcRef.arrTagHolder=new Array();
ASSetPropFlags(this[strName],"arrTagHolder",7);

mcRef.rxGetRef = function (strName) {
	if(typeof(this)!="movieclip")
		var mcThisRef=arguments.callee.prototype.rxZeusPath;
	else var mcThisRef=this;

  return mcThisRef.arrTagHolder[strName];
} /* end rxGetRef function */
mcRef.rxGetRef.prototype.rxZeusPath=mcRef;

mcRef.rxSetRef = function (strName,mcRef,bOverWrite) {
	if(typeof(this)!="movieclip")
		var mcThisRef=arguments.callee.prototype.rxZeusPath;
	else var mcThisRef=this;
		if((exists(mcThisRef.arrTagHolder[strName]) and bOverWrite) or !exists(mcThisRef.arrTagHolder[strName]))		mcThisRef.arrTagHolder[strName]=mcRef;	else
		_global.systemError("You have tried to overwrite " add strName add " in the Zeus Reference space. Read the Wiki. In " add mcRef);
} /* end rxSetRef function */
mcRef.rxSetRef.prototype.rxZeusPath=mcRef;

mcRef.rxUnSetRef = function (strName) {
	if(typeof(this)!="movieclip")
		var mcThisRef=arguments.callee.prototype.rxZeusPath;
	else var mcThisRef=this;

  delete(mcThisRef.arrTagHolder[strName]);
} /* end rxUnSetRef function */
mcRef.rxUnSetRef.prototype.rxZeusPath=mcRef;

	return mcRef;
} /* end rxCreateZeus function */
ASSetPropFlags(Object.prototype,"rxCreateZeus",7);