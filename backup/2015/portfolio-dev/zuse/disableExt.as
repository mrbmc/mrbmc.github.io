var disableExt = ExtensionManager.declareExtension("disableBlocker");
disableExt._visible=false
disableExt._x=disableExt._y=0;
disableExt.onPress = function() {}
disableExt.useHandCursor = false;
fillRect(disableExt,0,0,2000,1600,0,0x000000,0xFFFFFF,0);
disableExt.origDepth=disableExt.getDepth();
disableExt.counter=0;

disableExt.disableGUI = function()
{
	this.counter++;
	this.swapDepths(1009970);
	this._visible=true;
}

disableExt.enableGUI = function()
{
	this.counter--;
	if (this.counter==0)
	{
		this.swapDepths(this.origDepth);
		this._visible=false;
	}
}

ExtensionManager.setExtensionState("disableBlocker","Ready");

_global.disableGUI = function() {
	var disBlocker = ExtensionManager.getExtensionRef("disableBlocker");
	disBlocker.disableGUI(disBlocker, arguments);
}
_global.enableGUI = function() {
	var disBlocker = ExtensionManager.getExtensionRef("disableBlocker");
	disBlocker.enableGUI.apply(disBlocker, arguments);
}


