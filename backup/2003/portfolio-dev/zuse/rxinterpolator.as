MovieClip.prototype.rxCreateInterpol = function (strName,iDepth) {
	var mcRef=this.createEmptyMovieClip(strName,iDepth);
	ZeusSet("interpol",mcRef);

	/* temp vars reserved for speed */
	mcRef.__objFrom=new Object();
	mcRef.__objTo=new Object();
	mcRef.__iTime=0;
	mcRef.__iCurrT=0;
	mcRef.__iInitT=0;
	mcRef.__iTotalT=0;
	mcRef.__iLoop=0;
	mcRef.__iLooped=0;
	mcRef.__bFlip=false;
	mcRef.__iValDiff="";
	mcRef.__iValPerc="";
	mcRef.__iTemp1="";
	mcRef.__objDate=new Date();

	mcRef.rxEFFECTHOLDER = new Object();

	mcRef.rxINTERVALPERIOD=5;
	
	ASSetPropFlags(mcRef,null,1);

	mcRef._rxARRINTERPOLHOLDER = new Array();
	
	mcRef.rxJumpStartInterval = function () {
		//_dfs("3x");
		clearInterval(this.rxINTERVALID);
		this.rxINTERVALID=setInterval(this.rxProcessInterpol_exec,this.rxINTERVALPERIOD,this);
	}
	
	mcRef.rxProcessInterpol_exec = function (objMom) {
		objMom.rxProcessInterpol();
		updateAfterEvent();
	}
	
	mcRef.rxProcessInterpol = function () {
		//_dfs(this._rxARRINTERPOLHOLDER.length+" len");
		if(this._rxARRINTERPOLHOLDER.length>0) {
			for(var i=0;i<this._rxARRINTERPOLHOLDER.length;i++) {
				var arrRefIP=this._rxARRINTERPOLHOLDER[i]._rxARRINTERPOLL;
				if(arrRefIP.length>0)
				this.rxProcessChange(arrRefIP,this._rxARRINTERPOLHOLDER[i],i);
			}
			delete(i);
		} 
		else {
			//_dfs("1x");
			clearInterval(this.rxINTERVALID);
			delete(this.rxINTERVALID);
		}
	}

	mcRef.rxExecFuncObject = function (objExec) {
		if(objExec.objArgs instanceof Array) {
			objExec.fnRef.apply(objExec.mcRef,objExec.objArgs);
		}
		else {
			objExec.fnRef.apply(objExec.mcRef);
		}
	}

	mcRef.rxProcessChange = function (arrRef,objRef,objRefID) {
				var i=0;
				//_dfs(arrRef.length+" arl");
				this.__objFrom=arrRef[i]['from']; 
				this.__objTo=arrRef[i]['to'];
				this.__iTime=arrRef[i]['time'];
				this.__iLoop=arrRef[i]['loop'];
				this.__iLooped=arrRef[i]['looped'];
				this.__bFlip=arrRef[i]['flip'];
				this.__iCurrT=this.rxGetCurrTime();
				this.__iInitT=arrRef[i]['inittime'];

				this.__iTotalT=(this.__iInitT+this.__iTime);
				if(this.__iCurrT>this.__iTotalT) {
					for(var each in this.__objFrom) {
						objRef[each]=this.__objTo[each];
						if(this.__bFlip) {
							this.__iTemp1=this.__objTo[each];
							this.__objTo[each]=this.__objFrom[each];
							this.__objFrom[each]=this.__iTemp1;
						}
					}
					delete(each);
					if(this.__iLooped<this.__iLoop or this.__iLoop=="forever") {
						arrRef[i]['inittime']=this.rxGetCurrTime();
						if(int(arrRef[i]['looped'])==0) arrRef[i]['looped']=1;
						arrRef[i]['looped']=int(arrRef[i]['looped'])+1;
					}
					else {
						
						/* execute our functions when animation is finished */
						
						this.rxExecProgress(arrRef[i]['exonprogress'], 1);
						this.rxExecProgress(arrRef[i]['exwhendone'], 1);
						
						arrRef.splice(0,1);
						if(arrRef.length==0)
						{
							this._rxARRINTERPOLHOLDER.splice(objRefID,1);
							if(this._rxARRINTERPOLHOLDER.length==0) {
								clearInterval(this.rxINTERVALID);
								delete(this.rxINTERVALID);
							}
						}
						else {
							arrRef[0]['inittime']=this.rxGetCurrTime();
						}
					}
				}
				else
				{
					this.__iValPerc=((this.__iCurrT-this.__iInitT)/this.__iTime);					
					
					for(var each in this.__objFrom) {
					this.__iValDiff=(this.__objTo[each]-this.__objFrom[each]);
					objRef[each]=this.__objFrom[each]+this.__iValDiff*this.__iValPerc;
					//_dfs(objRef add "." add each add " " add objRef._alpha);
				}
				delete(each);
				this.rxExecProgress(arrRef[i]['exonprogress'], this.__iValPerc);
					
			}
			delete(i);
		}
	

	mcRef.rxExecProgress = function (execObj, iRatio) {
		if(execObj instanceof Array)
		{
			for(var i2=0;i2<execObj.length;i2++) {
				if(isExecObject(execObj[i2])) {
					rxExecuteCallBack(execObj[i2], iRatio);
				}
			}
		}
		else if(execObj instanceof Object) {
			if(isExecObject(execObj))
				rxExecuteCallBack(execObj, iRatio);
		}
	}
	mcRef.rxGetCurrTime = function () {
		this.__objDate = new Date();
		return this.__objDate.getTime();
	}
	
	mcRef.rxIfExistsAdd = function (objRef) {
		var arrRefIPH=this._rxARRINTERPOLHOLDER;
		var bIPRExst=false;
		for(var i=0;i<arrRefIPH.length;i++) {
			if(arrRefIPH[i]==objRef) {
				bIPRExst=true;
				break;
			}
		}
		delete(i);

		if(!bIPRExst) arrRefIPH[arrRefIPH.length]=objRef;
		delete(arrRefIPH);
		delete(bIPRExst);
	}
	
	mcRef.rxAddInterpol = function (objRef,objFrom,objTo,iTime,iLoop,bFlip,objExecWhenDone, objExecOnProgress) {
		this.rxIfExistsAdd(objRef);
		objRef.rxCreateIfNot("_rxARRINTERPOLL","array",true);
		var l=objRef._rxARRINTERPOLL.length;
		objRef._rxARRINTERPOLL['objref']=objRef;
		objRef._rxARRINTERPOLL[l]=new Array();
		objRef._rxARRINTERPOLL[l]['from']=objFrom;
		objRef._rxARRINTERPOLL[l]['to']=objTo;
		objRef._rxARRINTERPOLL[l]['time']=getFloat(iTime);
		objRef._rxARRINTERPOLL[l]['loop']=iLoop;
		objRef._rxARRINTERPOLL[l]['flip']=bFlip;
		objRef._rxARRINTERPOLL[l]['inittime']=this.rxGetCurrTime();
		
		if(isExecObject(objExecWhenDone)) {
			objRef._rxARRINTERPOLL[l]['exwhendone']=objExecWhenDone;
		}
		
		if(isExecObject(objExecOnProgress)) {
			objRef._rxARRINTERPOLL[l]['exonprogress']=objExecOnProgress;
		}
		
		delete(l);
		if(typeof(this.rxINTERVALID)=="undefined") this.rxJumpStartInterval();
		
	}
	mcRef.registerEffect = function (strEffectName, fnRef) {
		var effObject = this.rxEFFECTHOLDER.rxCreateIfNot(strEffectName, "object");
		effObject.fnRef = fnRef;
	}
	
	mcRef.addEffect = function (tgt, strType, objExec, objProgress) {
		var args =  strType.split(",");
		var strEffectName = args[0];
		args.splice(0, 1, tgt, objExec, objProgress);
		this.rxEFFECTHOLDER[strEffectName].fnRef.apply(null, args);
	}

/* function that adds an interpol 
signature1: var1=object1, var2=object2, var3= howlong (miliseconds), var4 = loop (int), var5 = flip (true/false)
signature2: var1=array, var2=howlong (miliseconds), var3=loop (int), var4=flip (true/false)
*/
	delete(objInterPol);
	delete(objFrom);
	delete(objTo);
	delete(iTime);
	delete(iLoop);
	delete(bFlip);
}
ASSetPropFlags(MovieClip.prototype,"rxCreateInterpol",7);

Object.prototype.rxInterpolate = function (var1,var2,var3,var4,var5,var6,var7) {
			var objInterPol=ZeusGet("interpol");
			if(var1 instanceof Array) {
				var iTime = int(parseInt(var2));
				var iLoop = var3;
				var bFlip = var4;
				var objExec = var5;
				var objProgress = var6;
				
			}
			else if((var1 instanceof Object) and (var2 instanceof Object)) {
				var objFrom=var1;
				var objTo=var2;
				var iTime=int(parseInt(var3));
				var iLoop=var4;
				var bFlip=var5;
				var objExec=var6;
				var objProgress = var7;
				
				ASSetPropFlags(this,"_rxINTERPOLL",7);
				
				objInterPol.rxAddInterpol(this, objFrom, objTo, iTime, iLoop, bFlip, objExec, objProgress);
			}
			else
				false;
}
ASSetPropFlags(Object.prototype,"rxInterpolate",7);
