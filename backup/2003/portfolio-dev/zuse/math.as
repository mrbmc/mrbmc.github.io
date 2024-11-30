_global.rxMath = new Object();

rxMath.degToRad = function(deg){
  return (Math.PI * deg) / 180;
}

rxMath.even = function (num)
{
    return num - (num%2);
}

rxMath.percent = function(num,denom)
{
	var d = (denom==null) ? 1 : denom;
	return Math.abs(Math.round(num/d*100));
}

