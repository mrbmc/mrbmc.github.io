	function doStage(a,b,c) {



	 BROWSER_NAME = navigator.appName;
	 if (BROWSER_NAME == "Netscape") {PLAT = "NN";}
	 if (BROWSER_NAME == "Microsoft Internet Explorer") {PLAT = "IE";}

	if (navigator.appVersion.charAt(0) < 4) {
			var theUrl = "content.pl?action=" + a + "&src=" + b + "&" + c;
			Version3fitWindow = window.open(theUrl,"fit;","width=412,height=412,scrollbars=no,menubar=no,status=no,toolbar=no");
	}
	// this is the netscape switcher
	if (PLAT == "NN") {
		document.stage.src = "content.pl?action=" + a + "&src=" +b + "&" + c;

	// this is the explorer switcher
	} else if (PLAT == "IE") {
		top.document.frames['stage'].location = "content.pl?action=" + a + "&src=" +b + "&" + c;
		top.document.stage.focus();
	}

	}
