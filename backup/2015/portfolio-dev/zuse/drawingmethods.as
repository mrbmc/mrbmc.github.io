MovieClip.prototype.drawFilledRectangle = function (x, y, width, height, round, lineWidth,fillColor,lineColor,lineAlpha,fillAlpha, bevel, inset) {
	if(!exists(x)) return;
	if(x instanceof Object)
	{
		var y = x.y;
		var width = x.width;
		var height = x.height;
		var round = x.round;
		var lineWidth = x.lineWidth;
		var fillColor = x.fillColor;
		var lineColor = x.lineColor;
		var lineAlpha = x.lineAlpha;
		var fillAlpha = x.fillAlpha;
		var bevel = x.bevel;
		var inset = x.inset;
		var x = x.x;
	}

	

	if(lineWidth<=0) var lineWidth=undefined;


	if(getBoolean(inset))

	{

		width -= lineWidth;
		height -= lineWidth;

	}
	
	this.lineStyle(lineWidth, lineColor, lineAlpha);

	this.beginFill(fillColor,fillAlpha);

	this.drawRectangle(width, height, round, x, y);

	this.endFill();



	if(getBoolean(bevel))

	{

		this.lineStyle(1, "0xDDDDDD", 100);

		this.beginFill("0x000000", 0);

		this.drawRectangle(width, height, round, x, y);

		this.endFill();

	}



} //drawFilledRectangle



// Include the custom Math library from Chapter 5 to access Math.degToRad()

MovieClip.prototype.drawRectangle = function (width, height, round, x, y) {

  // Make sure the rectangle is at least as wide and tall as the rounded corners

  if (width < (round * 2)) {

		width = round * 2;

  }

  if (height < (round * 2)) {

		height = round * 2;

  }

	
	var xr0 = x + round

	var yr0 = y + round

	var xr1 = x + width - round

	var yr1 = y + height - round

	

  this.moveTo(xr0, y);

	this.lineTo(xr1, y);

	this.drawQuarterTo(Math.PI/2*3,round,round,xr1,yr0);

	this.lineTo(x + width, yr1);

	this.drawQuarterTo(0,round,round,xr1,yr1);

	this.lineTo(xr0, y+height);
	this.drawQuarterTo(Math.PI/2,round,round,xr0,yr1);

	this.lineTo(x, yr0);

	this.drawQuarterTo(Math.PI,round,round,xr0,yr0);

}



MovieClip.prototype.drawCircle = function (radius, x, y) {

		drawEllipse(radius,radius,x,y);

}



MovieClip.prototype.drawEllipse = function (xRadius, yRadius, x, y) {

  this.moveTo(x + xRadius, y);

	drawQuarterTo(0,xRadius, yRadius, x, y);

	drawQuarterTo(Math.PI/2,xRadius, yRadius, x, y);

	drawQuarterTo(Math.PI,xRadius, yRadius, x, y);

	drawQuarterTo(Math.PI/2*3,xRadius, yRadius, x, y);  

}





MovieClip.prototype.drawQuarterTo = function (angle, xRadius, yRadius, x, y) 

{
	if (xRadius==0 && yRadius==0)

		return;

	var angleDelta = 0.785398163397448; //Pi/4

  var xCtrlDist = xRadius/0.923879532511287; //Math.cos(Math.PI / 8)

  var yCtrlDist = yRadius/0.923879532511287;

  var rx, ry, ax, ay;

  for (var i = 0; i < 2; i++) {

    angle += angleDelta;

    rx = x + Math.cos(angle-(angleDelta/2))*(xCtrlDist);

    ry = y + Math.sin(angle-(angleDelta/2))*(yCtrlDist);

    ax = x + Math.cos(angle)*xRadius;

    ay = y + Math.sin(angle)*yRadius;

    this.curveTo(rx, ry, ax, ay);

  }

}



