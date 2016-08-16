#!/usr/bin/env perl

use strict;

my (%seen, @sorted);
our (@seen_in_order, $line_count);

my $infile = $ARGV[0];
die "Invalid input file: $infile" unless (-r $infile);
open(my $in, '<', $infile) or die "Can't open $infile";
while (my $line = <$in>) {
	$line_count++;
	chomp $line;
	# skip blank lines and comments
	next unless $line =~ /\S/;
	next if $line =~ /^\s*\#/;
	my ($from, $to) = $line =~ /Redirect\s+301\s+(\S+)\s+(\S+)/;
	die "Couldn't parse: $line on line $line_count" unless $from and $to;
	if (defined $seen{$from}) {
		print STDERR "Skipping duplicate rule: $from on line $line_count\n";
		next;
	}
	check_for_obscured_from($from);
	if (defined($seen{$to}) && ($seen{$to}->[2] eq $from)) {
		print STDERR "Skipping infinite redirect from $from to $to on line $line_count due to rule on line $seen{$to}->[0]\n";
		next;
	}
	push @seen_in_order, $from;
	$seen{$from} = [$line_count, length $from, $to];
}
close $in;

@sorted = 	map { "Redirect 301 " . $_->[1] . " " . $_->[2] }
			sort { $b->[0] <=> $a->[0] }
			map { [ $seen{$_}->[1], $_, $seen{$_}->[2] ] } 
			keys %seen;
print join "\n", @sorted;

sub check_for_obscured_from() {
	my $test = shift;
	my $i = 0;
	for my $seen (@seen_in_order) {
		$i++;
		if ($test =~ /^$seen/) {
			print STDERR "Error: $test on line $line_count obscured by $seen on line $i\n";
			return 1;
		}
	}
	return 0;
}
