#!/usr/bin/perl

use strict;
use warnings;

use lib qw{../lib/};
use EMGaugeDB::Recipient;
use EMGaugeDB::Listmembers;
use EMGaugeDB::List;

use Getopt::Long;

my $listid;
my $file;

GetOptions(
	'list=i' => \$listid,
	'file=s' => \$file,
);

open my $io, "<", $file or die "$file: $!";

my $count = 0;

while (<$io>) {

	chomp;
	s/^\s+//;
	s/\s+$//;
	
	my $rcpt = EMGaugeDB::Recipient->find_or_create({
		email => $_,
	});

	EMGaugeDB::Listmembers->insert({
		list => $listid,
		recipient => $rcpt->id,
	});
	
	++$count;
	
	my $list = EMGaugeDB::List->retrieve(id => $listid);
	$list->set(
		records => $count,
		filename => $file,
		active => 1,
	);
	$list->update;
		
	print "$count\n";
}

exit;
