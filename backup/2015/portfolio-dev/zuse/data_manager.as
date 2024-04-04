_global.gCS = new Array();
gCS.sUrl = _root.base;
gCS.connectionID = _root.connectionID;
gCS.embedWidth = _root.embedWidth;
gCS.embedHeight = _root.embedHeight;


_global.readXmlParams=function(obj,node)
{
	debugFunc("readXmlParams",arguments);

	for (i=0;i<settingsXML.firstChild.childNodes.length;i++)
	{
		with(settingsXML.firstChild.childNodes[i])
		{
			if (nodeName.toLowerCase() == node.toLowerCase())
			{
				for (attrib in attributes)
				{
					var sAttr=attributes[attrib];
					set(obj + "." + attrib, sAttr);
				}
				return;
			}
		}
	}
}

