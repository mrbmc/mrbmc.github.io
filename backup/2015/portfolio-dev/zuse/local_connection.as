var lc = new LocalConnection();

lc.externSendEvent = function(sParams)
{
    var arrArgs=sParams.split("|@");
    EventManager.sendEvent.apply(EventManager,arrArgs);
}

lc.callFunction = function(sParams)
{
    var arrArgs=sParams.split("|@");
	var func = eval("_global."+arrArgs[0]);
	arrArgs.splice(0,1);
    func.apply(_global,arrArgs);
}

lc.setVariables = function(query) 
{
	var i, values;
	var chunk = query.split("&");
	for (i in chunk) {
		values = chunk[i].split("=");
		_root[values[0]] = values[1];
	}
}

lc.connect(gCS.connectionID);
