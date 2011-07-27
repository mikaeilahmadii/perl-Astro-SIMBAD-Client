package Astro::SIMBAD::Client::Test;

use strict;
use warnings;

use Astro::SIMBAD::Client;
use Test::More 0.52;

use base qw{ Exporter };

our @EXPORT_OK = qw{
    access
    call
    call_a
    canned
    clear
    count
    deref
    deref_curr
    dumper
    echo
    end
    find
    load_data
    load_module
    module_loaded
    test
};
our @EXPORT = @EXPORT_OK;	## no critic (ProhibitAutomaticExportation)

my $canned;	# Canned data to test against.
my $got;	# Result of method call.
my %loaded;	# Record of the results of attempting to load modules.
my $obj;	# The object to be tested.
my $ref;	# Reference to result of method call, if it is a reference.
my $skip;	# True to skip tests.

sub access () {	## no critic (ProhibitSubroutinePrototypes)
    eval {
	require LWP::UserAgent;
	1;
    } or plan skip_all => 'Can not load LWP::UserAgent';
    my $svr = Astro::SIMBAD::Client->get ('server');
    my $resp = LWP::UserAgent->new->get ("http://$svr/");
    $resp->is_success
	or plan skip_all => "@{[$resp->status_line]}";
    return;
}

sub call (@) {	## no critic (ProhibitSubroutinePrototypes)
    my ( $method, @args ) = @_;
    $obj ||= Astro::SIMBAD::Client->new();
    eval {
	$got = $obj->$method( @args );
	1;
    } or do {
	diag "$method failed: $@";
	$got = $_;
    };
    $ref = ref $got ? $got : undef;
    return;
}

sub call_a (@) {	## no critic (ProhibitSubroutinePrototypes)
    my ( $method, @args ) = @_;
    $obj ||= Astro::SIMBAD::Client->new();
    eval {
	$got = [ $obj->$method( @args ) ];
	1;
    } or do {
	diag "$method failed: $@";
	$got = $_;
    };
    $ref = ref $got ? $got : undef;
    return;
}

sub canned (@) {	## no critic (ProhibitSubroutinePrototypes)
    my ( @args ) = @_;
    my $want = $canned;
    foreach my $key (@args) {
	my $ref = ref $want;
	if ($ref eq 'ARRAY') {
	    $want = $want->[$key];
	} elsif ($ref eq 'HASH') {
	    $want = $want->{$key};
	} elsif ($ref) {
	    die "Loaded data contains unexpected $ref reference for key $key\n";
	} else {
	    die "Loaded data does not contain key @args\n";
	}
    }
    return $want;
}

sub clear (@) {	## no critic (ProhibitSubroutinePrototypes)
    $got = $ref = undef;	# clear
    $skip = undef;		# noskip
    return;
}

sub count () {	## no critic (ProhibitSubroutinePrototypes)
    if ( 'ARRAY' eq ref $got ) {
	$got = @{ $got };
    } else {
	$got = undef;
    };
    return;
}

sub deref (@) {	## no critic (ProhibitSubroutinePrototypes)
    $got = $ref;
    goto &deref_curr;
}

sub deref_curr (@) {	## no critic (ProhibitSubroutinePrototypes)
    my ( @args ) = @_;
    foreach my $key (@args) {
	my $type = ref $got;
	if ($type eq 'ARRAY') {
	    $got = $got->[$key];
	} elsif ($type eq 'HASH') {
	    $got = $got->{$key};
	} else {
	    $got = undef;
	}
    }
    return;
}

sub dumper () {	## no critic (ProhibitSubroutinePrototypes)
	require Data::Dumper;
	diag Data::Dumper::Dumper( $got );
    return;
}

sub echo (@) {	## no critic (ProhibitSubroutinePrototypes)
    my @args = @_;
    foreach ( @args ) {
	note $_;
    }
    return;
}

sub end () {	## no critic (ProhibitSubroutinePrototypes)
    done_testing;
    return;
}

