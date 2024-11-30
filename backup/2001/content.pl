#!/usr/bin/perl

# # # # # # # # # # # # # # # # # # # # # #
#										  #
# this content provider                   #
#										  #
# © 2001 brian mcconnell € www.kageki.com #
#										  #
# # # # # # # # # # # # # # # # # # # # # #





















# # # # # # # # # # # # # # # # # # # # # #
# this parses cgi data and cleans it up

# Get the input
my $in;
if ($ENV{'REQUEST_METHOD'} eq "GET") {
	$in = $ENV{'QUERY_STRING'};
} else {
	$in = <STDIN>;
}

#clean the input

@pairs = split(/\&/, $in);
my %stuff;
foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);

   # Un-Webify plus signs and %-encoding
   $value =~ s/\+/ /g;
   $value =~ s/%(..)/pack("c",hex($1))/ge;

   $stuff{$name} = $value;
}





# # # # # # # # # # # # # # # # # # # # # #
# FLASH module start
if ($stuff{'action'} eq "flash") {




# this is the data file
$flashDataFile = "elements/".$stuff{'src'}.".swf";


if ($stuff{'quality'} ne "low") { 
	$stuff{'quality'} = "high"; 
};



# # # # # # # # # # # # # # # # # # # # # #
# this outputs the HTML
print <<END;
Content-Type: text/html\n\n

<html>
<head>
	<title>+ kageki ++ $flash{'flash'}<\/title>

	<link rel=\"STYLESHEET\" type=\"text\/css\" href=\"\/2001\/imnotfrench.css">

<body text=330066>



<table border=0 width=406 cellspacing=0 cellpadding=0 class=key>
<tr>
	<td>


<OBJECT classid=clsid:D27CDB6E-AE6D-11cf-96B8-444553540000
codebase=http://active.macromedia.com/flash2/cabs/swflash.cab\#version=4,0,0,0
 ID=wow WIDTH=404 HEIGHT=404>

<PARAM NAME=movie VALUE=$flashDataFile>
<PARAM NAME=quality VALUE=$stuff{'quality'}> 
<PARAM NAME=bgcolor VALUE=EAEAEA>

<EMBED src=$flashDataFile quality=$stuff{'quality'} bgcolor=EAEAEA WIDTH=404 HEIGHT=404 TYPE=application/x-shockwave-flash PLUGINSPAGE=http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash>

</EMBED>
</OBJECT>


	</td>
</tr>
</table>


</body>


<\/html>

END

}

# FLASH module end
# # # # # # # # # # # # # # # # # # # # # #





if ($stuff{'action'} eq "blog") {

# # # # # # # # # # # # # # # # # # # # # #
# blog module start




# set data file source
$blogDataFile = "blogs/".$stuff{'src'}.".txt";


# open data file
open (FILE,"$blogDataFile") || die "Can't Open $blogDataFile: $!\n";
	@blogData=<FILE>;
close(FILE);


# HTML header
print <<END;
Content-Type: text/html\n\n

<html>
<head>
	<title>+ kageki + blog<\/title>
	<link rel=STYLESHEET type=text/css href=\"\/2001\/imnotfrench.css\">

<body>

<table border=0 width="98%" cellspacing=0 cellpadding=0>
<tr>
	<td class="blog">

END


# output the blog data

for ($i = 0; $i <= $#blogData; $i++) {
	print "$blogData[$i]<br>\n";
}

# HTML footer

print <<END;

	<\/td>
<\/tr>
<\/table>

<\/body>

<\/html>

END

# blog module end
# # # # # # # # # # # # # # # # # # # # # #

}