MovieClip.prototype.drawTriangle = function (ab, ac, angle, rotation, x, y, clr, alpha) {



  // Convert the angle between the sides from degrees to radians.

  angle = rxMath.degToRad(angle);



  // Convert the rotation of the triangle from degrees to radians.

  rotation = rxMath.degToRad(rotation);



  // Calculate the coordinates of points b and c.

  var bx = Math.cos(angle - rotation) * ab;

  var by = Math.sin(angle - rotation) * ab;

  var cx = Math.cos(-rotation) * ac;

  var cy = Math.sin(-rotation) * ac;



  // Calculate the centroid's coordinates.

  var centroidX = (cx + bx)/3 - x;

  var centroidY = (cy + by)/3 - y;



  // Move to point a, then draw line ac, then line cb, and finally ba (ab).

	this.beginFill(clr,alpha);

  this.moveTo(-centroidX, -centroidY);

  this.lineTo(cx - centroidX, cy - centroidY);

  this.lineTo(bx - centroidX, by - centroidY);

  this.lineTo(-centroidX, -centroidY);

	this.endFill();

}



MovieClip.prototype.drawRegularPolygon = function (sides, length, rotation, x, y) {



  // Convert rotation from degrees to radians

  rotation = rxMath.degToRad(rotation);



  // The angle formed between the segments from the polygon's center as shown in

  // Figure 4-5. Since the total angle in the center is 360 degrees (2p radians),

  // each segment's angle is 2p divided by the number of sides.

  var angle = (2 * Math.PI) / sides;



  // Calculate the length of the radius that circumscribes the polygon (which is

  // also the distance from the center to any of the vertices).

  var radius = (length/2)/Math.sin(angle/2);



  // The starting point of the polygon is calculated using trigonometry where

  // radius is the hypotenuse and rotation is the angle.

  var px = (Math.cos(rotation) * radius) + x;

  var py = (Math.sin(rotation) * radius) + y;



  // Move to the starting point without yet drawing a line.

  this.moveTo(px, py);



  // Draw each side. Calculate the vertex coordinates using the same trigonometric

  // ratios used to calculate px and py earlier.

  for (var i = 1; i <= sides; i++) {

    px = (Math.cos((angle * i) + rotation) * radius) + x;

    py = (Math.sin((angle * i) + rotation) * radius) + y;

    this.lineTo(px, py);

  }

}



MovieClip.prototype.getNextDepth = function ()

{

	//debugFunc("getNextDepth",arguments);

	var iNewDepth=-99999999;

	for (each in this)

	{

		var testObj = this[each];

        var iObjDepth=testObj.getDepth();

		if((((typeof(testObj)=="movieclip") or (typeof(testObj)=="object")) and testObj._name==each) and typeof(iObjDepth)=="number") {

			iNewDepth = Math.max(testObj.getDepth(),iNewDepth);

		}

	}

	iNewDepth++;

	if(iNewDepth<0) iNewDepth=1;

	return iNewDepth;

}



Object.prototype.setClipColor = function (objColor)

{

	var ColorSet = new Color(this);

	ColorSet.setRGB(parseInt(objColor));

}



Object.prototype.resetClipColor = function ()

{



var my_color = new Color(this);



var myColorTransform = new Object();

myColorTransform.ra = 100;

myColorTransform.rb = 0;

myColorTransform.ga = 100;

myColorTransform.gb = 0;

myColorTransform.ba = 100;

myColorTransform.bb = 0;

myColorTransform.aa = 100;

myColorTransform.ab = 0;



my_color.setTransform(myColorTransform);



}

_global.RGB_to_HSV = function(R,G,B) {

	

	// RGB are each on [0, 1]. S and V are returned on [0, 1] and H is

	// returned on [0, 6]. Exception: H is returned UNDEFINED if S==0.
	

var v, x, f, i;

	x = Math.min(Math.min(R, G),B);

	v = Math.max(Math.max(R, G),B);

	if(v == x) return {h:6,s:0,v:v};

	f = ((R == x) ? G - B : ((G == x) ? B - R : R - G));

	i = ((R == x) ? 3 : ((G == x) ? 5 : 1));

	return {h:(i - f /(v - x)),s:((v - x)/v),v:v};

}