sub find (@) {	## no critic (ProhibitSubroutinePrototypes)
    my ( @args ) = @_;
    my $target = pop @args;
    if (ref $got eq 'ARRAY') {
	foreach my $item ( @{ $got } ) {
	    my $test = $item;
	    foreach my $key ( @args ) {
		my $type = ref $test;
		if ($type eq 'ARRAY') {
		    $test = $test->[$key];
		} elsif ($type eq 'HASH') {
		    $test = $test->{$key};
		} else {
		    $test = undef;
		} 
	    }
	    (defined $test && $test eq $target)
	       and do {$got = $item; last;};
	}
    }
    return;
}

sub load_data ($) {	## no critic (ProhibitSubroutinePrototypes)
    my ( @args ) = @_;
    if ( @args ) {
	my $fn = $args[0];
	open (my $fh, '<', $fn) or die "Failed to open $fn: $!\n";
	local $/ = undef;
	# Perl::Critic does not like string evals, but the
	# following needs to load arbitrary data dumped with
	# Data::Dumper. I could switch to YAML, but that is
	# not a core module.
	$canned = eval scalar <$fh>;	## no critic (ProhibitStringyEval)
	$canned or die $@;
	close $fh;
    } else {
	$canned = undef;
    }
    return;
}

sub load_module (@) {	## no critic (ProhibitSubroutinePrototypes)
    my @args = @_;
    $skip = @args > 1 ? ("Can not load any of " . join (', ', @args)) :
	@args ? "Can not load @args" : '';
    foreach ( @args ) {
	if ( exists $loaded{$_} ) {
	    $loaded{$_} and do {
		$skip = '';
		last;
	    };
	} else {
	    $loaded{$_} = undef;
	    eval "require $_; 1" and do {
		$skip = '';
		$loaded{$_} = 1;
		last;
	    };
	}
    }
    return;
}

sub module_loaded (@) {		## no critic (ProhibitSubroutinePrototypes,RequireArgUnpacking)
    my ( @args ) = @_;
    $loaded{shift @args} or return;
    my $verb = shift @args;
    my $code = __PACKAGE__->can( $verb )
	or die "Unknown command $verb";
    @_ = @args;
    goto &$code;
}

sub test ($$) {		## no critic (ProhibitSubroutinePrototypes,RequireArgUnpacking)
    my ( $want, $title ) = @_;
    $got = 'undef' unless defined $got;
    foreach ($want, $got) {
	ref $_ and next;
	chomp $_;
	m/(.+?)\s+$/ and _numberp ($1 . '') and $_ = $1;
    }
    if ( $skip ) {
	SKIP: {
	    skip $skip, 1;
	}
    } elsif (ref $want eq 'Regexp') {
	@_ = ( $got, $want, $title );
	goto &like;
    } elsif (_numberp ($want) && _numberp ($got)) {
	@_ = ( $got, '==', $want, $title );
	goto &cmp_ok;
    } else {
	@_ = ( $got, $want, $title );
	goto &is;
    }
    return;
}

##################################################################

sub _numberp {
    return ($_[0] =~ m/^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/);
}

1;

__END__

=head1 NAME

Astro::SIMBAD::Client::Test - Provide test harness for Astro::SIMBAD::Client

=head1 SYNOPSIS

 use lib qw{ inc };
 use Astro::SIMBAD::Client::Test;
 
 access;	# Check access to SIMBAD web site.

 # Tests here

 end;		# All testing complete

=head1 DETAILS

This module provides some subroutines to help test the
L<Astro::SIMBAD::Client|Astro::SIMBAD::Client> package. All the
documented subroutines are prototyped, and are exported by default.

A test would typically consist of:

* A call to C<call()>, to execute a method;

* A call to C<deref()>, to select from the output structure the value to
be tested;

* A call to C<test()>, to provide the standard value and the test name,
and actually perform the test.

