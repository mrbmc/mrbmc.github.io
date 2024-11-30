#!/usr/bin/perl

# # # # # # # # # # # # # # # # # # # # # # #
#										    #
# this is the real time flash poll script   #
#										    #
# © 2000 brian mcconnell € www.kageki.com   #
#										    #
# # # # # # # # # # # # # # # # # # # # # # #























# # # # # # # # # # # # # # # # # # # # # #
# this is the data file
$pollDataFile = "poll.txt";




# # # # # # # # # # # # # # # # # # # # # #
# this parses out the new vote info and cleans it up

# Get the input
my $in;
if ($ENV{'REQUEST_METHOD'} eq "GET") {
	$in = $ENV{'QUERY_STRING'};
} else {
	$in = <STDIN>;
}

#clean the input

@pairs = split(/&/, $in);

foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);

   # Un-Webify plus signs and %-encoding
   $value =~ s/\+/ /g;
   $value =~ s/%(..)/pack("c",hex($1))/ge;

   $poll{$name} = $value;
}


# # # # # # # # # # # # # # # # # # # # # #
# this loads the old Poll data

open (FILE,"$pollDataFile") || die "Can't Open $pollDataFile: $!\n";
	@pollData=<FILE>;

	#this converts the old Poll data to integers and gets rid of the line breaks
	$pollData[0]++;
	$pollData[1]++;
	$pollData[2]++;
	$pollData[3]++;
	$pollData[0]--;
	$pollData[1]--;
	$pollData[2]--;
	$pollData[3]--;

close(FILE);

# # # # # # # # # # # # # # # # # # # # # #
# this processes the old Poll data with the new vote

	if ($poll{'vote'} eq "A") {
		$pollData[0]++;
	}
	if ($poll{'vote'} eq "B") {
		$pollData[1]++;
	}
	if ($poll{'vote'} eq "C") {
		$pollData[2]++;
	}
	if ($poll{'vote'} eq "D") {
		$pollData[3]++;
	}

# # # # # # # # # # # # # # # # # # # # # #
# this writes the Poll info to the data file

open (FILE,">$pollDataFile");
	print FILE "$pollData[0]\n$pollData[1]\n$pollData[2]\n$pollData[3]";
close(FILE);



# # # # # # # # # # # # # # # # # # # # # #
# this outputs the new poll data to flash
#

print <<END;
Content-Type: text/html\n\n

&a=$pollData[0]&b=$pollData[1]&c=$pollData[2]&d=$pollData[3]&loaded=yeah&

END


