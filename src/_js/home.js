import { startRenderLoop } from "./modules/molf-boids.mjs";

window.addEventListener('load', function(e) {
    "use strict";
	// if(!MOBILE) 
		startRenderLoop();
},false);
