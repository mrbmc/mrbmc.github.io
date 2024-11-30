	function doStage(a,b) {



	 BROWSER_NAME = navigator.appName;
	 if (BROWSER_NAME == "Netscape") {PLAT = "NN";}
	 if (BROWSER_NAME == "Microsoft Internet Explorer") {PLAT = "IE";}

	if (navigator.appVersion.charAt(0) < 4) {
			var theUrl = a + ".pl?" + a + "=" +b;
			Version3fitWindow = window.open(theUrl,"fit;","width=412,height=412,scrollbars=no,menubar=no,status=no,toolbar=no");
	}
	// this is the netscape switcher
	if (PLAT == "NN") {
		document.stage.src = a + ".pl?" + a + "=" +b;

	// this is the explorer switcher
	} else if (PLAT == "IE") {
		top.document.frames['stage'].location = a + ".pl?" + a + "=" +b;
		top.document.stage.focus();
	}

	}

