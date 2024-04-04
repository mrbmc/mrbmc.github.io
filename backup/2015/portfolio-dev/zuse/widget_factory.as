_global.WidgetFactory = new Object();

WidgetFactory.Widgets = new Array();WidgetFactory.REGISTRY = new Array();

WidgetFactory.registerWidget = function(widgetTypeName, widgetObject)
{
	debugFunc('WF.registerWidget', arguments);	widgetTypeName = widgetTypeName.toLowerCase();
	this.Widgets[widgetTypeName] = widgetObject;	if(!exists(this.REGISTRY[widgetTypeName]))		this.REGISTRY[widgetTypeName] = new Array();
}

WidgetFactory.getWidgetObjectReference = function(widgetTypeName)
{
	debugFunc('WF.getWidgetObjectReference', arguments);	var widgetObject = this.Widgets[widgetTypeName.toLowerCase()];
	return widgetObject;
}

WidgetFactory.createWidget = function(widgetTypeName, parent, name, x, y, w, h, style) //add any additional params
{
	debugFunc('WF.createWidget', arguments);
	widgetTypeName = widgetTypeName.toLowerCase();
	if (typeof(this.Widgets[widgetTypeName])=="object")
	{
		arguments.splice(0,1);
		var objWidget = this.Widgets[widgetTypeName].createWidget.apply(this.Widgets[widgetTypeName],arguments);
		objWidget._rxtype = widgetTypeName;		
		this.REGISTRY[widgetTypeName].push(objWidget);
		
		return objWidget;
	}

	_dfs("Attempt to create non existent widget: " + widgetTypeName);
	return {};
}
WidgetFactory.getAllReferencesFor = function(widgetTypeName) {
	widgetTypeName = widgetTypeName.toLowerCase();
	return this.REGISTRY[widgetTypeName].copy();
}
WidgetFactory.createWidgetStyle = function(widgetTypeName)
{
	debugFunc('WF.createWidgetStyle', arguments);
	widgetTypeName = widgetTypeName.toLowerCase();
	if (typeof(this.Widgets[widgetTypeName])=="object")
		return this.Widgets[widgetTypeName].createWidgetStyle.apply(this.Widgets[widgetTypeName]);

	_dfs("Attempt to create non existent widget style: " + widgetTypeName);
	return {};
}