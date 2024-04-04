rxLoadManager.createGroup("ZeusInit");

settingsXML = new XML();
settingsXML.ignoreWhite=true
if(_root.settingsURI.length>0)
	settingsXML.rxLoadXML(gCS.sUrl add _root.settingsURI,{},{},{strGroup:"ZeusInit"})

AppXML = new XML();
AppXML.ignoreWhite=true
var appFileName = (_root.appFileName.length>0 ? _root.appFileName : "Application.xmt");
AppXML.rxLoadXML(gCS.sUrl add appFileName,{},{},{strGroup:"ZeusInit"})

this.initZeus = function ()
{
	//Callback after xmls have loaded
	debugFunc('initZeus', arguments, "boot");
	readXMLParams(this,"zeus");
	ExtensionManager.loadExtensions();
}


this.InitStyles = function ()
{
	debugFunc('InitStyles', arguments, "boot");
	ExtensionManager.readExtensionSettings();
	EventManager.sendEvent("eInitStyles");
	ExtensionManager.WaitForReady({fnRef:this.configureApplication, mcRef:this});
	return true;
}

this.configureApplication = function ()
{
	debugFunc('configureApplication', arguments, "boot");
	EventManager.sendEvent("eConfigureApplication");
	ExtensionManager.WaitForReady({fnRef:this.InitApplication, mcRef:this});
	return true;
}

this.InitApplication = function ()
{
	debugFunc('InitApplication', arguments, "boot");
	EventManager.sendEvent("eInitApplication");
	ExtensionManager.WaitForReady({fnRef:this.ApplicationInitialized, mcRef:this});
	return true;
}

this.ApplicationInitialized = function ()
{
	debugFunc('ApplicationInitialized', arguments, "boot");
	EventManager.sendEvent("eApplicationInitialized");
}

EventManager.registerEvent("InitStyles","eExtensionsReady",_target)

rxLoadManager.rxSetGroupEvents("ZeusInit",{fnRef:this.initZeus,mcRef:this});
