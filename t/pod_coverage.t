use strict;
use warnings;

my $ok;
BEGIN {
    eval "use Test::More";
    if ($@) {
	print "1..0 # skip Test::More required to test pod coverage.\n";
	exit;
    }
    eval "use Test::Pod::Coverage 1.00";
    if ($@) {
	print <<eod;
1..0 # skip Test::Pod::Coverage 1.00 or greater required.
eod
	exit;
    }
}

all_pod_coverage_ok ({coverage_class => 'Pod::Coverage::CountParents'});