_global.HSV_to_RGB = function(h,s,v) {

	
	// H is given on [0, 6] or UNDEFINED. S and V are given on [0, 1].

	// RGB are each returned on [0, 1].
	

var m, n, f, i;



	if(h == undefined) return {r:v,g:v,b:v};

	i = Math.floor(h);

	f = h - i;

	if(!(i & 1)) f = 1 - f; // if i is even

	m = v * (1 - s);

	n = v * (1 - s * f);

	switch (i) {

		case 6: return {r:v,g:n,b:m};

		break;

		case 0: return {r:v,g:n,b:m};

		break;

		case 1: return {r:n,g:v,b:m};

		break;

		case 2: return {r:m,g:v,b:n};

		break;

		case 3: return {r:m,g:n,b:v};

		break;

		case 4: return {r:n,g:m,b:v};

		break;

		case 5: return {r:v,g:m,b:n};

		break;

	}

}


_global.interpolateColor = function (colorA,colorB,fPerc) {

	

	var oldVal = int(colorA);
	var newVal = int(colorB);



	var oNT = {r:((newVal>>16)&0xFF)/255, g:((newVal>>8)&0xFF)/255, b:(newVal&0xFF)/255};

	var oOT = {r:((oldVal>>16)&0xFF)/255, g:((oldVal>>8)&0xFF)/255, b:(oldVal&0xFF)/255};


	var oN_hsv = RGB_to_HSV(oNT.r,oNT.g,oNT.b);

	var oO_hsv = RGB_to_HSV(oOT.r,oOT.g,oOT.b);


	oO_hsv.sync(oN_hsv,fPerc);
	

	var oLClr = HSV_to_RGB(oO_hsv.h,oO_hsv.s,oO_hsv.v);



	return ((oLClr.r*255)<<16) | ((oLClr.g*255)<<8) | (oLClr.b*255);

}



_global.drawRect = function (obj,x,y,w,h)

{

	obj.drawRectangle(w,h,0,x,y);

}



_global.fillRect = function (obj,x,y,w,h,lineWidth,lineColor,fillColor,fillAlpha) {

	if(lineWidth>0)

		obj.lineStyle(lineWidth,lineColor,100);

	obj.beginFill(fillColor,fillAlpha);

	obj.lineWidth(lineWidth);

	obj.drawRectangle(w,h,0,x,y);

	obj.endFill(fillColor,fillAlpha);

}



_global.drawIcon = function(t,s,sx,sy){ var h,c,p,d,v,l,y,x,i,b,a,f,w;s=s.split(';');h=new LoadVars();h.decode(unescape(s[0]));if(h.x==undefined)h.x=0;if(h.y==undefined)h.y=0;if(sx!=undefined&&Number(sx)!=NaN)h.x=sx;if(sy!=undefined && Number(sy)!=NaN) h.y=sy;c = s[1].split(',');c.unshift('');p = s[2].split('<');t.clear();for(d in p){v=p[d];if(v.charAt(0)=='*') v = p[Number(v.slice(1,v.length))];if(v=='')continue;l=v.split('|');x=0+Number(h.x);y=Number(d)+Number(h.y);for(i=0;i<l.length;i++){b=l[i];if(b.length==1){if(b=='0'){x+=1;continue;}w=1;f=b}else{a = b.split(':');if(a[0]=='0'){x+=Number(a[1]);continue}if(a.length==1){f=a[0];w=1}else{f=a[0];w = a[1]}}w=Number(w);f=c[Number(f)].split('|');t.moveTo(x,y);t.beginFill(f[0],f[1]?f[1]:100);t.moveTo(x,y);t.lineTo(x+w,y);t.lineTo(x+w,y+1);t.lineTo(x,y+1);t.lineTo(x,y);t.endFill();x+=w}}};MovieClip.prototype.drawIcon=function(s,x,y){arguments.unshift(this);_global.drawIcon.apply(this,arguments)};ASSetPropFlags(MovieClip.prototype, 'drawIcon', 1)



