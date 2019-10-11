#!/usr/bin/perl

use MIME::Base64;
use Time::HiRes;

@files = glob("/badge/art/ansi/*.565");

$i=0;
$j=0;
%art;
$maxres=18;
# not real
$baud=9600;

print "ANSi ARTiSTS:\n\nacidjazz\ncardiac arrest\newheat (RIP)\nnapalm death\nnootropic\nvade79\n";
sleep 3;

foreach $f (@files) {
	$i++;
	if (-f $f) {
		open(F, "$f") or die "$!";
		$j=0;
		$pretty=$f;
		$pretty =~ s/\/badge\/art\/ansi\///g;	
		$pretty =~ s/\.565//g;	
		$art{$i}{filename}=$pretty;
		while (read(F, $buf, $baud)) {
			$j++;
			$art{$i}{$j}=$buf;
		}
		close F;
	}
}

while (1) {
	foreach my $i (keys %art) {
		$maxlines=keys %{$art{$i}};
		$itermax=int($maxlines - $maxres);

		$begin=1;
		$end=$maxres;
		$iter=1;

		while ($iter < $itermax) {
			open(FB, ">", "/dev/fb1") or die "$!";
			for ($line=$begin; $line<$end; $line++) {
				print FB "$art{$i}{$line}";
			}
			$begin++;
			$end++;
			$iter++;
			Time::HiRes::usleep(110000);
			close FB;
		}
		sleep 1;
	}
}
