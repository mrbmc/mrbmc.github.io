/* Included in Catalog.fla:Frame 4 */
//Event Handler
	function gRegisterEvent(obj,eventName,strTarget)
	{
		debugFunc("gRegisterEvent",arguments);
		//_dfsX("gRegisterEvent: obj = " add obj add ", eventname = " add eventname add ", strTarget = " add strTarget);
		
		if (!exists(this.eRegistry[eventName]))
		{
			var currentEvent = this.eRegistry[eventName] = new Array();
		}
		else
			var currentEvent = this.eRegistry[eventName];
		//_dfs("add event " add eventname add ":" add obj add " " add strTarget)
		
		if(isExecObject(obj)) {
			currentEvent.push(obj);
		}
		else
			currentEvent.push(new Array(strTarget,obj));
		
	}
	
	function gUnregisterEvent(obj, eventName, strTarget)
	{
		debugFunc("gRegisterEvent",arguments);
		//_dfsX("gRegisterEvent: obj = " add obj add ", eventname = " add eventname add ", strTarget = " add strTarget);		
		if (exists(this.eRegistry[eventName]))
		{
			var currentEvent = this.eRegistry[eventName];
		}
		else
			return;
					for(var i=0;i<currentEvent.length;i++)
		{			var bIsSame = false;			if(isExecObject(currentEvent[i]))
			{
				if(isExecObject(obj)) {
					bIsSame = compareExecObjects(currentEvent[i], obj);
				}
				else
					bIsSame = compareExecObjects(isExecObject(obj),eval(strTarget) add "." add obj);
			}			else
			{
				if(isExecObject(obj)) {
					var strMcString = (eval(currentEvent[i][0]) instanceof MovieClip) ? eval(currentEvent[i][0]) : currentEvent[i][0];
					bIsSame = compareExecObjects(strMcString add "." add currentEvent[i][1], obj);
				}
				else {					var strMcString = (eval(currentEvent[i][0]) instanceof MovieClip) ? eval(currentEvent[i][0]) : currentEvent[i][0];					var strMc2String = (eval(strTarget) instanceof MovieClip) ? eval(strTarget) : strTarget;					var str1 = strMcString add "." add currentEvent[i][1];					var str2 = strMc2String add "." add obj;
					bIsSame = compareExecObjects(str1, str2);				}
			}
						if(bIsSame) {
				currentEvent.splice(i,1);
				EventManager.unregisterEvent(obj, eventName, strTarget);
				return true;
			}						delete(bIsSame);
		}
	}

	function gAddNewEvent(eventName)
	{
			debugFunc("gAddNewEvent",arguments);
			
	}

	function gcallEventHandler(currentEvent,args)
	{
		debugFunc("gcallEventHandler",arguments);
		for (var i=0;i<currentEvent.length;i++)
		{
			//get the current handler function pointer.
			if(isExecObject(currentEvent[i])) {
				if (rxExecuteCallBack(currentEvent[i])==false)
					return false;
			}
			else if(exists(currentEvent[i][0]) and exists(currentEvent[i][1])) {
				
				if(currentEvent[i][0][currentEvent[i][1]] instanceof Function)
					var refToFunc = currentEvent[i][0][currentEvent[i][1]];
				else {
					var pathToFunc = currentEvent[i][0] add "." add currentEvent[i][1];
					var refToFunc = eval(pathToFunc);
				}
				
				args["target"] = currentEvent[i][0];
				
				if(currentEvent[i][0] instanceof Object)
					var objThisInFunc = currentEvent[i][0];
				else
					var objThisInFunc = eval(currentEvent[i][0]);
					
				var ret = refToFunc.apply(objThisInFunc, [args]);
				
				if (typeof(ret)=="undefined") {
					var errStr=(currentHandler add " " add args["target"]);
					systemError("systemError" add " " add errStr add ": " add pathToHandler + " did not return a boolean value! ("+args["curEvent"]+")");
					return false;
				}

				if (!ret)
					return false;
				
			}
			
		} /* end for i */
		return true;
	}

	function gSendEvent(eventName)
	{
			debugFunc("gSendEvent",arguments);
			var args = new Array()
			args["curEvent"]=eventName;
			for (i=1; i<arguments.length; i+=2)
			{
					args[arguments[i]]=arguments[i+1];
			}
			
			//if either call return false then return false
			if (this.eRegistry[eventName].length > 0)
			{
				if (!this.callEventHandler(this.eRegistry[eventName],args))
					return false
			}
			if (this.eRegistry['all'].length > 0)
			{
				if (!this.callEventHandler(this.eRegistry['all'],args))
					return false
			}
			return true
	}


	function Event()
	{
			this.callEventHandler = gcallEventHandler;
			
			this.eRegistry = new Object()
			this.registerEvent=gRegisterEvent;
			this.unregisterEvent=gUnregisterEvent;
			this.sendEvent=gSendEvent;
			this.addNewEvent=gAddNewEvent;
	}

_global.EventManager = new Event();
