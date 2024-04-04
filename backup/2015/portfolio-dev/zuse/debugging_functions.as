/*
 * Global functions
 *
 */

//debugging function
_global._fs = function(c,v)
{
	if (_root.fs_command==1)
		fscommand(c,v);
	else
		getURL("javascript:geturl_FSCommand('" add c add "','" add v add "');")
}

_global._dfs = function(v) { _fs('debug',v); }

_global.dumpObj = function(obj, bRecurse, strAdd)
{
	if (obj.____a==1)
	{
		_dfs(strAdd + "[objref]");
		return;
	}

	if(!exists(strAdd))
	{
		strAdd="  ";
		_dfs("Dumping '"+obj._name+"'  type="+typeof(obj));
	}

	if (typeof(obj)=="object" || typeof(obj)=="movieclip" )
	{
		obj.____a=1;
	}	

	for (attr in obj)
	{
		if (typeof(obj[attr])=='string')
			_dfs(strAdd + attr + "='" +obj[attr]+"'");
		else if(bRecurse and (obj[attr] instanceof Object)) {
			
			if(obj[attr] instanceof Array) {
				_dfs(strAdd + attr + "= [");
				dumpObj(obj[attr], true, strAdd add "  ");
				var strSpace = new String(" ");
						strSpace = strSpace.multiply(attr.length);
				_dfs(strAdd + strSpace + "= ]");
			}
			else
			{
				_dfs(strAdd + attr + "= {");
				dumpObj(obj[attr], true, strAdd add "  ");
				var strSpace = new String(" ");
						strSpace = strSpace.multiply(attr.length);
				_dfs(strAdd + strSpace + "= }");
			}
			
		}
		else
		{
			if (attr!="____a")
				_dfs(strAdd + attr + "=" + obj[attr]);
		}
	}
	
	if (typeof(obj)=="object" || typeof(obj)=="movieclip")
	{
		delete obj.____a;
	}	
}

_global.dumpFunc = function(funcName,args)
{
	_dfs("func: " + funcName + "(" + args + ")");
}

_global.debugFunc = function(funcName,args,stype)
{
	if (_root.func_debug == 1 && stype != "borders")
		dumpFunc(funcName,args);
}

_global.dumpHierarchy = function(obj, sPrefix)
{
	var st="";
	st+=sPrefix+'Pos=('+obj._x+','+obj._y+')  Dim=('+obj._width+','+obj._height+')  scale=('+obj._xscale+','+obj._yscale+')  visible='+obj._visible+'   alpha='+obj._alpha+'<br>';
	for (j in obj)
	{
		switch (typeof(obj[j]))
		{
			case 'function' : break;
			case 'movieclip':
				if (obj[j]._name==j)
				{
					st+=sPrefix+j+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;['+obj[j]+']<br>';
					st+=DumpHierarchy(obj[j],sPrefix+'-------');
				}
				else
					st+=sPrefix+j+'='+obj[j]+'<br>';
				break;
			case 'string':
				st+=sPrefix+j+'="'+escape(obj[j])+'"<br>';
				break;
			default:
				if (obj[j] instanceof Array && obj[j].length>100)
				{
					st+=sPrefix+j+'=Array[length='+obj[j].length+']<br>';
				}
				else
				if (obj[j] instanceof XML)
				{
					st+=sPrefix+j+'=[ XML DATA ]<br>';
				}
				else
					st+=sPrefix+j+'='+obj[j]+'<br>';
				break;
		}
	}
	return st;
}

_global._ShowFlashHierarchy = function()
{
	_fs('DumpDebugWindow',escape("=") + dumpHierarchy(_root,""));
}

_global._ShowStateExternal = function()
{
	var buff = "";
	for (prop in gCS)
	{
		if (typeof(gCS[prop]) != "function")
		{
			if (typeof(gCS[prop]) == "string")
				buff+=prop + ":\t'" + gCS[prop] + "'\n"
			else
				buff+=prop + ":\t" + gCS[prop] + "\n"
		}
	}

	buff+=":\t\n:\t\nVersions:\t\n";
	buff+="Zeus:\t"+ZEUSVERSION+"\n"
	for (ext in ExtensionManager.extensions)
	{
		var extRef = ExtensionManager.getExtensionRef(ext);

		buff+=ext+":\t"+ExtensionManager.getExtensionState(ext)+"\t"+extRef.VERSION;
		if (typeof(extRef.getCustomizationVersion)=="function")
			buff+="\t"+extRef.getCustomizationVersion();
		buff+="\n"
	}

	_fs('ShowStateWindow',escape(escape("=" + buff)));
}

_global.systemError = function(msg)
{
	//Gives a noticable error in a browser of flash editor
	trace(msg)
	_dfs(msg);

	//escape " chars for javascript syntax
	var s = msg.split("\"");
	msg = s.join("'");
	getURL('javascript:alert("' + msg+ '");');
}