Since many tests use the same data, the C<load_data()> subroutine can be
called to import a data structure (stored as a
L<Data::Dumper|Data::Dumper> hash), and the C<canned()> subroutine can
be used to select the standard value from the hash.

The subroutines exported are:

=head2 access

This subroutine must be called, if at all, before the first test. It
checks access to the SIMBAD web site. If the web site is accessable, it
simply returns. If not, it calls C<plan skip_all>.

=head2 call

This subroutine calls an C<Astro::SIMBAD::Client|Astro::SIMBAD::Client>
method, instantiating the object if needed. The results of the call are
not returned, but are made available for testing.

=head2 call_a

This subroutine is similar to C<call>, but the method call is made
inside an array constructor.

=head2 canned

This subroutine returns the content of the canned data hash loaded by
the most recent call to C<load_data()>. The arguments are the hash keys
and array indices needed to navigate to the desired datum. If the
desired datum is not found, an exception is thrown.

=head2 clear

This subroutine prepares for another round of testing by clearing the
skip indicator and any results.

=head2 count

This subroutine counts the number of elements in the array reference
returned by the most recent C<call()>, and makes that available for
testing. If the most recent C<call()> did not return an array reference,
the tested value is C<undef>.

=head2 deref

This subroutine returns the selected datum from the result of the most
recent C<call()>, and makes it available for testing. The arguments are
the hash keys and array indices needed to navigate to the desired datum.
If the desired datum is not found, C<undef> is used for testing.

=head2 deref_curr

This subroutine is like C<deref()>, but the navigation is applied to the
current value to be tested.

=head2 dumper

This subroutine loads L<Data::Dumper|Data::Dumper> and dumps the current
content of the value to be tested.

=head2 echo

This subroutine simply displays its arguments. It is implemented via the
L<Test::More|Test::More> diag() method.

=head2 end

This subroutine B<must> be called after testing is complete, to let the
test harness know that testing B<is> complete.

=head2 find

This subroutine finds a given value in the structure which is available
for testing. The value to look for is the last argument; the other
argumments are navigation information, such as would be passed to
C<deref()>.

If structure available for testing is not an array reference, C<undef>
is made available for testing. Otherwise, the subroutine iterates over
the elements in the array, performing the navigation on each in turn,
and testing whether the desired value is found. If it is, the array
element in which it is found becomes the value available for testing.
Otherwise C<undef> becomes available for testing.

=head2 load_data

This subroutine takes as its argument a file containing data to be
provided via the C<canned()> subroutine. The contents of the file will
be string C<eval>-ed.

=head2 load_module

This subroutine takes as arguments a number of Perl module names. It
attempts to C<require> these in order, stopping when the first
C<require> succeeds. If none succeeds, the internal skip indicator is
set, so that subsequent tests are skipped until C<clear()> is called.

Load status is cached, so only one C<eval> is done per module.

=head2 module_loaded

This subroutine takes as its first argument the name of a module. The
second argument is the name of one of the C<Astro::SIMBAD::Client::Test>
subroutines, and subsequent arguments are arguments for the named
subroutine. If the named module has not been loaded, nothing happens. If
the named module has been loaded, the named subroutine is called (as a
co-routine), with the given arguments.

=head2 test

This subroutine performs the actual test. It takes two arguments: the
expected value, and the name of the test. The value made available by
C<call()>, C<count()>, C<deref()>, C<deref_curr()>, or C<find()> is
compared to the expected value, and the test succeeds or fails based on
the result of the comparison.

If the expected value is a C<Regexp> object, the comparison is done with
the C<Test::More> C<like()> subroutine. If it looks like a number, the
comparison is done with C<cmp_ok> for numeric equality. Otherwise, the
comparison is done with C<is>.

=head1 AUTHOR

Thomas R. Wyant, III (F<wyant at cpan dot org>)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Thomas R. Wyant, III

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.0. For more details, see the full text
of the licenses in the directory LICENSES.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# ex: set textwidth=72 :
