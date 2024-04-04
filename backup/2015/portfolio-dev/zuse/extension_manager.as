rxLoadManager.createGroup("bootseq");

_global.ExtensionManager = new Object();

ExtensionManager.extensions = new Array();
ExtensionManager.iWaitInterval = new Array();

ExtensionManager.loadExtensions = function()
{
	debugFunc('loadExtensions', arguments);

	//We don't do getNextDepth() for every call to allow reordering while loading
	ExtensionDepth=eval(_target).getNextDepth();

	var Count = AppXML.firstChild.childNodes.length;
	for (i=0; i<Count; i++)
	{
		var node = AppXML.firstChild.childNodes[i];
		var name = node.attributes["name"];
		var file = node.attributes["file"];
		var type = node.attributes["type"];

		var bUse=eval("USE"+name.toUpperCase());
		if (typeof(bUse)=="undefined" || bUse!=0)
		{
			switch (type)
			{
				case "extension":
					this.setExtensionState(name, "Loading");
					break;
				case undefined:
					break;
				default:
					systemError("Undefined type '" + type + " for extension '" + name + "'");
			}
			
			ExtensionDepth+=10;
			
			var mc=_root.Zeus.createEmptyMovieClip(name,ExtensionDepth);
			mc.rxLoadMovie(gCS.sUrl add file,{},{},{strGroup:"bootseq",bWaitToInit:(type=="extension" ? true : false)});
		}
	}
	rxLoadManager.rxSetGroupEvents("bootseq",{fnRef:this.doneLoading,mcRef:this});
}

ExtensionManager.declareExtension = function(name)
{
	this.setExtensionState(name, "Loading");
	if (typeof(eval(name))=="undefined")
	{
		ExtensionDepth+=10;
		createEmptyMovieClip(name,ExtensionDepth);
	}
    if (typeof(eval(name).rxStyle)=="undefined") 
		eval(name).rxStyle=new Object();
	return eval(name);
}

ExtensionManager.getExtensionRef = function(name)
{
	return eval("_root.Zeus." + name);
}

ExtensionManager.doneLoading = function()
{
	//Callback after all extensions have been loaded
	debugFunc('doneLoading', arguments);

	for (ext in this.extensions)
	{
		if (typeof(this.extensions[ext])=="string" && this.extensions[ext]!="Ready")
			systemError("Extension " + ext + " did not register");
	}

	for (i=0;i<AppXML.firstChild.childNodes.length;i++)
	{
		var name = AppXML.firstChild.childNodes[i].attributes["name"];
		var ref=this.getExtensionRef(name);
		if (typeof(ref)=="movieclip")
		{
			for(attr in AppXML.firstChild.childNodes[i].attributes)
			{
				if (attr!="file" && attr!="type" && attr!="name")
					ref[attr]=AppXML.firstChild.childNodes[i].attributes[attr];
			}
		}
	}

	EventManager.sendEvent("eExtensionsReady");
}

ExtensionManager.registerExtension = function(ext)
{
	debugFunc('registerExtension', arguments);

	if (this.extensions[ext._name]=="Ready")
		systemError("Extension '" + ext._name + "' is registering twice");
	else
		if (this.extensions[ext._name]!="Loading")
			systemError("Non extension movie clip '" + ext._name + "' is registering");

	if (typeof(ext.getCustomizationVersion)!="function")
	{
		systemError("Extension '" + ext._name + "' did not define 'getCustomizationVersion()'");
	}

    if (typeof(ext.rxStyle)=="undefined") 
		ext.rxStyle=new Object();
	ext.rxSetInited();
	this.setExtensionState(ext._name,"Ready");
}

ExtensionManager.removeExtension = function(ext)
{
	debugFunc('removeExtension', arguments);
	this.setExtensionState(ext._name, undefined);
	ext.unloadMovie();
}

ExtensionManager.setExtensionState = function(name, state)
{
	debugFunc('setExtensionState', arguments);
	this.extensions[name]=state;
}

ExtensionManager.getExtensionState = function(name)
{
	return this.extensions[name];
}


ExtensionManager.WaitForReady = function(callBack) 
{
	debugFunc('WaitForReady', arguments);
	this.waitTimer=0;
	this.iWaitInterval.push(setInterval(this.WaitForReadyInterval,50,callBack, this, this.iWaitInterval.length));
	ExtensionManager.WaitForReadyInterval(callBack, this, this.iWaitInterval.length-1);
}

ExtensionManager.WaitForReadyInterval = function(callBack, mcRef, interval) 
{
	//debugFunc('WaitForReadyInterval', arguments);
	with (mcRef)
	{
		for (ext in extensions)
		{
			if (typeof(extensions[ext])=="string" && extensions[ext]!="Ready")
			{
				if (ExtensionManager.waitTimer++>100)
					_dfs("Extension "+ext+" is in state "+extensions[ext]);
				return;
			}
		}

		clearInterval(ExtensionManager.iWaitInterval[interval]);
		rxExecuteCallBack(callBack);
	}
}

ExtensionManager.readExtensionSettings = function() 
{
	debugFunc('readExtensionSettings', arguments);
	for (ext in this.extensions)
	{
		readXMLParams(this.getExtensionRef(ext),ext);
	}
}
