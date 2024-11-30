#!/usr/bin/perl


$date = `date +"%D"`; chop($date);


# # # # # # # # # # # # # # # # # # #
# Get the input
my $in;
if ($ENV{'REQUEST_METHOD'} eq "GET") {
	$in = $ENV{'QUERY_STRING'};
} else {
	$in = <STDIN>;
}


#clean the input

@pairs = split(/&/, $in);
my %var;
foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);

   # Un-Webify plus signs and %-encoding
   $value =~ s/\+/ /g;
   $value =~ s/%(..)/pack("c",hex($1))/ge;

   $var{$name} = $value;
}



# # # # # # # # # # # # # # # # # # # # # # #
# send the file

$sourceFile = "source/".$var{'var'}.".zip";
print "Location: $sourceFile \n\n";



# # # # # # # # # # # # # # # # # # # # # # #
# log the download

$logfile = "downloads_log";


open (FILE, "$logfile");
@stats=<FILE>;

my %monkey;
foreach $stat (@stats) {
   ($name, $value) = split(/\|/, $stat);
   # Un-Webify plus signs and %-encoding
   $value =~ s/\+/ /g;
   $value =~ s/%(..)/pack("c",hex($1))/ge;
   $value = $value+1;
   $value = $value-1;

   $monkey{$name} = $value;
}

$keyname = $var{'var'};
$monkey{$keyname} = $monkey{$keyname}+1;

close (FILE);


open (FILE, ">$logfile");
foreach $slotname (keys (%monkey)) {
	print FILE "$slotname"."|"."$monkey{$slotname}\n";
}
close (FILE);



exit;


