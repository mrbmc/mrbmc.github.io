#include "ZeusVersion.txt"

/* Included in zeus.fla:Frame 1 */
System.useCodepage = false;

#include "actionscript/zeus/debugging_functions.as"
#include "actionscript/zeus/data_manager.as"
#include "actionscript/zeus/rxextends.as"
#include "actionscript/zeus/rxinterpolator.as"
#include "actionscript/zeus/rxtwinky.as"
#include "actionscript/zeus/rxscale.as"
#include "actionscript/zeus/globalstyles.as"
#include "actionscript/zeus/local_connection.as"
#include "actionscript/zeus/load_manager.as"
#include "actionscript/zeus/event_manager.as"
#include "actionscript/zeus/rxzeus.as"
#include "actionscript/zeus/math.as"
#include "actionscript/zeus/drawingmethods.as"
#include "actionscript/zeus/extension_manager.as"
#include "actionscript/zeus/widget_factory.as"
#include "actionscript/zeus/disableExt.as"

ASSetPropFlags(Object.prototype,null,1);
ASSetPropFlags(String.prototype,null,1);
ASSetPropFlags(Array.prototype,null,1);
ASSetPropFlags(XML.prototype,null,1);
ASSetPropFlags(MovieClip.prototype,null,1);
ASSetPropFlags(TextField.prototype,null,1);
ASSetPropFlags(TextFormat.prototype,null,1);

_global.Zeus=this.rxCreateZeus("rxZeusGod",100);
_global.ZeusGet=_global.Zeus.rxGetRef;
_global.ZeusSet=_global.Zeus.rxSetRef;

this.rxCreateInterpol("rxInterpol",120);

#include "actionscript/zeus/zeus_init.as"
#include "actionscript/zeus/rxeffects.as"
stop();
